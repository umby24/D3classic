function Command_Build_Mode_Cancel(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Canceled"))
	local State = Build_Mode_State_Get(Client_ID)
	if State == 2 then
		Build_Mode_String_Set(Client_ID, 0, "")
	end
	CPE_Selection_Cuboid_Delete(Client_ID, 254)
	CPE_Selection_Cuboid_Delete(Client_ID, 253)
	CPE_Selection_Cuboid_Delete(Client_ID, 252)
	CPE_Selection_Cuboid_Delete(Client_ID, 250)
	Build_Mode_String_Set(Client_ID, 0, "")
	Build_Mode_Set(Client_ID, "Normal")
end
function Command_Build_Mode_Accept(Client_ID, ...)
	local State = Build_Mode_State_Get(Client_ID)
	if State == 2 and Build_Mode_Get(Client_ID) == "Export Map-Area" then
		local X_0, Y_0, Z_0 = Build_Mode_Coordinate_Get(Client_ID, 1)
		local X_1, Y_1, Z_1 = Build_Mode_Coordinate_Get(Client_ID, 0)
		
		local Filename = Build_Mode_String_Get(Client_ID, 0)
		
		Map_Export(Client_Get_Map_ID(Client_ID), X_0, Y_0, Z_0, X_1, Y_1, Z_1, Filename)
		System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Export: Saved"))
		
		CPE_Selection_Cuboid_Delete(Client_ID, 254)
		
		Build_Mode_Set(Client_ID, "Normal")
	elseif State == 2 and Build_Mode_Get(Client_ID) == "Box" then
		local Block_Type = Build_Mode_Long_Get(Client_ID, 3)
		local X_0, Y_0, Z_0 = Build_Mode_Coordinate_Get(Client_ID, 1)
		local X_1, Y_1, Z_1 = Build_Mode_Coordinate_Get(Client_ID, 0)
		
		local Replace_Material = Build_Mode_Long_Get(Client_ID, 0)
		local Hollow = Build_Mode_Long_Get(Client_ID, 1)
		
		local Player_Number = Entity_Get_Player(Client_Get_Entity(Client_ID))
		
		local Blocks = math.abs(X_0-X_1)*math.abs(Y_0-Y_1)*math.abs(Z_0-Z_1)
		
		if Hollow == 0 and Blocks < 500000 then
			Build_Box_Player(Player_Number, Client_Get_Map_ID(Client_ID), X_0, Y_0, Z_0, X_1, Y_1, Z_1, Block_Type, Replace_Material, Hollow, 2, 1, 0)
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Box created"))
		elseif Hollow == 1 and Blocks < 5000000 then
			Build_Box_Player(Player_Number, Client_Get_Map_ID(Client_ID), X_0, Y_0, Z_0, X_1, Y_1, Z_1, Block_Type, Replace_Material, Hollow, 2, 1, 0)
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Box created"))
		else
			System_Message_Network_Send(Client_ID, Lang_Get("", "Buildmode: Box too big"))
		end
		
		Build_Mode_Set(Client_ID, "Normal")
		CPE_Selection_Cuboid_Delete(Client_ID, 250)
		Build_Mode_String_Set(Client_ID, 0, "")
	end
end