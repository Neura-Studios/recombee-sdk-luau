local Symbol = require(script.Parent.Symbol)

--[=[
	Optional parameters for performing a retry.

	.retries? number -- The number of retries to perform on the operation.
	.backoff? number -- The time to delay between operations.
	.verbose? boolean -- Whether to report in verbose mode.
	.errorOnFail? boolean -- Whether to throw an error after all attempts have been exhausted.

	@within SafeRetry
	@interface RetryOptions
]=]
type OnFailCallback = (error: string, attempt: number) -> unknown
export type RetryOptions = {
	retries: number?,
	backoff: number?,
	verbose: boolean?,
	errorOnFail: boolean?,
	onFail: OnFailCallback?,
}

type NormalizedOptions = {
	retries: number,
	backoff: number,
	verbose: boolean,
	errorOnFail: boolean,
	onFail: OnFailCallback?,
}

local function normalizeOptions(options: RetryOptions?): NormalizedOptions
	return {
		retries = if options and options.retries then math.floor(options.retries) else 2,
		backoff = if options and options.backoff then options.backoff else 1,
		verbose = if options and options.verbose ~= nil then options.verbose else false,
		errorOnFail = if options and options.errorOnFail ~= nil then options.errorOnFail else false,
		onFail = if options then options.onFail else nil,
	}
end

--[=[
	Allows retrying with timeout. This is a callable table, see usage.

	@class SafeRetry
]=]
local SafeRetry = {}

--[=[
	Indicates failure after attempting retries.

	@within SafeRetry
	@prop Fail Symbol
]=]
SafeRetry.Fail = Symbol.create("SafeRetryFail")

--[=[
	Retries an operation with an incremental backoff without propagating errors.

	Retries a maximum of retries times after the first attempt. Stops retrying and
	returns early when successful.

	Incrementally delays retries based on the backoff.

	Optionally verbosely warns of failures.

	```lua
	local result, finalError = SafeRetry(function()
		return Http:RequestAsync({
			Url = "https://google.com/",
		})
	end, {
		retries = 2,
		backoff = 1,
		errorOnFail = false,
	})

	if result ~= SafeRetry.Fail then
		print(result.Body)
	else
		warn(`Failed to fetch web contents (final error message: {finalError})`)
	end
	```

	@within SafeRetry
	@function SafeRetry

	@error "Operation failed" -- If `errorOnFail` is provided, SafeRetry will throw an error after all attempts have been exhausted

	@param fn () -> T -- The operation to attempt
	@param options RetryOptions?
	@return T | Symbol, string?
]=]
local function safeRetry<T>(fn: () -> T, options: RetryOptions?): (T | Symbol.Symbol, string?)
	local options = normalizeOptions(options)
	assert(options.retries >= 0, "Retries must be non-negative.")
	assert(options.backoff >= 0, "Backoff must be at least 0.")

	local err: string | nil = nil
	local tries = options.retries + 1
	for attempt = 1, tries do
		-- We want to wait at the start of the loop so this doesn't take the entire
		-- backoff period to return its failure state, but we also don't want to
		-- wait on the first try.
		if attempt > 1 and options.backoff > 0 then
			task.wait(options.backoff * (attempt - 1)) -- Incremental backoff
		end

		local success: boolean, result: T | string = pcall(fn)

		if success then
			-- We know for certain this is type T. Luau doesn't currently allow the
			-- correct return type for pcall: `(true, T) | (false, string)`, and
			-- instead has the less correct return type: `(boolean, T | string)`. So
			-- we must assert we know this is a T here.
			return result :: T
		else
			err = tostring(result)
			if options.onFail then
				options.onFail(err, attempt)
			end
		end

		if options.verbose or attempt == tries then
			warn(string.format(
				"Attempt %u/%u failed: %s",
				attempt,
				tries,
				-- The same assertion happens here.
				`{result :: string}\n{debug.traceback()}`
			))
		end
	end

	local verboseMessage =
		string.format("Operation failed after %u %s", tries, if tries == 1 then "try" else "tries")
	if options.verbose then
		warn(verboseMessage)
	end
	if options.errorOnFail then
		error(`{verboseMessage}: {err}`)
	end

	return SafeRetry.Fail, err
end

return table.freeze(setmetatable(SafeRetry, {
	__call = function(_, fn, options)
		return safeRetry(fn, options)
	end,
}))
