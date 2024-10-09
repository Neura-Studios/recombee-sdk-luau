local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local Immutable = require(script.Parent.Parent.Vendor.Immutable)
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local RecommendNextItemsRequestType = gt.build(gt.table({
	recommId = Types.RecommendationId,
	count = gt.optional(gt.number({
		integer = true,
	})),
}))

return function(params: typeof(RecommendNextItemsRequestType:type()))
	RecommendNextItemsRequestType:assert(params)

	return sendRequest({
		name = "RecommendNextItems",
		method = "GET",
		path = `/recomms/next/items/{params.recommId}`,
		params = Immutable.merge(params, {
			recommId = Immutable.Nil,
		}),
	})
end
