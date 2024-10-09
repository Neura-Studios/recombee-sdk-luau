local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest

return function()
	return sendRequest({
		name = "ListUsers",
		method = "GET",
		path = "/users/list/",
	})
end
