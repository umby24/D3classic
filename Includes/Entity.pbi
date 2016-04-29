
; ########################################## Konstanten ##########################################

; ########################################## Variablen ###########################################

Structure Entity_Main
    Timer_Send.l                    ; Timer für das Senden der Entities (Pos, Löschen, Erstellen)
    Timer_Check_Pos.l               ; Timer für das Überprüfen der Position
EndStructure
Global Entity_Main.Entity_Main

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Imports #############################################

; ########################################## Macros ##############################################

; ########################################## Initkram ############################################

; ########################################## Proceduren ##########################################

Procedure Entity_Select_ID(ID, Log=1)
    If ListIndex(Entity()) <> -1 And Entity()\ID = ID
        ProcedureReturn #True
    Else
        ForEach Entity()
            If Entity()\ID = ID
                ProcedureReturn #True
            EndIf
        Next
    EndIf
    
    If Log
        Log_Add("Entity", Lang_Get("", "Can't find Entity()\ID = [Field_0]", Str(ID)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    EndIf
    ProcedureReturn #False
EndProcedure

Procedure Entity_Select_Name(Name.s, Log=1)
    If ListIndex(Entity()) <> -1 And LCase(Entity()\Name) = LCase(Name)
        ProcedureReturn #True
    Else
        ForEach Entity()
            If LCase(Entity()\Name) = LCase(Name)
                ProcedureReturn #True
            EndIf
        Next
    EndIf
    
    If Log
        Log_Add("Entity", Lang_Get("", "Can't find Entity()\Name = [Field_0]", Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    EndIf
    ProcedureReturn #False
EndProcedure

Procedure Entity_Get_Pointer(ID)
    List_Store(*Pointer, Entity())
    If ListIndex(Entity()) <> -1 And Entity()\ID = ID
        ProcedureReturn Entity()
    Else
        ForEach Entity()
            If Entity()\ID = ID
                *Result = Entity()
                List_Restore(*Pointer, Entity())
                ProcedureReturn *Result
            EndIf
        Next
    EndIf
    
    Log_Add("Entity", Lang_Get("", "Can't find Entity()\ID = [Field_0]", Str(ID)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    List_Restore(*Pointer, Entity())
    ProcedureReturn 0
EndProcedure

Procedure Entity_Get_Free_ID()
    List_Store(*Pointer, Entity())
    ID = 0
    Repeat
        Found = 0
        ForEach Entity()
            If ID = Entity()\ID
                Found = 1
                Break
            EndIf
        Next
        If Found = 0
            List_Restore(*Pointer, Entity())
            ProcedureReturn ID
        Else
            ID + 1
        EndIf
    ForEver
    
    Log_Add("Entity", Lang_Get("", "No free Entity()\ID"), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    List_Restore(*Pointer, Entity())
    ProcedureReturn -1
EndProcedure

Procedure Entity_Get_Free_ID_Client(Map_ID)
    List_Store(*Pointer, Entity())
    For ID = 0 To 127
        Found = 0
        ForEach Entity()
            If ID = Entity()\ID_Client And Map_ID = Entity()\Map_ID
                Found = 1
                Break
            EndIf
        Next
        If Found = 0
            List_Restore(*Pointer, Entity())
            ProcedureReturn ID
        EndIf
    Next
    
    Log_Add("Entity", Lang_Get("", "No free Entity()\ID_Client"), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    List_Restore(*Pointer, Entity())
    ProcedureReturn -1
EndProcedure

;-

Procedure Entity_Add(Name.s, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f)
    ID = Entity_Get_Free_ID()
    ID_Client = Entity_Get_Free_ID_Client(Map_ID)
    
    If ID <> -1 And ID_Client <> -1
        
        AddElement(Entity())
        Entity()\Prefix = ""
        Entity()\Name = Name
        Entity()\Suffix = ""
        Entity()\ID = ID
        Entity()\ID_Client = ID_Client
        Entity()\Map_ID = Map_ID
        Entity()\X = X
        Entity()\Y = Y
        Entity()\Z = Z
        Entity()\Rotation = Rotation
        Entity()\Look = Look
        Entity()\Build_Mode = "Normal"
        
        Plugin_Event_Entity_Add(Entity())
        
        ProcedureReturn ID
    EndIf
    
    ProcedureReturn -1
EndProcedure

Procedure Entity_Delete(ID)
    If Entity_Select_ID(ID)
        
        Plugin_Event_Entity_Add(Entity())
        
        ; ############# Pointer zu dem Element löschen
        ForEach Network_Client()
            If Network_Client()\Player\Entity = Entity()
                Network_Client()\Player\Entity = 0
            EndIf
        Next
        
        ; ############# Element löschen
        DeleteElement(Entity())
    EndIf
EndProcedure

Procedure Entity_Resend(ID)
    If Entity_Select_ID(ID)
        Entity()\Resend = 1
    EndIf
EndProcedure

Procedure Entity_Message_2_Clients(ID, Message.s) ; Sendet eine Nachricht zu den Mutterklienten
    List_Store(*Pointer, Network_Client())
    
    ForEach Network_Client()
        If Network_Client()\Player\Entity
            If Network_Client()\Player\Entity\ID = ID
                System_Message_Network_Send(Network_Client()\ID, Message)
            EndIf
        EndIf
    Next
    
    List_Restore(*Pointer, Network_Client())
EndProcedure

Threaded Entity_Displayname_Get_Return_String.s = ""
Procedure.s Entity_Displayname_Get(ID)
    
    List_Store(*Pointer, Entity())
    If Entity_Select_ID(ID)
        Entity_Displayname_Get_Return_String = Entity()\Prefix + Entity()\Name + Entity()\Suffix
        List_Restore(*Pointer, Entity())
        ProcedureReturn Entity_Displayname_Get_Return_String
    EndIf
    List_Restore(*Pointer, Entity())
EndProcedure

Procedure Entity_Displayname_Set(ID, Prefix.s, Name.s, Suffix.s)
    List_Store(*Pointer, Entity())
    If Entity_Select_ID(ID)
        Entity()\Prefix = Prefix
        Entity()\Name = Name
        Entity()\Suffix = Suffix
        Entity_Resend(ID)
    EndIf
    List_Restore(*Pointer, Entity())
EndProcedure

Procedure Entity_Kill(ID)
    List_Store(*Pointer, Entity())
    If Entity_Select_ID(ID)
        Map_ID = Entity()\Map_ID
        If Map_Select_ID(Map_ID)
            
            If Plugin_Event_Entity_Die(Entity())
                
                If Entity()\Time_Message_Death < Milliseconds()
                    Entity()\Time_Message_Death = Milliseconds() + 2000
                    System_Message_Network_Send_2_All(Map_ID, Lang_Get("", "Ingame: [Field_0] Died", Entity()\Name))
                EndIf
                
                X.f = Map_Data()\Spawn_X
                Y.f = Map_Data()\Spawn_Y
                Z.f = Map_Data()\Spawn_Z
                Rotation.f = Map_Data()\Spawn_Rot
                Look.f = Map_Data()\Spawn_Look
                Entity_Position_Set(ID, Map_ID, X, Y, Z, Rotation, Look, 5, 1)
                
            EndIf
            
        EndIf
    EndIf
    List_Restore(*Pointer, Entity())
EndProcedure

Procedure Entity_Position_Check(ID) ; Prüft, ob dieses Entity den Block betreten darf/ ob er tötlich ist ... und Teleporter
    List_Store(*Pointer, Entity())
    If Entity_Select_ID(ID)
        Map_ID = Entity()\Map_ID
        X = Round(Entity()\X, #PB_Round_Down)
        Y = Round(Entity()\Y, #PB_Round_Down)
        Z = Round(Entity()\Z, #PB_Round_Down)
        
        If Map_Select_ID(Map_ID)
            ForEach Map_Data()\Teleporter()
                If X >= Map_Data()\Teleporter()\X_0 And X <= Map_Data()\Teleporter()\X_1 And Y >= Map_Data()\Teleporter()\Y_0 And Y <= Map_Data()\Teleporter()\Y_1 And Z >= Map_Data()\Teleporter()\Z_0 And Z <= Map_Data()\Teleporter()\Z_1
                    Dest_Map_Unique_ID.s = Map_Data()\Teleporter()\Dest_Map_Unique_ID
                    Dest_Map_ID = Map_Data()\Teleporter()\Dest_Map_ID
                    Dest_X.f = Map_Data()\Teleporter()\Dest_X
                    Dest_Y.f = Map_Data()\Teleporter()\Dest_Y
                    Dest_Z.f = Map_Data()\Teleporter()\Dest_Z
                    Dest_Rot.f = Map_Data()\Teleporter()\Dest_Rot
                    Dest_Look.f = Map_Data()\Teleporter()\Dest_Look
                    
                    If Dest_Map_Unique_ID And Map_Select_Unique_ID(Dest_Map_Unique_ID, 0)
                        If Dest_X = -1 And Dest_Y = -1 And Dest_Z = -1
                            Dest_X = Map_Data()\Spawn_X
                            Dest_Y = Map_Data()\Spawn_Y
                            Dest_Z = Map_Data()\Spawn_Z
                            Dest_Rot = Map_Data()\Spawn_Rot
                            Dest_Look = Map_Data()\Spawn_Look
                        EndIf
                        Entity_Position_Set(ID, Map_Data()\ID, Dest_X, Dest_Y, Dest_Z, Dest_Rot, Dest_Look, 10, 1)
                    ElseIf Dest_Map_ID <> -1 And Map_Select_ID(Dest_Map_ID, 0)
                        If Dest_X = -1 And Dest_Y = -1 And Dest_Z = -1
                            Dest_X = Map_Data()\Spawn_X
                            Dest_Y = Map_Data()\Spawn_Y
                            Dest_Z = Map_Data()\Spawn_Z
                            Dest_Rot = Map_Data()\Spawn_Rot
                            Dest_Look = Map_Data()\Spawn_Look
                        EndIf
                        Entity_Position_Set(ID, Map_Data()\ID, Dest_X, Dest_Y, Dest_Z, Dest_Rot, Dest_Look, 10, 1)
                    EndIf
                    Break
                EndIf
            Next
        Else ; ###### Wenn aktuelle Karte nicht vorhanden
            If FirstElement(Map_Data())
                Entity_Position_Set(ID, Map_Data()\ID, Map_Data()\Spawn_X, Map_Data()\Spawn_Y, Map_Data()\Spawn_Z, Map_Data()\Spawn_Rot, Map_Data()\Spawn_Look, 255, 1)
            EndIf
        EndIf
        
        If Map_Select_ID(Map_ID)
            For i = 0 To 1
                Type = Map_Block_Get_Type(Map_Data(), X, Y, Z+i)
                If Type >= 0 And Type <= 255
                    If Block(Type)\Killer
                        Entity_Kill(ID)
                    EndIf
                EndIf
            Next
        EndIf
    EndIf
    List_Restore(*Pointer, Entity())
EndProcedure

Procedure Entity_Position_Set(ID, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
    If Entity_Select_ID(ID)
        If Entity()\Send_Pos <= Priority
            
            If Plugin_Event_Entity_Position_Set(Entity(), Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
                
                If Entity()\Map_ID <> Map_ID ; ############## When switching maps, then: New ID_Client, send texts, check rank
                    If Map_Select_ID(Map_ID)
                        If Entity()\Player_List = 0 Or Entity()\Player_List\Rank >= Map_Data()\Rank_Join
                            System_Message_Network_Send_2_All(Entity()\Map_ID, Lang_Get("", "Ingame: Entity '[Field_0]' changes to map '[Field_1]'", Entity_Displayname_Get(ID), Map_Data()\Name))
                            System_Message_Network_Send_2_All(Map_ID, Lang_Get("", "Ingame: Entity '[Field_0]' joins map '[Field_1]'", Entity_Displayname_Get(ID), Map_Data()\Name))
                            
                            Map_Data()\Clients + 1
                            
                            Old_Map_ID = Entity()\Map_ID
                            
                            PushListPosition(Map_Data())
                            Map_Select_ID(Old_Map_ID)
                            Map_Data()\Clients - 1
                            PopListPosition(Map_Data())
                            
                            Entity()\Map_ID = Map_ID
                            Entity()\X = X
                            Entity()\Y = Y
                            Entity()\Z = Z
                            Entity()\Rotation = Rotation
                            Entity()\Look = Look
                            Entity()\ID_Client = Entity_Get_Free_ID_Client(Map_ID)
                            
                            
                            ;CPEEEEE
                            NameID.w = 0
                            PlayerName.s = Entity()\Name
                            ListName.s = Entity()\Prefix + Entity()\Name + Entity()\Suffix
                            
                            ForEach Network_Client()
                                If Network_Client()\Logged_In = #True
                                    If Network_Client()\Player\Entity\ID = ID
                                        NameID = Network_Client()\Player\NameID
                                        ;Map change event!
                                        Plugin_Event_Entity_Map_Change(Network_Client()\ID, Map_ID, Old_Map_ID)
                                        Break
                                    EndIf
                                EndIf
                            Next
                            
                            Map_Select_ID(Entity()\Map_ID)
                            
                            ForEach Network_Client()
                                If Network_Client()\ExtPlayerList = #True
                                    Network_Client_Output_Write_Byte(Network_Client()\ID, 24)
                                    Network_Client_Output_Write_Word(Network_Client()\ID, NameID)
                                    
                                    Network_Client_Output_Write_Byte(Network_Client()\ID, 22)
                                    Network_Client_Output_Write_Word(Network_Client()\ID, NameID)
                                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(PlayerName,64," "),64)
                                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(ListName, 64, " "), 64)
                                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(Map_Data()\Name, 64, " "),64)
                                    Network_Client_Output_Write_Byte(Network_Client()\ID, 0)      
                                EndIf
                            Next
                            
                            ProcedureReturn #True
                        Else
                            Entity_Message_2_Clients(ID, Lang_Get("", "Ingame: You are not allowed to join map '[Field_0]'", Map_Data()\Name))
                            ProcedureReturn #False
                        EndIf
                    Else
                        Entity_Message_2_Clients(ID, Lang_Get("", "Ingame: Can't find Map"))
                        ProcedureReturn #False
                    EndIf
                Else
                    If Map_Select_ID(Entity()\Map_ID) ; ###### Wenn aktuelle Karte vorhanden
                        If Send_Own_Client Or Not Entity()\Send_Pos_Own
                            Entity()\X = X
                            Entity()\Y = Y
                            Entity()\Z = Z
                            Entity()\Rotation = Rotation
                            Entity()\Look = Look
                            Entity()\Send_Pos = Priority
                            
                            If Send_Own_Client
                                Entity()\Send_Pos_Own = #True
                            EndIf
                        EndIf
                        ProcedureReturn #True
                    Else
                        ProcedureReturn #False
                    EndIf
                EndIf
                
            Else ; When moving blocked, send old position to the client
                Entity()\Send_Pos_Own = #True
                ProcedureReturn #False
            EndIf
        EndIf
    EndIf
    
    ProcedureReturn #False
EndProcedure

;-

Procedure Entity_Send() ; Maintained moving, creating and deleting entities of the client
    
    ForEach Network_Client()
        If Not Network_Client()\Logged_In
            Continue
        EndIf
    
        ; ############### Entities löschen / Deleting Entities
        ForEach Network_Client()\Player\Entities() ; For Every entity the player can see (Entities() is a list)
            ID = Network_Client()\Player\Entities()\ID ; Get their ID, and their on-client ID.
            ID_Client = Network_Client()\Player\Entities()\ID_Client
            
            If Entity_Select_ID(ID, 0) ; Selects this entity in the global entities list
                Delete = 0
                ; ######## Wenn das Entity nicht auf der selben Karte ist / If the entity is not on the same map.
                If Entity()\Map_ID <> Network_Client()\Player\Map_ID
                    Delete = 1 ;Delete it from our client
                EndIf
                ; ######## Das Entitie von sich selbst löschen / Delete yourself, if you're spawned on your own client.
                If Network_Client()\Player\Entity
                    If Network_Client()\Player\Entity\ID = Entity()\ID
                        Delete = 1
                    EndIf
                EndIf
                ; ######## Wenn das Entity neu gesendet werden soll / If the entity is to be resent
                If Entity()\Resend
                    Entity()\Resend = 0
                    Delete = 1 ;Delete it, and resend it.
                EndIf
                
                If Delete ;If in any previous step, we decided to despawn this entity, then send it to the client.
                    Network_Out_Entity_Delete(Network_Client()\ID, ID_Client)
                    DeleteElement(Network_Client()\Player\Entities()) ; And remove the entity from our visible entities list.
                EndIf
            Else ; ##### Wenn Entity nicht mehr existiert / If the entity no longer exists in the global list
                Network_Out_Entity_Delete(Network_Client()\ID, ID_Client) ; Delete them from the client's list.
                DeleteElement(Network_Client()\Player\Entities())
            EndIf
        Next
        
        ; ############### Entities erstellen / Creating Entities
        ForEach Entity() ;Now, looping through the global entities list..
            If Entity()\Map_ID <> Network_Client()\Player\Map_ID ; If they're on the same map as us
                Continue
            EndIf
            
            ; ####### Wenn entity noch nicht vorhanden / If Entity does not exist
            Create = 1
            ForEach Network_Client()\Player\Entities() ;Search our entire list to see if we have it already
                If Network_Client()\Player\Entities()\ID = Entity()\ID
                    Create = 0 ; If so, Do not spawn the entity twice.
                    Break
                EndIf
            Next
            ; ####### Und wenn es nicht das Eigene ist! / And if it's not you!
            If Network_Client()\Player\Entity
                If Network_Client()\Player\Entity\ID = Entity()\ID
                    Create = 0
                EndIf
            EndIf
            
            If Create ; If we decided to spawn this entity on the client..
                AddElement(Network_Client()\Player\Entities()) ; Add it to our entities list
                Network_Client()\Player\Entities()\ID = Entity()\ID
                Network_Client()\Player\Entities()\ID_Client = Entity()\ID_Client
                Network_Out_Entity_Add(Network_Client()\ID, Entity()\ID_Client, Entity_Displayname_Get(Entity()\ID), Entity()\X, Entity()\Y, Entity()\Z, Entity()\Rotation, Entity()\Look)
                ; and spawn it on the client.
                CPE_Handle_Entity()
            EndIf
        Next
    Next
    
    ; ################ Entities bewegen / Entities move
    
    ForEach Entity() ; Loop through the entire global entities list *again*
        If Entity()\Send_Pos ; If they need their position sent
            Entity()\Send_Pos = 0 ; Set it to false so it doesn't get sent twice..
            ForEach Network_Client() ; For every client..
                If Network_Client()\Logged_In ; That is logged in
                    ForEach Network_Client()\Player\Entities() ; And can see this entity
                        If Network_Client()\Player\Entities()\ID = Entity()\ID
                            Network_Out_Entity_Position(Network_Client()\ID, Entity()\ID_Client, Entity()\X, Entity()\Y, Entity()\Z, Entity()\Rotation, Entity()\Look)
                            ; Update its location.
                            Break
                        EndIf
                    Next
                EndIf
            Next
        EndIf
        
        If Entity()\Send_Pos_Own ; If this entity needs to be sent its own position
            Entity()\Send_Pos_Own = 0 ; Don't do it twice..
            
            ForEach Network_Client() ; For every client..
                If Network_Client()\Logged_In And Network_Client()\Player\Entity = Entity() ; If the clients entity is this entity, send them their update.
                    Network_Out_Entity_Position(Network_Client()\ID, 255, Entity()\X, Entity()\Y, Entity()\Z, Entity()\Rotation, Entity()\Look)
                EndIf
            Next
        EndIf
    Next
    
EndProcedure

Procedure Entity_Main()
    ForEach Entity()
        Entity_Position_Check(Entity()\ID)
    Next
    
    Entity_Send()
EndProcedure

RegisterCore("Entity", 100, #Null, #Null, @Entity_Main())
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 472
; FirstLine = 429
; Folding = ---
; EnableXP
; DisableDebugger
; CompileSourceDirectory