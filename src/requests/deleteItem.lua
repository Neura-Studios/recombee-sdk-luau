local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local Types = require(script.Parent.Parent.types)

local ItemIdType = Types.ItemId

return function(itemId: typeof(ItemIdType:type()))
	ItemIdType:assert(itemId)

	return enqueueRequest({
		name = "DeleteItem",
		method = "DELETE",
		path = `/items/{itemId}`,
	})
end
