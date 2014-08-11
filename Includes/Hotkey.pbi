Structure Hotkey_Main
    Timer_File_Check.l
    File_Date_Last.l
EndStructure

Structure Hotkey
    Label.s
    Action.s
    Keycode.l
    Keymods.b
EndStructure

Global Hotkey_Main.Hotkey_Main
Global NewList Hotkeys.Hotkey()

Declare Hotkeys_Save(Filename.s)

Procedure Hotkey_Remove(Label.s)
    ForEach Hotkeys()
        If Hotkeys()\Label = Label
            DeleteElement(Hotkeys())
            Hotkeys_Save(Files_File_Get("Hotkeys"))
            ProcedureReturn
        EndIf
    Next
EndProcedure

Procedure Hotkey_Add(Label.s, Action.s, Keycode.l, Keymods.b)
    Hotkey_Remove(Label)
    AddElement(Hotkeys())
    Hotkeys()\Label = Label
    Hotkeys()\Action = Action
    Hotkeys()\Keycode = Keycode
    Hotkeys()\Keymods = Keymods
    
    Hotkeys_Save(Files_File_Get("Hotkeys"))
EndProcedure

Procedure Hotkeys_Load(Filename.s)
    ClearList(Hotkeys())
    
    If OpenPreferences(Filename) <> 0
        If ExaminePreferenceGroups()
            While NextPreferenceGroup()
                AddElement(Hotkeys())
                
                Hotkeys()\Label = PreferenceGroupName()
                Hotkeys()\Action = ReadPreferenceString("Action", "")
                Hotkeys()\Keycode = ReadPreferenceInteger("Keycode", 0)
                Hotkeys()\Keymods = ReadPreferenceInteger("Modifier", 0)
            Wend
        EndIf
    Else
        Log_Add("Hotkeys", "Error loading hotkeys.", 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        ProcedureReturn
    EndIf
    ClosePreferences()
    Log_Add("Hotkeys", "Hotkeys loaded", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
EndProcedure

Procedure Hotkeys_Save(Filename.s)
    If FileSize(Filename) <> -1
        DeleteFile(Filename)
    EndIf
    
    If CreatePreferences(Filename) <> 0
        ForEach Hotkeys()
            PreferenceGroup(Hotkeys()\Label)
            PrintN(Str(Hotkeys()\Keycode))
            WritePreferenceString("Action", Hotkeys()\Action)
            WritePreferenceLong("Keycode", Hotkeys()\Keycode)
            WritePreferenceInteger("Modifier", Hotkeys()\Keymods)
        Next
    Else
        Log_Add("Hotkeys", "Error saving hotkeys.", 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        ProcedureReturn
    EndIf
    ClosePreferences()
    
    Hotkey_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Hotkeys", "Hotkeys saved", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
EndProcedure

Procedure Hotkey_Main()
  File_Date = GetFileDate(Files_File_Get("Hotkeys"), #PB_Date_Modified)
  
  If Hotkey_Main\File_Date_Last <> File_Date
      Hotkeys_Load(Files_File_Get("Hotkeys"))
      Hotkey_Main\File_Date_Last = File_Date
  EndIf
EndProcedure

RegisterCore("Hotkeys", 1000, #Null, #Null, @Hotkey_Main())
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 82
; FirstLine = 33
; Folding = -
; EnableThread
; EnableXP
; EnableOnError
; CompileSourceDirectory