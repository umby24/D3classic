UsePNGImageEncoder()
UseSQLiteDatabase()

; ########################################## Documentation ######################################
;
; Todo:
; - Name shortcuts (/tp umb rather than /tp umby24)
; - Console Input

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
; Map unloading system occationally causes a server crash.

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
  Mutex.i             ; Main mutex
  Running_Time.l      ; Time since the server started (using Date())
EndStructure

Global Main.Main
XIncludeFile "Shared Includes/Main_Structures.pbi"

XIncludeFile "Headers.pbi"
Global NewList Player_List.Player_List()
Global NewList Map_Data.Map_Data()
Global NewList Entity.Entity()
Global Running = 0
Global FreeID.w = 0 ; For CPE stuff.
Global NextID.w = 0
; ########################################## Ladekram / Loading ############################################

Main\Version = 1015 ;#PB_Editor_CompileCount*0.4 + #PB_Editor_BuildCount*4.9

Main\Running_Time = Date()

; ########################################## Declares ############################################

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

XIncludeFile "Includes/Events.pbi"
XIncludeFile "Includes/Files.pbi"
XIncludeFile "Includes/Math.pbi"
XIncludeFile "Includes/Mem.pbi"
XIncludeFile "Includes/Watchdog.pbi"
XIncludeFile "Includes/Log.pbi"
XIncludeFile "Includes/String.pbi"
XIncludeFile "Includes/Language.pbi"
XIncludeFile "Includes/Network.pbi"
XIncludeFile "Network/NetworkClientOutput.pbi"
XIncludeFile "Network/NetworkClientInput.pbi"
XIncludeFile "Includes/Error.pbi"
XIncludeFile "Network/Packets.pbi"
XIncludeFile "Includes/System.pbi"
XIncludeFile "Includes/Block.pbi"
XIncludeFile "Includes/NBT.pbi"
;XIncludeFile "Includes/ClassicWorld.pbi"
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
XIncludeFile "Includes/Command.pbi"
;XIncludeFile "Includes/Answer.pbi"
XIncludeFile "Includes/TMessage.pbi"
XIncludeFile "Includes/Font.pbi"
XIncludeFile "Includes/Undo.pbi"
;XIncludeFile "Includes/View_3D.pbi"
XIncludeFile "Includes/Network_Functions.pbi"
XIncludeFile "Includes/Entity.pbi"
XIncludeFile "Includes/Hotkey.pbi"
XIncludeFile "Includes/CPE.pbi"

; ########################################## Proceduren / Procedures ##########################################

; ########################################## Initkram / Init ##########################################

OpenConsole("D3 Server " + Main\Version)

Main\Mutex = CreateMutex()

Language_Strings_Load(Files_File_Get("Language_Strings"))

Network_Settings\Port = 25565
Network_Load(Files_File_Get("Network"))
      
;GZip_Init()

Player_Load(Files_File_Get("Player"))
Player_List_Load(Files_File_Get("Playerlist"))
Player_List_Load_Old("Data/Playerlist.txt") ; Load old playerlist
Block_Load(Files_File_Get("Block"))
Command_Load(Files_File_Get("Command"))
;Answer_Load(Files_File_Get("Answer"))
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
Running = 1

While Running = #True
  
  LockMutex(Main\Mutex)
  
  Watchdog_Watch("Main", "Begin Mainslope", 0)
  
  CoreLoop()
  
  UnlockMutex(Main\Mutex)
  
  Watchdog_Watch("Main", "End Mainslope", 2)
  
  Delay(3) ; ############## Sicherer Wartebereich / Safe Waiting Area
  
Wend

CoreShutdown()
; ########################################## Ende / End ##########################################
; IDE Options = PureBasic 5.30 (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 182
; FirstLine = 165
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