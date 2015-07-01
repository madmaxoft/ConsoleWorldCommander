
-- BlockTypesSource.lua

-- Implements the BlockTypesSource "class" representing a blackbox providing block types for fill operations

--[[
The main function used is the CreateBlockTypesSource(). It takes the user input and returns the blocktype source object.
The returned object is a function that takes three coords as params (X, Y, Z) and returns two numbers,
the blocktype and blockmeta that was chosen for that particular location.
If there is an error in the input data, the returned object is instead a string description of the error.
--]]




--- Converts the specified string into a blocktype and meta
-- Returns the block type and meta on success, false and error message on failure
function StringToBlockType(a_BlockTypeStr)
	-- Convert:
	local item = cItem()
	if not(StringToItem(a_BlockTypeStr, item)) then
		return false, "Not a valid block type: " .. a_BlockTypeStr
	end
	
	-- Check that it's a block, not an item:
	local blockType = item.m_ItemType
	if (blockType >= 256) then
		return false, "Invalid block type (it's an item): " .. a_BlockTypeStr
	end
	
	return blockType, item.m_ItemDamage
end





local function MakeSingleBlockTypeSource(a_BlockTypeStr)
	-- Convert to a block type, check for errors:
	local blockType, blockMeta = StringToBlockType(a_BlockTypeStr)
	if not(blockType) then
		-- Conversion failed, blockMeta contains the error message
		return blockMeta
	end
	
	-- Return the BlockTypeSource:
	return function()
		return blockType, blockMeta
	end
end





--- Creates a MultiBlockTypesSource instance based on the user-provided definitions
-- a_Definitions is an array of strings with the user definitions
-- a_StartIndex is the index to the first item in a_Definitions that should be parsed into blocktypes
local function MakeMultiBlockTypesSource(a_Definitions, a_StartIndex)
	-- TODO
	return "Not implemented yet"
end





--- Creates a BlockTypesSource instance based on the user-provided definitions
-- a_Definitions is an array of strings with the user definitions
-- a_StartIndex is the index to the first item in a_Definitions that should be parsed
function CreateBlockTypesSource(a_Definitions, a_StartIndex)
	-- If the definitions is a single item not starting with a dash, make a single-type source:
	if (not(a_Definitions[a_StartIndex + 1]) and (string.sub(a_Definitions[a_StartIndex], 1, 1) ~= "-")) then
		return MakeSingleBlockTypeSource(a_Definitions[a_StartIndex])
	end
	
	-- Consider the definitions a list of blocktypes and their chances, make a multi-type source:
	return MakeMultiBlockTypesSource(a_Definitions, a_StartIndex)
end






