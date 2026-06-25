local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local AddDetailViewRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	timestamp = gt.optional(Types.DateTime),
	cascadeCreate = gt.optional(gt.boolean()),
	duration = gt.optional(gt.number()),
	recommId = gt.optional(Types.RecommendationId),
	additionalData = gt.optional(gt.dictionary(gt.string(), gt.any())),
}))

return function(body: typeof(AddDetailViewRequestType:type()))
	AddDetailViewRequestType:assert(body)

	return enqueueRequest({
		name = "AddDetailView",
		method = "POST",
		path = "/detailviews/",
		body = body,
	})
end
