function Physic_Standart_Slab(Map_ID, X, Y, Z)
	Player_Number = Map_Block_Get_Player_Last(Map_ID, X, Y, Z)
	
	if Map_Block_Get_Type(Map_ID, X, Y, Z-1) == 50 then
		Map_Block_Change(-1, Map_ID, X, Y, Z, 0, 1, 0, 1, 5)
		Map_Block_Change(Player_Number, Map_ID, X, Y, Z-1, 4, 1, 1, 1, 5)
	end
	
end
