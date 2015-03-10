#CPE_Extensions = 13

;-############## Macro
Procedure List_Contains(Value.b, List mList.b())
  PushListPosition(mList())
  Result = #False
  
  ResetList(mList())
  While NextElement(mList())
    If mList() = Value
      Result = #True
      Break
    EndIf
  Wend
  
  PopListPosition(mList())
  
  ProcedureReturn Result
EndProcedure

Procedure List_PopPosition(Value.b, List mList.b()) ; Sets the list position to the given element
  Result = #False
  
  ResetList(mList())
  While NextElement(mList())
    If mList() = Value
      Result = #True
      Break
    EndIf
  Wend
  
EndProcedure
;-##############

Declare CPE_Set_Env_Colors(Type.b, Red.w, Green.w, Blue.w)

Procedure CPE_Send_ExtInfo(Client_ID, Name.s, MPPass.s, Version)
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    Network_Client()\Player\Login_Name = Name ;Some required internal stuff :P
    Network_Client()\Player\MPPass = MPPass
    Network_Client()\Player\Client_Version = Version
    
    Network_Client_Output_Write_Byte(Client_ID, 16) ; Send ExtInfo
    Network_Client_Output_Write_String(Client_ID, LSet("D3 Server",64," "),64)
    Network_Client_Output_Write_Word(Client_ID, #CPE_Extensions)

    ;Send ExtEntry for each supported extension.
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("CustomBlocks", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("EmoteFix", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("HeldBlock", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("ClickDistance", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("ChangeModel", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("ExtPlayerList", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
     
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("EnvWeatherType", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("EnvMapAppearance", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("MessageTypes", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("BlockPermissions", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("EnvMapAppearance", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("TextHotKey", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
    
    Network_Client_Output_Write_Byte(Client_ID, 17)
    Network_Client_Output_Write_String(Client_ID, LSet("HackControl", 64, " "), 64)
    Network_Client_Output_Write_Int(Client_ID, 1)
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client()) ; Wait for the rest of the negotiation to take place...
EndProcedure

Procedure CPE_Send_Extensions(Client_ID)
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\ClickDistance = #True
      Network_Client_Output_Write_Byte(Client_ID, 18)
      Network_CLient_Output_Write_Word(Client_ID, System_Main\Click_Distance)
    EndIf
    
    If Network_Client()\CustomBlocks = #True
      Network_Client_Output_Write_Byte(Client_ID, 19)
      Network_Client_Output_Write_Byte(Client_ID, 1) ; We support 1st level of blocks :D
    Else
      Client_Login(Client_ID, Network_Client()\Player\Login_Name, Network_Client()\Player\MPPass, Network_Client()\Player\Client_Version)
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client()) 
EndProcedure

Procedure.s Emote_Replace(Message.s)
  Message = ReplaceString(Message, "{:)}", Chr(1))
  Message = ReplaceString(Message, "{smile2}", Chr(2))
  Message = ReplaceString(Message, "{smile}", Chr(1))
  Message = ReplaceString(Message, "{<3}", Chr(3))
  Message = ReplaceString(Message, "{heart}", Chr(3))
  Message = ReplaceString(Message, "{diamond}",Chr(4))
  Message = ReplaceString(Message, "{club}", Chr(5))
  Message = ReplaceString(Message, "{spade}", Chr(6))
  Message = ReplaceString(Message, "{male}", Chr(11))
  Message = ReplaceString(Message, "{female}", Chr(12))
  Message = ReplaceString(Message, "{note}", Chr(13))
  Message = ReplaceString(Message, "{notes}", Chr(14))
  Message = ReplaceString(Message, "{sun}", Chr(15))
  Message = ReplaceString(Message, "{!!}", Chr(19))
  Message = ReplaceString(Message, "{P}", Chr(20))
  Message = ReplaceString(Message, "{S}", Chr(21))
  Message = ReplaceString(Message, "{*}", Chr(7))
  Message = ReplaceString(Message, "{hole}", Chr(8))
  Message = ReplaceString(Message, "{circle}", Chr(9))
  Message = ReplaceString(Message, "{-}", Chr(22))
  Message = ReplaceString(Message, "{L}", Chr(28))
  Message = ReplaceString(Message, "{house}", Chr(127))
  Message = ReplaceString(Message, "{caret}", Chr(94))
  Message = ReplaceString(Message, "{tilde}", Chr(126))
  Message = ReplaceString(Message, "{'}", Chr(180))
  Message = ReplaceString(Message, "{^}", Chr(24))
  Message = ReplaceString(Message, "{v}", Chr(25))
  Message = ReplaceString(Message, "{>}", Chr(26))
  Message = ReplaceString(Message, "{<}", Chr(27))
  Message = ReplaceString(Message, "{^^}", Chr(30))
  Message = ReplaceString(Message, "{vv}", Chr(31))
  Message = ReplaceString(Message, "{>>}", Chr(16))
  Message = ReplaceString(Message, "{<<}", Chr(17))
  Message = ReplaceString(Message, "{<>}", Chr(29))
  Message = ReplaceString(Message, "{updown}", Chr(18))
  Message = ReplaceString(Message, "{updown2}", Chr(23))
  
  ProcedureReturn Message.s
EndProcedure

Procedure CPE_HoldThis(Client_ID, Block, CanChange)
  List_Store(*Network_Client_Old, Network_Client()) ; Store the old NetworkClient
  
  If Network_Client_Select(Client_ID) ; Get the NetworkClient of the person getting the packet..
    If Network_Client()\HeldBlock = #True
        If Block > 49 And Network_Client()\CustomBlocks = #False ; If this is a custom block, and the client doesn't support it..
          List_Restore(*Network_Client_Old, Network_Client())
          ProcedureReturn
        EndIf
    
    
      Network_Client_Output_Write_Byte(Client_ID, 20)
      Network_Client_Output_Write_Byte(Client_ID, Block)
      Network_Client_Output_Write_Byte(Client_ID, CanChange)
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure CPE_Selection_Cuboid_Add(Client_ID, SelectionID, Label.s, StartX.w, StartY.w, StartZ.w, EndX.w, EndY.w, EndZ.w, Red.w, Green.w, Blue.w, Opacity.w)
  If (StartX > EndX) Or (StartY > EndY) Or (StartZ > EndZ)
    ProcedureReturn 0
  EndIf
  
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\SelectionCuboid = #True And List_Contains(SelectionID, Network_Client()\Selections()) = #False
      
      LastElement(Network_Client()\Selections()) ; Add to our ID list.
      AddElement(Network_Client()\Selections())
      Network_Client()\Selections() = SelectionID
      
      
      Network_Client_Output_Write_Byte(Client_ID, 26)
      Network_Client_Output_Write_Byte(Client_ID, SelectionID)
      Network_Client_Output_Write_String(CLient_ID, LSet(Label, 64, " "), 64)
      Network_Client_Output_Write_Word(Client_ID, StartX)
      Network_Client_Output_Write_Word(Client_ID, StartZ)
      Network_Client_Output_Write_Word(Client_ID, StartY)
      Network_Client_Output_Write_Word(Client_ID, EndX)
      Network_Client_Output_Write_Word(Client_ID, EndZ)
      Network_Client_Output_Write_Word(Client_ID, EndY)
      Network_Client_Output_Write_Word(Client_ID, Red)
      Network_Client_Output_Write_Word(Client_ID, Green)
      Network_Client_Output_Write_Word(Client_ID, Blue)
      Network_Client_Output_Write_Word(Client_ID, Opacity)
      
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client()) 
EndProcedure

Procedure CPE_Selection_Cuboid_Delete(Client_ID, Selection_ID)
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\SelectionCuboid = #True And List_Contains(Selection_ID, Network_Client()\Selections()) = #True
      Network_Client_Output_Write_Byte(Client_ID, 27)
      Network_Client_Output_Write_Byte(Client_ID, Selection_ID)
      
      List_PopPosition(Selection_ID, Network_Client()\Selections())
      DeleteElement(Network_Client()\Selections())
      
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client()) 
EndProcedure

Procedure.i Map_Export_Get_Size_X(Filename.s)
  Map_Size_X = 0
  Map_Size_Y = 0
  Map_Size_Z = 0
  
  *Temp_Buffer = Mem_Allocate(10, #PB_Compiler_File, #PB_Compiler_Line, "Temp")

  If *Temp_Buffer
  
  Temp_Buffer_Offset = 0
  
  Result = GZip_Decompress_From_File(Filename, *Temp_Buffer, 10)
    If Result = 10
      File_Version = PeekL(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 4
      Map_Size_X = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Y = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Z = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      
    EndIf
  EndIf
  
  Mem_Free(*Temp_Buffer)
  ProcedureReturn Map_Size_X
EndProcedure

Procedure.i Map_Export_Get_Size_Y(Filename.s)
    Map_Size_X = 0
  Map_Size_Y = 0
  Map_Size_Z = 0
  
  *Temp_Buffer = Mem_Allocate(10, #PB_Compiler_File, #PB_Compiler_Line, "Temp")

  If *Temp_Buffer
  
  Temp_Buffer_Offset = 0
  
  Result = GZip_Decompress_From_File(Filename, *Temp_Buffer, 10)
    If Result = 10
      File_Version = PeekL(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 4
      Map_Size_X = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Y = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Z = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      
    EndIf
  EndIf
  
  Mem_Free(*Temp_Buffer)
  ProcedureReturn Map_Size_Y
EndProcedure

Procedure.i Map_Export_Get_Size_Z(Filename.s)
  Map_Size_X = 0
  Map_Size_Y = 0
  Map_Size_Z = 0
  
  *Temp_Buffer = Mem_Allocate(10, #PB_Compiler_File, #PB_Compiler_Line, "Temp")

  If *Temp_Buffer
  
  Temp_Buffer_Offset = 0
  
  Result = GZip_Decompress_From_File(Filename, *Temp_Buffer, 10)
    If Result = 10
      File_Version = PeekL(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 4
      Map_Size_X = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Y = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      Map_Size_Z = PeekW(*Temp_Buffer+Temp_Buffer_Offset) : Temp_Buffer_Offset + 2
      
    EndIf
    Mem_Free(*Temp_Buffer)
  EndIf
  
  ProcedureReturn Map_Size_Z
EndProcedure

Procedure CPE_Model_Change(Client_ID, Model.s)
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    Map_ID = Network_Client()\Player\Entity\Map_ID
    Entity_ID = Network_Client()\Player\Entity\ID_Client
    Network_Client()\Player\Entity\Model = Model
    
      ForEach Network_Client()
        If Network_Client()\Logged_In = #True And Network_Client()\ChangeModel = #True And Network_Client()\Player\Entity\Map_ID = Map_ID
          Network_Client_Output_Write_Byte(Network_Client()\ID, 29)
          Network_Client_Output_Write_Byte(Network_Client()\ID, Entity_ID)
          Network_Client_Output_Write_String(Network_Client()\ID, LSet(Model, 64, " "), 64)
        EndIf
      Next
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client()) 
EndProcedure

Procedure CPE_Aftermap_Actions(Client_ID, *MapData.Map_Data)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Not *MapData
        ProcedureReturn
    EndIf
    
    If Network_Client_Select(Client_ID)
        If Network_Client()\EnvColors = #True
            If *MapData\ColorsSet = #True
                R = Red(*MapData\SkyColor)
                G = Green(*MapData\SkyColor)
                B = Blue(*MapData\SkyColor)
                CPE_Set_Env_Colors(0, R, G, B)
                
                R = Red(*MapData\CloudColor)
                G = Green(*MapData\CloudColor)
                B = Blue(*MapData\CloudColor)
                CPE_Set_Env_Colors(1, R, G, B)
                
                R = Red(*MapData\FogColor)
                G = Green(*MapData\FogColor)
                B = Blue(*MapData\FogColor)
                CPE_Set_Env_Colors(2, R, G, B)
                
                R = Red(*MapData\alight)
                G = Green(*MapData\alight)
                B = Blue(*MapData\alight)
                CPE_Set_Env_Colors(3, R, G, B)
                
                R = Red(*MapData\dlight)
                G = Green(*MapData\dlight)
                B = Blue(*MapData\dlight)
                CPE_Set_Env_Colors(4, R, G, B)
            EndIf
        EndIf
        If Network_Client()\EnvMapAppearance = #True And *MapData\CustomAppearance = #True
            CPE_Client_Send_Map_Appearence(Network_Client()\ID, *MapData\CustomURL, *MapData\Side_Block, *MapData\Edge_Block, *MapData\Side_level) ; Send the client the map's custom parameters.
        EndIf
        If Network_Client()\HackControl = #True
            CPE_Client_Hackcontrol_Send(Network_Client()\ID, *MapData\Flying, *MapData\NoClip, *MapData\Speeding, *MapData\SpawnControl, *MapData\ThirdPerson, *MapData\Weather, *MapData\JumpHeight)
        EndIf
        ;CPE_Client_Send_Hotkeys(Network_Client()\ID)
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client()) 
EndProcedure

Procedure CPE_Set_Env_Colors(Type.b, Red.w, Green.w, Blue.w)
    Network_Client_Output_Write_Byte(Network_Client()\ID, 25)
    Network_Client_Output_Write_Byte(Network_Client()\ID, Type)
    Network_Client_Output_Write_Word(Network_Client()\ID, Red)
    Network_Client_Output_Write_Word(Network_Client()\ID, Green)
    Network_Client_Output_Write_Word(Network_Client()\ID, Blue)
EndProcedure

Procedure CPE_Set_Weather(Client_ID, Weather.b)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        If Network_Client()\CPEWeather = #True
            Network_Client_Output_Write_Byte(Network_Client()\ID, 31)
            Network_Client_Output_Write_Byte(Network_Client()\ID, Weather)
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure CPE_Handle_Entity()
  If Network_Client()\Logged_In = #True And Network_Client()\ChangeModel = #True And Entity()\Model <> "default"
    Network_Client_Output_Write_Byte(Network_Client()\ID, 29)
    Network_Client_Output_Write_Byte(Network_Client()\ID, Entity()\ID_Client)
    Network_Client_Output_Write_String(Network_Client()\ID, LSet(Entity()\Model, 64, " "), 64)
  EndIf
  
EndProcedure

Procedure CPE_Client_Set_Block_Permissions(Client_ID, Block_ID, CanPlace, CanDelete)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        If Network_Client()\BlockPermissions = #True
            Network_Client_Output_Write_Byte(Client_ID, 28)
            Network_Client_Output_Write_Byte(Client_ID, Block_ID)
            Network_Client_Output_Write_Byte(Client_ID, CanPlace)
            Network_Client_Output_Write_Byte(Client_ID, CanDelete)
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure CPE_Client_Send_Map_Appearence(Client_ID, URL.s, Side_Block, Edge_Block, Side_Level.w)
    List_Store(*Network_Client_Old, Network_Client())
    ;URL = LSet(URL, 64)
    If Network_Client_Select(Client_ID)
        If Network_Client()\EnvMapAppearance = #True
            Network_Client_Output_Write_Byte(Client_ID, 30)
            Network_Client_Output_Write_String(Client_ID, LSet(URL, 64, " "), 64)
            Network_Client_Output_Write_Byte(Client_ID, Side_Block)
            Network_Client_Output_Write_Byte(Client_ID, Edge_Block)
            Network_Client_Output_Write_Word(Client_ID, Side_Level)
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure CPE_Client_Send_Hotkeys(Client_ID)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        If Network_Client()\TextHotkey = #True
            ForEach Hotkeys()
                Network_Client_Output_Write_Byte(Client_ID, 21)
                Network_Client_Output_Write_String(Client_ID, LSet(Hotkeys()\Label, 64, " "), 64)
                Network_Client_Output_Write_String(Client_ID, LSet(ReplaceString(Hotkeys()\Action, "\n", Chr(13)), 64, " "), 64)
                Network_Client_Output_Write_Int(Client_ID, Hotkeys()\Keycode)
                Network_Client_Output_Write_Byte(Client_ID, Hotkeys()\Keymods)
            Next
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure CPE_Client_Hackcontrol_Send(Client_ID, Flying, Noclip, Speeding, SpawnControl, ThirdPerson, WeatherControl, Jumpheight.w)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        If Network_Client()\HackControl = #True
            Network_Client_Output_Write_Byte(Client_ID, 32)
            Network_Client_Output_Write_Byte(Client_ID, Flying)
            Network_Client_Output_Write_Byte(Client_ID, Noclip)
            Network_Client_Output_Write_Byte(Client_ID, Speeding)
            Network_Client_Output_Write_Byte(Client_ID, SpawnControl)
            Network_Client_Output_Write_Byte(Client_ID, ThirdPerson)
            Network_Client_Output_Write_Byte(Client_ID, WeatherControl)
            Network_Client_Output_Write_Word(Client_ID, Jumpheight)
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 452
; FirstLine = 415
; Folding = 9---
; EnableThread
; EnableXP
; EnableOnError
; DisableDebugger
; CompileSourceDirectory