local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local Immutable = require(script.Parent.Parent.Vendor.Immutable)
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local RecommendItemsToUserRequestType = gt.build(gt.table({
	userId = Types.UserId,
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

return function(params: typeof(RecommendItemsToUserRequestType:type()))
	RecommendItemsToUserRequestType:assert(params)

	return sendRequest({
		name = "RecommendItemsToUser",
		method = "GET",
		path = `/recomms/users/{params.userId}/items/`,
		params = Immutable.merge(params, {
			userId = Immutable.Nil,
		}),
	})
end
