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

; IDE Options = PureBasic 5.30 (Windows - x64)
; Folding = -
; EnableThread
; EnableXP