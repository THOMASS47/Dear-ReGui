local function filtergc(
	filter_type: "function" | "table",
	filter_options: {
		["Name"]: string?,
		["IgnoreExecutor"]: boolean?,
		["Hash"]: any?,
		["Constants"]: { any }?,
		["Upvalues"]: { any }?,
	} | {
		["Keys"]: { any }?,
		["Values"]: { any }?,
		["KeyValuePairs"]: { [any]: any }?,
		["Metatable"]: { [string]: any }?,
	},
	return_one: boolean?
): ((...any) -> ...any)? | { [any]: any }? | { (...any) -> ...any } | { { [any]: any } }
	local out = {}

	filter_options = filter_options or {}

	if filter_type == "function" then
		local gc = getgc(false)

		-- Change type
		local _filter_options = filter_options :: {
			["Name"]: string?,
			["IgnoreExecutor"]: boolean?,
			["Hash"]: any?,
			["Constants"]: { any }?,
			["Upvalues"]: { any }?,
		}

		-- Default IgnoreExecutor to true
		if _filter_options.IgnoreExecutor == nil then
			_filter_options.IgnoreExecutor = true
		end

		for _, func in pairs(gc) do
			if type(func) ~= "function" then
				continue
			end

			local matches = true

			-- Check if function is from executor
			if _filter_options.IgnoreExecutor then
				if isexecutorclosure(func) then
					matches = false
				end
			end

			-- Check Name filter
			if matches and _filter_options.Name then
				local info = debug.info(func, "n")
				if info ~= _filter_options.Name then
					matches = false
				end
			end

			-- Check Hash filter
			if matches and _filter_options.Hash then
				if iscclosure(func) or getfunctionhash(func) ~= _filter_options.Hash then
					matches = false
				end
			end

			-- Check Constants filter
			if matches and _filter_options.Constants and next(_filter_options.Constants) then
				-- Only Lua closures have constants, C functions don't
				if islclosure(func) then
					-- Get constants
					local constants = debug.getconstants(func)

					-- Check if all target constants exist in the function's constants
					for _, targetConst in pairs(_filter_options.Constants) do
						local found = false
						for _, const in pairs(constants) do
							-- Use direct comparison to handle special values like NaN
							if
								targetConst == const
								or (
									type(targetConst) == "number"
									and type(const) == "number"
									and targetConst ~= targetConst
									and const ~= const
								)
							then -- Special case for NaN
								found = true
								break
							end
						end
						if not found then
							matches = false
							break
						end
					end
				else
					-- C functions don't have constants, so they can't match
					matches = false
				end
			end

			-- Check Upvalues filter
			if matches and _filter_options.Upvalues and next(_filter_options.Upvalues) then
				-- Check if the function has upvalues (C functions might not)
				if islclosure(func) then
					-- Get upvalues
					local upvalues = debug.getupvalues(func)

					-- Check if all target upvalues exist in the function's upvalues
					for _, targetUpvalue in pairs(_filter_options.Upvalues) do
						if not table.find(upvalues, targetUpvalue) then
							matches = false
							break
						end
					end
				else
					-- Function doesn't support upvalues, so it can't match
					matches = false
				end
			end

			if matches then
				if return_one then
					return func
				end
				table.insert(out, func)
			end
		end
	elseif filter_type == "table" then
		local gc = getgc(true)

		-- Change type
		local _filter_options = filter_options :: {
			["Keys"]: { any }?,
			["Values"]: { any }?,
			["KeyValuePairs"]: { [any]: any }?,
			["Metatable"]: { [string]: any }?,
		}

		for _, tab in pairs(gc) do
			if type(tab) ~= "table" then
				continue
			end

			local matches = true

			-- Check Keys filter
			if _filter_options.Keys and next(_filter_options.Keys) then
				for _, key in pairs(_filter_options.Keys) do
					if rawget(tab, key) == nil then
						matches = false
						break
					end
				end
			end

			-- Check Values filter
			if matches and _filter_options.Values and next(_filter_options.Values) then
				local valueMatches = false
				for _, value in pairs(tab) do
					for _, targetValue in pairs(_filter_options.Values) do
						if value == targetValue then
							valueMatches = true
							break
						end
					end
					if valueMatches then
						break
					end
				end
				matches = valueMatches
			end

			-- Check KeyValuePairs filter
			if matches and _filter_options.KeyValuePairs and next(_filter_options.KeyValuePairs) then
				for key, value in pairs(_filter_options.KeyValuePairs) do
					if rawget(tab, key) ~= value then
						matches = false
						break
					end
				end
			end

			-- Check Metatable filter
			if matches and _filter_options.Metatable then
				local mt = getmetatable(tab)
				if mt ~= _filter_options.Metatable then
					matches = false
				end
			end

			if matches then
				if return_one then
					return tab
				end
				table.insert(out, tab)
			end
		end
	else
		error("Invalid filter_type")
	end

	if return_one then
		return nil
	end

	return out
end
getgenv().filtergc = filtergc
