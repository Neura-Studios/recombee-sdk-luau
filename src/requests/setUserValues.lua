local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local Types = require(script.Parent.Parent.types)
local gt = require(script.Parent.Parent.Parent.gt)

local StringKeyMapType = Types.StringKeyMap
local UserIdType = Types.UserId
local SetUserValuesOptionsType = gt.build(gt.optional(gt.table({
	cascadeCreate = gt.optional(gt.boolean()),
})))

return function(
	userId: typeof(UserIdType:type()),
	userValues: typeof(StringKeyMapType:type()),
	options: typeof(SetUserValuesOptionsType:type())
)
	UserIdType:assert(userId)
	SetUserValuesOptionsType:assert(options)

	local requestBody = userValues
	if options then
		for optionName, optionValue in pairs(options) do
			requestBody[`!{optionName}`] = optionValue
		end
	end

	return enqueueRequest({
		name = "SetUserValues",
		method = "POST",
		path = `/users/{userId}`,
		body = requestBody,
	})
end
