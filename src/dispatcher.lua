local HttpService = game:GetService("HttpService")
local SafeRetry = require(script.Parent.Vendor.SafeRetry)
local Immutable = require(script.Parent.Vendor.Immutable)
local Types = require(script.Parent.types)
local credentials = require(script.Parent.credentials)
local Signal = require(script.Parent.Parent.Signal)
local HashLib = require(script.Parent.Parent.HashLib)
local logger = require(script.Parent.logger)

local DISPATCH_INTERVAL_SECONDS = 1
local MAXIMUM_ENQUEUED_REQUEST_EXECUTION_COUNT = 10
local BASE_URL = "https://rapi-us-west.recombee.com"
-- "name:httpcode" strings to ignore logging when encountered --
local IGNORE_ERROR_CODES = {
	["SetViewPortion:409"] = true,
}

local requestQueue: { PendingRequest } = {}
local dispatchJobsActive = 0
local shuttingDown = false

type RecombeeRequest = typeof(Types.RecombeeRequest:type())
-- Request that is currently sitting in the request queue --
type PendingRequestResponse = {
	Success: boolean,
	StatusCode: number,
	Body: any,
}
type PendingRequest = RecombeeRequest & {
	responseReceivedSignal: Signal.Signal<PendingRequestResponse>,
	executionCount: number,
}

local function stringifyDateTimes(tbl)
	for key, value in tbl do
		if typeof(value) == "DateTime" then
			tbl[key] = value:ToIsoDate()
		elseif typeof(value) == "table" then
			stringifyDateTimes(value)
		end
	end
end

-- https://docs.recombee.com/authentication --
local function sendRequest(request: RecombeeRequest)
	local recombeeCredentials = credentials.getCredentials()
	local databaseId = recombeeCredentials.DATABASE_ID

	local requestMethod = request.method
	assert(requestMethod, "request method must be supplied")
	local requestPath = `/{databaseId}` .. request.path
	local params = request.params or {} :: { [string]: any }
	local requestBody = request.body

	-- Convert any DateTime objects to ISO strings --
	if params then
		stringifyDateTimes(params)
	end
	if requestBody then
		stringifyDateTimes(requestBody)
	end

	-- Start query params with signing timestamp --
	local timestamp = DateTime.now()

	-- Append url params to path --
	local queryPrefixChar = "?"
	local function useQueryPrefixChar()
		local char = queryPrefixChar
		queryPrefixChar = "&"
		return char
	end

	for paramName, paramValue in params do
		requestPath ..= useQueryPrefixChar() .. `{paramName}={HttpService:UrlEncode(tostring(paramValue))}`
	end

	-- Append signature to query params --
	requestPath ..= useQueryPrefixChar() .. `hmac_timestamp={timestamp.UnixTimestamp}`
	requestPath ..= useQueryPrefixChar() .. `hmac_sign={HashLib.hmac(
		HashLib.sha1,
		recombeeCredentials.DATABASE_TOKEN,
		requestPath
	)}`

	local url = BASE_URL .. requestPath
	logger.info(`sending request {request.method} {url} with body:`, requestBody)
	return SafeRetry(function()
		local response = HttpService:RequestAsync({
			Url = url,
			Method = request.method,
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = if requestMethod ~= "GET" then HttpService:JSONEncode(requestBody) else nil,
		})
		response.Body = HttpService:JSONDecode(response.Body)
		return response
	end)
end

local function enqueueRequest(request: RecombeeRequest)
	assert(not shuttingDown, `Game is shutting down, cannot enqueue request to Recombee`)

	if request.params then
		stringifyDateTimes(request.params)
	end
	if request.body then
		stringifyDateTimes(request.body)
	end

	local request = request :: PendingRequest
	local responseReceivedSignal = Signal.new()
	request.responseReceivedSignal = responseReceivedSignal
	request.executionCount = 0
	table.insert(requestQueue, request)
	logger.info(`enqueued request {request.name} with body`, request.body)

	local response = responseReceivedSignal:Wait()
	responseReceivedSignal:Destroy()

	if not response.Success and not IGNORE_ERROR_CODES[`{request.name}:{response.StatusCode}`] then
		logger.warn(
			`HTTP {response.StatusCode} error for {request.name} request: {HttpService:JSONEncode(response.Body)}`
		)
	end

	return response
end

local function dispatchRequests()
	-- Only dispatch if credentials are loaded and request queue is not empty --
	if not credentials.areCredentialsLoaded() then
		logger.warn(`skipping dispatch, credentials not loaded yet`)
		return
	end

	-- Create carbon copy of requests to dispatch. Remove from pending queue and add back if request fails. --
	local requestsToDispatch = {}
	while #requestQueue > 0 do
		local request = table.remove(requestQueue, #requestQueue)
		if request then
			if request.executionCount < MAXIMUM_ENQUEUED_REQUEST_EXECUTION_COUNT then
				request.executionCount += 1
				table.insert(requestsToDispatch, request)
			else
				logger.warn(
					`request {request.name} has exceeded maximum enqueued request execution count. removing from queue.`
				)
			end
		end
	end

	if #requestsToDispatch == 0 then
		return
	end

	dispatchJobsActive += 1

	-- Used when you need to put the requests back into the queue --
	local function unflushQueue()
		for _, request in requestsToDispatch do
			table.insert(requestQueue, request)
		end
	end

	-- Send request --
	local batchPayload = {}
	for index, request in requestsToDispatch do
		local params = Immutable.merge(request.body or {}, request.params or {}) :: any
		if next(params) == nil then
			params = nil
		end

		batchPayload[index] = {
			method = request.method,
			path = request.path,
			params = params,
		}
	end
	local response, recombeeError = sendRequest({
		name = "Batch",
		method = "POST",
		path = "/batch/",
		body = {
			requests = batchPayload,
			distinctRecomms = false,
		},
		responseReceivedSignal = nil,
	})

	-- If request fails, put requests back into queue --
	if response == SafeRetry.Fail then
		logger.warn(`failed to send batch request containing {#requestsToDispatch} requests:`, recombeeError)
		unflushQueue()
		dispatchJobsActive -= 1
		return
	elseif response.StatusCode ~= 200 then
		logger.warn(`HTTP error sending batch request containing {#requestsToDispatch} requests:`, response.Body)
		unflushQueue()
		dispatchJobsActive -= 1
		return
	else
		logger.info(`batch request success, response body:`, response.Body)
	end

	-- Send all responses back to awaiting threads --
	for index, pendingRequest in requestsToDispatch do
		local response = response.Body[index] or {}
		local responseCode = response.code or -1337
		local isOk = responseCode >= 200 and responseCode <= 399
		local isResponseJson, errOrJson = pcall(function()
			if typeof(response.json) == "table" then
				return response.json
			else
				return HttpService:JSONDecode(response.json)
			end
		end)

		pendingRequest.responseReceivedSignal:Fire({
			Success = isOk,
			StatusCode = responseCode,
			Body = if isOk and isResponseJson then errOrJson else response,
		})
	end

	dispatchJobsActive -= 1
end

task.spawn(function()
	while true do
		wait(DISPATCH_INTERVAL_SECONDS)
		local success, err = pcall(function()
			dispatchRequests()
		end)
		if not success and err then
			logger.warn(`error while dispatching requests: {err}`)
		end
	end
end)

game:BindToClose(function()
	shuttingDown = true

	while true do
		dispatchRequests()

		if (dispatchJobsActive == 0 and #requestQueue == 0) or not credentials.areCredentialsLoaded() then
			break
		else
			wait(1)
		end
	end
end)

return {
	enqueueRequest = enqueueRequest,
	sendRequest = sendRequest,
}
