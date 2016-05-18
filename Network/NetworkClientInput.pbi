Procedure Network_Client_Input_Available(*Client.Network_Client)     ;  -- Bytes available in the receive buffer
    Protected ReturnValue
    ReturnValue = *Client\Buffer_Input_Available
    ProcedureReturn ReturnValue
EndProcedure

Procedure Network_Client_Input_Add_Offset(*Client.Network_Client, Bytes)     ; Addiert einige Bytes zum Offset des Empfangbuffers -- Adds some bytes to offset the receive buffer
    
    *Client\Buffer_Input_Offset + Bytes
    *Client\Buffer_Input_Available - Bytes
    
    If *Client\Buffer_Input_Offset < 0
        *Client\Buffer_Input_Offset + #Network_Buffer_Size
    EndIf
    
    If *Client\Buffer_Input_Offset >= #Network_Buffer_Size
        *Client\Buffer_Input_Offset - #Network_Buffer_Size
    EndIf
EndProcedure

Procedure.b Network_Client_Input_Read_Byte(*Client.Network_Client)     ; Liest ein Byte aus dem Empfangsbuffer -- Reads a byte from the receive buffer
    Protected Value.b
    If *Client\Buffer_Input_Available >= 1
        
        Value = PeekB(*Client\Buffer_Input + *Client\Buffer_Input_Offset)
        
        *Client\Buffer_Input_Offset + 1
        *Client\Buffer_Input_Available - 1
        
        If *Client\Buffer_Input_Offset >= #Network_Buffer_Size
            *Client\Buffer_Input_Offset - #Network_Buffer_Size
        EndIf
    EndIf
    ProcedureReturn Value
EndProcedure

Procedure.w ClientInputReadShort(*Client.Network_Client)     ; Liest ein Byte aus dem Empfangsbuffer -- Reads a short from the receive buffer
    Protected Value.w, *Network_Client_Old
    If *Client\Buffer_Input_Available >= 2
        
        Value = PeekW(*Client\Buffer_Input + *Client\Buffer_Input_Offset)
        
        *Client\Buffer_Input_Offset + 2
        *Client\Buffer_Input_Available - 2
        
        Value = EndianW(Value)
        
        If *Client\Buffer_Input_Offset >= #Network_Buffer_Size
            *Client\Buffer_Input_Offset - #Network_Buffer_Size
        EndIf
    EndIf
    ProcedureReturn Value
EndProcedure

Procedure.l ClientInputReadInt(*Client.Network_Client)
    Protected Value.l, *Network_Client_Old
    If *Client\Buffer_Input_Available >= 4
        
        Value = PeekL(*Client\Buffer_Input + *Client\Buffer_Input_Offset)
        
        *Client\Buffer_Input_Offset + 4
        *Client\Buffer_Input_Available - 4
        
        Value = Endian(Value)
        
        If *Client\Buffer_Input_Offset >= #Network_Buffer_Size
            *Client\Buffer_Input_Offset - #Network_Buffer_Size
        EndIf
    EndIf
    
    ProcedureReturn Value
EndProcedure

Procedure.s Network_Client_Input_Read_String(*Client.Network_Client, Length)     ; Liest ein String angegebener L?nge aus dem Empfangsbuffer -- Reads a string of specified length from the receive buffer
    Protected *Temp_Buffer, Data_Read.l, Ringbuffer_Max_Data.l, *Ringbuffer_Adress, Data_Temp_Size.l
    
    *Temp_Buffer = Mem_Allocate(Length, #PB_Compiler_File, #PB_Compiler_Line, "Temp_Buffer")
    
    If *Client\Buffer_Input_Available >= Length
        Network_Client_Input_Read_Buffer(*Client.Network_Client, *Temp_Buffer, Length) ; - Read the bytes off the buffer
    EndIf
    
    String.s = PeekS(*Temp_Buffer, Length)
    
    Mem_Free(*Temp_Buffer)
    
    ProcedureReturn String
EndProcedure

Procedure Network_Client_Input_Read_Buffer(*Client.Network_Client, *Data_Buffer, Data_Size)   ; Liest Daten aus dem Empfangsbuffer -- Reads data from the receive buffer
    
    ; Anzahl gelesener Daten - Amount of data read
    Data_Read = 0
    
    While Data_Read < Data_Size
        
        ; Platz bis zum "ende" des Ringbuffers - Square to the 'end' of the ring buffer
        Ringbuffer_Max_Data = #Network_Buffer_Size - (*Client\Buffer_Input_Offset)
        ; Bufferadresse mit Offset - Buffer address with offset
        *Ringbuffer_Adress = *Client\Buffer_Input + *Client\Buffer_Input_Offset
        ; Tempor?re zu lesende Datenmenge - Temporary data to be read 
        Data_Temp_Size = Data_Size - Data_Read
        
        If Data_Temp_Size > Ringbuffer_Max_Data 
            Data_Temp_Size = Ringbuffer_Max_Data 
        EndIf
        
        CopyMemory(*Ringbuffer_Adress, *Data_Buffer + Data_Read, Data_Temp_Size)
        Data_Read + Data_Temp_Size
        *Client\Buffer_Input_Offset + Data_Temp_Size
        *Client\Buffer_Input_Available - Data_Temp_Size
        
        If *Client\Buffer_Input_Offset >= #Network_Buffer_Size
            *Client\Buffer_Input_Offset - #Network_Buffer_Size
        EndIf
    Wend
EndProcedure

;- Writes data into a clients input buffer, after it has been received from a socket.
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
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 54
; FirstLine = 40
; Folding = --
; EnableUnicode
; EnableXP