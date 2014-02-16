; ########################################## Variablen ##########################################

Structure System_Main
  Save_File.b                 ; Zeigt an, ob gespeichert werden soll
  File_Date_Last.l            ; Datum letzter �nderung, bei �nderung speichern
  Timer_File_Check.l          ; Timer f�r das �berpr�fen der Dateigr��e
  ; ---------------------------
  Server_Name.s
  MOTD.s
  Click_Distance.l
EndStructure
Global System_Main.System_Main

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure System_Save(Filename.s) ; Speichert die Einstellungen
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    WriteStringN(File_ID, "Server_Name = "+System_Main\Server_Name)
    WriteStringN(File_ID, "MOTD = "+System_Main\MOTD)
    WriteStringN(File_ID, "Click_Distance = " + Str(System_Main\Click_Distance))
    
    System_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("System", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure System_Load(Filename.s) ; L�dt die Einstellungen
  If OpenPreferences(Filename)
    
    System_Main\Server_Name = ReadPreferenceString("Server_Name", "")
    System_Main\MOTD = ReadPreferenceString("MOTD", "")
    System_Main\Click_Distance = ReadPreferenceLong("Click_Distance",160)
    
    System_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("System", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
    
  EndIf
EndProcedure

Procedure System_Main()
  If System_Main\Save_File
    System_Main\Save_File = 0
    System_Save(Files_File_Get("System"))
  EndIf
  
  If System_Main\Timer_File_Check < Milliseconds()
    System_Main\Timer_File_Check = Milliseconds() + 1000
    File_Date = GetFileDate(Files_File_Get("System"), #PB_Date_Modified)
    If System_Main\File_Date_Last <> File_Date
      System_Load(Files_File_Get("System"))
    EndIf
  EndIf
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 25
; FirstLine = 17
; Folding = -
; EnableXP
; DisableDebugger
; EnableCompileCount = 0
; EnableBuildCount = 0