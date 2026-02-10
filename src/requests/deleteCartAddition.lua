local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local DeleteCartAdditionRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	timestamp = gt.optional(gt.number()),
}))

return function(body: typeof(DeleteCartAdditionRequestType:type()))
	DeleteCartAdditionRequestType:assert(body)

	return enqueueRequest({
		name = "DeleteCartAddition",
		method = "DELETE",
		path = "/cartadditions/",
		body = body,
	})
end
