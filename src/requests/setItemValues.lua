local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local Types = require(script.Parent.Parent.types)

local ItemIdType = Types.ItemId
local ItemValuesType = Types.StringKeyMap

return function(itemId: typeof(ItemIdType:type()), itemValues: typeof(ItemValuesType:type()))
	ItemIdType:assert(itemId)
	ItemValuesType:assert(itemValues)

	return sendRequest({
		name = "SetItemValues",
		method = "POST",
		path = `/items/{itemId}`,
		body = itemValues,
	})
end
