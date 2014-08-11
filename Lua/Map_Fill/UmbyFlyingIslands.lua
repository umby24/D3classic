function Random(X, Y, Seed)
	local Value = X + Y*1.2345 + Seed*5.6789
	local Value = Value + Value - X
	local Value = Value + Value + Y
	local Value = Value + Value + X * 12.3
	local Value = Value + Value - Y * 45.6
	local Value = Value + math.sin(X*78.9012)+Y + math.cos(Seed*78.9012)
	local Value = Value + math.cos(Y*12.3456)-X + math.sin(Seed*Value+Value+X)
	local Value = Value + math.sin(Y*45.6789)+X + math.cos(Seed*Value+Value-Y)
	return Value - math.floor(Value)
end

function Quantize(X, Y, Factor)
	return math.floor(X/Factor)*Factor, math.floor(Y/Factor)*Factor
end
function Random_Map(Chunk_X, Chunk_Y, Chunks, Result_Size, Randomness, Seed)
	local Chunk_Size = 16 -- in m
	local Map_Divider = Chunks -- in 1
	local Map_Pos_X, Map_Pos_Y = Quantize(Chunk_X, Chunk_Y, Map_Divider) -- in Chunks
	local Map_Pos_X_m, Map_Pos_Y_m = Map_Pos_X*Chunk_Size, Map_Pos_Y*Chunk_Size -- in m
	local Map_Offset_X, Map_Offset_Y = Chunk_X-Map_Pos_X, Chunk_Y-Map_Pos_Y -- in Chunks
	--local Map_Offset_X_m, Map_Offset_Y_m = Map_Offset_X*Chunk_Size/Result_Size, Map_Offset_Y*Chunk_Size/Result_Size -- in m
	
	local Map = {}
	
	-- Fill it with random start values
	local Size = 1 -- (2x2)
	for ix = 0, Size do
		Map[ix] = {}
		for iy = 0, Size do
			Map[ix][iy] = Random(Map_Pos_X_m + ix*Chunk_Size*Chunks, Map_Pos_Y_m + iy*Chunk_Size*Chunks, Seed)
		end
	end
	
	-- Do the iterations
	while Size < Chunks*Result_Size do
		
		-- Resize the array
		for ix = Size+1, Size*2 do
			Map[ix] = {}
		end
		for ix = Size, 0, -1 do
			for iy = Size, 0, -1 do
				Map[ix*2][iy*2] = Map[ix][iy]
			end
		end
		Size = Size * 2
		
		local Size_Factor = Chunks*Chunk_Size / Size
		
		local Random_Factor = Randomness
		
		-- The diamond step
		for ix = 1, Size, 2 do
			for iy = 1, Size, 2 do
				local Temp_Avg = (Map[ix+1][iy+1] + Map[ix-1][iy+1] + Map[ix+1][iy-1] + Map[ix-1][iy-1]) / 4
				local Temp_Max = math.max(math.abs(Temp_Avg-Map[ix+1][iy+1]), math.abs(Temp_Avg-Map[ix-1][iy+1]), math.abs(Temp_Avg-Map[ix+1][iy-1]), math.abs(Temp_Avg-Map[ix-1][iy-1]))
				Map[ix][iy] = Temp_Avg + ((Random(Map_Pos_X_m + ix*Size_Factor, Map_Pos_Y_m + iy*Size_Factor, Seed)*2-1) * Temp_Max * Random_Factor)
			end
		end
		
		-- The square step
		for ix = 0, Size, 2 do
			for iy = 1, Size, 2 do
				local Temp_Avg = (Map[ix][iy-1] + Map[ix][iy+1]) / 2
				local Temp_Max = math.max(math.abs(Temp_Avg-Map[ix][iy-1]), math.abs(Temp_Avg-Map[ix][iy+1]))
				Map[ix][iy] = Temp_Avg + ((Random(Map_Pos_X_m + ix*Size_Factor, Map_Pos_Y_m + iy*Size_Factor, Seed)*2-1) * Temp_Max * Random_Factor)
			end
		end
		for ix = 1, Size, 2 do
			for iy = 0, Size, 2 do
				local Temp_Avg = (Map[ix-1][iy] + Map[ix+1][iy]) / 2
				local Temp_Max = math.max(math.abs(Temp_Avg-Map[ix-1][iy]), math.abs(Temp_Avg-Map[ix+1][iy]))
				Map[ix][iy] = Temp_Avg + ((Random(Map_Pos_X_m + ix*Size_Factor, Map_Pos_Y_m + iy*Size_Factor, Seed)*2-1) * Temp_Max * Random_Factor)
			end
		end
		
	end
	
	-- Return the Map
	
	local Result = {}
	
	for ix = 0, Result_Size do
		Result[ix] = {}
		for iy = 0, Result_Size do
			Result[ix][iy] = Map[Map_Offset_X*Result_Size+ix][Map_Offset_Y*Result_Size+iy]
		end
	end
	
	return Result
end

function Heightmap_Fractal(Chunk_X, Chunk_Y, Quantisation, It_Per_Chunk, Randomness, Seed)
	local Chunk_Size = 16
	
	-- Fill it with random start values
	local Size = It_Per_Chunk -- (2x2)
	local Heightmap = Random_Map(Chunk_X, Chunk_Y, Quantisation, Size, Randomness, Seed)
	
	-- Do the iterations
	while Size < Chunk_Size do
		
		-- Resize the array
		for ix = Size+1, Size*2 do
			Heightmap[ix] = {}
			--for iy = Size+1, Size*2 do
			--	Heightmap[ix][iy] = 0
			--end
		end
		for ix = Size, 0, -1 do
			for iy = Size, 0, -1 do
				Heightmap[ix*2][iy*2] = Heightmap[ix][iy]
			end
		end
		Size = Size * 2
		
		-- The diamond step
		for ix = 1, Size, 2 do
			for iy = 1, Size, 2 do
				Heightmap[ix][iy] = (Heightmap[ix+1][iy+1] + Heightmap[ix-1][iy+1] + Heightmap[ix+1][iy-1] + Heightmap[ix-1][iy-1]) / 4
			end
		end
		
		-- The square step
		for ix = 0, Size, 2 do
			for iy = 1, Size, 2 do
				Heightmap[ix][iy] = (Heightmap[ix][iy-1] + Heightmap[ix][iy+1]) / 2
			end
		end
		for ix = 1, Size, 2 do
			for iy = 0, Size, 2 do
				Heightmap[ix][iy] = (Heightmap[ix-1][iy] + Heightmap[ix+1][iy]) / 2
			end
		end
	end
	
	-- Return the Heightmap
	
	return Heightmap
end

function create_skyislands(Map_ID, Chunk_X, Chunk_Y, Seed, Generation_State, Map_Z)
	local Chunk_Size = 16
	local Offset_X = Chunk_X * Chunk_Size -- in Blocks
	local Offset_Y = Chunk_Y * Chunk_Size -- in Blocks
	
	--local Start_Time = os.clock()
	
	local Heightmap_0 = Heightmap_Fractal(Chunk_X, Chunk_Y, 1, 1, 1, Seed)
	local Heightmap_1 = Heightmap_Fractal(Chunk_X, Chunk_Y, 1, 1, 0, Seed)
	local Total_Height = Heightmap_Fractal(Chunk_X, Chunk_Y, 4, 1, 0, Seed)
	
	local Treetypemap = Heightmap_Fractal(Chunk_X, Chunk_Y, 8, 1, 0.0, Seed + 3)
	
	if Generation_State == 1 then
		-- Build the chunk
		for ix = 0, Chunk_Size-1 do
			for iy = 0, Chunk_Size-1 do
				
				local Total_Height = 20 + Total_Height[ix][iy] * (Map_Z)
				local Height_0 = math.floor(Total_Height + Heightmap_0[ix][iy] * 50)
				local Height_1 = math.floor((Map_Z / 2) + Heightmap_1[ix][iy] * 15)
				
				for iz = Height_0, Height_1 do
					if iz == Height_1 then
						--World_Block_Set(World_ID, Offset_X+ix, Offset_Y+iy, iz, 2, 0, 0, 0, 0, 0, 1, 0)
                        Map_Block_Change(-1, Map_ID,Offset_X+ix, Offset_Y+iy, iz, 2, 0, 0, 0, 0)
                        
					else
						--World_Block_Set(World_ID, Offset_X+ix, Offset_Y+iy, iz, 3, 0, 0, 0, 0, 0, 0, 0)
                        Map_Block_Change(-1, Map_ID,Offset_X+ix, Offset_Y+iy, iz, 3, 0, 0, 0, 0)
					end
				end
			end
		end
		return 100 -- Next step ONLY if there are neighbours around the chunk
	else
		-- Build the trees
		for ix = 0, Chunk_Size-1 do
			for iy = 0, Chunk_Size-1 do
				
				local Total_Height = 20 + Total_Height[ix][iy] * (Map_Z)
				local Height_0 = math.floor(Total_Height + Heightmap_0[ix][iy] * 50)
				local Height_1 = math.floor((Map_Z / 2) + Heightmap_1[ix][iy] * 15)
				
				if Treetypemap[ix][iy] <= 0.2 then
					Treetype = ""
				elseif Treetypemap[ix][iy] <= 0.4 then
					Treetype = "pine"
				elseif Treetypemap[ix][iy] <= 0.6 then
					Treetype = "birch"
				elseif Treetypemap[ix][iy] <= 0.8 then
					Treetype = "oak"
				else
					Treetype = ""
				end
				
				for iz = Height_0, Height_1 do
					if iz == Height_1 and math.random(40) == 1 then
						create_tree(Map_ID, Offset_X+ix, Offset_Y+iy, iz+1, 1+math.random(), Treetype)
                        --Map_Block_Change(-1, Map_ID,Offset_X+ix, Offset_Y+iy, iz+1, 17, 0, 0, 0, 0)
					end
				end
			end
		end
		--Message_Send_2_All("§eTime to generate the Chunk: "..tostring(math.ceil((os.clock()-Debug_Time)*1000)/1000).."s")
		return 0 -- Disables any further generation steps
	end
	
	return 0 -- should never be reached
end

function create_skyislands2(Map_ID, Chunk_X, Chunk_Y, Seed, Generation_State, Map_Z, Division_Factor)
	local Chunk_Size = 16
	local Offset_X = Chunk_X * Chunk_Size -- in Blocks
	local Offset_Y = Chunk_Y * Chunk_Size -- in Blocks
	
	--local Start_Time = os.clock() 
	
	local Heightmap_0 = Heightmap_Fractal(Chunk_X, Chunk_Y, 1, 1, 2, Seed)
	local Heightmap_1 = Heightmap_Fractal(Chunk_X, Chunk_Y, 1, 1, 2, Seed)
	local Total_Height = Heightmap_Fractal(Chunk_X, Chunk_Y, 4, 1, 4, Seed)
	
	
	if Generation_State == 1 then
		-- Build the chunk
		for ix = 0, Chunk_Size-1 do
			for iy = 0, Chunk_Size-1 do
				
				local Total_Height = 20 + Total_Height[ix][iy] * (Map_Z * 2)
				local Height_0 = math.floor(Total_Height + Heightmap_0[ix][iy] * 50)
				local Height_1 = math.floor((Map_Z / 2) + Heightmap_1[ix][iy] * 15)
								
				for iz = Height_0, Height_1 do
					if iz == Height_1 then
						--World_Block_Set(World_ID, Offset_X+ix, Offset_Y+iy, iz, 2, 0, 0, 0, 0, 0, 1, 0)
                        Map_Block_Change(-1, Map_ID,Offset_X+ix, Offset_Y+iy, iz / Division_Factor, 2, 0, 0, 0, 0)
                        
					else
						--World_Block_Set(World_ID, Offset_X+ix, Offset_Y+iy, iz, 3, 0, 0, 0, 0, 0, 0, 0)
                        Map_Block_Change(-1, Map_ID,Offset_X+ix, Offset_Y+iy, iz / Division_Factor, 3, 0, 0, 0, 0)
					end
				end
			end
		end
		return 100 -- Next step ONLY if there are neighbours around the chunk
	else
		-- Build the trees
		
		--Message_Send_2_All("§eTime to generate the Chunk: "..tostring(math.ceil((os.clock()-Debug_Time)*1000)/1000).."s")
		return 0 -- Disables any further generation steps
	end
	
	return 0 -- should never be reached
end

function create_tree(Map_ID, X, Y, Z, Size, Type)
    Map_Block_Change(-1, Map_ID,X, Y, Z-1, 3, 0, 0, 0, 0)
	if Type == 'oak' then
		local Block_Size = math.floor(Size * 5)
		if Block_Size > 7 then Block_Size = 7 end
		if Block_Size < 6 then Block_Size = 6 end
		for iz = 0, Block_Size-2 do
			--World_Block_Set(World_ID, X, Y, Z+iz, 17, 0, 0, 0, 0, 0, 0, 0)
            Map_Block_Change(-1, Map_ID,X, Y, Z+iz, 17, 0, 0, 0, 0)
		end
		local Radius = 0.5
		for iz = Block_Size, Block_Size-4, -1 do
			local Int_Radius = math.ceil(Radius)
			for ix = -Int_Radius, Int_Radius do
				for iy = -Int_Radius, Int_Radius do
					local Dist = math.sqrt(math.pow(ix,2) + math.pow(iy,2))
					if Dist <= Radius then
						--local Result, Type = World_Block_Get(World_ID, X+ix, Y+iy, Z+iz)
                        local Type = Map_Block_Get_Type(Map_ID, X+ix, Y+iy, Z+iz)
						--if Result and Type == 0 then
                        if Type == 0 then
							if iz >= Block_Size then
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 0, -1, -1, 0, 1, 1, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							else
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 0, -1, -1, 0, 1, 0, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							end
						end
					end
				end
			end
			if Radius < 2 then
				Radius = Radius + 0.7
			end
		end
	elseif Type == 'birch' then
		local Block_Size = math.floor(Size * 5)
		if Block_Size > 7 then Block_Size = 7 end
		if Block_Size < 6 then Block_Size = 6 end
		for iz = 0, Block_Size-2 do
			--World_Block_Set(World_ID, X, Y, Z+iz, 17, 2, 0, 0, 0, 0, 0, 0)
            Map_Block_Change(-1, Map_ID,X, Y, Z+iz, 17, 0, 0, 0, 0)
		end
		local Radius = 0.5
		for iz = Block_Size, Block_Size-4, -1 do
			local Int_Radius = math.ceil(Radius)
			for ix = -Int_Radius, Int_Radius do
				for iy = -Int_Radius, Int_Radius do
					local Dist = math.sqrt(math.pow(ix,2) + math.pow(iy,2))
					if Dist <= Radius then
						--local Result, Type = World_Block_Get(World_ID, X+ix, Y+iy, Z+iz)
						--if Result and Type == 0 then
                        local Type = Map_Block_Get_Type(Map_ID, X+ix, Y+iy, Z+iz)
                        if Type == 0 then
							if iz >= Block_Size then
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 2, -1, -1, 0, 1, 1, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							else
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 2, -1, -1, 0, 1, 0, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							end
						end
					end
				end
			end
			if Radius < 2 then
				Radius = Radius + 0.7
			end
		end
	elseif Type == 'pine' then
		local Block_Size = math.floor(Size * 7)
		for iz = 0, Block_Size-2 do
			--World_Block_Set(World_ID, X, Y, Z+iz, 17, 1, 0, 0, 0, 0, 0, 0)
            Map_Block_Change(-1, Map_ID,X, Y, Z+iz, 17, 0, 0, 0, 0)
		end
		local Radius = 0
		local Step = 0
		for iz = Block_Size, 3, -1 do
			for ix = -Radius, Radius do
				for iy = -Radius, Radius do
					if Radius == 0 or ( math.abs(ix) < Radius and math.abs(iy) < Radius ) then
						--local Result, Type = World_Block_Get(World_ID, X+ix, Y+iy, Z+iz)
						--if Result and Type == 0 then
                        local Type = Map_Block_Get_Type(Map_ID, X+ix, Y+iy, Z+iz)
                        if Type == 0 then
							if iz >= Block_Size-2 then
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 1, -1, -1, 0, 1, 1, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							else
								--World_Block_Set(World_ID, X+ix, Y+iy, Z+iz, 18, 1, -1, -1, 0, 1, 0, 0)
                                Map_Block_Change(-1, Map_ID,X+ix, Y+iy, Z+iz, 18, 0, 0, 0, 0)
							end
						end
					end
				end
			end
			Step = Step + 1
			if Step == 3 then
				Step = 0
				Radius = Radius - 1
			else
				Radius = Radius + 1
			end
		end
	end
end

function Mapfill_umbyflying(Map_ID,MapX,MapY,MapZ,args)
	local chunkX, chunkY = MapX/16, MapY/16
	
    local randomSeed = math.random(-500,500) / 2 
	local randomSeed2 = math.random(-500,500) / 2
	
	System_Message_Network_Send_2_All(Map_ID, "&2Generation Seed: &a" .. tostring(randomSeed))
	System_Message_Network_Send_2_All(Map_ID, "&2Generation Seed: &a" .. tostring(randomSeed2))
	
	for ix = 0, MapX do -- Create water
		for iy = 0, MapY do
			for iz = 0, 2 do
				Map_Block_Change(-1, Map_ID, ix, iy, iz, 9, 0, 0, 0, 0)
			end
		end
	end
	
    for x = 0, chunkX-1 do
        for y = 0, chunkY-1 do
            create_skyislands(Map_ID, x, y, randomSeed2, 1, MapZ)
            create_skyislands(Map_ID, x, y, randomSeed2, 2, MapZ)
			if MapZ > 64 then
				create_skyislands2(Map_ID, x, y, randomSeed, 1, MapZ, 3)
			end
			if MapZ > 256 then
			local newseed = math.random(-500,500) / 2
				create_skyislands2(Map_ID, x, y, newseed, 1, MapZ, 10)
			end
        end
    end
    
	
    System_Message_Network_Send_2_All(Map_ID, "&aDone!")
    
   
end

System_Message_Network_Send_2_All(-1, "&9Umby flying islands reloaded!")