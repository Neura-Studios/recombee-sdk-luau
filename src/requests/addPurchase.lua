local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local AddPurchaseRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	timestamp = gt.optional(Types.DateTime),
	cascadeCreate = gt.optional(gt.boolean()),
	amount = gt.optional(gt.number()),
	price = gt.optional(gt.number()),
	profit = gt.optional(gt.number()),
	recommId = gt.optional(Types.RecommendationId),
}))

return function(body: typeof(AddPurchaseRequestType:type()))
	AddPurchaseRequestType:assert(body)

	return enqueueRequest({
		name = "AddPurchase",
		method = "POST",
		path = "/purchases/",
		body = body,
	})
end
