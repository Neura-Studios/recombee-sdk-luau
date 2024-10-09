local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local AddBookmarkRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = gt.union(Types.ItemId, Types.UserId),
	timestamp = gt.optional(Types.DateTime),
	cascadeCreate = gt.optional(gt.boolean()),
	recommId = gt.optional(Types.RecommendationId),
}))

return function(body: typeof(AddBookmarkRequestType:type()))
	AddBookmarkRequestType:assert(body)

	return enqueueRequest({
		name = "AddBookmark",
		method = "POST",
		path = "/bookmarks/",
		body = body,
	})
end
