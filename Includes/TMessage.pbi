; ########################################## Variablen ##########################################

Structure TMessage_Main
  Save_File.b             ; Zeigt an, ob gespeichert werden soll
  File_Date_Last.l        ; Datum letzter �nderung, bei �nderung speichern
  Timer_File_Check.l      ; Timer f�r das �berpr�fen der Dateigr��e
  Timer_Do.l              ; Timer f�r das Ausf�hren vom TMessage
EndStructure
Global TMessage_Main.TMessage_Main

Structure TMessage
  String.s                ; Nachricht, welche nach Zeit erscheint
EndStructure
Global NewList TMessage.TMessage()

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure TMessage_Load(Filename.s)
  File_ID = ReadFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    ClearList(TMessage())
    
    While Eof(File_ID) = 0
      AddElement(TMessage())
      TMessage()\String = ReadString(File_ID)
    Wend
    
    If FirstElement(TMessage())
      TMessage()\String = "&eRunning Dadido3's Custom Server V"+StrF(Main\Version/1000, 3)
    EndIf
    
    TMessage_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("TMessage", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure TMessage_Save(Filename.s)
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    ForEach TMessage()
      WriteStringN(File_ID, TMessage()\String)
    Next
    
    TMessage_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("TMessage", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure TMessage_Do() ; Sendet eine Nachricht
  If ListSize(TMessage()) > 0
    Message_Number = Random(ListSize(TMessage())-1)
    If SelectElement(TMessage(), Message_Number)
      System_Message_Network_Send_2_All(-1, TMessage()\String)
    EndIf
  EndIf
EndProcedure

Procedure TMessage_Main()
  If TMessage_Main\Timer_Do < Milliseconds()
    TMessage_Main\Timer_Do = Milliseconds() + 120000
    TMessage_Do()
  EndIf
  
  If TMessage_Main\Save_File
    TMessage_Main\Save_File = 0
    TMessage_Save(Files_File_Get("Timed_Messages"))
  EndIf
  
  File_Date = GetFileDate(Files_File_Get("Timed_Messages"), #PB_Date_Modified)
  
  If TMessage_Main\File_Date_Last <> File_Date
    TMessage_Load(Files_File_Get("Timed_Messages"))
  EndIf
EndProcedure

RegisterCore("TMessage", 1000, #Null, #Null, @TMessage_Main())
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 85
; FirstLine = 26
; Folding = -
; EnableXP
; DisableDebugger
; EnableCompileCount = 0
; EnableBuildCount = 0