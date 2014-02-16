; ################################################### Documentation #########################################
; 
; Todo:
;  - 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; ################################################### Includes ##############################################

XIncludeFile "../Include/Include.pbi"

; ################################################### Inits #################################################

; ################################################### Konstants #############################################

#Plugin_Name = "Heartbeat_MC"
#Plugin_Author = "David Vogel"

#Network_Temp_Buffer_Size = 1024

; ################################################### Variables #############################################

Structure Heartbeat_Main_MC
  Salt.s
  Public.a
  Thread_ID.i
  
  Timer_File_Check.l
  File_Date_Last.l
  Save_File.a
  Load_File.a
EndStructure
Global Heartbeat_Main_MC.Heartbeat_Main_MC

Structure Heartbeat_Info_MC
  Filename.s
  Port.u
  Clients.u
  Clients_Max.u
  Name.s
  Public.a
  Version.a
  Salt.s
  State.a
EndStructure

; ################################################### Declares ##############################################

; ################################################### Prototypes ############################################

; ################################################### Procedures ############################################

Procedure.s Create_Salt_MC()
  Salt.s = ""
  
  For i = 1 To 32
    Salt.s + Chr(65 + Random(25))
  Next
  
  ProcedureReturn Salt
EndProcedure

Procedure Heartbeat_Save_MC(Filename.s) ; Speichert die Einstellungen
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    WriteStringN(File_ID, "Public = "+Str(Heartbeat_Main_MC\Public))
    WriteStringN(File_ID, "Salt = "+Heartbeat_Main_MC\Salt)
    
    Heartbeat_Main_MC\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("HeartbeatMC", PeekS(Lang_Get("", "File saved", Filename)), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure Heartbeat_Load_MC(Filename.s) ; Lädt die Einstellungen
  If OpenPreferences(Filename)
    
    Heartbeat_Main_MC\Public = ReadPreferenceLong("Public", 1)
    If Heartbeat_Main_MC\Salt = ""
      Heartbeat_Main_MC\Salt = Create_Salt_MC()
    Else
      Heartbeat_Main_MC\Salt = ReadPreferenceString("Salt", Create_Salt_MC())
    EndIf
    
    Heartbeat_Main_MC\Save_File = 1
    
    Heartbeat_Main_MC\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("HeartbeatMC", PeekS(Lang_Get("", "File loaded", Filename)), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
    
  EndIf
EndProcedure

ProcedureCDLL Init(*Plugin_Info.Plugin_Info, *Plugin_Function.Plugin_Function) ; Aufgerufen beim Laden der Library / Called with the loading of the library
  *Plugin_Info\Name = #Plugin_Name
  *Plugin_Info\Version = #Plugin_Version
  *Plugin_Info\Author = #Plugin_Author
  
  InitNetwork()
  
  Heartbeat_Main_MC\Load_File = 1
  
  Define_Prototypes(*Plugin_Function)
  
  OpenConsole()
EndProcedure

ProcedureCDLL Deinit() ; Aufgerufen beim Entladen der Library / Called with the unloading of the library
  While Heartbeat_Main_MC\Thread_ID
    Delay(100)
  Wend
EndProcedure

Procedure Heartbeat_Do_MC(*Heartbeat_Info_MC.Heartbeat_Info_MC)
  
  *Heartbeat_Info_MC\Name = ReplaceString(*Heartbeat_Info_MC\Name, " ", "%20")
  
  If *Heartbeat_Info_MC\Public
    Public_String.s = "true"
  Else
    Public_String.s = "false"
  EndIf
  
  If ReceiveHTTPFile("https://www.minecraft.net/heartbeat.jsp?port="+Str(*Heartbeat_Info_MC\Port)+"&users="+Str(*Heartbeat_Info_MC\Clients)+"&max="+Str(*Heartbeat_Info_MC\Clients_Max)+"&name="+*Heartbeat_Info_MC\Name+"&public="+Public_String+"&version="+Str(*Heartbeat_Info_MC\Version)+"&salt="+*Heartbeat_Info_MC\Salt, *Heartbeat_Info_MC\Filename)
  ;If ReceiveHTTPFile("http://www.classicube.net/heartbeat.jsp?port="+Str(*Heartbeat_Info_MC\Port)+"&users="+Str(*Heartbeat_Info_MC\Clients)+"&max="+Str(*Heartbeat_Info_MC\Clients_Max)+"&name="+*Heartbeat_Info_MC\Name+"&public="+Public_String+"&version="+Str(*Heartbeat_Info_MC\Version)+"&salt="+*Heartbeat_Info_MC\Salt, *Heartbeat_Info_MC\Filename)
    *Heartbeat_Info_MC\State = 2
  Else
    *Heartbeat_Info_MC\State = 3
  EndIf
  
  Heartbeat_Main_MC\Thread_ID = 0
EndProcedure

ProcedureCDLL Event_Client_Verify_Name_MC(Name.s, Pass.s)
  Fingerprint.s = Heartbeat_Main_MC\Salt + Name
  Pass_Valid.s = MD5Fingerprint(@Fingerprint, Len(Fingerprint))
  
  If Trim(LCase(Pass_Valid)) = Trim(LCase(Pass))
    ProcedureReturn #True
  Else
    Log_Add("HeartbeatMC", Trim(LCase(Pass_Valid)) + " !=" + Trim(LCase(Pass)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    ProcedureReturn #False
  EndIf
EndProcedure

ProcedureCDLL Main()
  Static Timer
  Static Heartbeat_Info_MC.Heartbeat_Info_MC
  
  Select Heartbeat_Info_MC\State
    Case 0
      If Timer < ElapsedMilliseconds() And Heartbeat_Main_MC\Thread_ID = 0 And Heartbeat_Main_MC\Salt <> ""
        Timer = ElapsedMilliseconds() + 30000
        Heartbeat_Info_MC\Filename = PeekS(Files_File_Get("Heartbeat_HTML_MC"))
        Heartbeat_Info_MC\Port = Network_Settings_Get_Port()
        Heartbeat_Info_MC\Clients = Client_Count_Elements()
        Heartbeat_Info_MC\Clients_Max = Player_Get_Players_Max()
        Heartbeat_Info_MC\Name = PeekS(System_Get_Server_Name())
        Heartbeat_Info_MC\Public = Heartbeat_Main_MC\Public
        Heartbeat_Info_MC\Version = 7
        Heartbeat_Info_MC\Salt = Heartbeat_Main_MC\Salt
        Heartbeat_Main_MC\Thread_ID = CreateThread(@Heartbeat_Do_MC(), @Heartbeat_Info_MC)
        Heartbeat_Info_MC\State = 1
      EndIf
    Case 2
      Log_Add("HeartbeatMC", "sent", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Heartbeat_Info_MC\State = 0
    Case 3
      Log_Add("HeartbeatMC", "not sent", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Heartbeat_Info_MC\State = 0
  EndSelect
  
  ; ######## Loading/Saving
  
  If Heartbeat_Main_MC\Timer_File_Check < ElapsedMilliseconds()
    Heartbeat_Main_MC\Timer_File_Check = ElapsedMilliseconds() + 1000
    File_Date = GetFileDate(PeekS(Files_File_Get("Heartbeat")), #PB_Date_Modified)
    If Heartbeat_Main_MC\File_Date_Last <> File_Date Or Heartbeat_Main_MC\Load_File
      Heartbeat_Main_MC\Load_File = 0
      Heartbeat_Load_MC(PeekS(Files_File_Get("Heartbeat")))
    EndIf
  EndIf
  
  If Heartbeat_Main_MC\Save_File
    Heartbeat_Main_MC\Save_File = 0
    Heartbeat_Save_MC(PeekS(Files_File_Get("Heartbeat")))
  EndIf
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 173
; FirstLine = 148
; Folding = --
; EnableThread
; EnableXP
; EnableOnError
; Executable = Heartbeat_MC.x86.dll
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 5.00 (Windows - x86)