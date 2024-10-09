local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local gt = require(ReplicatedStorage.Packages.gt)
local Types = require(script.Parent.Parent.types)

local SearchItemsRequestType = gt.build(gt.table({
	userId = Types.UserId,
	searchQuery = gt.string(),
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
}))

return function(params: typeof(SearchItemsRequestType:type()))
	SearchItemsRequestType:assert(params)

	return sendRequest({
		name = "SearchItems",
		method = "GET",
		path = `/search/users/{params.userId}/items/`,
		params = params,
	})
end
