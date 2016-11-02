
; ########################################## Konstanten ########################################

#Plugin_Version = 510

; ######################################### Prototypes ##########################################

Declare PluginBuildModeGet(ClientID, *Result)
Declare PluginBuildModeStringGet(Client_ID, Index, *Result)
Declare PluginEntityDisplaynameGet(ID, *Result)
Declare PluginPlayerAttributeStringGet(Player_Number, Attribute.s, *Result)
Declare PluginSystemGetServerName(*Result)
Declare PluginLangGet(Language.s, Input.s, *Result, Field_0.s = "", Field_1.s = "", Field_2.s = "", Field_3.s = "")
Declare PluginFilesFileGet(File.s, *Result)
Declare PluginFilesFolderGet(Name.s, *Result)
        
PrototypeC   Plugin_Inside_Main()
PrototypeC   Plugin_Inside_Event_Block_Physics(Argument.s, *Map_Data.Map_Data, X, Y, Z)
PrototypeC   Plugin_Inside_Event_Block_Create(Argument.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Block_Delete(Argument.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Map_Fill(Argument.s, *Map_Data.Map_Data, Argument_String.s)
PrototypeC   Plugin_Inside_Event_Command(Argument.s, *Client.Network_Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
PrototypeC   Plugin_Inside_Event_Build_Mode(Argument.s, *Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode, Block_Type)

PrototypeC   Plugin_Inside_Event_Client_Add(*Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Client_Delete(*Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Client_Verify_Name(Name.s, Pass.s)
PrototypeC   Plugin_Inside_Event_Client_Verify_Name_MC(Name.s, Pass.s)
PrototypeC   Plugin_Inside_Event_Client_Login(*Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Client_Logout(*Client.Network_Client)
PrototypeC   Plugin_Inside_Event_Entity_Add(*Entity.Entity)
PrototypeC   Plugin_Inside_Event_Entity_Delete(*Entity.Entity)
PrototypeC   Plugin_Inside_Event_Entity_Position_Set(*Entity.Entity, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
PrototypeC   Plugin_Inside_Event_Entity_Die(*Entity.Entity)
PrototypeC   Plugin_Inside_Event_Map_Add(*Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Action_Delete(Action_ID, *Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Action_Resize(Action_ID, *Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Action_Fill(Action_ID, *Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Action_Save(Action_ID, *Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Action_Load(Action_ID, *Map_Data.Map_Data)
PrototypeC   Plugin_Inside_Event_Map_Block_Change(Player_Number, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
PrototypeC   Plugin_Inside_Event_Map_Block_Change_Client(*Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode.a, Type.a)
PrototypeC   Plugin_Inside_Event_Map_Block_Change_Player(*Player.Player_List, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
PrototypeC   Plugin_Inside_Event_Chat_Map(*Entity.Entity, Message.s)
PrototypeC   Plugin_Inside_Event_Chat_All(*Entity.Entity, Message.s)
PrototypeC   Plugin_Inside_Event_Chat_Private(*Entity.Entity, Player_Name.s, Message.s)
PrototypeC   Plugin_Inside_Event_Entity_Map_Change(Client_ID, New_Map_ID, Old_Map_ID)
; ########################################## Variablen ##########################################

Structure Plugin_Main
    Timer_File_Check.l          ; Timer für das überprüfen der Dateigröße
    Plugin_Thread_ID.i
EndStructure

Global Plugin_Main.Plugin_Main

Structure Plugin_Info
    Name.s{16}                  ; Bezeichnung des Plugins (16 Zeichen!) / Name of the Plugin (16 Chars!)
    Version.l                   ; Pluginversion (Wird geändert wenn ältere Plugins nicht mehr kompatibel sind) /  Pluginversion
    Author.s{16}                ; Autor des Plugins (16 Zeichen!) / Author of the plugin
EndStructure

Structure Plugin_Inside_Functions
    Main.Plugin_Inside_Main
    Event_Block_Physics.Plugin_Inside_Event_Block_Physics
    Event_Block_Create.Plugin_Inside_Event_Block_Create
    Event_Block_Delete.Plugin_Inside_Event_Block_Delete
    Event_Map_Fill.Plugin_Inside_Event_Map_Fill
    Event_Command.Plugin_Inside_Event_Command
    Event_Build_Mode.Plugin_Inside_Event_Build_Mode
    
    Event_Client_Add.Plugin_Inside_Event_Client_Add
    Event_Client_Delete.Plugin_Inside_Event_Client_Delete
    Event_Client_Verify_Name.Plugin_Inside_Event_Client_Verify_Name
    Event_Client_Verify_Name_MC.Plugin_Inside_Event_Client_Verify_Name_MC
    Event_Client_Login.Plugin_Inside_Event_Client_Login
    Event_Client_Logout.Plugin_Inside_Event_Client_Logout
    Event_Entity_Add.Plugin_Inside_Event_Entity_Add
    Event_Entity_Delete.Plugin_Inside_Event_Entity_Delete
    Event_Entity_Position_Set.Plugin_Inside_Event_Entity_Position_Set
    Event_Entity_Die.Plugin_Inside_Event_Entity_Die
    Event_Map_Add.Plugin_Inside_Event_Map_Add
    Event_Map_Action_Delete.Plugin_Inside_Event_Map_Action_Delete
    Event_Map_Action_Resize.Plugin_Inside_Event_Map_Action_Resize
    Event_Map_Action_Fill.Plugin_Inside_Event_Map_Action_Fill
    Event_Map_Action_Save.Plugin_Inside_Event_Map_Action_Save
    Event_Map_Action_Load.Plugin_Inside_Event_Map_Action_Load
    Event_Map_Block_Change.Plugin_Inside_Event_Map_Block_Change
    Event_Map_Block_Change_Client.Plugin_Inside_Event_Map_Block_Change_Client
    Event_Map_Block_Change_Player.Plugin_Inside_Event_Map_Block_Change_Player
    Event_Chat_Map.Plugin_Inside_Event_Chat_Map
    Event_Chat_All.Plugin_Inside_Event_Chat_All
    Event_Chat_Private.Plugin_Inside_Event_Chat_Private
    Event_Entity_Map_Change.Plugin_Inside_Event_Entity_Map_Change
EndStructure

Structure Plugin
    Plugin_Info.Plugin_Info
    Functions.Plugin_Inside_Functions
    Valid.b
    Loaded.b
    Filename.s
    Library_ID.i                ; Rückgabe von Openlibrary (0: Ungültig)
    File_Date_Last.l            ; Datum letzter Änderung
EndStructure

Structure UnloadedPlugin
    Filename.s
    PluginName.s
    File_Date_Last.l
EndStructure

Global NewMap Plugins.Plugin()

Structure Plugin_Result_Element
    *Pointer
    ID.i
EndStructure

XIncludeFile "../Shared Includes/Plugin_Functions.pbi"
Global Plugin_Function.Plugin_Function

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Imports ##########################################

; ########################################## Macros #############################################

; #################################### Initkram ###############################################

;-################################## Proceduren im Plugin ##########################################

Procedure Client_Count_Elements()
    ProcedureReturn ListSize(Network_Client())
EndProcedure

Procedure Client_Get_Array(*Memory)
    Element = 0
    ForEach Network_Client()
        *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = Network_Client()
        *Pointer\ID = Network_Client()\ID
        Element + 1
    Next
EndProcedure

Procedure Network_Settings_Get_Port()
    ProcedureReturn Network_Settings\Port
EndProcedure

Procedure Entity_Count_Elements()
    ProcedureReturn ListSize(Entity())
EndProcedure

Procedure Entity_Get_Array(*Memory)
    Element = 0
    ForEach Entity()
        *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = Entity()
        *Pointer\ID = Entity()\ID
        Element + 1
    Next
EndProcedure

Procedure Player_Count_Elements()
    ProcedureReturn ListSize(Player_List())
EndProcedure

Procedure Player_Get_Array(*Memory)
    Element = 0
    ForEach Player_List()
        *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = Player_List()
        *Pointer\ID = Player_List()\Number
        Element + 1
    Next
EndProcedure

Procedure Player_Get_Players_Max()
    ProcedureReturn Player_Main\Players_Max
EndProcedure

Procedure Map_Count_Elements()
    ProcedureReturn ListSize(Map_Data())
EndProcedure

Procedure Map_Get_Array(*Memory)
    Element = 0
    ForEach Map_Data()
        *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = Map_Data()
        *Pointer\ID = Map_Data()\ID
        Element + 1
    Next
EndProcedure

Procedure Block_Count_Elements()
    ProcedureReturn 256
EndProcedure

Procedure Block_Get_Array(*Memory)
    For i = 0 To 255
        *Pointer.Plugin_Result_Element = *Memory + i*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = @Block(i)
        *Pointer\ID = i
    Next
EndProcedure

Procedure Rank_Count_Elements()
    ProcedureReturn ListSize(Rank())
EndProcedure

Procedure Rank_Get_Array(*Memory)
    Element = 0
    ForEach Rank()
        *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
        *Pointer\Pointer = Rank()
        *Pointer\ID = Rank()\Rank
        Element + 1
    Next
EndProcedure

Procedure Teleporter_Count_Elements(*Map_Data.Map_Data)
    If *Map_Data
        ProcedureReturn MapSize(*Map_Data\Teleporter())
    EndIf
    
    ProcedureReturn -1
EndProcedure

Procedure Teleporter_Get_Array(*Map_Data.Map_Data, *Memory)
    If *Map_Data
        Element = 0
        ForEach *Map_Data\Teleporter()
            *Pointer.Plugin_Result_Element = *Memory + Element*SizeOf(Plugin_Result_Element)
            *Pointer\Pointer = *Map_Data\Teleporter()
            *Pointer\ID = -1;Teleporter()\ID
            Element + 1
        Next
    EndIf
EndProcedure

Procedure.s System_Get_Server_Name()
    ProcedureReturn System_Main\Server_Name
EndProcedure

Procedure Main_LockMutex()
    LockMutex(Main\Mutex)
EndProcedure

Procedure Main_UnlockMutex()
    UnlockMutex(Main\Mutex)
EndProcedure

; ########################################## Eintragen der Funktionen in die Struktur / Place the functions into the structure
;{
Plugin_Function\Client_Count_Elements = @Client_Count_Elements()
Plugin_Function\Client_Get_Array = @Client_Get_Array()
Plugin_Function\Client_Get_Pointer = @Network_Client_Get_Pointer()
Plugin_Function\Client_Kick = @Network_Client_Kick()

Plugin_Function\Network_Settings_Get_Port = @Network_Settings_Get_Port()

Plugin_Function\Build_Mode_Set = @Build_Mode_Set()
Plugin_Function\Build_Mode_Get = @PluginBuildModeGet()
Plugin_Function\Build_Mode_State_Set = @Build_Mode_State_Set()
Plugin_Function\Build_Mode_State_Get = @Build_Mode_State_Get()
Plugin_Function\Build_Mode_Coordinate_Set = @Build_Mode_Coordinate_Set()
Plugin_Function\Build_Mode_Coordinate_Get_X = @Build_Mode_Coordinate_Get_X()
Plugin_Function\Build_Mode_Coordinate_Get_Y = @Build_Mode_Coordinate_Get_Y()
Plugin_Function\Build_Mode_Coordinate_Get_Z = @Build_Mode_Coordinate_Get_Z()
Plugin_Function\Build_Mode_Long_Set = @Build_Mode_Long_Set()
Plugin_Function\Build_Mode_Long_Get = @Build_Mode_Long_Get()
Plugin_Function\Build_Mode_Float_Set = @Build_Mode_Float_Set()
Plugin_Function\Build_Mode_Float_Get = @Build_Mode_Float_Get()
Plugin_Function\Build_Mode_String_Set = @Build_Mode_String_Set()
Plugin_Function\Build_Mode_String_Get = @PluginBuildModeStringGet()

Plugin_Function\Build_Line_Player = @Build_Line_Player()
Plugin_Function\Build_Box_Player = @Build_Box_Player()
Plugin_Function\Build_Sphere_Player = @Build_Sphere_Player()
Plugin_Function\Build_Rank_Box = @Build_Rank_Box()

Plugin_Function\Font_Draw_Text = @Font_Draw_Text()
Plugin_Function\Font_Draw_Text_Player = @Font_Draw_Text_Player()

Plugin_Function\Entity_Count_Elements = @Entity_Count_Elements()
Plugin_Function\Entity_Get_Array = @Entity_Get_Array()
Plugin_Function\Entity_Get_Pointer = @Entity_Get_Pointer()
Plugin_Function\Entity_Add = @Entity_Add()
Plugin_Function\Entity_Delete = @Entity_Delete()
Plugin_Function\Entity_Resend = @Entity_Resend()
Plugin_Function\Entity_Message_2_Clients = @Entity_Message_2_Clients()
Plugin_Function\Entity_Displayname_Get = @PluginEntityDisplaynameGet()
Plugin_Function\Entity_Displayname_Set = @Entity_Displayname_Set()
Plugin_Function\Entity_Position_Set = @Entity_Position_Set()
Plugin_Function\Entity_Kill = @Entity_Kill()

Plugin_Function\Player_Count_Elements = @Player_Count_Elements()
Plugin_Function\Player_Get_Array = @Player_Get_Array()
Plugin_Function\Player_Get_Pointer = @Player_List_Get_Pointer()
Plugin_Function\Player_Get_Players_Max = @Player_Get_Players_Max()
Plugin_Function\Player_Attribute_Long_Set = @Player_Attribute_Long_Set()
Plugin_Function\Player_Attribute_Long_Get = @Player_Attribute_Long_Get()
Plugin_Function\Player_Attribute_String_Set = @Player_Attribute_String_Set()
Plugin_Function\Player_Attribute_String_Get = @PluginPlayerAttributeStringGet()
Plugin_Function\Player_Inventory_Set = @Player_Inventory_Set()
Plugin_Function\Player_Inventory_Get = @Player_Inventory_Get()
Plugin_Function\Player_Rank_Set = @Player_Rank_Set()
Plugin_Function\Player_Kick = @Player_Kick()
Plugin_Function\Player_Ban = @Player_Ban()
Plugin_Function\Player_Unban = @Player_Unban()
Plugin_Function\Player_Stop = @Player_Stop()
Plugin_Function\Player_Unstop = @Player_Unstop()
Plugin_Function\Player_Mute = @Player_Mute()
Plugin_Function\Player_Unmute = @Player_Unmute()
Plugin_Function\Player_Get_Prefix = @Player_Get_Prefix()
Plugin_Function\Player_Get_Name = @Player_Get_Name()
Plugin_Function\Player_Get_Suffix = @Player_Get_Suffix()

Plugin_Function\Map_Count_Elements = @Map_Count_Elements()
Plugin_Function\Map_Get_Array = @Map_Get_Array()
Plugin_Function\Map_Get_Pointer = @Map_Get_Pointer()
Plugin_Function\Map_Block_Change = @Map_Block_Change()
Plugin_Function\Map_Block_Change_Client = @Map_Block_Change_Client()
Plugin_Function\Map_Block_Change_Player = @Map_Block_Change_Player()
Plugin_Function\Map_Block_Move = @Map_Block_Move()
Plugin_Function\Map_Block_Get_Type = @Map_Block_Get_Type()
Plugin_Function\Map_Block_Get_Rank = @Map_Block_Get_Rank()
Plugin_Function\Map_Block_Get_Player_Number = @Map_Block_Get_Player_Number()
Plugin_Function\Map_Block_Set_Rank_Box = @Map_Block_Set_Rank_Box()
Plugin_Function\Map_Add = @Map_Add()
Plugin_Function\Map_Action_Add_Save = @Map_Action_Add_Save()
Plugin_Function\Map_Action_Add_Load = @Map_Action_Add_Load()
Plugin_Function\Map_Action_Add_Resize = @Map_Action_Add_Resize()
Plugin_Function\Map_Action_Add_Fill = @Map_Action_Add_Fill()
Plugin_Function\Map_Action_Add_Delete = @Map_Action_Add_Delete()
Plugin_Function\Map_Export = @Map_Export()
Plugin_Function\Map_Import_Player = @Map_Import_Player()
Plugin_Function\Map_Resend = @Map_Resend()

Plugin_Function\Block_Count_Elements = @Block_Count_Elements()
Plugin_Function\Block_Get_Array = @Block_Get_Array()
Plugin_Function\Block_Get_Pointer = @Block_Get_Pointer()

Plugin_Function\Rank_Count_Elements = @Rank_Count_Elements()
Plugin_Function\Rank_Get_Array = @Rank_Get_Array()
Plugin_Function\Rank_Get_Pointer = @Rank_Get_Pointer()
Plugin_Function\Rank_Add = @Rank_Add()
Plugin_Function\Rank_Delete = @Rank_Delete()

Plugin_Function\Teleporter_Count_Elements = @Teleporter_Count_Elements()
Plugin_Function\Teleporter_Get_Array = @Teleporter_Get_Array()
Plugin_Function\Teleporter_Get_Pointer = @Teleporter_Get_Pointer()
Plugin_Function\Teleporter_Add = @Teleporter_Add()
Plugin_Function\Teleporter_Delete = @Teleporter_Delete()

Plugin_Function\System_Message_Network_Send_2_All = @System_Message_Network_Send_2_All()
Plugin_Function\System_Message_Network_Send = @System_Message_Network_Send()
Plugin_Function\System_Get_Server_Name = @PluginSystemGetServerName()

Plugin_Function\Network_Out_Block_Set = @Network_Out_Block_Set()

Plugin_Function\Main_LockMutex = @Main_LockMutex()
Plugin_Function\Main_UnlockMutex = @Main_UnlockMutex()

Plugin_Function\Lang_Get = @PluginLangGet()

Plugin_Function\Files_File_Get = @PluginFilesFileGet()
Plugin_Function\Files_Folder_Get = @PluginFilesFolderGet()

Plugin_Function\Log_Add = @Log_Add()

Plugin_Function\CPE_Selection_Cuboid_Add = @CPE_Selection_Cuboid_Add()
Plugin_Function\CPE_Selection_Cuboid_Delete = @CPE_Selection_Cuboid_Delete()

Plugin_Function\Map_Export_Get_Size_X = @Map_Export_Get_Size_X()
Plugin_Function\Map_Export_Get_Size_Y = @Map_Export_Get_Size_Y()
Plugin_Function\Map_Export_Get_Size_Z = @Map_Export_Get_Size_Z()

Plugin_Function\CPE_HoldThis = @CPE_HoldThis()
Plugin_Function\CPE_Model_Change = @CPE_Model_Change()
Plugin_Function\CPE_Set_Weather = @CPE_Set_Weather()

Plugin_Function\Map_Env_Colors_Change = @Map_Env_Colors_Change()

Plugin_Function\CPE_Client_Set_Block_Permissions = @CPE_Client_Set_Block_Permissions()
Plugin_Function\Map_Env_Appearance_Set = @Map_Env_Appearance_Set()
Plugin_Function\CPE_Client_Send_Map_Appearence = @CPE_Client_Send_Map_Appearence()
Plugin_Function\CPE_Client_Hackcontrol_Send = @CPE_Client_Hackcontrol_Send()
Plugin_Function\CPE_Client_Send_Hotkeys = @CPE_Client_Send_Hotkeys()
Plugin_Function\Hotkey_Add = @Hotkey_Add()
Plugin_Function\Hotkey_Remove = @Hotkey_Remove()
Plugin_Function\Map_HackControl_Set = @Map_HackControl_Set()
;}
;-########################################## Procedures ##########################################

Procedure Plugin_Event_Block_Physics(Destination.s, *Map_Data.Map_Data, X, Y, Z)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Block_Physics
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Block_Physics(Argument, *Map_Data, X, Y, Z)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Block_Physics
            Continue
        EndIf
        
        Plugins()\Functions\Event_Block_Physics(Argument, *Map_Data, X, Y, Z)
    Next
    
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Event_Block_Create(Destination.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Block_Create
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Block_Create(Argument, *Map_Data, X, Y, Z, Old_Block.a, *Client)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Block_Create
            Continue
        EndIf
        
        Plugins()\Functions\Event_Block_Create(Argument, *Map_Data, X, Y, Z, Old_Block.a, *Client)
    Next
    
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Event_Block_Delete(Destination.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Block_Delete
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Block_Delete(Argument, *Map_Data, X, Y, Z, Old_Block.a, *Client)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Block_Delete
            Continue
        EndIf
        
        Plugins()\Functions\Event_Block_Delete(Argument, *Map_Data, X, Y, Z, Old_Block.a, *Client)
    Next
    
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Event_Map_Fill(Destination.s, *Map_Data.Map_Data, Argument_String.s)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Map_Fill
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Map_Fill(Argument, *Map_Data, Argument_String)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Fill
            Continue
        EndIf
        
        Plugins()\Functions\Event_Map_Fill(Argument, *Map_Data, Argument_String)
    Next
    
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Event_Command(Destination.s, *Client.Network_Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Command
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Command(Argument, *Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Command
            Continue
        EndIf
        
        Plugins()\Functions\Event_Command(Argument, *Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
    Next
    
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Event_Build_Mode(Destination.s, *Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode, Block_Type)
    If FindString(Destination, ":", 1)
        Plugin.s = StringField(Destination, 1, ":")
        Argument.s = Mid(Destination, 2+Len(Plugin))
    Else
        Plugin.s = Destination
        Argument.s = ""
    EndIf
    
    If Plugin <> "*"
        ForEach Plugins()
            If Plugins()\Plugin_Info\Name <> Plugin
                Continue
            EndIf
            
            Plugin = Plugins()\Filename
            Break
        Next
        
        If Not Plugins(Plugin)\Library_ID
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Plugin)\Functions\Event_Build_Mode
            ProcedureReturn #False
        EndIf
        
        Plugins(Plugin)\Functions\Event_Build_Mode(Argument, *Client, *Map_Data, X, Y, Z, Mode, Block_Type)
        ProcedureReturn #True
    EndIf
    
    ForEach Plugins()
        If Not Plugins()\Loaded
            Continue
        EndIf
        
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Build_Mode
            Continue
        EndIf
        
        Plugins()\Functions\Event_Build_Mode(Argument, *Client, *Map_Data, X, Y, Z, Mode, Block_Type)
    Next
    
    ProcedureReturn #True
EndProcedure

;-Plugin Extention methods...

Procedure PluginBuildModeGet(ClientID, *Result)
    Protected str.s
    str = Build_Mode_Get(ClientID)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginBuildModeStringGet(Client_ID, Index, *Result)
    Protected str.s
    str = Build_Mode_String_Get(Client_ID, Index)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginEntityDisplaynameGet(ID, *Result)
    Protected str.s
    str = Entity_Displayname_Get(ID)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginPlayerAttributeStringGet(Player_Number, Attribute.s, *Result)
    Protected str.s
    str = Player_Attribute_String_Get(Player_Number, Attribute)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginSystemGetServerName(*Result)
    Protected str.s
    Str = System_Get_Server_Name()
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginLangGet(Language.s, Input.s, *Result, Field_0.s = "", Field_1.s = "", Field_2.s = "", Field_3.s = "")
    Protected str.s
    str = Lang_Get(Language, Input, Field_0, Field_1, Field_2, Field_3)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginFilesFileGet(File.s, *Result)
    Protected str.s
    str = Files_File_Get(File)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

Procedure PluginFilesFolderGet(Name.s, *Result)
    Protected str.s
    str = Files_Folder_Get(Name)
    
    If *Result
        ProcedureReturn PokeS(*Result, str)
    EndIf
    
    ProcedureReturn StringByteLength(str)
EndProcedure

;-
Procedure Plugin_Event_Client_Add(*Client.Network_Client)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Client_Add
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Client_Add(*Client) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Client_Delete(*Client.Network_Client)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Client_Delete
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Client_Delete(*Client) = #False
            Result = #False
        EndIf
    Next
    
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Client_Verify_Name(Name.s, Pass.s)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Client_Verify_Name
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Client_Verify_Name(Name.s, Pass.s) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Client_Login(*Client.Network_Client)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Client_Login
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Client_Login(*Client) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Client_Logout(*Client.Network_Client)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Client_Logout
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Client_Logout(*Client) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Entity_Add(*Entity.Entity)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Entity_Add
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Entity_Add(*Entity) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Entity_Delete(*Entity.Entity)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Entity_Delete
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Entity_Delete(*Entity) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Entity_Position_Set(*Entity.Entity, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Entity_Position_Set
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Entity_Position_Set(*Entity, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Entity_Map_Change(Client_ID, New_Map_ID, Old_Map_ID)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Entity_Map_Change
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Entity_Map_Change(Client_ID, New_Map_ID, Old_Map_ID) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Entity_Die(*Entity.Entity)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Entity_Die
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Entity_Die(*Entity)= #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Add(*Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Add
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Add(*Map_Data)= #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Action_Delete(Action_ID, *Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Action_Delete
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Action_Delete(Action_ID, *Map_Data)= #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Action_Resize(Action_ID, *Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Action_Resize
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Action_Resize(Action_ID, *Map_Data) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Action_Fill(Action_ID, *Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Action_Fill
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Action_Fill(Action_ID, *Map_Data) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Action_Save(Action_ID, *Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Action_Save
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Action_Save(Action_ID, *Map_Data) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Action_Load(Action_ID, *Map_Data.Map_Data)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Action_Load
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Action_Load(Action_ID, *Map_Data) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Block_Change(Player_Number, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Block_Change
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Block_Change(Player_Number, *Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Block_Change_Client(*Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode.a, Type.a)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Block_Change_Client
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Block_Change_Client(*Client, *Map_Data, X, Y, Z, Mode.a, Type.a)= #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Map_Block_Change_Player(*Player.Player_List, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Map_Block_Change_Player
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Map_Block_Change_Player(*Player, *Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Chat_Map(*Entity.Entity, Message.s)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Chat_Map
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Chat_Map(*Entity, Message) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Chat_All(*Entity.Entity, Message.s)
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Chat_All
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Chat_All(*Entity, Message)= #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

Procedure Plugin_Event_Chat_Private(*Entity.Entity, Player_Name.s, Message.s) ; ####################### Not Finished !!!!!!!!!!!!!
    Result = #True
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Event_Chat_Private
            Continue
        EndIf
        
        If Plugins()\Functions\Event_Chat_Private(*Entity, Player_Name.s, Message.s) = #False
            Result = #False
        EndIf
    Next
    
    ProcedureReturn Result
EndProcedure

;-##################################

Procedure Plugin_Initialize(Filename.s) ; Initialisiert Plugin und übergibt Funktionspointer...
    ;ForEach Plugins()
        If Not FindMapElement(Plugins(), Filename)
            ProcedureReturn #False
        EndIf
        
        If Not Plugins(Filename)\Library_ID
            ProcedureReturn #False
        EndIf
        
        Plugins(Filename)
        
        CallCFunction(Plugins(Filename)\Library_ID, "Init", @Plugins()\Plugin_Info, @Plugin_Function)

        If Plugins(Filename)\Plugin_Info\Version <> #Plugin_Version
            Plugins()\Loaded = #True
            Plugins()\Valid = #False
            ProcedureReturn #False
        EndIf
        
        Plugins()\Functions\Main = GetFunction(Plugins()\Library_ID, "Main")
        Plugins()\Functions\Event_Block_Physics = GetFunction(Plugins()\Library_ID, "Event_Block_Physics")
        Plugins()\Functions\Event_Block_Create = GetFunction(Plugins()\Library_ID, "Event_Block_Create")
        Plugins()\Functions\Event_Block_Delete = GetFunction(Plugins()\Library_ID, "Event_Block_Delete")
        Plugins()\Functions\Event_Map_Fill = GetFunction(Plugins()\Library_ID, "Event_Map_Fill")
        Plugins()\Functions\Event_Command = GetFunction(Plugins()\Library_ID, "Event_Command")
        Plugins()\Functions\Event_Build_Mode = GetFunction(Plugins()\Library_ID, "Event_Build_Mode")
        Plugins()\Functions\Event_Client_Add = GetFunction(Plugins()\Library_ID, "Event_Client_Add")
        Plugins()\Functions\Event_Client_Delete = GetFunction(Plugins()\Library_ID, "Event_Client_Delete")
        Plugins()\Functions\Event_Client_Verify_Name = GetFunction(Plugins()\Library_ID, "Event_Client_Verify_Name")
        Plugins()\Functions\Event_Client_Login = GetFunction(Plugins()\Library_ID, "Event_Client_Login")
        Plugins()\Functions\Event_Client_Logout = GetFunction(Plugins()\Library_ID, "Event_Client_Logout")
        Plugins()\Functions\Event_Entity_Add = GetFunction(Plugins()\Library_ID, "Event_Entity_Add")
        Plugins()\Functions\Event_Entity_Delete = GetFunction(Plugins()\Library_ID, "Event_Entity_Delete")
        Plugins()\Functions\Event_Entity_Position_Set = GetFunction(Plugins()\Library_ID, "Event_Entity_Position_Set")
        Plugins()\Functions\Event_Entity_Die = GetFunction(Plugins()\Library_ID, "Event_Entity_Die")
        Plugins()\Functions\Event_Map_Add = GetFunction(Plugins()\Library_ID, "Event_Map_Add")
        Plugins()\Functions\Event_Map_Action_Delete = GetFunction(Plugins()\Library_ID, "Event_Map_Action_Delete")
        Plugins()\Functions\Event_Map_Action_Resize = GetFunction(Plugins()\Library_ID, "Event_Map_Action_Resize")
        Plugins()\Functions\Event_Map_Action_Fill = GetFunction(Plugins()\Library_ID, "Event_Map_Action_Fill")
        Plugins()\Functions\Event_Map_Action_Save = GetFunction(Plugins()\Library_ID, "Event_Map_Action_Save")
        Plugins()\Functions\Event_Map_Action_Load = GetFunction(Plugins()\Library_ID, "Event_Map_Action_Load")
        Plugins()\Functions\Event_Map_Block_Change = GetFunction(Plugins()\Library_ID, "Event_Map_Block_Change")
        Plugins()\Functions\Event_Map_Block_Change_Client = GetFunction(Plugins()\Library_ID, "Event_Map_Block_Change_Client")
        Plugins()\Functions\Event_Map_Block_Change_Player = GetFunction(Plugins()\Library_ID, "Event_Map_Block_Change_Player")
        Plugins()\Functions\Event_Chat_Map = GetFunction(Plugins()\Library_ID, "Event_Chat_Map")
        Plugins()\Functions\Event_Chat_All = GetFunction(Plugins()\Library_ID, "Event_Chat_All")
        Plugins()\Functions\Event_Chat_Private = GetFunction(Plugins()\Library_ID, "Event_Chat_Private")
        Plugins()\Functions\Event_Entity_Map_Change = GetFunction(Plugins()\Library_ID, "Event_Entity_Map_Change")
        
        Plugins()\Loaded = #True
        Plugins()\Valid = #True
        ProcedureReturn #True
EndProcedure

Procedure Plugin_Deinitialize(Filename.s) ; Deinitialisiert Plugin...
    If Not FindMapElement(Plugins(), Filename)
        ProcedureReturn #False
    EndIf
        
    If Not Plugins(Filename)\Library_ID
        ProcedureReturn #False
    EndIf
    
    CallCFunction(Plugins(Filename)\Library_ID, "Deinit")
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Unload(Filename.s) ; Entlädt die Lib, löscht sie aber nicht aus der Liste / Unloads plugin but does not remove from list
    PushMapPosition(Plugins())
    
    If  Not FindMapElement(Plugins(), Filename)
        PopMapPosition(Plugins())
        ProcedureReturn #False
    EndIf
        
    If Plugins(Filename)\Library_ID = 0 Or Plugins(Filename)\Loaded = #False
        ProcedureReturn #False
    EndIf
    
    Plugin_Deinitialize(Filename)
    CloseLibrary(Plugins(Filename)\Library_ID)
    Plugins()\Library_ID = 0
    Log_Add("Plugin", Lang_Get("", "Plugin unloaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    Plugins()\Loaded = #False
    
    PopMapPosition(Plugins())
    ProcedureReturn #True
EndProcedure

Procedure Plugin_Load(Filename.s) ; Lädt die Lib (Wenn in der Liste vorhanden) / Loads the library (If its in the list)
    If Not FindMapElement(Plugins(), Filename)
        ProcedureReturn #False
    EndIf
        
    If Plugins(Filename)\Loaded
        PushMapPosition(Plugins())
        Plugin_Unload(Filename)
        PopMapPosition(Plugins())
    EndIf
    
    Plugins(FIlename)\Library_ID = OpenLibrary(#PB_Any, Filename)
    
    If Plugins()\Library_ID = 0
        Log_Add("Plugin", Lang_Get("", "Plugin not loaded: Can't open it", Filename), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        ProcedureReturn #False
    EndIf
    
    If Plugin_Initialize(Filename) = #True
        Log_Add("Plugin", Lang_Get("", "Plugin loaded", Filename, Plugins(Filename)\Plugin_Info\Name, Plugins(Filename)\Plugin_Info\Author), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        ProcedureReturn #True
    EndIf
    
    Plugin_Unload(Filename)
    Log_Add("Plugin", Lang_Get("", "Plugin not loaded: Incompatible", Filename, Str(Plugins()\Plugin_Info\Version)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    ProcedureReturn #False    
EndProcedure

Procedure Plugin_Check_Files(Directory.s)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            Suffix.s = ".x86.dll"
        CompilerElse
            Suffix.s = ".x64.dll"
        CompilerEndIf
    CompilerElse
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            Suffix.s = ".x86.so"
        CompilerElse
            Suffix.s = ".x64.so"
        CompilerEndIf
    CompilerEndIf
    
    ; ##################### gelöschte Plugins entladen + von Liste entfernen / Removed unused plugins from list
    
    ForEach Plugins()
        If FileSize(Plugins()\Filename) <> -1
            Continue
        EndIf
        
        If Plugin_Unload(Plugins()\Filename) = #True
            DeleteMapElement(Plugins())
        EndIf
    Next
    
    ; ##################### neue Plugins zur Liste hinzufügen / Add new plugins to the list
    
    If Right(Directory, 1) = "/" Or Right(Directory, 1) = "\"
        Directory = Left(Directory, Len(Directory)-1)
    EndIf
    
    Directory_ID = ExamineDirectory(#PB_Any, Directory, "*.*")
    
    If Directory_ID
        While NextDirectoryEntry(Directory_ID)
            Entry_Name.s = DirectoryEntryName(Directory_ID)
            
            If Entry_Name = "." Or Entry_Name = ".."
                Continue
            EndIf
            
            Filename.s = Directory + "/" + Entry_Name
            
            If DirectoryEntryType(Directory_ID) = #PB_DirectoryEntry_File
                If LCase(Right(Entry_Name, Len(Suffix))) = Suffix
                    If FindMapElement(Plugins(), Filename)
                        Continue
                    EndIf
                    
                    AddMapElement(Plugins(), Filename)
                    Plugins()\Filename = Filename
                    Plugins()\Plugin_Info\Name = Left(GetFilePart(Filename), Len(GetFilePart(Filename))-Len(Suffix))
                EndIf
            Else
                Plugin_Check_Files(Filename)
            EndIf
            
        Wend
        FinishDirectory(Directory_ID)
    EndIf
    
    ; ################### Plugins laden / Load plugins
    ForEach Plugins()
        File_Date = GetFileDate(Plugins()\Filename, #PB_Date_Modified)
        
        If Plugins()\File_Date_Last = File_Date
            Continue
        EndIf
        
        Plugins()\File_Date_Last = File_Date
        Plugin_Load(Plugins()\Filename)
    Next
    
EndProcedure

Procedure Plugin_Main()
    If Plugin_Main\Timer_File_Check < Milliseconds()
        Plugin_Main\Timer_File_Check = Milliseconds() + 1000
        Plugin_Check_Files(Files_Folder_Get("Plugins"))
    EndIf
    
    ; ########## Main bei den Plugins ausführen / Run main function in the plugins
    
    ForEach Plugins()
        If Not Plugins()\Library_ID
            Continue
        EndIf
        
        If Not Plugins()\Functions\Main
            Continue
        EndIf
        
        Plugins()\Functions\Main()
    Next
EndProcedure

Procedure Plugin_Thread(*Dummy)
    Repeat
        LockMutex(Main\Mutex)
        
        Watchdog_Watch("Plugin_Main", "Begin Thread-Slope", 0)
        
        Plugin_Main()
        
        UnlockMutex(Main\Mutex)
        
        Watchdog_Watch("Plugin_Main", "End Thread-Slope", 2)
        
        Delay(100)
    ForEver
EndProcedure
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 119
; FirstLine = 115
; Folding = 8---0-----8-
; EnableXP
; DisableDebugger
; CompileSourceDirectory