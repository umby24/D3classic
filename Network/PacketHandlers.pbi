; D3 Server - Packet Handlers
; - This file contains methods for handling incoming packets from clients.
; - By umby24

Procedure HandleHandshake(*Client.Network_Client)
    Protected ClientVersion.b, PlayerName.s, Mppass.s, Cpe.b
    
    InputAddOffset(*Client, 1)
    ClientVersion = ClientInputReadByte(*Client)
    PlayerName = ClientInputReadString(*Client, 64)
    Mppass = ClientInputReadString(*Client, 64)
    Cpe = ClientInputReadByte(*Client)
    
    *Client\CPE = #False ; Set this to false until properly negotiated.
    *Client\CustomBlocks_Level = 0
    
    If *Client\Logged_In = 0 And *Client\Disconnect_Time = 0 And Cpe <> 66
        Client_Login(*Client\ID, Trim(PlayerName), Mppass, ClientVersion)
    ElseIf Cpe = 66 And *Client\Logged_In = 0 And *Client\Disconnect_Time = 0
        ;CPE Enabled Client
        CPE_Send_ExtInfo(*Client\ID, Trim(PlayerName), Mppass, ClientVersion)
        Log_Add("Network","CPE Client Detected", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    EndIf
EndProcedure

Procedure HandlePing(*Client.Network_Client)
    InputAddOffset(*Client, 1)
    *Client\Ping = Milliseconds() - *Client\Ping_Sent_Time
EndProcedure

Procedure HandleBlockChange(*Client.Network_Client)
    Protected X.w, Y.w, Z.w, Mode.b, Type.b
    
    InputAddOffset(*Client, 1)
    X = ClientInputReadShort(*Client)
    Z = ClientInputReadShort(*Client)
    Y = ClientInputReadShort(*Client)
    Mode = (ClientInputReadByte(*Client) & 255)
    Type = (ClientInputReadByte(*Client) & 255)
    
    
    If Not *Client\Logged_In Or Not *Client\Player\Entity
        ProcedureReturn
    EndIf
    
    If *Client\Player\Entity\Map_ID = *Client\Player\Map_ID
        Build_Mode_Distribute(*Client\ID, -1, X, Y, Z, Mode, Type)
    EndIf
EndProcedure

Procedure HandlePlayerTeleport(*Client.Network_Client)
    Protected X.w, Y.W, Z.w, R.w, L.w
    
    If CPE_GetClientExtVersion("heldblock") = 1
        InputAddOffset(*Client, 1)
        
        If *Client\Player\Entity
            *Client\Player\Entity\Held_Block = ClientInputReadByte(*Client) ; Update the CPE Held_Block for this client.
        Else
            InputAddOffset(*Client, 1)
        EndIf
        
    Else
        InputAddOffset(*Client, 2)
    EndIf
    
    X = ClientInputReadShort(*Client)
    Z = ClientInputReadShort(*Client)
    Y = ClientInputReadShort(*Client)
    R = ClientInputReadByte(*Client)
    L = ClientInputReadByte(*Client)
    
    If Not *Client\Logged_In Or Not *Client\Player\Entity
        ProcedureReturn
    EndIf
    
    If *Client\Player\Entity\Map_ID = *Client\Player\Map_ID
        Entity_Position_Set(*Client\Player\Entity\ID, *Client\Player\Entity\Map_ID, X/32, Y/32, (Z-51)/32, R * 360 / 256, L * 360 / 256, 1, 0)
    EndIf
EndProcedure

Procedure HandleChatPacket(*Client.Network_Client)
    Protected Text.s, PlayerId.b
    InputAddOffset(*Client, 1)
    
    playerId = ClientInputReadByte(*Client)
    Text = Trim(ClientInputReadString(*Client, 64))
    
    If *Client\Logged_In = 1
        If *Client\Player\Entity
            HandleIncomingChat(Text, playerId)
        EndIf
    EndIf
EndProcedure

Procedure HandleExtInfo(*Client.Network_Client)
    Protected AppName.s, Extensions.w
    InputAddOffset(*Client, 1)
    
    AppName = Trim(ClientInputReadString(*Client, 64))
    Extensions = ClientInputReadShort(*Client)
    
    *Client\CPE = #True
    *Client\CustomExtensions = Extensions
    
    If Extensions = 0
        CPE_Send_Extensions(*Client)
        
        If CPE_GetClientExtVersion("texthotkey") = 1
            CPE_Client_Send_Hotkeys(*Client)
        EndIf
    EndIf
    
    Log_Add("CPE","Client supports " + Str(Extensions) + " extensions", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
EndProcedure

Procedure HandleExtEntry(*Client.Network_Client)
    Protected ExtName.s, ExtVersion.l
    InputAddOffset(*Client, 1)
    
    ExtName = Trim(ClientInputReadString(*Client, 64))
    ExtVersion = ClientInputReadInt(*Client)
    
    AddMapElement(Network_Client()\Extensions(), LCase(ExtName))
    Network_Client()\Extensions() = ExtVersion
    
    *Client\CustomExtensions - 1
    
    If *Client\CustomExtensions = 0
        CPE_Send_Extensions(*Client\ID)
        
        If CPE_GetClientExtVersion("texthotkey") = 1
            CPE_Client_Send_Hotkeys(*Client\ID)
        EndIf
    EndIf
EndProcedure

Procedure HandleCustomBlockSupportLevel(*Client.Network_Client)
    ;Client just confirming it supports CustomBlocks.
    InputAddOffset(*Client, 1)
    Level = ClientInputReadByte(*Client)
    
    *Client\CustomBlocks_Level = Level
    
    Log_Add("CPE","CPE Process Complete.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    Client_Login(*Client\ID, *Client\Player\Login_Name, *Client\Player\MPPass, *Client\Player\Client_Version)    
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 142
; FirstLine = 97
; Folding = --
; EnableUnicode
; EnableXP