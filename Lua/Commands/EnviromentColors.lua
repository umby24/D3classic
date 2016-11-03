function Command_Set_Env_Colors(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	Red = tonumber(Arg_0)
	Green = tonumber(Arg_1)
	Blue = tonumber(Arg_2)
	Type = tonumber(Arg_3)

	if Type ~= 0 and Type ~= 1 and Type ~= 2 and Type ~= 3 and Type ~= 4 then
		System_Message_Network_Send(Client_ID, "&cInvalid color type " .. Type)
		return
	end

	Map_ID = Client_Get_Map_ID(Client_ID)

	CPE_Map_Set_Env_Colors(Map_ID, Red, Green, Blue, Type)
	System_Message_Network_Send(Client_ID, "&eColors set!")
end
