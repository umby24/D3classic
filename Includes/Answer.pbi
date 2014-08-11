; ########################################## Variables ##########################################

Structure Answer_Main
  Save_File.b             ; Indicates whether to save
  File_Date_Last.l        ; Date of last change, saves file on change.
  Timer_File_Check.l      ; Timer for checking file size
EndStructure
Global Answer_Main.Answer_Main

Structure Answer
  Command.s                             ; Expected command
  Operator.s [#Command_Operators_Max]   ; Expected operators
  Answer.s                              ; Reply
EndStructure
Global NewList Answer.Answer()

; ########################################## Constants ############################################

; ########################################## Declares ############################################

; ########################################## Procedures ##########################################

Procedure Answer_Load(Filename.s)
  If OpenPreferences(Filename)
    
    ClearList(Answer())
    
    If ExaminePreferenceGroups()
      While NextPreferenceGroup()
        AddElement(Answer())
        Answer()\Command = ReadPreferenceString("Command", "")
        
        For i = 0 To #Command_Operators_Max-1
          Answer()\Operator [i] = ReadPreferenceString("Operator["+Str(i)+"]", "")
        Next
        
        Answer()\Answer = ReadPreferenceString("Answer", "")
      Wend
    EndIf
    
    Answer_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Answer", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
  EndIf
EndProcedure

Procedure Answer_Save(Filename.s)
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    ForEach Answer()
      WriteStringN(File_ID, "["+Str(ListIndex(Answer()))+"]")
      WriteStringN(File_ID, "Command = "+Answer()\Command)
      
      For i = 0 To #Command_Operators_Max-1
        WriteStringN(File_ID, "Operator["+Str(i)+"] = "+Answer()\Operator [i])
      Next
      
      WriteStringN(File_ID, "Answer = "+Answer()\Answer)
    Next
    
    Answer_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Answer", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure Answer_Do()
  ForEach Answer()
    
    Correct = 1
    
    If Answer()\Command <> LCase(Command_Main\Parsed_Command)
      Correct = 0
    EndIf
    
    For i = 0 To #Command_Operators_Max-1
      If Answer()\Operator [i] <> LCase(Command_Main\Parsed_Operator [i])
        Correct = 0
      EndIf
    Next
    
    If Correct = 1
      System_Message_Network_Send(Command_Main\Command_Client_ID, Answer()\Answer)
      Break
    EndIf
  Next
  
  ProcedureReturn Correct
EndProcedure

Procedure Answer_Main()
  If Answer_Main\Save_File
    Answer_Main\Save_File = 0
    Answer_Save(Files_File_Get("Answer"))
  EndIf
  

  File_Date = GetFileDate(Files_File_Get("Answer"), #PB_Date_Modified)
  
  If Answer_Main\File_Date_Last <> File_Date
    Answer_Load(Files_File_Get("Answer"))
  EndIf
EndProcedure

RegisterCore("Answer", 1000, #Null, #Null, @Answer_Main())
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 107
; FirstLine = 48
; Folding = -
; EnableXP
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0