local Symbol = require(script.Parent.Symbol)

--[=[
	Contains useful tools for working with immutable tables.

	These never mutate the original data. Instead, they perform a shallow copy of
	the modified data to return.

	@class Immutable
]=]
local Immutable = {}
local NIL_SYMBOL = Symbol.create("Immutable.Nil")
Immutable.Nil = NIL_SYMBOL

--[=[
	Filters all entries in the filter set from the original data.

	```lua
		local data = {
			height = 5,
			width = 3,
			depth = 2
		}

		local filtered = Immutable.filter(data, {
			height = true,
			width = true,
		})

		-- Prints `{ depth = 2 }`
		print(data)
	```

	The values of the filter dictionary don't matter. This function treats the
	filter as a set, so only the existence of a key matters.

	@param original { [K]: V } -- The original data
	@param filter { [K]: unknown } -- The set of keys to filter
	@return { [K]: V } -- A filtered copy of the data
]=]
function Immutable.filter(original, filter)
	-- It would be good to type these properly when/if roblox supports typing these
	-- correctly.
	local filtered = {}
	for key, value in pairs(original) do
		if filter[key] then
			continue
		end
		filtered[key] = value
	end
	return filtered
end

--[=[
	Filters a data set by including the given keys in the resulting set.

	```lua
		local data = {
			height = 5,
			width = 3,
			depth = 2
		}

		local isolated = Immutable.include(data, {
			height = true,
			width = true,
		})

		-- Prints `{ height = 5, width = 3 }`
		print(data)
	```

	The values of the include dictionary don't matter. This function treats the
	filter as a set, so only the existence of a key matters.

	@param original { [K]: V } -- The original data
	@param include { [K]: unknown } -- The set of keys to include
	@return { [K]: V } -- A filtered copy of the data
]=]
function Immutable.include(original, include)
	-- It would be good to type these properly when/if roblox supports typing these
	-- correctly.
	local filtered = {}
	for key, value in pairs(original) do
		if include[key] then
			filtered[key] = value
		end
	end
	return filtered
end

--[=[
	Merges all entries from any number of original data tables.
	Using a value of `Immutable.Nil` in a partial table will remove the corresponding key from the resulting table.

	```lua
		local merged = Immutable.merge(data, {
			height = 10,
			width = 20,
			deleteMe = Immutable.Nil,
		})
	```

	@param ... { [K]: V } -- The original data
	@return { [K]: V } -- A merged copy of the data
]=]
function Immutable.merge<T>(base: T, ...: {} | T)
	local merged = {}
	for _, original in { base, ... } do
		for key, value in original do
			merged[key] = if value == NIL_SYMBOL then nil else value
		end
	end
	return merged
end

--[=[
	Compares all entries from any number of original data tables for shallow
	equality.

	```lua
		local equal = Immutable.equal(data, {
			height = 10,
			width = 20,
		})
	```

	This is an O(nm²) operation. Be careful when using large data sets.

	@param ... { [K]: V } -- The original data
	@return boolean -- True if all entries are equal, false otherwise
]=]
function Immutable.equal(...)
	for _, left in { ... } do
		for _, right in { ... } do
			if left == right then
				-- This is the same table, we short circuit
				continue
			end
			for key, value in left do
				if value == right[key] then
					continue
				end
				return false
			end
		end
	end
	return true
end

function Immutable.arrayAppend<T>(base: T, item)
	local arr = table.clone(base :: any)
	table.insert(arr, item)
	return arr
end

return Immutable
