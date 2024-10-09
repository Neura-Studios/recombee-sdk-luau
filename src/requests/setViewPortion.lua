local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(ReplicatedStorage.Packages.gt)
local Types = require(script.Parent.Parent.types)

local SetViewPortionRequestType = gt.build(gt.table({
	userId = Types.UserId,
	itemId = Types.ItemId,
	portion = gt.number({
		range = {
			min = 0,
			max = 1,
		},
	}),
	timestamp = gt.optional(Types.DateTime),
	sessionId = gt.optional(Types.UUID),
	cascadeCreate = gt.optional(gt.boolean()),
	recommId = gt.optional(Types.RecommendationId),
}))

return function(body: typeof(SetViewPortionRequestType:type()))
	SetViewPortionRequestType:assert(body)

	return enqueueRequest({
		name = "SetViewPortion",
		method = "POST",
		path = "/viewportions/",
		body = body,
	})
end
