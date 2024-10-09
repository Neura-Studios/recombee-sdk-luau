local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local Immutable = require(script.Parent.Parent.Vendor.Immutable)
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local RecommendItemsToItemRequestType = gt.build(gt.table({
	itemId = Types.ItemId,
	targetUserId = Types.UserId,
	count = gt.optional(gt.number({
		integer = true,
	})),
	scenario = gt.optional(gt.string()),
	cascadeCreate = gt.optional(gt.boolean()),
	returnProperties = gt.optional(gt.boolean()),
	includedProperties = gt.optional(gt.array(gt.string())),
	filter = gt.optional(gt.string()),
	booster = gt.optional(gt.string()),
	logic = gt.optional(gt.string()),
	minRelevance = gt.optional(gt.string()),
	rotationRate = gt.optional(gt.number()),
	rotationTime = gt.optional(gt.number()),
}))

return function(params: typeof(RecommendItemsToItemRequestType:type()))
	RecommendItemsToItemRequestType:assert(params)

	return sendRequest({
		name = "RecommendItemsToItem",
		method = "GET",
		path = `/recomms/items/{params.itemId}/items/`,
		params = Immutable.merge(params, {
			itemId = Immutable.Nil,
		}),
	})
end
