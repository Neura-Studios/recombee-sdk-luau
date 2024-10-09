local SYMBOL_NAME = "Symbol(%s)"

export type Symbol = typeof(setmetatable({}, {}))

--[=[
	Symbols are unique runtime markers.

	@class Symbol
]=]
local Symbol = {}

--[=[
	Creates a new symbol.

	When used as a string provides its name.

	```lua
	local mySymbol = Symbol.create("MySymbol")

	-- Prints `Symbol(MySymbol)`
	print(mySymbol)
	```

	@return Symbol
]=]
function Symbol.create(name: string): Symbol
	local self = setmetatable({}, {
		__tostring = function()
			return string.format(SYMBOL_NAME, name)
		end,
	})

	return table.freeze(self)
end

return Symbol
