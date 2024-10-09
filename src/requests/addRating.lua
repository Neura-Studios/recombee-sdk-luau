local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local AddRatingRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	rating = gt.number({
		integer = true,
	}),
	timestamp = gt.optional(Types.DateTime),
	cascadeCreate = gt.optional(gt.boolean()),
	recommId = gt.optional(Types.RecommendationId),
}))

return function(body: typeof(AddRatingRequestType:type()))
	AddRatingRequestType:assert(body)

	return enqueueRequest({
		name = "AddRating",
		method = "POST",
		path = "/ratings/",
		body = body,
	})
end
