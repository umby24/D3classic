UsePNGImageEncoder()
UseSQLiteDatabase()

; ########################################## Dokumentation ######################################
;
; Todo:
; - Gui (eventuell �ber html)
; - Logdatei/debugmessages --> gui
; - Textausgabe (zum Clienten) �berpr�fen auf ung�ltige zeichen
; - Killareas oder rang-beschr�nkte bereiche
; - Wortfilter / Wort'highlighter'
; - Tag-Nachzyklus (Bl�cke dazu)
; - Wettersystem (Regen, Gewitter, Schnee)
; - Answersystem verbessern (/me, Globalausgabe, Mapausgabe, Privatausgabe..., Einsetzen von Operanden)
; - Nur Mitglieder funktion
; - IRC-Chat einbinden
; - Wildcards f�r Benutzer
; - Abk�rzungen f�r Befehle/Materialien
; - Farbcodes
; - Textvervollst�ndigung
; - Hack-prevention (Fliegen, Noclip, Speedhack, Au�erhalb der Karte, Distance)
; - Spam detection
; - Grief detection
; - Spielerzahl / Doppelte Spielernamen / Doppelte IP's... begrenzen
; - Place max/min wenn au�erhalb der karte
; - Backupsystem
; - IDs anstatt namen, materialnummern anstatt namen...
; - System f�r eindeutige clientnummern verbessern
; - Client_Op_mode verbessern (Ab bestimmtem Rang)
; - Mapstats als HTML (Changes/s, Usage, Physics, User...)
; - Bei Kartenwechsel, dem Benutzer die Karte anzeigen...
; - Blockchangeing-Spielerinformation mitverschieben
; - DDOS abwehrsystem
; - IP-Ban
; - Image (Als bild) der Speicherbelegung erstellen
; - Kollisionskontrolle fehlerhaft (Acid.../Rundungsfehler...)
; - Koordinaten +16 (Halben block eventuell)
; - M�glichkeit, maps komprimiert zu speichern
; - Speichern, von wem der Rang ge�ndert wurde/ wer gemuted hat / gekick / gebannt...
; - Blockchanges bei pget nur an einen Spieler senden
; - Ping (N-Befehl 1)
; - Andere beweg/rotier befehle (Netzwerk...)
; - Spielernamen und Farbe �nderbar
; - LUA-Scripts pro map.
; - Spezifischer Rang pro map...
; - Block�nderung Spielernummer als Word
; - Messageblocks
; - Willkommensnachricht per Map
; - Serverausschalten richtig machen (Speichern warten...)
; - Beim Shutdown kickscreen...


; - Befehle:
;   - Servereinstellungen ver�ndern...
;   - Votekick
;   - Voteban
;   - Setownspawn (Spieler kann seinen Spawn setzen)
;   - AFK
;   - 'Timed Messages' ausschalten
;   - Private nachrichten / Rang-Nachrichten
;   - Spieler Folgen modus (Ich sehe das was du siehst)
;   - Unsichtbar machen
;   - Spieler umbenennen
;   - Stop/unstop physics
;   - Report Griefer Command
;   - Report Bug Command
;   - Abfragen der Kartengr��e
;   - Copy/Paste extra (mit Rang, last player...)
;   - Importierte Maps rotieren
;   - Neue baufunktionen: Text, Circle, Sphere, Bezier, Polygon, Paint (Hohl und gef�llt...)
;   - RulerBox, gibt volumen l�nge bla blub zur�ck, Rouler line...
;   - Spielerliste auf andern karten... (Players [Map]...)
;   - Mapstats (Changes/s, Usage, Physics, User, Size...)
;   - Undo
;   - Reload Map m�glichkeit bei Box / Extra befehl (f�r h�heren Rang)
;   - /material water brick (beim bauen von 'Brick' ersetzen durch 'Water'...)
;   - bei R-Get auch kartenbeschr�nkung ausgeben
;   - Compass / Coordinaten abfragen...
;   - PGetBox
;   - Kill / Suicide
;   - Pinfo: (Stundenz�hler, Karte/n, Muted, Letzter login, erster login, letzte Aktion (Zeit), hinterlegte infos, Gesamtzeit...)
;   - Infos in Spieler hinterlegen/Abfragen
;   - Stop/Start(Disable/Protect) Maps
;   - TimeMute funktion �ber Date() machen, dauerhaft speichern
;   - Mute / Demute (Ohne Zeit, Demute deaktiviert Zeit...)
;   - Individuelle Namen der Befehle...
;   - Mapimport: namen des Importeurs als Blockinfo ablegen...

; - Materialien:
;   - Feuer
;   - 'Normale' Schw�mme (Kein Draining von Seen)
;   - Blitz
;   - Andere Quellen/Schw�mme (Sandquelle, S�urequelle, )
;   - Wasserpumpen (bl�cke, welche wasser anheben)
;   - Treppen nicht von unten zusammenfassen
;   - Pflanzen (sterben, wachsen, Gras nur wo sonne ist....)
;   - Lava verwandelt sich zu stein nach zeit
;   - TNT explodiert (AdminTNT...)
;   - Liquid concrete
;   - Logikbl�cke
;   - Feuerwerk!
;   - Dampf
;   - Eis
;   - Hitzeblock....


; Bugs:


; Gel�ste Bugs:
; - Fehler im Sende-Ringbuffer
; - sporadische Endlosschleife im der Auswerte-funktion der empfangenen Daten
; - Bug in Setrank (mit -1 konnte man jemanden auf 255 setzen)
; - Bei wechseln bleibt spielerliste bestehen
; - Tp/Bring geht nicht immer!
; - Bring geht nicht mehr
; - Map_Block_Do bei Mapresize l�schen
; - Sand geht durch blockkanten
; - Bei kartenl�schen und kartenwechsel (erzwungen) falsche position
; - Kartenspeichern, verschieben nur wenn Temp gespeichert!
; - Beim synchronen Login von zwei Spielern wird der Name verstauscht.

; ########################################## Variablen / Variables ##########################################

Structure Main
  Version.l           ; Version 1000 = V.1.000
  Mutex.i             ; Hauptmutex
  Running_Time.l      ; Zeitpunkt (Date()), seit dem der Server l�uft
EndStructure
Global Main.Main

XIncludeFile "Shared Includes/Main_Structures.pbi"
Global NewList Player_List.Player_List()
Global NewList Map_Data.Map_Data()
Global NewList Entity.Entity()
Global FreeID.w = 0
Global NextID.w = 0
; ########################################## Ladekram / Loading ############################################

Main\Version = 1010 ;#PB_Editor_CompileCount*0.4 + #PB_Editor_BuildCount*4.9

Main\Running_Time = Date()

; ########################################## Declares ############################################

Declare Log_Add(Module.s, Message.s, Type, PB_File.s, PB_Line, PB_Procedure.s)

Declare.s Lang_Get(Language.s, Input.s, Field_0.s = "", Field_1.s = "", Field_2.s = "", Field_3.s = "")

Declare Network_Load(Filename.s)
Declare Network_Save(Filename.s)
Declare Network_Start()
Declare Network_Stop()
Declare Network_Client_Select(Client_ID, Log=1)
Declare Network_Client_Output_Write_Byte(Client_ID, Value.b)
Declare Network_Client_Kick(Client_ID, Message.s, Hide)
Declare Network_Client_Delete(Client_ID, Message.s, Show_2_All)

Declare Network_Out_Entity_Delete(Client_ID, ID_Client)
Declare Network_Out_Entity_Position(Client_ID, ID_Client, X.f, Y.f, Z.f, Rotation.f, Look.f)
Declare Network_Out_Block_Set(Client_ID, X, Y, Z, Type.a)
Declare Network_Out_Block_Set_2_Map(Map_ID, X, Y, Z, Type.a)

Declare System_Message_Network_Send(Client_ID, Message.s)
Declare System_Message_Network_Send_2_All(Map_ID, Message.s)
Declare System_Login_Screen(Client_ID, Message_0.s, Message_1.s, Op_Mode)
Declare System_Red_Screen(Client_ID, Message.s)

Declare Map_Action_Add_Save(Client_ID, Map_ID, Directory.s)
Declare Map_Action_Add_Load(Client_ID, Map_ID, Directory.s)
Declare Map_Action_Add_Resize(Client_ID, Map_ID, X, Y, Z)
Declare Map_Action_Add_Fill(Client_ID, Map_ID, Function_Name.s, Argument_String.s)
Declare Map_Action_Add_Delete(Client_ID, Map_ID)

Declare.s Map_Get_MOTD_Override(Map_ID)
Declare Map_Delete(Map_ID)
Declare Map_Load(Map_ID, Filename.s)
Declare Map_Add(Map_ID, X, Y, Z, Name.s)
Declare Map_Fill(Map_ID, Filename.s, Argument_String.s)
Declare Map_Send(Client_ID, Map_ID)
Declare Map_Resend(Map_ID)
Declare Map_Overview_Save_2D(*Map_Data_Element, Filename.s)
Declare Map_Overview_Save_Iso_Fast(*Map_Data_Element, Filename.s)
Declare Map_Block_Change(Player_Number, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Priority.a)
Declare Map_Block_Change_Player(*Player.Player_List, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
Declare Map_Block_Move(*Map_Data.Map_Data, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Priority, Undo, Physic)
Declare Map_Select_ID(Map_ID, Log=1)
Declare Map_HackControl_Set(*Map_Data.Map_Data, Flying, NoClip, Speeding, SpawnControl, ThirdPerson, Weather, JumpHeight.w)

Declare Physic_Block_Compute_10(Map_ID, X.l, Y.l, Z.l)
Declare Physic_Block_Compute_11(Map_ID, X.l, Y.l, Z.l)
Declare Physic_Block_Compute_20(Map_ID, X.l, Y.l, Z.l)
Declare Physic_Block_Compute_21(Map_ID, X.l, Y.l, Z.l)

Declare Player_List_Select(Name.s, Log=1)
Declare Player_List_Select_Number(Number, Log=1)
Declare Player_List_Get_Pointer(Number, Log=1)

Declare Player_Kick(Player_Number, Reason.s, Count, Log, Show)
Declare Player_Ban(Player_Number, Reason.s)
Declare Player_Unban(Player_Number)
Declare Player_Stop(Player_Number, Reason.s)
Declare Player_Unstop(Player_Number)
Declare.s Player_Get_Prefix(Player_Number)
Declare.s Player_Get_Name(Player_Number)
Declare.s Player_Get_Suffix(Player_Number)

Declare Client_Login(Client_ID, Name.s, MPPass.s, Version)
Declare Client_Logout(Client_ID, Message.s, Show_2_All)

Declare Entity_Select_ID(ID, Log=1)
Declare Entity_Select_Name(Name.s, Log=1)
Declare Entity_Delete(ID)
Declare Entity_Add(Name.s, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f)
Declare Entity_Resend(ID)
Declare Entity_Message_2_Clients(ID, Message.s)
Declare Entity_Position_Set(ID, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
Declare.s Entity_Displayname_Get(ID)
Declare Entity_Displayname_Set(ID, Prefix.s, Name.s, Suffix.s)
Declare Entity_Get_Pointer(ID)
Declare Entity_Kill(ID)

Declare Rank_Select(Rank, Exact=0)
Declare Rank_Get_On_Client(Rank, Exact=0)

Declare Chat_Message_Network_Send_2_All(Entity_ID, Message.s)
Declare Chat_Message_Network_Send_2_Map(Entity_ID, Message.s)
Declare Chat_Message_Network_Send(Entity_ID, Player_Name.s, Message.s)

Declare Build_Mode_Distribute(Client_ID, Map_ID, X, Y, Z, Mode, Block_Type.a)
Declare Build_Mode_Set(Client_ID, Build_Mode.s)
Declare Build_Mode_Line(Client_ID, Map_ID, X, Y, Z, Mode, Type)
Declare Build_Mode_Box(Client_ID, Map_ID,  X, Y, Z, Mode, Type)
Declare Build_Mode_Restricted_Box(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Teleporter_Box(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Block_Get(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Restricted_Get(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Player_Get(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Map_Export(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Map_Import(Client_ID, Map_ID, X, Y, Z, Mode)
Declare Build_Mode_Sphere(Client_ID, Map_ID, X, Y, Z, Mode, Type)
Declare Build_Mode_Teleporter_Get(Client_ID, Map_ID, X, Y, Z, Mode)

Declare Font_Draw_Text(Player_Number, Font_ID.s, Map_ID, X, Y, Z, V_X.f, V_Y.f, String.s, Material_F, Material_B)
Declare Font_Draw_Text_Player(*Player.Player_List, Font_ID.s, Map_ID, X, Y, Z, V_X.f, V_Y.f, String.s, Material_F, Material_B)

Declare Command_Do(Client_ID, Input.s)

Declare Answer_Do()

;Declare Heartbeat_Salt_Get()

Declare Plugin_Event_Block_Physics(Destination.s, *Map_Data.Map_Data, X, Y, Z)
Declare Plugin_Event_Block_Create(Destination.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
Declare Plugin_Event_Block_Delete(Destination.s, *Map_Data.Map_Data, X, Y, Z, Old_Block.a, *Client.Network_Client)
Declare Plugin_Event_Map_Fill(Destination.s, *Map_Data.Map_Data, Argument_String.s)
Declare Plugin_Event_Command(Destination.s, *Client.Network_Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
Declare Plugin_Event_Build_Mode(Destination.s, *Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode, Block_Type)
Declare Plugin_Event_Client_Add(*Client.Network_Client)
Declare Plugin_Event_Client_Delete(*Client.Network_Client)
Declare Plugin_Event_Client_Verify_Name(Name.s, Pass.s)
Declare Plugin_Event_Client_Verify_Name_MC(Name.s, Pass.s)
Declare Plugin_Event_Client_Login(*Client.Network_Client)
Declare Plugin_Event_Client_Logout(*Client.Network_Client)
Declare Plugin_Event_Map_Add(*Map_Data.Map_Data)
Declare Plugin_Event_Map_Action_Delete(Action_ID, *Map_Data.Map_Data)
Declare Plugin_Event_Map_Action_Resize(Action_ID, *Map_Data.Map_Data)
Declare Plugin_Event_Map_Action_Fill(Action_ID, *Map_Data.Map_Data)
Declare Plugin_Event_Map_Action_Save(Action_ID, *Map_Data.Map_Data)
Declare Plugin_Event_Map_Action_Load(Action_ID, *Map_Data.Map_Data)
Declare Plugin_Event_Map_Block_Change(Player_Number, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
Declare Plugin_Event_Map_Block_Change_Client(*Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode.a, Type.a)
Declare Plugin_Event_Map_Block_Change_Player(*Player.Player_List, *Map_Data.Map_Data, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
Declare Plugin_Event_Chat_Map(*Entity.Entity, Message.s)
Declare Plugin_Event_Chat_All(*Entity.Entity, Message.s)
Declare Plugin_Event_Chat_Private(*Entity.Entity, Player_Name.s, Message.s)

Declare Undo_Add(Player_Number, Map_ID, X, Y, Z, Type_Before.b, Player_Before)
Declare Undo_Do_Time(Map_ID, Time)
Declare Undo_Do_Player(Map_ID, Player_Number, Time)
Declare Undo_Clear_Map(Map_ID)

;Declare Protect_Destruct_Start()

Declare CPE_Send_ExtInfo(Client_ID, Name.s, MPPass.s, Version)
Declare CPE_Send_Extensions(Client_ID)
Declare CPE_HoldThis(Client_ID, Block, CanChange)
Declare.s Emote_Replace(Message.s)

Declare CPE_Selection_Cuboid_Add(Client_ID, SelectionID, Label.s, StartX.w, StartY.w, StartZ.w, EndX.w, EndY.w, EndZ.w, Red.w, Green.w, Blue.w, Opacity.w)
Declare CPE_Selection_Cuboid_Delete(Client_ID, Selection_ID)

Declare.i Map_Export_Get_Size_X(Filename.s)
Declare.i Map_Export_Get_Size_Y(Filename.s)
Declare.i Map_Export_Get_Size_Z(Filename.s)

Declare CPE_Model_Change(Client_ID, Model.s)
Declare CPE_Handle_Entity()
Declare CPE_Set_Weather(Client_ID, Weather.b)
Declare CPE_Aftermap_Actions(Client_ID, *MapData)
Declare Map_Env_Colors_Change(*Map_Data.Map_Data, Red, Green, Blue, Type)

Declare System_Message_Status1_Send(Client_ID, Message.s)
Declare System_Message_Status2_Send(Client_ID, Message.s)
Declare System_Message_Status3_Send(Client_ID, Message.s)
Declare System_Message_BR1_Send(Client_ID, Message.s)
Declare System_Message_BR2_Send(Client_ID, Message.s)
Declare System_Message_BR3_Send(Client_ID, Message.s)
Declare System_Message_TopLeft_Send(Client_ID, Message.s)
Declare System_Message_Announcement_Send(Client_ID, Message.s)

Declare System_Message_Status1_Send_2_All(Map_ID, Message.s)
Declare System_Message_Status2_Send_2_All(Map_ID, Message.s)
Declare System_Message_Status3_Send_2_All(Map_ID, Message.s)
Declare System_Message_BR1_Send_2_All(Map_ID, Message.s)
Declare System_Message_BR2_Send_2_All(Map_ID, Message.s)
Declare System_Message_BR3_Send_2_All(Map_ID, Message.s)
Declare System_Message_TopLeft_Send_2_All(Map_ID, Message.s)
Declare System_Message_Announcement_Send_2_All(Map_ID, Message.s)

Declare CPE_Client_Set_Block_Permissions(Client_ID, Block_ID, CanPlace, CanDelete)
Declare CPE_Client_Send_Map_Appearence(Client_ID, URL.s, Side_Block, Edge_Block, Side_Level.w)
Declare Map_Env_Appearance_Set(*Map_Data.Map_Data, Texture.s, Side_Block, Edge_Block, Side_Level.w)
Declare CPE_Client_Hackcontrol_Send(Client_ID, Flying, Noclip, Speeding, SpawnControl, ThirdPerson, WeatherControl, Jumpheight.w)
Declare CPE_Client_Send_Hotkeys(Client_ID)
Declare Hotkey_Add(Label.s, Action.s, Keycode.l, Keymods.b)
Declare Hotkey_Remove(Label.s)
; ########################################## Macros ##############################################

Macro List_Store(Pointer, Listname)
  If ListIndex(Listname) <> -1
    Pointer = Listname
  Else
    Pointer = 0
  EndIf
EndMacro

Macro List_Restore(Pointer, Listname)
  If Pointer
    ChangeCurrentElement(Listname, Pointer)
  EndIf
EndMacro

Macro Milliseconds()
  (ElapsedMilliseconds() & 2147483647)
EndMacro

; ########################################## Includes ############################################


XIncludeFile "Includes/Files.pbi"
XIncludeFile "Includes/Math.pbi"
XIncludeFile "Includes/Mem.pbi"
XIncludeFile "Includes/Watchdog.pbi"
XIncludeFile "Includes/Log.pbi"
XIncludeFile "Includes/String.pbi"
XIncludeFile "Includes/Language.pbi"
XIncludeFile "Includes/Network.pbi"
XIncludeFile "Includes/Error.pbi"
XIncludeFile "Includes/System.pbi"
XIncludeFile "Includes/Block.pbi"
XIncludeFile "Includes/GZip.pbi"
XIncludeFile "Includes/Location.pbi"
XIncludeFile "Includes/Teleporter.pbi"
XIncludeFile "Includes/Rank.pbi"
XIncludeFile "Includes/Map.pbi"
XIncludeFile "Includes/Map_Overview.pbi"
XIncludeFile "Includes/Build.pbi"
XIncludeFile "Includes/Physic.pbi"
XIncludeFile "Includes/Player_List.pbi"
XIncludeFile "Includes/Player.pbi"
XIncludeFile "Includes/Client.pbi"
XIncludeFile "Includes/Chat.pbi"
XIncludeFile "Includes/Build_Mode.pbi"
XIncludeFile "Includes/Plugin.pbi"
;XIncludeFile "Includes/Trace.pbi"
XIncludeFile "Includes/Command.pbi"
XIncludeFile "Includes/Answer.pbi"
XIncludeFile "Includes/TMessage.pbi"
XIncludeFile "Includes/Font.pbi"
XIncludeFile "Includes/Undo.pbi"
;XIncludeFile "Includes/Protect.pbi"
XIncludeFile "Includes/View_3D.pbi"
XIncludeFile "Includes/Network_Functions.pbi"
XIncludeFile "Includes/Entity.pbi"
XIncludeFile "Includes/Hotkey.pbi"
XIncludeFile "Includes/CPE.pbi"

; ########################################## Proceduren / Procedures ##########################################

; ########################################## Initkram / Init ##########################################

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  OpenConsole()
CompilerEndIf

Main\Mutex = CreateMutex()

Language_Strings_Load(Files_File_Get("Language_Strings"))

Network_Settings\Port = 25565
Network_Load(Files_File_Get("Network"))
      
GZip_Init()

Player_Load(Files_File_Get("Player"))
Player_List_Load(Files_File_Get("Playerlist"))
Player_List_Load_Old("Data/Playerlist.txt") ; L�dt die alte Spielerliste!
Block_Load(Files_File_Get("Block"))
Command_Load(Files_File_Get("Command"))
Answer_Load(Files_File_Get("Answer"))
Location_Load(Files_File_Get("Location"))
Rank_Load(Files_File_Get("Rank"))
TMessage_Load(Files_File_Get("Timed_Messages"))

Network_Start()

Map_Main\Blockchanging_Thread_ID = CreateThread(@Map_Blockchanging_Thread(), 0)
Map_Main\Physic_Thread_ID = CreateThread(@Map_Physic_Thread(), 0)
Map_Main\Action_Thread_ID = CreateThread(@Map_Action_Thread(), 0)
Client_Main\Login_Thread_ID = CreateThread(@Client_Login_Thread(), 0)
Plugin_Main\Plugin_Thread_ID = CreateThread(@Plugin_Thread(), 0) ; -- oo, shiny.

Watchdog_Thread_ID_Set("Map_Blockchanging", Map_Main\Blockchanging_Thread_ID)
Watchdog_Thread_ID_Set("Map_Physic", Map_Main\Physic_Thread_ID)
Watchdog_Thread_ID_Set("Map_Action", Map_Main\Action_Thread_ID)
Watchdog_Thread_ID_Set("Client_Login", Client_Main\Login_Thread_ID)
Watchdog_Thread_ID_Set("Plugin_Main", Plugin_Main\Plugin_Thread_ID) ; -- New!

; ########################################## Hautpschleife / Main Loop ##########################################

Repeat
  
  LockMutex(Main\Mutex)
  
  Watchdog_Watch("Main", "Begin Mainslope", 0)
  
  Watchdog_Watch("Main", "Before: Files_Main()", 1)
  Files_Main()
  
  Watchdog_Watch("Main", "Before: Mem_Main()", 1)
  Mem_Main()
  
  Watchdog_Watch("Main", "Before: Network_Events()", 1)
  Network_Events()
  
  Watchdog_Watch("Main", "Before: Network_Input_Do()", 1)
  Network_Input_Do()
  
  Watchdog_Watch("Main", "Before: Network_Output_Do()", 1)
  Network_Output_Do()
  
  Watchdog_Watch("Main", "Before: Network_Output_Send()", 1)
  Network_Output_Send()
  
  Watchdog_Watch("Main", "Before: Network_Main()", 1)
  Network_Main()
  
  Watchdog_Watch("Main", "Before: System_Main()", 1)
  System_Main()
  
  Watchdog_Watch("Main", "Before: Location_Main()", 1)
  Location_Main()
  
  Watchdog_Watch("Main", "Before: Teleporter_Main()", 1)
  Teleporter_Main()
  
  Watchdog_Watch("Main", "Before: Log_Main()", 1)
  Log_Main()
  
  Watchdog_Watch("Main", "Before: Player_List_Main()", 1)
  Player_List_Main()
  
  Watchdog_Watch("Main", "Before: Player_Main()", 1)
  Player_Main()
  
  Watchdog_Watch("Main", "Before: Client_Main()", 1)
  Client_Main()
  
  Watchdog_Watch("Main", "Before: Language_Main()", 1)
  Language_Main()
  
  Watchdog_Watch("Main", "Before: Block_Main()", 1)
  Block_Main()
  
  Watchdog_Watch("Main", "Before: Map_Main()", 1)
  Map_Main()
  
  Watchdog_Watch("Main", "Before: Build_Main()", 1)
  Build_Main()
  
  Watchdog_Watch("Main", "Before: Physic_Main()", 1)
  Physic_Main()
  
  ;Watchdog_Watch("Main", "Before: Heartbeat_Main()", 1)
  ;Heartbeat_Main()
  
  Watchdog_Watch("Main", "Before: Build_Mode_Main()", 1)
  Build_Mode_Main()
  
  Watchdog_Watch("Main", "Before: Command_Main()", 1)
  Command_Main()
  
  Watchdog_Watch("Main", "Before: Answer_Main()", 1)
  Answer_Main()
  
  Watchdog_Watch("Main", "Before: Rank_Main()", 1)
  Rank_Main()
  
  Watchdog_Watch("Main", "Before: TMessage_Main()", 1)
  TMessage_Main()
  
  Watchdog_Watch("Main", "Before: String_Main()", 1)
  String_Main()
  
  Watchdog_Watch("Main", "Before: Font_Main()", 1)
  Font_Main()
  
  Watchdog_Watch("Main", "Before: Undo_Main()", 1)
  Undo_Main()
  
  ;Watchdog_Watch("Main", "Before: Protect_Main()", 1)
  ;Protect_Main()
  
  Watchdog_Watch("Main", "Before: View_3D_Main()", 1)
  View_3D_Main()
  
  ;Watchdog_Watch("Main", "Before: Plugin_Main()", 1)    -- Now handled in threads!
  ;Plugin_Main()
  
  Watchdog_Watch("Main", "Before: Entity_Main()", 1)
  Entity_Main()
  
  ;Watchdog_Watch("Main", "Before: Trace_Main()", 1)
  ;Trace_Main()
  
  Watchdog_Watch("Main", "Before: Hotkey_Main()", 1)
  Hotkey_Main()
  
  UnlockMutex(Main\Mutex)
  
  Watchdog_Watch("Main", "End Mainslope", 2)
  
  Delay(3) ; ############## Sicherer Wartebereich / Safe Waiting Area
  
ForEver

; ########################################## Ende / End ##########################################
; IDE Options = PureBasic 5.00 (Linux - x86)
; ExecutableFormat = Console
; CursorPosition = 382
; FirstLine = 373
; Folding = -
; EnableThread
; EnableXP
; EnableOnError
; Executable = Minecraft-Server.x86.exe
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 5.00 (Windows - x86)
; EnablePurifier
; EnableCompileCount = 3273
; EnableBuildCount = 205