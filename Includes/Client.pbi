;Done
; ########################################## Variablen ##########################################

Structure Client_Main
  Login_Thread_ID.i               ; ID of the login thread.
EndStructure

Global Client_Main.Client_Main

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure Client_Login(Client_ID, Name.s, MPPass.s, Version) ; A new player has logged in, everything important is created.
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    
    Network_Client()\Player\Login_Name = Name
    Network_Client()\Player\MPPass = MPPass
    Network_Client()\Player\Client_Version = Version
    
    Pre_Login_Correct = 1
    
    If Version <> 7
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Unknown Client-Version [Field_0] (IP=[Field_0], Name='[Field_1]')", Str(Version), Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Unknown Client-Version"), 1)
    ElseIf String_IV(Trim(Name)) = #True
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Invalid name (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Invalid name"), 1)
    ElseIf Network_Client()\Player\Login_Name = ""
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Invalid name (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Invalid name"), 1)
    ElseIf Player_Main\Name_Verification And Network_Client()\IP <> "127.0.0.1" And Plugin_Event_Client_Verify_Name(Network_Client()\Player\Login_Name, Network_Client()\Player\MPPass) = #False
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Name-Verification (MPPass=[Field_0], IP=[Field_1], Name='[Field_2]')", Trim(MPPass), Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Name-Verification"), 1)
    ElseIf Network_Client_Count() > Player_Main\Players_Max
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Server is full (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Server is full"), 1)
    ElseIf Map_Select_ID(Player_Main\Spawn_Map_ID) = #False
      Pre_Login_Correct = 0
      Log_Add("Client", Lang_Get("", "Login failed: Spawnmap invalid (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Spawnmap invalid"), 1)
    EndIf
    
    If Pre_Login_Correct = 1
      
      ; ###### If not present in the playerDB, add.
      If Player_List_Select(Network_Client()\Player\Login_Name, 0) = #False
        Player_List_Add(Network_Client()\Player\Login_Name)
      EndIf
      
      If Player_List_Select(Network_Client()\Player\Login_Name)
        Login_Correct = 1
        
        If Player_List()\Banned
          Login_Correct = 0
          Log_Add("Client", Lang_Get("", "Login failed: Player is banned (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: You are banned"), 1)
        EndIf
        
        If Login_Correct = 1
          Player_List()\Online = 1
          Player_List()\Counter_Login + 1
          Player_List()\IP = Network_Client()\IP
          Network_Client()\GlobalChat = Player_List()\GlobalChat
          
          If Map_Select_ID(Player_Main\Spawn_Map_ID) = #True
            
            If Entity_Add(Name, Player_Main\Spawn_Map_ID, Map_Data()\Spawn_X, Map_Data()\Spawn_Y, Map_Data()\Spawn_Z, Map_Data()\Spawn_Rot, Map_Data()\Spawn_Look) <> -1
              
              Player_Number = Player_List()\Number
              Entity_Displayname_Set(Entity()\ID, Player_Get_Prefix(Player_Number), Player_Get_Name(Player_Number), Player_Get_Suffix(Player_Number))
              
              Entity()\Build_Material = -1
              Entity()\Player_List = Player_List()
              Network_Client()\Player\Entity = Entity()
              
              Network_Client()\Player\Map_ID = -1
              Network_Client()\Logged_In = 1
              
              Log_Add("Client", Lang_Get("", "Player logged in (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Network_Client()\Player\Login_Name), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
              
              System_Message_Network_Send_2_All(-1, Lang_Get("", "Ingame: Player '[Field_0]<c>' logged in", Entity_Displayname_Get(Entity()\ID)))
              System_Message_Network_Send(Client_ID, Player_Main\Message_Welcome)
              
              Entity()\Model = "default"
              Map_Data()\Clients + 1
              
              Plugin_Event_Client_Login(Network_Client())
              
              ;CPE ExtPlayerList time.
              
              tempClient = Network_Client()\ID
              loginName.s = Network_Client()\Player\Login_Name
              namePrefix.s = Network_Client()\Player\Entity\Prefix
              nameSuffix.s = Network_Client()\Player\Entity\Suffix
              mapName.s = Map_Data()\Name
              CPE = Network_Client()\ExtPlayerList
              tempID = FreeID
              Network_Client()\Player\NameID = FreeID
              
              If (FreeID <> NextID)
                FreeID = NextID  
              Else
                FreeID = FreeID + 1
                NextID = FreeID
              EndIf
              
              ForEach Network_Client()
                ;Send the new player to everyone..
                If Network_Client()\ID <> tempClient ;If it is not the new player..
                  If Network_Client()\ExtPlayerList = #True
                    Network_Client_Output_Write_Byte(Network_Client()\ID, 22) ; - Send the new player's information to the client
                    Network_Client_Output_Write_Word(Network_Client()\ID, tempID)
                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(loginName,64," "),64)
                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(namePrefix + loginName + nameSuffix, 64, " "),64)
                    Network_Client_Output_Write_String(Network_Client()\ID, LSet(mapName, 64, " "), 64)
                    Network_Client_Output_Write_Byte(Network_Client()\ID, 0)
                  EndIf
                  
                  If CPE = #True
                    Map_Select_ID(Network_Client()\Player\Map_ID)
                    Network_Client_Output_Write_Byte(tempClient, 22) ; - And send the new player the client's information.
                    Network_Client_Output_Write_Word(tempClient, Network_Client()\Player\NameID)
                    Network_Client_Output_Write_String(tempClient, LSet(Network_Client()\Player\Login_Name,64," "),64)
                    Network_Client_Output_Write_String(tempClient, LSet(Network_Client()\Player\Entity\Prefix + Network_Client()\Player\Login_Name + Network_Client()\Player\Entity\Suffix, 64, " "), 64)
                    Network_Client_Output_Write_String(tempClient, LSet(Map_Data()\Name, 64, " "),64)
                    Network_Client_Output_Write_Byte(tempClient, 0)    
                  EndIf
                Else
                  If CPE = #True
                    Network_Client_Output_Write_Byte(tempClient, 22)
                    Network_Client_Output_Write_Word(tempClient, tempID)
                    Network_Client_Output_Write_String(tempClient, LSet(loginName,64," "),64)
                    Network_Client_Output_Write_String(tempClient, LSet(namePrefix + loginName + nameSuffix, 64, " "), 64)
                    Network_Client_Output_Write_String(tempClient, LSet(mapName, 64, " "),64)
                    Network_Client_Output_Write_Byte(tempClient, 0)   
                  EndIf
                EndIf
              Next
              ;##########################################
              
              Player_List()\Save = 1
              Player_List_Main\Save_File = 1
              
            Else
              Log_Add("Client", Lang_Get("", "Login failed: Spawnmap is full (IP=[Field_0], Name='[Field_1]')", Network_Client()\IP, Name), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
              Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Spawnmap is full"), 1)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Client_Logout(Client_ID, Message.s, Show_2_All) ; Player has logged out, everything important is sent out and done.
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    If Player_List_Select(Network_Client()\Player\Login_Name)
      If Rank_Select(Player_List()\Rank)
        Player_List()\Online = Player_Get_Online(Player_List()\Number, Client_ID)
        
        Plugin_Event_Client_Logout(Network_Client())
        
        Log_Add("Client", Lang_Get("", "Player logged out (IP=[Field_0], Name='[Field_1]', Message='[Field_2]')", Network_Client()\IP, Network_Client()\Player\Login_Name, Message), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        
        
        If Network_Client()\Player\Entity
         loginName = Network_Client()\Player\NameID
         FreeID = loginName
         
         PushListPosition(Network_Client())
         ForEach Network_Client()
           If Network_Client()\ExtPlayerList = #True
             Network_Client_Output_Write_Byte(Network_Client()\ID, 24)
             Network_Client_Output_Write_Word(Network_Client()\ID, loginName)
           EndIf
         Next
         PopListPosition(Network_Client())
         
         If Map_Select_ID(Network_Client()\Player\Map_ID)
           Map_Data()\Clients - 1
         EndIf
         
          If Show_2_All And Network_Client()\Player\Logout_Hide = 0
            System_Message_Network_Send_2_All(-1, Lang_Get("", "Ingame: Player '[Field_0]<c>' logged out ([Field_1])", Entity_Displayname_Get(Network_Client()\Player\Entity\ID), Message))
          EndIf
          
          Entity_Delete(Network_Client()\Player\Entity\ID)
        EndIf
        
        Player_List()\Save = 1
        Player_List_Main\Save_File = 1
        
      EndIf
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Client_Login_Thread(*Dummy) ; In this thread, all logins are processed sequentially.
  Repeat
    
    LockMutex(Main\Mutex)
    
    Watchdog_Watch("Client_Login", "Begin Thread-Slope", 0)
    
    ForEach Network_Client()
      If Network_Client()\Logged_In And Network_Client()\Player\Entity
        If Network_Client()\Player\Map_ID <> Network_Client()\Player\Entity\Map_ID
          
          If Network_Client()\Player\Entity\Player_List
            Rank = Network_Client()\Player\Entity\Player_List\Rank
          Else
            Rank = 0
          EndIf
          
          If Map_Get_MOTD_Override(Network_Client()\Player\Entity\Map_ID)
            MOTD.s = Map_Get_MOTD_Override(Network_Client()\Player\Entity\Map_ID)
          Else
            MOTD.s = System_Main\MOTD
          EndIf
          
          Client_ID = Network_Client()\ID
          
          Entity_Map_ID = Network_Client()\Player\Entity\Map_ID
          Entity_X.f = Network_Client()\Player\Entity\X
          Entity_Y.f = Network_Client()\Player\Entity\Y
          Entity_Z.f = Network_Client()\Player\Entity\Z
          Entity_Rotation.f = Network_Client()\Player\Entity\Rotation
          Entity_Look.f = Network_Client()\Player\Entity\Look
          
          System_Login_Screen(Client_ID, System_Main\Server_Name, MOTD, Rank_Get_On_Client(Rank))
          
          ; ############# Mutex is unlocked
          Map_Send(Client_ID, Entity_Map_ID)
          ; ############# Mutex is locked
          
          If Network_Client_Select(Client_ID)
            ; ############### Send map spawn
            Network_Out_Entity_Position(Client_ID, 255, Entity_X, Entity_Y, Entity_Z, Entity_Rotation, Entity_Look)
            ; ############### Entity locations
            ForEach Network_Client()\Player\Entities()
              ID_Client = Network_Client()\Player\Entities()\ID_Client
              Network_Out_Entity_Delete(Network_Client()\ID, ID_Client)
              DeleteElement(Network_Client()\Player\Entities())
            Next
            ; ############### Map is now sent, change client map.
            Network_Client()\Player\Map_ID = Entity_Map_ID
          EndIf
        EndIf
      EndIf
    Next
    
    UnlockMutex(Main\Mutex)
    
    Watchdog_Watch("Client_Login", "End Thread-Slope", 2)
    
    Delay(100)
    
  ForEver
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 126
; FirstLine = 109
; Folding = -
; EnableXP
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0