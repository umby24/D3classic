; ########################################## Variablen ##########################################

Structure Undo_Main
  Save_File.b                 ; Zeigt an, ob gespeichert werden soll
  File_Date_Last.l            ; Datum letzter �nderung, bei �nderung speichern
  Timer_File_Check.l          ; Timer f�r das �berpr�fen der Dateigr��e
  Max_Steps.l                 ; Anzahl maximaler Schritte f�r Undo
EndStructure
Global Undo_Main.Undo_Main

;Structure Undo_Step
;  Player_Number.w
;  Map_ID.l
;  X.w
;  Y.w
;  Z.w
;  Time.l
;  Type_Before.b           ; Material vor �nderung
;  Player_Number_Before.w  ; Spielernummer vor �nderung
;EndStructure
Global NewList Undo_Step.Undo_Step()

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure Undo_Save(Filename.s) ; Speichert die Einstellungen / Saves Settings
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    WriteStringN(File_ID, "Max_Steps = "+Str(Undo_Main\Max_Steps))
    
    Undo_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Undo", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure Undo_Load(Filename.s) ; L�dt die Einstellungen / Loads settings
  If OpenPreferences(Filename)
    
    Undo_Main\Max_Steps = ReadPreferenceLong("Max_Steps", 100000)
    
    Undo_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Undo", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
    
  EndIf
EndProcedure

Procedure Undo_Add(Player_Number, Map_ID, X, Y, Z, Type_Before.b, Player_Before) ; Adds a step to the change tracking system
;Procedure Undo_Add_temp(*Map_Data.Map_Data, Player_Number, X, Y, Z, Type_Before.b, Player_Before)
  ;If X >= 0 And X < *Map_Data\Size_X And Y >= 0 And Y < *Map_Data\Size_Y And Z >= 0 And Z < *Map_Data\Size_Z
    FirstElement(Undo_Step())
    If InsertElement(Undo_Step())
      Undo_Step()\Player_Number = Player_Number
      Undo_Step()\Map_ID = Map_ID
      Undo_Step()\Time = Date()
      Undo_Step()\X = X
      Undo_Step()\Y = Y
      Undo_Step()\Z = Z
      Undo_Step()\Type_Before = Type_Before
      Undo_Step()\Player_Number_Before = Player_Before
    EndIf
  ;EndIf
EndProcedure

Procedure Undo_Do_Player(Map_ID, Player_Number, Time) ; Macht alle �nderungen von einem bestimmten Player r�ckg�ngig. / Undoes changes made by a particular player
  ForEach Undo_Step()
    If Undo_Step()\Player_Number = Player_Number And Undo_Step()\Time >= Time
      If Map_ID = -1 Or Undo_Step()\Map_ID = Map_ID
        Map_Block_Change(Undo_Step()\Player_Number_Before, Map_Get_Pointer(Undo_Step()\Map_ID), Undo_Step()\X, Undo_Step()\Y, Undo_Step()\Z, Undo_Step()\Type_Before, 0, 0, 1, 5)
        DeleteElement(Undo_Step(), 0)
      EndIf
    ElseIf Undo_Step()\Time < Time
      Break
    EndIf
  Next
EndProcedure

Procedure Undo_Do_Time(Map_ID, Time) ; Stellt alle Bl�cke von einem bestimmten Zeitraum wieder her. / Undoes block changes based on time.
  ForEach Undo_Step()
    If Undo_Step()\Time >= Time
      If Map_ID = -1 Or Undo_Step()\Map_ID = Map_ID
        Map_Block_Change(Undo_Step()\Player_Number_Before, Map_Get_Pointer(Undo_Step()\Map_ID), Undo_Step()\X, Undo_Step()\Y, Undo_Step()\Z, Undo_Step()\Type_Before, 0, 0, 1, 5)
        DeleteElement(Undo_Step(), 0)
      EndIf
    Else
      Break
    EndIf
  Next
EndProcedure

Procedure Undo_Clear_Map(Map_ID) ; L�scht Undo-Schritte einer Map / Removes all undo steps for a given map
  ForEach Undo_Step()
    If Undo_Step()\Map_ID = Map_ID
      DeleteElement(Undo_Step())
    EndIf
  Next
EndProcedure

Procedure Undo_Clear() ; L�scht �ltere Undo-Schritte / Removes all undo steps.
  LastElement(Undo_Step())
  While ListSize(Undo_Step()) > Undo_Main\Max_Steps
    DeleteElement(Undo_Step())
  Wend
EndProcedure

Procedure Undo_Main()
  If Undo_Main\Save_File
    Undo_Main\Save_File = 0
    Undo_Save(Files_File_Get("Undo"))
  EndIf

  File_Date = GetFileDate(Files_File_Get("Undo"), #PB_Date_Modified)
  
  If Undo_Main\File_Date_Last <> File_Date
    Undo_Load(Files_File_Get("Undo"))
  EndIf
  
  Undo_Clear()
  
EndProcedure

RegisterCore("Undo", 1000, #Null, #Null, @Undo_Main())
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 105
; FirstLine = 75
; Folding = --
; EnableXP
; DisableDebugger
; EnableCompileCount = 0
; EnableBuildCount = 0