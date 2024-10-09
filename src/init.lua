-- Package by Juniper Hovey (EncodedLua) @ Neura Studios 2024 --

local requests = script.requests

require(script.dispatcher)

return {
	AddBookmark = require(requests.addBookmark),
	AddItem = require(requests.addItem),
	AddPurchase = require(requests.addPurchase),
	AddRating = require(requests.addRating),
	DeleteBookmark = require(requests.deleteBookmark),
	DeleteItem = require(requests.deleteItem),
	DeleteRating = require(requests.deleteRating),
	ListUsers = require(requests.listUsers),
	RecommendItemsToItem = require(requests.recommendItemsToItem),
	RecommendItemsToUser = require(requests.recommendItemsToUser),
	RecommendNextItems = require(requests.recommendNextItems),
	SearchItems = require(requests.searchItems),
	SetItemValues = require(requests.setItemValues),
	SetUserValues = require(requests.setUserValues),
	SetViewPortion = require(requests.setViewPortion),
}
