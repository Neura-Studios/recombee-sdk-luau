local function log(logFn)
	return function(...)
		if logFn == print and not script.Parent:GetAttribute("DebugEnabled") then
			return
		end

		logFn(`[Recombee]:`, ...)
	end
end

return {
	info = log(print),
	warn = log(warn),
	error = log(error),
}
