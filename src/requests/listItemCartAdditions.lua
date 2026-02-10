local enqueueRequest = require(script.Parent.Parent.dispatcher).enqueueRequest
local gt = require(script.Parent.Parent.Parent.gt)
local Types = require(script.Parent.Parent.types)

local ListItemCartAdditionsRequestType = gt.build(gt.table({
	itemId = Types.ItemId,
}))

return function(body: typeof(ListItemCartAdditionsRequestType:type()))
	ListItemCartAdditionsRequestType:assert(body)

	return enqueueRequest({
		name = "ListItemCartAdditions",
		method = "GET",
		path = `/items/{body.itemId}/cartadditions/`,
		params = {},
	})
end
