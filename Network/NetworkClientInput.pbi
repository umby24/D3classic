Procedure Network_Client_Input_Available(Client_ID)     ; Bytes verf?gbar im Empfangsbuffer -- Bytes available in the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    Return_Value = Network_Client()\Buffer_Input_Available
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
  ProcedureReturn Return_Value
EndProcedure

Procedure Network_Client_Input_Add_Offset(Client_ID, Bytes)     ; Addiert einige Bytes zum Offset des Empfangbuffers -- Adds some bytes to offset the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    Network_Client()\Buffer_Input_Offset + Bytes
    Network_Client()\Buffer_Input_Available - Bytes
    
    If Network_Client()\Buffer_Input_Offset < 0
      Network_Client()\Buffer_Input_Offset + #Network_Buffer_Size
    EndIf
    
    If Network_Client()\Buffer_Input_Offset >= #Network_Buffer_Size
      Network_Client()\Buffer_Input_Offset - #Network_Buffer_Size
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure.b Network_Client_Input_Read_Byte(Client_ID)     ; Liest ein Byte aus dem Empfangsbuffer -- Reads a byte from the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\Buffer_Input_Available >= 1
    
      Value.b = PeekB(Network_Client()\Buffer_Input + Network_Client()\Buffer_Input_Offset)
      
      Network_Client()\Buffer_Input_Offset + 1
      Network_Client()\Buffer_Input_Available - 1
      If Network_Client()\Buffer_Input_Offset >= #Network_Buffer_Size
        Network_Client()\Buffer_Input_Offset - #Network_Buffer_Size
      EndIf
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
  ProcedureReturn Value.b
EndProcedure

Procedure.s Network_Client_Input_Read_String(Client_ID, Length)     ; Liest ein String angegebener L?nge aus dem Empfangsbuffer -- Reads a string of specified length from the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  ;*Temp_Buffer = AllocateMemory(Length)
  *Temp_Buffer = Mem_Allocate(Length, #PB_Compiler_File, #PB_Compiler_Line, "Temp_Buffer")
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\Buffer_Input_Available >= Length
      
      ; Anzahl gelesener Daten
      Data_Read = 0
      
      While Data_Read < Length
        ; Platz bis zum "ende" des Ringbuffers
        Ringbuffer_Max_Data = #Network_Buffer_Size - (Network_Client()\Buffer_Input_Offset)
        ; Bufferadresse mit Offset
        *Ringbuffer_Adress = Network_Client()\Buffer_Input + Network_Client()\Buffer_Input_Offset
        ; Tempor?re zu lesende Datenmenge
        Data_Temp_Size = Length - Data_Read
        If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
        
        CopyMemory(*Ringbuffer_Adress, *Temp_Buffer+Data_Read, Data_Temp_Size)
        
        Data_Read + Data_Temp_Size
        Network_Client()\Buffer_Input_Offset + Data_Temp_Size
        Network_Client()\Buffer_Input_Available - Data_Temp_Size
        If Network_Client()\Buffer_Input_Offset >= #Network_Buffer_Size
          Network_Client()\Buffer_Input_Offset - #Network_Buffer_Size
        EndIf
      Wend
      
    EndIf
  EndIf
  
  String.s = PeekS(*Temp_Buffer, Length)
  
  ;FreeMemory(*Temp_Buffer)
  Mem_Free(*Temp_Buffer)
  
  List_Restore(*Network_Client_Old, Network_Client())
  ProcedureReturn String
EndProcedure

Procedure Network_Client_Input_Read_Buffer(Client_ID, *Data_Buffer, Data_Size)   ; Liest Daten aus dem Empfangsbuffer -- Reads data from the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    
    ; Anzahl gelesener Daten
    Data_Read = 0
    
    While Data_Read < Data_Size
      
      ; Platz bis zum "ende" des Ringbuffers
      Ringbuffer_Max_Data = #Network_Buffer_Size - (Network_Client()\Buffer_Input_Offset)
      ; Bufferadresse mit Offset
      *Ringbuffer_Adress = Network_Client()\Buffer_Input + Network_Client()\Buffer_Input_Offset
      ; Tempor?re zu lesende Datenmenge
      Data_Temp_Size = Data_Size - Data_Read
      If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
      
      CopyMemory(*Ringbuffer_Adress, *Data_Buffer + Data_Read, Data_Temp_Size)
      Data_Read + Data_Temp_Size
      Network_Client()\Buffer_Input_Offset + Data_Temp_Size
      Network_Client()\Buffer_Input_Available - Data_Temp_Size
      If Network_Client()\Buffer_Input_Offset >= #Network_Buffer_Size
        Network_Client()\Buffer_Input_Offset - #Network_Buffer_Size
      EndIf
    Wend
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Input_Write_Buffer(Client_ID, *Data_Buffer, Data_Size)   ; Schreibt Daten in den Empfangsbuffer -- Write data in the receive buffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    
    ; Anzahl geschriebener Daten
    Data_Wrote = 0
    
    While Data_Wrote < Data_Size
      
      ; Position im Ringbuffer
      Ringbuffer_Write_Offset = (Network_Client()\Buffer_Input_Offset + Network_Client()\Buffer_Input_Available) % #Network_Buffer_Size
      ; Platz bis zum "ende" des Ringbuffers
      Ringbuffer_Max_Data = #Network_Buffer_Size - (Ringbuffer_Write_Offset)
      ; Bufferadresse mit Offset
      *Ringbuffer_Adress = Network_Client()\Buffer_Input + Ringbuffer_Write_Offset
      ; Tempor?re zu schreibende Datenmenge
      Data_Temp_Size = Data_Size - Data_Wrote
      If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
      
      CopyMemory(*Data_Buffer + Data_Wrote, *Ringbuffer_Adress, Data_Temp_Size)
      Data_Wrote + Data_Temp_Size
      Network_Client()\Buffer_Input_Available + Data_Temp_Size
    Wend
    
    ;If Data_Size
    ;  If IsFile(tempfile) ; ######################################### Debug
    ;    WriteData(tempfile, *Data_Buffer, Data_Size)
    ;    WriteString(tempfile, "|||")
    ;  EndIf
    ;EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 158
; FirstLine = 50
; Folding = n-
; EnableUnicode
; EnableXP