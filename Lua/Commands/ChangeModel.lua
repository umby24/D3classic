function Command_Change_Model(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	Model = string.lower(Arg_0)
	
	if Model ~= "chicken" and Model ~= "creeper" and Model ~= "croc" and Model ~= "printer" and Model ~= "zombie" and Model ~= "humanoid" and Model ~= "default" and Model ~= "pig" and Model ~= "sheep" and Model ~= "skeleton" and Model ~= "spider" and tonumber(Model) == nil then
		System_Message_Network_Send(Client_ID, "&4Error: &fModel not found!")
		return
	end
	
	CPE_Model_Change(Client_ID, Model)
	System_Message_Network_Send(Client_ID, "&eModel changed!")
end
function Command_Model_Reset(Client_ID, Command, Text_0, Text_1, Arg_0, Arg_1, Arg_2, Arg_3, Arg_4)
	CPE_Model_Change(Client_ID, "cow")
	System_Message_Network_Send(Client_ID, "&eModel reset")
end