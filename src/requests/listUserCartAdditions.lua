local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local ListUserCartAdditionsRequestType = gt.build(gt.table({
	userId = Types.UserId,
}))

return function(body: typeof(ListUserCartAdditionsRequestType:type()))
	ListUserCartAdditionsRequestType:assert(body)

	return enqueueRequest({
		name = "ListUserCartAdditions",
		method = "GET",
		path = `/users/{body.userId}/cartadditions/`,
		params = {},
	})
end
