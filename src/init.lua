-- Package by Juniper Hovey (EncodedLua) @ Neura Studios 2024 --

if not game:GetService("RunService"):IsServer() then
	error(`This module can only be used on the server`)
end

local requests = script.requests

require(script.dispatcher)

return {
	AddBookmark = require(requests.addBookmark),
	AddCartAddition = require(requests.addCartAddition),
	AddItem = require(requests.addItem),
	AddPurchase = require(requests.addPurchase),
	AddRating = require(requests.addRating),
	DeleteBookmark = require(requests.deleteBookmark),
	DeleteCartAddition = require(requests.deleteCartAddition),
	DeleteItem = require(requests.deleteItem),
	DeleteRating = require(requests.deleteRating),
	GetItemValues = require(requests.getItemValues),
	ListItemCartAdditions = require(requests.listItemCartAdditions),
	ListUserCartAdditions = require(requests.listUserCartAdditions),
	ListUsers = require(requests.listUsers),
	RecommendItemsToItem = require(requests.recommendItemsToItem),
	RecommendItemsToUser = require(requests.recommendItemsToUser),
	RecommendNextItems = require(requests.recommendNextItems),
	SearchItems = require(requests.searchItems),
	SetItemValues = require(requests.setItemValues),
	SetUserValues = require(requests.setUserValues),
	SetViewPortion = require(requests.setViewPortion),
}
