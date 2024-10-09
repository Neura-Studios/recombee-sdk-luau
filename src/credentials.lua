local DataStoreService = game:GetService("DataStoreService")
local SafeRetry = require(script.Parent.Vendor.SafeRetry)
local logger = require(script.Parent.logger)

local CREDENTIALS_REFRESH_INTERVAL_SECONDS = 60

local credentials = nil
local secretsStore = DataStoreService:GetDataStore("secrets")

local function getCredentials()
	assert(credentials ~= nil, `Recombee credentials have not loaded yet`)
	return credentials
end

local function refreshCredentials()
	local fetchedCredentials, credentialsError = SafeRetry(function()
		return secretsStore:GetAsync("RECOMBEE_CREDS")
	end, {
		retries = if credentials == nil then math.huge else 2,
	})

	if fetchedCredentials == SafeRetry.Fail then
		logger.warn(`Failed to refresh Recombee credentials: {credentialsError}`)
		return
	else
		credentials = fetchedCredentials
	end
end

task.spawn(function()
	while true do
		refreshCredentials()
		wait(CREDENTIALS_REFRESH_INTERVAL_SECONDS)
	end
end)

return {
	getCredentials = getCredentials,
	areCredentialsLoaded = function()
		return credentials ~= nil
	end,
}
