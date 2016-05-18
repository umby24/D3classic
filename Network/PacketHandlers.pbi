; D3 Server - Packet Handlers
; - This file contains methods for handling incoming packets from clients.
; - By umby24

Procedure HandleHandshake(*Client.Network_Client)
    Protected ClientVersion.b, PlayerName.s, Mppass.s, Cpe.b
    
    Network_Client_Input_Add_Offset(*Client, 1)
    ClientVersion = Network_Client_Input_Read_Byte(*Client)
    PlayerName = Network_Client_Input_Read_String(*Client, 64)
    Mppass = Network_Client_Input_Read_String(*Client, 64)
    Cpe = Network_Client_Input_Read_Byte(*Client)
    
    *Client\CPE = #False ; Set this to false until properly negotiated.
    *Client\CustomBlocks_Level = 0
    *Client\HeldBlock = #False
    *Client\ClickDistance = #False
    *Client\ExtPlayerList = #False
    *Client\ChangeModel = #False
    *Client\CPEWeather = #False
    *Client\EnvColors = #False
    *Client\MessageTypes = #False
    *Client\BlockPermissions = #False
    *Client\EnvMapAppearance = #False
    *Client\TextHotkey = #False
    *Client\HackControl = #False
    *Client\LongerMessages = #False
    
    If *Client\Logged_In = 0 And *Client\Disconnect_Time = 0 And Cpe <> 66
        Client_Login(*Client\ID, Trim(PlayerName), Mppass, ClientVersion)
    ElseIf Cpe = 66 And *Client\Logged_In = 0 And *Client\Disconnect_Time = 0
        ;CPE Enabled Client
        CPE_Send_ExtInfo(*Client\ID, Trim(PlayerName), Mppass, ClientVersion)
        Log_Add("Network","CPE Client Detected", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    EndIf
EndProcedure

Procedure HandlePing(*Client.Network_Client)
    Network_Client_Input_Add_Offset(*Client, 1)
    *Client\Ping = Milliseconds() - *Client\Ping_Sent_Time
EndProcedure

Procedure HandleBlockChange(*Client.Network_Client)
    Protected X.w, Y.w, Z.w, Mode.b, Type.b
    
    Network_Client_Input_Add_Offset(*Client, 1)
    X = ClientInputReadShort(*Client)
    Z = ClientInputReadShort(*Client)
    Y = ClientInputReadShort(*Client)
    ; X = Network_Client_Input_Read_Byte(*Client) * 256
    ; X + (Network_Client_Input_Read_Byte(*Client) & 255)
    ;  Z = Network_Client_Input_Read_Byte(*Client) * 256
    ;  Z + (Network_Client_Input_Read_Byte(*Client) & 255)
    ;  Y = Network_Client_Input_Read_Byte(*Client) * 256
    ;  Y + (Network_Client_Input_Read_Byte(*Client) & 255)
    Mode = (Network_Client_Input_Read_Byte(*Client) & 255)
    Type = (Network_Client_Input_Read_Byte(*Client) & 255)
    
    
    If Not *Client\Logged_In Or Not *Client\Player\Entity
        ProcedureReturn
    EndIf
    
    If *Client\Player\Entity\Map_ID = *Client\Player\Map_ID
        Build_Mode_Distribute(*Client\ID, -1, X, Y, Z, Mode, Type)
    EndIf
EndProcedure

Procedure HandlePlayerTeleport(*Client.Network_Client)
    Protected X.w, Y.W, Z.w, R.w, L.w
    
    If *Client\HeldBlock = #True
        Network_Client_Input_Add_Offset(*Client, 1)
        
        If *Client\Player\Entity
            *Client\Player\Entity\Held_Block = Network_Client_Input_Read_Byte(*Client) ; Update the CPE Held_Block for this client.
        Else
            Network_Client_Input_Add_Offset(*Client, 1)
        EndIf
        
    Else
        Network_Client_Input_Add_Offset(*Client, 2)
    EndIf
    
    X = ClientInputReadShort(*Client)
    Z = ClientInputReadShort(*Client)
    Y = ClientInputReadShort(*Client)
    R = Network_Client_Input_Read_Byte(*Client)
    L = Network_Client_Input_Read_Byte(*Client)
    
    ;     *Temp_Buffer = AllocateMemory(8)
    ;     
    ;     If *Temp_Buffer
    ;         Network_Client_Input_Read_Buffer(*Client, *Temp_Buffer, 8)
    ;         X = PeekB(*Temp_Buffer)* 256
    ;         X + PeekB(*Temp_Buffer+1)& 255
    ;         Z = PeekB(*Temp_Buffer+2)* 256
    ;         Z + PeekB(*Temp_Buffer+3)& 255
    ;         Y = PeekB(*Temp_Buffer+4)* 256
    ;         Y + PeekB(*Temp_Buffer+5)& 255
    ;         R = PeekB(*Temp_Buffer+6)
    ;         L = PeekB(*Temp_Buffer+7)
    ;     EndIf
    ;     
    ;     FreeMemory(*Temp_Buffer)
    
    If Not *Client\Logged_In Or Not *Client\Player\Entity
        ProcedureReturn
    EndIf
    
    If *Client\Player\Entity\Map_ID = *Client\Player\Map_ID
        Entity_Position_Set(*Client\Player\Entity\ID, *Client\Player\Entity\Map_ID, X/32, Y/32, (Z-51)/32, R * 360 / 256, L * 360 / 256, 1, 0)
    EndIf
EndProcedure

Procedure HandleChatPacket(*Client.Network_Client)
    Protected Text.s, PlayerId.b
    Network_Client_Input_Add_Offset(*Client, 1)
    
    playerId = Network_Client_Input_Read_Byte(*Client)
    Text = Trim(Network_Client_Input_Read_String(*Client, 64))
    
    If *Client\Logged_In = 1
        If *Client\Player\Entity
            HandleIncomingChat(Text, playerId)
        EndIf
    EndIf
EndProcedure

Procedure HandleExtInfo(*Client.Network_Client)
    Protected AppName.s, Extensions.w
    Network_Client_Input_Add_Offset(*Client, 1)
    
    AppName = Trim(Network_Client_Input_Read_String(*Client, 64))
    Extensions = ClientInputReadShort(*Client)
    
    *Client\CPE = #True
    *Client\CustomExtensions = Extensions
    
    If Extensions = 0
        CPE_Send_Extensions(*Client)
        
        If *Client\TextHotkey = #True
            CPE_Client_Send_Hotkeys(*Client)
        EndIf
    EndIf
    
    Log_Add("CPE","Client supports " + Str(Extensions) + " extensions", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
EndProcedure

Procedure HandleExtEntry(*Client.Network_Client)
    Protected ExtName.s, ExtVersion.l
    Network_Client_Input_Add_Offset(*Client, 1)
    
    ExtName = Trim(Network_Client_Input_Read_String(*Client, 64))
    ExtVersion = ClientInputReadInt(*Client)
;     *Temp_Buffer = AllocateMemory(4) ; Read extVersion.
;     
;     If *Temp_Buffer
;         Network_Client_Input_Read_Buffer(*Client, *Temp_Buffer, 4)
;         extVersion = Endian(PeekL(*Temp_Buffer))
;     EndIf
;     
;     FreeMemory(*Temp_Buffer)
    
    AddElement(*Client\Extensions())
    *Client\Extensions() = ExtName
    
    AddElement(*Client\ExtensionVersions())
    *Client\ExtensionVersions() = extVersion
    
    Select LCase(ExtName)
        Case "customblocks"
            *Client\CustomBlocks = #True  
        Case "heldblock"
            *Client\HeldBlock = #True  
        Case "clickdistance"
            *Client\ClickDistance = #True
        Case "selectioncuboid"
            *Client\SelectionCuboid = #True
        Case "extplayerlist"
            *Client\ExtPlayerList = #True
        Case "changemodel"
            *Client\ChangeModel = #True
        Case "envweathertype"
            *Client\CPEWeather = #True
        Case "envcolors"
            *Client\EnvColors = #True  
        Case "messagetypes"
            *Client\MessageTypes = #True
        Case "blockpermissions"
            *Client\BlockPermissions = #True
        Case "envmapappearance"
            *Client\EnvMapAppearance = #True
        Case "hackcontrol"
            *Client\HackControl = #True
        Case "texthotkey"
            *Client\TextHotkey = #True
        Case "emotefix"
            *Client\EmoteFix = #True
        Case "longermessages"
            *Client\LongerMessages = #True
    EndSelect
    
    *Client\CustomExtensions - 1
    
    If *Client\CustomExtensions = 0
        CPE_Send_Extensions(*Client\ID)
        
        If *Client\TextHotkey = #True
            CPE_Client_Send_Hotkeys(*Client\ID)
        EndIf
        
    EndIf
EndProcedure

Procedure HandleCustomBlockSupportLevel(*Client.Network_Client)
    ;Client just confirming it supports CustomBlocks.
    Network_Client_Input_Add_Offset(*Client, 1)
    Level = Network_Client_Input_Read_Byte(*Client)
    
    *Client\CustomBlocks_Level = Level
    *Client\CustomBlocks = #True
    
    Log_Add("CPE","CPE Process Complete.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    Client_Login(*Client\ID, *Client\Player\Login_Name, *Client\Player\MPPass, *Client\Player\Client_Version)    
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 225
; FirstLine = 177
; Folding = --
; EnableUnicode
; EnableXP