-- map function: Applies a function to each element in the array and returns a new array
function map(array, func)
	local newArray = {}
	for i, v in ipairs(array) do
		newArray[i] = func(v, i)
	end
	return newArray
end

-- filter function: Returns a new array with elements that pass the test function
function filter(array, func)
	local newArray = {}
	for i, v in ipairs(array) do
		if func(v, i) then
			table.insert(newArray, v)
		end
	end
	return newArray
end

local a = require("polyfill")

a({ ["use game:Http for request"] = true })
