;{ CPE Packets
Procedure SendExtInfo(ClientID, Server.s, Extensions.w)
    Network_Client_Output_Write_Byte(ClientID, 16) ; Send ExtInfo
    Network_Client_Output_Write_String(ClientID, LSet(Server,64," "),64)
    Network_Client_Output_Write_Word(ClientID, Extensions)
EndProcedure

Procedure SendExtEntry(ClientID, ExtName.s, ExtVersion.l)
    Network_Client_Output_Write_Byte(ClientID, 17)
    Network_Client_Output_Write_String(ClientID, LSet(ExtName, 64, " "), 64)
    Network_Client_Output_Write_Int(ClientID, ExtVersion)
EndProcedure

Procedure SendClickDistance(ClientID, Distance.w)
    Network_Client_Output_Write_Byte(ClientID, 18)
    Network_CLient_Output_Write_Word(ClientID, Distance)
EndProcedure

Procedure SendCustomBlockSupportLevel(ClientID, SupportLevel.b)
    Network_Client_Output_Write_Byte(ClientID, 19)
    Network_Client_Output_Write_Byte(ClientID, SupportLevel)
EndProcedure

Procedure SendHoldThis(ClientID, HeldBlock.b, PreventChange.b)
    Network_Client_Output_Write_Byte(ClientID, 20)
    Network_Client_Output_Write_Byte(ClientID, HeldBlock)
    Network_Client_Output_Write_Byte(ClientID, PreventChange)
EndProcedure

Procedure SendTextHotkeys(ClientID, Label.s, Action.s, Keycode.l, Keymod.b)
    Network_Client_Output_Write_Byte(ClientID, 21)
    Network_Client_Output_Write_String(ClientID, LSet(Label, 64, " "), 64)
    Network_Client_Output_Write_String(ClientID, LSet(ReplaceString(Action, "\n", Chr(13)), 64, " "), 64)
    Network_Client_Output_Write_Int(ClientID, keycode)
    Network_Client_Output_Write_Byte(ClientID, Keymod)
EndProcedure
            
Procedure SendSetEnviromentColors(ClientID, Type.b, Red.w, Green.w, Blue.w)
    Network_Client_Output_Write_Byte(ClientID, 25)
    Network_Client_Output_Write_Byte(ClientID, Type)
    Network_Client_Output_Write_Word(ClientID, Red)
    Network_Client_Output_Write_Word(ClientID, Green)
    Network_Client_Output_Write_Word(ClientID, Blue)    
EndProcedure

Procedure SendSelectionBoxAdd(ClientID, SelectionID, Label.s, StartX.w, StartY.w, StartZ.w, EndX.w, EndY.w, EndZ.w, Red.w, Green.w, Blue.w, Opacity.w)
    Network_Client_Output_Write_Byte(ClientID, 26)
    Network_Client_Output_Write_Byte(ClientID, SelectionID)
    Network_Client_Output_Write_String(ClientID, LSet(Label, 64, " "), 64)
    Network_Client_Output_Write_Word(ClientID, StartX)
    Network_Client_Output_Write_Word(ClientID, StartZ)
    Network_Client_Output_Write_Word(ClientID, StartY)
    Network_Client_Output_Write_Word(ClientID, EndX)
    Network_Client_Output_Write_Word(ClientID, EndZ)
    Network_Client_Output_Write_Word(ClientID, EndY)
    Network_Client_Output_Write_Word(ClientID, Red)
    Network_Client_Output_Write_Word(ClientID, Green)
    Network_Client_Output_Write_Word(ClientID, Blue)
    Network_Client_Output_Write_Word(ClientID, Opacity)
EndProcedure

Procedure SendSelectionBoxDelete(ClientID, SelectionId)
    Network_Client_Output_Write_Byte(Client_ID, 27)
    Network_Client_Output_Write_Byte(Client_ID, Selection_ID)
EndProcedure

Procedure SendBlockPermissions(ClientID, BlockId.b, CanPlace.b, CanDelete.b)
    Network_Client_Output_Write_Byte(ClientID, 28)
    Network_Client_Output_Write_Byte(ClientID, BlockId)
    Network_Client_Output_Write_Byte(ClientID, CanPlace)
    Network_Client_Output_Write_Byte(ClientID, CanDelete)
EndProcedure
        
Procedure SendChangeModel(ClientID, EntityId, Model.s)
    Network_Client_Output_Write_Byte(ClientID, 29)
    Network_Client_Output_Write_Byte(ClientID, EntityId)
    Network_Client_Output_Write_String(ClientID, LSet(Model, 64, " "), 64)
EndProcedure

Procedure SendEnvMapAppearance(ClientID, Url.s, Sideblock.b, Edgeblock.b, Sidelevel.w)
    Network_Client_Output_Write_Byte(ClientID, 30)
    Network_Client_Output_Write_String(ClientID, LSet(Url, 64, " "), 64)
    Network_Client_Output_Write_Byte(ClientID, Sideblock)
    Network_Client_Output_Write_Byte(ClientID, Edgeblock)
    Network_Client_Output_Write_Word(ClientID, Sidelevel)
EndProcedure

Procedure SendSetWeather(ClientID, Weather.b)
    Network_Client_Output_Write_Byte(ClientID, 31)
    Network_Client_Output_Write_Byte(ClientID, Weather)    
EndProcedure

Procedure SendHackControl(ClientID, Flying.b, Noclip.b, Speeding.b, SpawnControl.b, ThirdPerson.b, Jumpheight.w)
    Network_Client_Output_Write_Byte(ClientID, 32)
    Network_Client_Output_Write_Byte(ClientID, Flying)
    Network_Client_Output_Write_Byte(ClientID, Noclip)
    Network_Client_Output_Write_Byte(ClientID, Speeding)
    Network_Client_Output_Write_Byte(ClientID, SpawnControl)
    Network_Client_Output_Write_Byte(ClientID, ThirdPerson)
    Network_Client_Output_Write_Word(ClientID, Jumpheight)
EndProcedure
        
;}


; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 104
; Folding = +--
; EnableThread
; EnableXP