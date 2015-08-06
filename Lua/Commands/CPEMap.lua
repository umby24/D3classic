function Command_Map_Set_Appearance(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	Map_Env_Apperance_Set(Entity_Get_Map_ID(Client_Get_Entity(Client_ID)), Arg_0, Arg_1, Arg_2, Arg_3)
	System_Message_Network_Send(Client_ID, "&eTexture applied.")
end