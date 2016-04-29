; NetworkClientOutput.pbi
; Contains all of the functions writing to the outgoing packet buffer for network clients.

Procedure Network_Client_Output_Available(Client_ID)     ; Returns the number of bytes in the output buffer.
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        Return_Value =  Network_Client()\Buffer_Output_Available
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
    ProcedureReturn Return_Value
EndProcedure

Procedure Network_Client_Output_Add_Offset(Client_ID, Bytes)     ; Addiert einige Bytes zum Offset des Sendebuffers
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        Network_Client()\Buffer_Output_Offset + Bytes
        Network_Client()\Buffer_Output_Available - Bytes
        If Network_Client()\Buffer_Output_Offset < 0
            Network_Client()\Buffer_Output_Offset + #Network_Buffer_Size
        EndIf
        If Network_Client()\Buffer_Output_Offset >= #Network_Buffer_Size
            Network_Client()\Buffer_Output_Offset - #Network_Buffer_Size
        EndIf
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Output_Read_Buffer(Client_ID, *Data_Buffer, Data_Size)   ; Liest Daten aus dem Sendebuffer
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        
        ; Anzahl gelesener Daten
        Data_Read = 0
        
        While Data_Read < Data_Size
            
            ; Square to the "end" of the ring buffer
            Ringbuffer_Max_Data = #Network_Buffer_Size - (Network_Client()\Buffer_Output_Offset)
            ; Buffer Address with offset
            *Ringbuffer_Adress = Network_Client()\Buffer_Output + Network_Client()\Buffer_Output_Offset
            ; Temporary data to be read
            Data_Temp_Size = Data_Size - Data_Read
            If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
            
            CopyMemory(*Ringbuffer_Adress, *Data_Buffer + Data_Read, Data_Temp_Size)
            Data_Read + Data_Temp_Size
            Network_Client()\Buffer_Output_Offset + Data_Temp_Size
            Network_Client()\Buffer_Output_Available - Data_Temp_Size
            
            If Network_Client()\Buffer_Output_Offset >= #Network_Buffer_Size
                Network_Client()\Buffer_Output_Offset - #Network_Buffer_Size
            EndIf
        Wend
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Output_Write_Byte(Client_ID, Value.b)     ; Writes a byte to the send buffer
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        
        ; Buffer address with offset.
        *Ringbuffer_Adress = Network_Client()\Buffer_Output + ((Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size)
        
        PokeB(*Ringbuffer_Adress, Value)
        
        Network_Client()\Buffer_Output_Available + 1
        
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure.w EndianW(val.w) ; Change Endianness of a Short (Word). Yay inline ASM!
    !MOV ax, word[p.v_val]
    !XCHG al, ah                ; Swap Lo byte <-> Hi byte
    !MOV word[p.v_val], ax
    ProcedureReturn val
EndProcedure

Procedure.l Endian(val.l) ; Change endianness of an int (long, DWORD, etc)
    !MOV Eax,dword[p.v_val]
    !BSWAP Eax
    ProcedureReturn
EndProcedure

Procedure Network_Client_Output_Write_Word(Client_ID, Value.w)     ; Write a short to the send buffer
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        
        ; Bufferadresse mit Offset
        *Ringbuffer_Adress = Network_Client()\Buffer_Output + ((Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size)
        PokeW(*Ringbuffer_Adress, EndianW(Value))
        Network_Client()\Buffer_Output_Available + 2
        
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure



Procedure Network_Client_Output_Write_Int(Client_ID, Value.l) ;Using 'Long' here, because in this context, it is an int (4 Bytes)
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        *Ringbuffer_Adress = Network_Client()\Buffer_Output + ((Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size)
        PokeL(*Ringbuffer_Adress, Endian(Value))
        Network_Client()\Buffer_Output_Available + 4
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Output_Write_String(Client_ID, String.s, Length)     ; Write a string of the given length to the sendbuffer
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        
        ; Anzahl geschriebener Daten
        Data_Wrote = 0
        
        While Data_Wrote < Length
            
            ; Position im Ringbuffer
            Ringbuffer_Write_Offset = (Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size
            ; Platz bis zum "ende" des Ringbuffers
            Ringbuffer_Max_Data = #Network_Buffer_Size - (Ringbuffer_Write_Offset)
            ; Bufferadresse mit Offset
            *Ringbuffer_Adress = Network_Client()\Buffer_Output + Ringbuffer_Write_Offset
            ; Tempor?re zu schreibende Datenmenge
            Data_Temp_Size = Length - Data_Wrote
            If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
            
            CopyMemory(@String + Data_Wrote, *Ringbuffer_Adress, Data_Temp_Size)
            
            Data_Wrote + Data_Temp_Size
            Network_Client()\Buffer_Output_Available + Data_Temp_Size
        Wend
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Output_Write_Buffer(Client_ID, *Data_Buffer, Data_Size)     ; Write raw bytes into the send buffer.
    List_Store(*Network_Client_Old, Network_Client())
    
    If Network_Client_Select(Client_ID)
        
        ; Anzahl geschriebener Daten
        Data_Wrote = 0
        
        While Data_Wrote < Data_Size
            
            ; Position im Ringbuffer
            Ringbuffer_Write_Offset = (Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size
            ; Platz bis zum "ende" des Ringbuffers
            Ringbuffer_Max_Data = #Network_Buffer_Size - (Ringbuffer_Write_Offset)
            ; Bufferadresse mit Offset
            *Ringbuffer_Adress = Network_Client()\Buffer_Output + Ringbuffer_Write_Offset
            ; Tempor?re zu schreibende Datenmenge
            Data_Temp_Size = Data_Size - Data_Wrote
            If Data_Temp_Size > Ringbuffer_Max_Data : Data_Temp_Size = Ringbuffer_Max_Data : EndIf
            
            CopyMemory(*Data_Buffer + Data_Wrote, *Ringbuffer_Adress, Data_Temp_Size)
            
            Data_Wrote + Data_Temp_Size
            Network_Client()\Buffer_Output_Available + Data_Temp_Size
        Wend
    EndIf
    
    List_Restore(*Network_Client_Old, Network_Client())
EndProcedure
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 160
; FirstLine = 137
; Folding = --
; EnableUnicode
; EnableXP