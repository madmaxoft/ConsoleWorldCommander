
-- Commands.lua

-- Implements the console command handlers




--- Holds the current selection
local g_Selection = cCuboid(0, 0, 0, 0, 0, 0)

--- Holds the current world name. Set to nil if default world is to be used
local g_CurrentWorldName

--- Compatibility wrapper
cWorld.SetBlockTypeMeta = cWorld.SetBlockTypeMeta or cWorld.SetBlock





--- Returns the description of the selection
local function GetSelectionDesc()
	return string.format("{%d, %d, %d] - {%d, %d, %d} (%d blocks)",
		g_Selection.p1.x, g_Selection.p1.y, g_Selection.p1.z,
		g_Selection.p2.x, g_Selection.p2.y, g_Selection.p2.z,
		g_Selection:GetVolume()
	)
end





--- Returns the cWorld object based on the g_CurrentWorldName value
local function GetCurrentWorld()
	-- If name not set, return the default world
	if not(g_CurrentWorldName) then
		return cRoot:Get():GetDefaultWorld()
	end

	-- Return the named world
	return cRoot:Get():GetWorld(g_CurrentWorldName)
end





--- Returns an array of chunk coords (as consumed by cWorld:ChunkStay()) of chunks that intersect the specified cuboid
local function ChunksFromCuboid(a_Cuboid)
	-- Calculate
	local MinX = math.floor(a_Cuboid.p1.x / 16)
	local MaxX = math.floor(a_Cuboid.p2.x / 16)
	local MinZ = math.floor(a_Cuboid.p1.z / 16)
	local MaxZ = math.floor(a_Cuboid.p2.z / 16)

	local res = {}
	local idx = 1
	for z = MinZ, MaxZ do
		for x = MinX, MaxX do
			res[idx] = {x, z}
			idx = idx + 1
		end
	end

	return res
end





--- Returns an array of chunk coords (as consumed by cWorld:ChunkStay()) of a chunk that contains the specified point
local function ChunksFromPoint(a_BlockX, a_BlockZ)
	return { { math.floor(a_BlockX / 16), math.floor(a_BlockZ / 16) } }
end





function HandleConsoleCmdFill(a_Split)
	-- Create the block type source, check for errors:
	local blockTypeSource = CreateBlockTypesSource(a_Split, 3)
	if (type(blockTypeSource) == "string") then
		-- An error occurred, report it:
		return true, blockTypeSource
	end

	-- Fill a block area with the data:
	local area = cBlockArea()
	local MinX = g_Selection.p1.x
	local MinY = g_Selection.p1.y
	local MinZ = g_Selection.p1.z
	area:Create(g_Selection:DifX() + 1, g_Selection:DifY() + 1, g_Selection:DifZ() + 1)
	for y = 0, g_Selection:DifY() do
		local wy = MinY + y
		for z = 0, g_Selection:DifZ() do
			local wz = MinZ + z
			for x = 0, g_Selection:DifX() do
				local wx = MinX + x
				local blockType, blockMeta = blockTypeSource(wx, wy, wz)
				area:SetRelBlockTypeMeta(x, y, z, blockType, blockMeta)
			end
		end
	end

	-- Write the area to the world:
	local world = GetCurrentWorld()
	world:ChunkStay(ChunksFromCuboid(g_Selection), nil,
		function()
			area:Write(world, g_Selection.p1)
			area:Clear()
			LOG("Selection " .. GetSelectionDesc() .. " has been filled.")
		end
	)

	return true
end





function HandleConsoleCmdGenChunk(a_Split)
	-- If the params contain only one set of coords, expand to two sets:
	local paramStart = 3  -- where the command's parameters start, "cwc genchunk _"
	a_Split[paramStart + 2] = a_Split[paramStart + 2] or a_Split[paramStart]
	a_Split[paramStart + 3] = a_Split[paramStart + 3] or a_Split[paramStart + 1]

	-- Read the params:
	local chunkX1 = tonumber(a_Split[paramStart])
	local chunkZ1 = tonumber(a_Split[paramStart + 1])
	if not(chunkX1) then
		return true, "Missing the ChunkX parameter"
	end
	if not(chunkZ1) then
		return true, "Missing the ChunkZ parameter"
	end
	local chunkX2 = tonumber(a_Split[paramStart + 2])
	if not(chunkX2) then
		return true, "Invalid ChunkX2 parameter"
	end
	local chunkZ2 = tonumber(a_Split[paramStart + 3])
	if not(chunkZ2) then
		return true, "Invalid ChunkZ2 parameter"
	end

	-- Sort the coords:
	local minX, maxX
	if (chunkX1 < chunkX2) then
		minX, maxX = chunkX1, chunkX2
	else
		minX, maxX = chunkX2, chunkX1
	end
	local minZ, maxZ
	if (chunkZ1 < chunkZ2) then
		minZ, maxZ = chunkZ1, chunkZ2
	else
		minZ, maxZ = chunkZ2, chunkZ1
	end

	-- Generate the chunks:
	local world = GetCurrentWorld()
	for x = minX, maxX do
		for z = minZ, maxZ do
			world:GenerateChunk(x, z)
		end
	end

	return true, "Chunk generation queued"
end





function HandleConsoleCmdGetBlock(a_Split)
	-- Check the params:
	if (not(a_Split[5]) or a_Split[6]) then
		return true, "Usage: cwc getblock x y z"
	end

	-- Get the coords:
	local x = tonumber(a_Split[3])
	local y = tonumber(a_Split[4])
	local z = tonumber(a_Split[5])
	if (not(x) or not(y) or not(z)) then
		return true, "Invalid coordinates"
	end

	-- Get the block from the world:
	local world = GetCurrentWorld()
	world:ChunkStay(ChunksFromPoint(x, z), nil,
		function()
			local isValid, blockType, blockMeta = world:GetBlockTypeMeta(x, y, z)
			if (isValid) then
				LOG(blockType .. ":" .. blockMeta)
				local blockStr = ItemToString(cItem(blockType, 1, blockMeta))
				if (blockStr and (blockStr ~= "")) then
					LOG(blockStr)
				end
			else
				-- Shouldn't happen, but just in case
				LOG("Error while getting block")
			end
		end
	)

	return true
end





function HandleConsoleCmdRegenChunk(a_Split)
	-- If the params contain only one set of coords, expand to two sets:
	local paramStart = 3  -- where the command's parameters start, "cwc genchunk _"
	a_Split[paramStart + 2] = a_Split[paramStart + 2] or a_Split[paramStart]
	a_Split[paramStart + 3] = a_Split[paramStart + 3] or a_Split[paramStart + 1]

	-- Read the params:
	local chunkX1 = tonumber(a_Split[paramStart])
	local chunkZ1 = tonumber(a_Split[paramStart + 1])
	if not(chunkX1) then
		return true, "Missing the ChunkX parameter"
	end
	if not(chunkZ1) then
		return true, "Missing the ChunkZ parameter"
	end
	local chunkX2 = tonumber(a_Split[paramStart + 2])
	if not(chunkX2) then
		return true, "Invalid ChunkX2 parameter"
	end
	local chunkZ2 = tonumber(a_Split[paramStart + 3])
	if not(chunkZ2) then
		return true, "Invalid ChunkZ2 parameter"
	end

	-- Sort the coords:
	local minX, maxX
	if (chunkX1 < chunkX2) then
		minX, maxX = chunkX1, chunkX2
	else
		minX, maxX = chunkX2, chunkX1
	end
	local minZ, maxZ
	if (chunkZ1 < chunkZ2) then
		minZ, maxZ = chunkZ1, chunkZ2
	else
		minZ, maxZ = chunkZ2, chunkZ1
	end

	-- Generate the chunks:
	local world = GetCurrentWorld()
	for x = minX, maxX do
		for z = minZ, maxZ do
			world:RegenerateChunk(x, z)
		end
	end

	return true, "Chunk regeneration queued"
end





function HandleConsoleCmdSelect(a_Split)
	-- Check params:
	if (not(a_Split[8]) or a_Split[9]) then
		return true, "Usage: cwc select x1 y1 z1 x2 y2 z2"
	end

	-- Set the selection:
	g_Selection:Assign(a_Split[3], a_Split[4], a_Split[5], a_Split[6], a_Split[7], a_Split[8])
	g_Selection:ClampY(0, 255)
	g_Selection:Sort()
	return true, "Selection is now " .. GetSelectionDesc()
end





function HandleConsoleCmdSetBlock(a_Split)
	-- Check the params:
	if (not(a_Split[6]) or a_Split[7]) then
		return true, "Usage: cwc setblock x y z blocktype"
	end

	-- Get the coords:
	local x = tonumber(a_Split[3])
	local y = tonumber(a_Split[4])
	local z = tonumber(a_Split[5])
	if (not(x) or not(y) or not(z)) then
		return true, "Invalid coordinates"
	end

	-- Get the blocktype:
	local blockType, blockMeta = StringToBlockType(a_Split[6])
	if not(blockType) then
		-- Conversion failed, blockMeta contains the error message
		return true, blockMeta
	end

	-- Set the block in the world:
	local world = GetCurrentWorld()
	world:ChunkStay(ChunksFromPoint(x, z), nil,
		function()
			world:SetBlockTypeMeta(x, y, z, blockType, blockMeta)
			LOG("Block set")
		end
	)

	return true
end





function HandleConsoleCmdWorld(a_Split)
	-- If a param is given, set the world name:
	if (a_Split[3]) then
		-- Special name "-" means "default world":
		if (a_Split[3] == '-') then
			g_CurrentWorldName = nil
			return true, "Current world set to default"
		end

		-- Check that the world exists:
		local w = cRoot:Get():GetWorldByName(a_Split[3])
		if not(w) then
			return true, "No such world: " .. a_Split[3]
		end
		g_CurrentWorldName = a_Split[3]
		return true, "Current world set to " .. a_Split[3]
	end

	-- No param was given, output the current world name:
	return true, GetCurrentWorld():GetName()
end




