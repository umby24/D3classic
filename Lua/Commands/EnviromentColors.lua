function Command_Set_Env_Colors(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	Red = Arg_0
	Green = Arg_1
	Blue = Arg_2
	Type = Arg_3
	Map_ID = Client_Get_Map_ID(Client_ID)
	
	CPE_Map_Set_Env_Colors(Map_ID, Red, Green, Blue, Type)
end
