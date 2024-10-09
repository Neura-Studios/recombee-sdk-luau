local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(ReplicatedStorage.Packages.gt)
local Types = require(script.Parent.Parent.types)

local DeleteBookmarkRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = gt.union(Types.ItemId, Types.UserId),
	timestamp = gt.optional(Types.DateTime),
}))

return function(params: typeof(DeleteBookmarkRequestType:type()))
	DeleteBookmarkRequestType:assert(params)

	return enqueueRequest({
		name = "DeleteBookmark",
		method = "DELETE",
		path = "/bookmarks/",
		params = params,
	})
end
