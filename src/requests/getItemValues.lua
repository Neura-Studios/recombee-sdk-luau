local sendRequest = require(script.Parent.Parent.dispatcher).sendRequest
local Types = require(script.Parent.Parent.types)

local ItemIdType = Types.ItemId

return function(itemId: typeof(ItemIdType:type()))
	ItemIdType:assert(itemId)

	return sendRequest({
		name = "GetItemValues",
		method = "GET",
		path = `/items/{itemId}`,
	})
end
