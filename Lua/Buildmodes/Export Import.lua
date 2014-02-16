-- ############################ Export #############################

function Command_Build_Mode_Export(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	if Arg_0 ~= "" then
		local Filename = Arg_0
		if string.lower(string.sub(Filename, string.len(Filename)-3)) ~= ".map" then
			Filename = Filename..".map"
		end
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Export started"))
		Build_Mode_Set(Client_ID, "Export Map-Area")
		Build_Mode_State_Set(Client_ID, 0)
		Build_Mode_String_Set(Client_ID, 0, Files_Folder_Get("Usermaps")..Filename)
	else
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Export: Define a file"))
	end
end

function Build_Mode_Export(Client_ID, Map_ID, X, Y, Z, Mode, Block_Type)
	if Mode == 1 then
		
		local State = Build_Mode_State_Get(Client_ID)
		
		if State == 0 then -- Ersten Punkt wählen
			Build_Mode_Coordinate_Set(Client_ID, 0, X, Y, Z)
			Build_Mode_State_Set(Client_ID, 1)
			
		elseif State == 1 then -- Zweiten Punkt wählen und bauen
			if Client_Get_Extension(Client_ID, "SelectionCuboid") == false then
				local X_0, Y_0, Z_0, X_1, Y_1, Z_1 = X, Y, Z, Build_Mode_Coordinate_Get(Client_ID, 0)
				local Filename = Build_Mode_String_Get(Client_ID, 0)
				
				Map_Export(Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Filename)
				System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Export: Saved"))
				
				Build_Mode_Set(Client_ID, "Normal")
			else
				Build_Mode_Coordinate_Set(Client_ID, 1, X, Y, Z)
				
				local X_0, Y_0, Z_0, X_1, Y_1, Z_1 = X, Y, Z, Build_Mode_Coordinate_Get(Client_ID, 0)
				System_Message_Network_Send(Client_ID, "&cThe shown area describes the export. Type /cancel to cancel. <br>&c/accept to continue.")
				
				Build_Mode_State_Set(Client_ID, 2)
				
				if X_0 > X_1 then
					local X_2 = X_0
					X_0 = X_1
					X_1 = X_2
				end
				if Y_0 > Y_1 then
					local Y_2 = Y_0
					Y_0 = Y_1
					Y_1 = Y_2
				end
				if Z_0 > Z_1 then
					local Z_2 = Z_0
					Z_0 = Z_1
					Z_1 = Z_2
				end
				
				Z_1 = Z_1 + 1
				X_1 = X_1 + 1
				Y_1 = Y_1 + 1
				
				CPE_Selection_Cuboid_Add(Client_ID, 254, "MapExport", X_0, Y_0, Z_0, X_1, Y_1, Z_1, 0, 255, 0, 90)
			end
		end
	end
end

-- ############################ Import #############################

function Command_Build_Mode_Import(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	if Arg_0 ~= "" then
		local Filename = Arg_0
		if string.lower(string.sub(Filename, string.len(Filename)-3)) ~= ".map" then
			Filename = Filename..".map"
		end
		local Temp_File = io.open(Files_Folder_Get("Usermaps")..Filename)
		if Temp_File ~= nil then
			io.close(Temp_File)
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Import started"))
			Build_Mode_Set(Client_ID, "Import Map-Area")
			Build_Mode_String_Set(Client_ID, 0, Files_Folder_Get("Usermaps")..Filename)
			Build_Mode_Long_Set(Client_ID, 0, 1)
			Build_Mode_Long_Set(Client_ID, 1, 1)
			Build_Mode_Long_Set(Client_ID, 2, 1)
		else
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Import: File '[Field_0]' not found", Filename))
		end
	else
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Import: Define a file"))
	end
end

function Command_Build_Mode_Scaleimport(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	if Arg_0 ~= "" then
		
		local SX, SY, SZ = tonumber(Arg_1), tonumber(Arg_2), tonumber(Arg_3)
		--if SX <= 1 then SX = 1 end
		--if SY <= 1 then SY = 1 end
		--if SZ <= 1 then SZ = 1 end
		
		local Filename = Arg_0
		if string.lower(string.sub(Filename, string.len(Filename)-3)) ~= ".map" then
			Filename = Filename..".map"
		end
		local Temp_File = io.open(Files_Folder_Get("Usermaps")..Filename)
		if Temp_File ~= nil then
			io.close(Temp_File)
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Scaleimport started"))
			Build_Mode_Set(Client_ID, "Import Map-Area")
			Build_Mode_String_Set(Client_ID, 0, Files_Folder_Get("Usermaps")..Filename)
			Build_Mode_Long_Set(Client_ID, 0, SX)
			Build_Mode_Long_Set(Client_ID, 1, SY)
			Build_Mode_Long_Set(Client_ID, 2, SZ)
		else
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Scaleimport: File '[Field_0]' not found", Filename))
		end
	else
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Scaleimport: Define a file"))
	end
end

function Build_Mode_Import(Client_ID, Map_ID, X, Y, Z, Mode, Block_Type)
	if Mode == 1 then 
		local Filename = Build_Mode_String_Get(Client_ID, 0)
		local SX, SY, SZ = Build_Mode_Long_Get(Client_ID, 0), Build_Mode_Long_Get(Client_ID, 1), Build_Mode_Long_Get(Client_ID, 2)
		
		local Player_Number = Entity_Get_Player(Client_Get_Entity(Client_ID))
		
		Map_Import_Player(Player_Number, Filename, Map_ID, X, Y, Z, SX, SY, SZ)
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Import: Imported"))
		
		Build_Mode_Set(Client_ID, "Normal")
		
		CPE_Selection_Cuboid_Delete(Client_ID, 253)
		CPE_Selection_Cuboid_Delete(Client_ID, 252)
	end
	
end

Event_Add("Import_Event_Timer", "Import_Event_Timer", "Timer", 0, 100, -1)

function Import_Event_Timer(Map_ID)
	local ClientTable = Client_Get_Table()
	
	for Index, Client_ID  in pairs (ClientTable) do
		if Build_Mode_Get(Client_ID) == "Import Map-Area" and Client_Get_Extension(Client_ID, "SelectionCuboid") then -- Not gonna waste the cpu cycles if they don't support SelectionCuboid :P
			local Entity_ID = Client_Get_Entity(Client_ID)
			local Size_X, Size_Y, Size_Z = Map_Export_Get_Size(Build_Mode_String_Get(Client_ID, 0))
			local SX, SY, SZ = Build_Mode_Long_Get(Client_ID, 0), Build_Mode_Long_Get(Client_ID, 1), Build_Mode_Long_Get(Client_ID, 2)
			local X, Y, Z, Rotation, Look = Entity_Get_X(Entity_ID), Entity_Get_Y(Entity_ID), Entity_Get_Z(Entity_ID), Entity_Get_Rotation(Entity_ID), Entity_Get_Look(Entity_ID)
			local M_X, M_Y, M_Z = math.cos(math.rad(Rotation-90))*math.cos(math.rad(Look))*4, math.sin(math.rad(Rotation-90))*math.cos(math.rad(Look))*4, -math.sin(math.rad(Look))*4
			local G_X, G_Y, G_Z = math.floor(X+M_X), math.floor(Y+M_Y), math.floor(Z+1.6+M_Z)
			
			CPE_Selection_Cuboid_Delete(Client_ID, 253) -- Delete the previous export preview.
			CPE_Selection_Cuboid_Delete(Client_ID, 252)
			
			if G_X ~= nil and G_Y ~= nil and G_Z ~= nil then
				CPE_Selection_Cuboid_Add(Client_ID, 253, "MapExport", G_X, G_Y, G_Z, G_X + Size_X, G_Y + Size_Y, G_Z + Size_Z, 255, 0, 0, 90)
				CPE_Selection_Cuboid_Add(Client_ID, 252, "MapExport", G_X, G_Y, G_Z, G_X + 1, G_Y + 1, G_Z + 1, 0, 255, 0, 90) -- Create the preview.
			end
		end
	end	
end

System_Message_Network_Send_2_All(-1, "&cReloaded Map Export/Import")