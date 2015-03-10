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
;Global NewList Answer.Answer()
Global NewMap Answers.Answer()
; ########################################## Constants ############################################

; ########################################## Declares ############################################

; ########################################## Procedures ##########################################

Procedure Answer_Load(Filename.s)
  If Not OpenPreferences(Filename)
      ProcedureReturn
  EndIf
  
ClearMap(Answers())

If ExaminePreferenceGroups()
  While NextPreferenceGroup()
    AddMapElement(Answers(), ReadPreferenceString("Command", ""))
    Answers()\Command = MapKey(Answers())
    
    For i = 0 To #Command_Operators_Max-1
      Answers()\Operator [i] = ReadPreferenceString("Operator["+Str(i)+"]", "")
    Next
    
    Answers()\Answer = ReadPreferenceString("Answer", "")
  Wend
EndIf

Answer_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
Log_Add("Answer", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)

ClosePreferences()
EndProcedure

Procedure Answer_Save(Filename.s)
    File_ID = CreateFile(#PB_Any, Filename)
    
  If Not IsFile(File_ID)
      ProcedureReturn
  EndIf
  
ForEach Answers()
  WriteStringN(File_ID, "["+MapKey(Answers())+"]")
  WriteStringN(File_ID, "Command = "+Answers()\Command)
  
  For i = 0 To #Command_Operators_Max-1
    WriteStringN(File_ID, "Operator["+Str(i)+"] = "+Answers()\Operator [i])
  Next
  
  WriteStringN(File_ID, "Answer = "+Answers()\Answer)
Next

Answer_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
Log_Add("Answer", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)

CloseFile(File_ID)
EndProcedure

Procedure Answer_Do()
    If Not FindMapElement(Answers(), Command_Main\Parsed_Command)
        ProcedureReturn #False
    EndIf
    
    Correct = 1
    
    For i = 0 To #Command_Operators_Max-1
      If Answers(Command_Main\Parsed_Command)\Operator [i] <> LCase(Command_Main\Parsed_Operator [i])
        Correct = 0
      EndIf
    Next
    
    If Correct = 1
      System_Message_Network_Send(Command_Main\Command_Client_ID, Answers()\Answer)
    EndIf
  
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
; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 37
; FirstLine = 30
; Folding = --
; EnableXP
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0