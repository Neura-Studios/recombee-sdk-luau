local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(ReplicatedStorage.Packages.gt)
local Types = require(script.Parent.Parent.types)

local DeleteRatingRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	timestamp = gt.optional(Types.DateTime),
}))

return function(params: typeof(DeleteRatingRequestType:type()))
	DeleteRatingRequestType:assert(params)

	return enqueueRequest({
		name = "DeleteRating",
		method = "DELETE",
		path = "/ratings/",
		params = params,
	})
end
