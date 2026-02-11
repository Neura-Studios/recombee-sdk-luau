local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local AddCartAdditionRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	timestamp = gt.optional(Types.DateTime),
	cascadeCreate = gt.optional(gt.boolean()),
	amount = gt.optional(gt.number()),
	price = gt.optional(gt.number()),
	recommId = gt.optional(Types.RecommendationId),
	additionalData = gt.optional(gt.dictionary(gt.string(), gt.any())),
}))

return function(body: typeof(AddCartAdditionRequestType:type()))
	AddCartAdditionRequestType:assert(body)

	return enqueueRequest({
		name = "AddCartAddition",
		method = "POST",
		path = "/cartadditions/",
		body = body,
	})
end
