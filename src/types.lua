local gt = require(script.Parent.Parent.gt)

local DateTime = gt.build(gt.isTypeof("DateTime"))
local StringKeyMap = gt.build(gt.dictionary(gt.string(), gt.any()))
local UUID =
	gt.build(gt.string({ pattern = "^[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+%-[a-f0-9]+$" }))

local RecombeeRequest = gt.build(gt.table({
	name = gt.string(),
	method = gt.string(),
	path = gt.string(),
	params = gt.optional(gt.dictionary(gt.string(), gt.any())),
	body = gt.optional(gt.dictionary(gt.string(), gt.any())),
}))

local ItemId = UUID
local UserId = gt.build(gt.string({
	pattern = "^[0-9]+$",
}))
local RecommendationId = gt.build(gt.string({
	pattern = "^[a-f0-9]+$",
}))

return {
	StringKeyMap = StringKeyMap,
	DateTime = DateTime,
	UUID = UUID,
	RecombeeRequest = RecombeeRequest,
	ItemId = ItemId,
	UserId = UserId,
	RecommendationId = RecommendationId,
}
