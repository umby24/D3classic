InitNetwork()

; ########################################## Variablen ##########################################

#Network_Temp_Buffer_Size = 2000
#Network_Buffer_Size = 3000000
#Network_Packet_Size = 1400

#Network_Client_Timeout = 6000*5

Structure Network_Main
  Save_File.b                   ; Zeigt an, ob gespeichert werden soll
  File_Date_Last.l              ; Datum letzter ?nderung, bei ?nderung speichern
  Server_ID.i                   ; ID des Servers
  *Buffer_Temp                  ; Buffer f?r tempor?re Aufgaben
  Timer_Rate.l                  ; Timer f?r Down/Upload-Rate
  Upload_Rate.l                 ; Uploadrate in bytes/s
  Download_Rate.l               ; Downloadrate in bytes/s
  Upload_Rate_Counter.l         ; Upload in bytes (Z?hler wird jede Sekunde 0 gesetzt und ?bernommen)
  Download_Rate_Counter.l       ; Download in bytes (Z?hler wird jede Sekunde 0 gesetzt und ?bernommen)
EndStructure

Global Network_Main.Network_Main

; ##################################################################
; !!! Struktur mit Klienten befindet sich in Main_Structures.pbi !!!
; ##################################################################
Global NewList Network_Client.Network_Client()
;Global NewMap Network_Client.Network_Client()

Structure Network_Settings
  Port.l                        ; Port des Servers
EndStructure

Global Network_Settings.Network_Settings

; ########################################## Ladekram ############################################

Network_Main\Buffer_Temp = Mem_Allocate(#Network_Temp_Buffer_Size, #PB_Compiler_File, #PB_Compiler_Line, "Network_Main\Buffer_Temp")

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure Network_Save(Filename.s) ; Speichert die Einstellungen
  File_ID = CreateFile(#PB_Any, Filename)
  If IsFile(File_ID)
    
    WriteStringN(File_ID, "Port = "+Str(Network_Settings\Port))
    
    Network_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Network", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure Network_Load(Filename.s) ; L?dt die Einstellungen
  If OpenPreferences(Filename)
    
    Port = ReadPreferenceLong("Port", Network_Settings\Port)
    
    If Network_Settings\Port <> Port
      Network_Settings\Port = Port
      Network_Start()
    EndIf
    
    Network_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Network", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
    
  EndIf
EndProcedure

Procedure Network_Start()
  If Network_Main\Server_ID
    Network_Stop()
  EndIf
  
  Network_Main\Server_ID = CreateNetworkServer(#PB_Any, Network_Settings\Port, #PB_Network_TCP)
  
  If Network_Main\Server_ID = 0
    Log_Add("Network", Lang_Get("", "Can't start server"), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  Else
    Log_Add("Network", Lang_Get("", "Server started", Str(Network_Settings\Port)), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
EndProcedure

Procedure Network_Stop()
  CloseNetworkServer(Network_Main\Server_ID)
  Network_Main\Server_ID = 0
  
  ForEach Network_Client()
    Network_Client_Delete(Network_Client()\ID, Lang_Get("", "Disconnected"), 1)
  Next
  
  Log_Add("Network", Lang_Get("", "Server stopped"), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
EndProcedure

Procedure Network_HTML_Stats()
  Generation_Time = Milliseconds()
  
  File_ID = CreateFile(#PB_Any, Files_File_Get("Network_HTML"))
  If IsFile(File_ID)
    
    WriteStringN(File_ID, "<html>")
    WriteStringN(File_ID, "  <head>")
    WriteStringN(File_ID, "    <title>Minecraft-Server Network</title>")
    WriteStringN(File_ID, "  </head>")
    WriteStringN(File_ID, "  <body>")
    
    WriteStringN(File_ID, "      <b><u>Overview:</u></b><br>")
    WriteStringN(File_ID, "      Port: "+Str(Network_Settings\Port)+".<br>")
    WriteStringN(File_ID, "      Download_Rate: "+StrD(Network_Main\Download_Rate/1024, 3)+"kbytes/s.<br>")
    WriteStringN(File_ID, "      Download_Rate: <font color="+Chr(34)+"#FF0000"+Chr(34)+">"+LSet("", Network_Main\Download_Rate*10/1024, "|")+"</font><br>")
    WriteStringN(File_ID, "      Upload_Rate: "+StrD(Network_Main\Upload_Rate/1024, 3)+"kbytes/s.<br>")
    WriteStringN(File_ID, "      Upload_Rate: <font color="+Chr(34)+"#FF0000"+Chr(34)+">"+LSet("", Network_Main\Upload_Rate*10/1024, "|")+"</font><br>")
    
    WriteStringN(File_ID, "      <br>")
    WriteStringN(File_ID, "      <br>")
    WriteStringN(File_ID, "      <br>")
    
    WriteStringN(File_ID, "      <b><u>Clients:</u></b><br>")
    WriteStringN(File_ID, "      <br>")
    WriteString(File_ID,  "      <table border=1>")
    WriteStringN(File_ID, "        <tr>")
    WriteStringN(File_ID, "          <th><b>ID</b></th>")
    WriteStringN(File_ID, "          <th><b>Login_Name</b></th>")
    WriteStringN(File_ID, "          <th><b>Client_Version</b></th>")
    WriteStringN(File_ID, "          <th><b>IP</b></th>")
    WriteStringN(File_ID, "          <th><b>Download_Rate</b></th>")
    WriteStringN(File_ID, "          <th><b>Upload_Rate</b></th>")
    WriteStringN(File_ID, "          <th><b>Entity_ID</b></th>")
    WriteStringN(File_ID, "        </tr>")
    ForEach Network_Client()
      WriteStringN(File_ID, "        <tr>")
      WriteStringN(File_ID, "          <td>"+Str(Network_Client()\ID)+"</td>")
      WriteStringN(File_ID, "          <td>"+Network_Client()\Player\Login_Name+"</td>")
      WriteStringN(File_ID, "          <td>"+Str(Network_Client()\Player\Client_Version)+"</td>")
      WriteStringN(File_ID, "          <td>"+Network_Client()\IP+"</td>")
      WriteStringN(File_ID, "          <td>"+StrD(Network_Client()\Download_Rate/1000, 3)+"kB/s</td>")
      WriteStringN(File_ID, "          <td>"+StrD(Network_Client()\Upload_Rate/1000, 3)+"kB/s</td>")
      If Network_Client()\Player\Entity
        WriteStringN(File_ID, "          <td>"+Str(Network_Client()\Player\Entity\ID)+"</td>")
      EndIf
      WriteStringN(File_ID, "        </tr>")
    Next
    WriteString(File_ID,  "      </table>")
    
    WriteStringN(File_ID, "      <br>")
    WriteStringN(File_ID, "      <br>")
    WriteStringN(File_ID, "      <br>")
    
    WriteStringN(File_ID, "      Site generated in "+Str(Milliseconds()-Generation_Time)+" ms. "+FormatDate("%hh:%ii:%ss  %dd.%mm.%yyyy", Date())+" ("+Str(Date())+")<br>")
    
    WriteStringN(File_ID, "  </body>")
    WriteStringN(File_ID, "</html>")
    
    CloseFile(File_ID)
  EndIf
EndProcedure

Procedure Network_Client_Count()
  ProcedureReturn ListSize(Network_Client())
EndProcedure

Procedure Network_Client_Get_Pointer(Client_ID, Log=1)    ; W�hlt das Linked-List-Objekt
  If ListIndex(Network_Client()) <> -1 And Network_Client()\ID = Client_ID
    ProcedureReturn Network_Client()
  Else
    ForEach Network_Client()
      If Network_Client()\ID = Client_ID
        ProcedureReturn Network_Client()
      EndIf
    Next
  EndIf
  
  If Log
    Log_Add("Network", Lang_Get("", "Can't find Network_Client()\ID = [Field_0]", Str(Client_ID)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  ProcedureReturn 0
EndProcedure

Procedure Network_Client_Select(Client_ID, Log=1)    ; W�hlt das Linked-List-Objekt
  If ListIndex(Network_Client()) <> -1 And Network_Client()\ID = Client_ID
    ProcedureReturn #True
  Else
    ForEach Network_Client()
      If Network_Client()\ID = Client_ID
        ProcedureReturn #True
      EndIf
    Next
  EndIf
  
  If Log
    Log_Add("Network", Lang_Get("", "Can't find Network_Client()\ID = [Field_0]", Str(Client_ID)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure Network_Client_Add(Client_ID)     ; F�gt einen Clienten hinzu / Adds a client
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  AddElement(Network_Client())
  Network_Client()\ID = Client_ID
  Network_Client()\IP = IPString(GetClientIP(Client_ID))
  Network_Client()\Buffer_Input = Mem_Allocate(#Network_Buffer_Size, #PB_Compiler_File, #PB_Compiler_Line, "Network_Client("+Str(Client_ID)+")\Buffer_Input")
  Network_Client()\Buffer_Input_Offset = 0
  Network_Client()\Buffer_Input_Available = 0
  Network_Client()\Buffer_Output = Mem_Allocate(#Network_Buffer_Size, #PB_Compiler_File, #PB_Compiler_Line, "Network_Client("+Str(Client_ID)+")\Buffer_Output")
  Network_Client()\Buffer_Output_Offset = 0
  Network_Client()\Buffer_Output_Available = 0
  Network_Client()\Last_Time_Event = Milliseconds()
  
  If Network_Client()\Buffer_Input = 0
    Log_Add("Network", Lang_Get("", "Can't allocate receive-memory", Str(Client_ID)), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  
  If Network_Client()\Buffer_Output = 0
    Log_Add("Network", Lang_Get("", "Can't allocate send-memory", Str(Client_ID)), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  
  If Network_Client()\Buffer_Input = 0 Or Network_Client()\Buffer_Output = 0
    If Network_Client()\Buffer_Input : Mem_Free(Network_Client()\Buffer_Input) : EndIf
    If Network_Client()\Buffer_Output : Mem_Free(Network_Client()\Buffer_Output) : EndIf
    Network_Client_Kick(Client_ID, Lang_Get("", "Redscreen: Can't allocate memory"), 1)
    DeleteElement(Network_Client())
  Else
    Log_Add("Network", Lang_Get("", "Client created", Str(Network_Client()\ID), Network_Client()\IP), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    Plugin_Event_Client_Add(Network_Client())
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
EndProcedure

Procedure Network_Client_Delete(Client_ID, Message.s, Show_2_All)     ; L�scht einen Clienten
  If Network_Client_Select(Client_ID)
    
    Plugin_Event_Client_Delete(Network_Client())
    
    Client_Logout(Client_ID, Message, Show_2_All)
    Mem_Free(Network_Client()\Buffer_Input)
    Mem_Free(Network_Client()\Buffer_Output)
    Log_Add("Network", Lang_Get("", "Client deleted", Str(Network_Client()\ID), Network_Client()\IP, Message), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    DeleteElement(Network_Client())
  EndIf
EndProcedure

Procedure Network_Client_Kick(Client_ID, Message.s, Hide) ; Kickt den Client
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    System_Red_Screen(Network_Client()\ID, Message)
    
    If Network_Client()\Disconnect_Time = 0
      Network_Client()\Disconnect_Time = Milliseconds() + 1000
      Network_Client()\Logged_In = 0
      Network_Client()\Player\Logout_Hide = Hide
      Log_Add("Network_Client", Lang_Get("", "Client kicked", Network_Client()\Player\Login_Name, Message), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    EndIf
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Ping(Client_ID) ; Pingt den Client an
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    Network_Client_Output_Write_Byte(Client_ID, 1)
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure Network_Client_Output_Available(Client_ID)     ; Bytes verf�gbar im Sendebuffer
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
      
      ; Platz bis zum "ende" des Ringbuffers
      Ringbuffer_Max_Data = #Network_Buffer_Size - (Network_Client()\Buffer_Output_Offset)
      ; Bufferadresse mit Offset
      *Ringbuffer_Adress = Network_Client()\Buffer_Output + Network_Client()\Buffer_Output_Offset
      ; Tempor�re zu lesende Datenmenge
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

Procedure Network_Client_Output_Write_Byte(Client_ID, Value.b)     ; Schreibt ein Byte in den Sendebuffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    
    ; Bufferadresse mit Offset
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

Procedure Network_Client_Output_Write_Word(Client_ID, Value.w)     ; Schreibt ein Word in den Sendebuffer
  List_Store(*Network_Client_Old, Network_Client())
  
  If Network_Client_Select(Client_ID)
    
    ; Bufferadresse mit Offset
    *Ringbuffer_Adress = Network_Client()\Buffer_Output + ((Network_Client()\Buffer_Output_Offset + Network_Client()\Buffer_Output_Available) % #Network_Buffer_Size)
    PokeW(*Ringbuffer_Adress, EndianW(Value))
    Network_Client()\Buffer_Output_Available + 2
    
  EndIf
  
  List_Restore(*Network_Client_Old, Network_Client())
EndProcedure

Procedure.l Endian(val.l)
    !MOV Eax,dword[p.v_val]
    !BSWAP Eax
    ProcedureReturn
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

Procedure Network_Client_Output_Write_String(Client_ID, String.s, Length)     ; Schreibt einen String angegebener L?nge in den Sendebuffer
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

Procedure Network_Client_Output_Write_Buffer(Client_ID, *Data_Buffer, Data_Size)     ; Schreibt einen Speicherbereich angegebener L?nge in den Sendebuffer
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





Procedure Network_Input_Do()  ; Wertet die empfangenen Daten aus. / Evaluates received data
  ForEach Network_Client()
    Repeat_Max = 10 ; Anzahl maximaler Durchl�ufe der Schleife f�r jeden client / Maximum number of iterations of the loop for each client
    
    List_Store(*Network_Client_Old, Network_Client())
    
    While Network_Client_Input_Available(Network_Client()\ID) >= 1 And Repeat_Max > 0
      Command_Byte = (Network_Client_Input_Read_Byte(Network_Client()\ID)& 255)
      Network_Client_Input_Add_Offset(Network_Client()\ID, -1)
      
      Network_Client()\Last_Time_Event = Milliseconds()
      
      
      Select Command_Byte
        Case 0 ; ################ Login
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 1 + 64 + 64 + 1
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            Client_Version = Network_Client_Input_Read_Byte(Network_Client()\ID)
            Player_Name.s = Network_Client_Input_Read_String(Network_Client()\ID, 64)
            Player_Pass.s = Network_Client_Input_Read_String(Network_Client()\ID, 64)
            Unused_ID = Network_Client_Input_Read_Byte(Network_Client()\ID)
            
            Network_Client()\CPE = #False ; Set this to false until properly negotiated.
            Network_Client()\CustomBlocks_Level = 0
            Network_Client()\HeldBlock = #False
            Network_Client()\ClickDistance = #False
            Network_Client()\ExtPlayerList = #False
            Network_Client()\ChangeModel = #False
            Network_Client()\CPEWeather = #False
            Network_Client()\EnvColors = #False
            Network_Client()\MessageTypes = #False
            Network_Client()\BlockPermissions = #False
            Network_Client()\EnvMapAppearance = #False
            Network_Client()\TextHotkey = #False
            Network_Client()\HackControl = #False
            
            If Network_Client()\Logged_In = 0 And Network_Client()\Disconnect_Time = 0 And Unused_ID <> 66
              Client_Login(Network_Client()\ID, Trim(Player_Name), Player_Pass, Client_Version)
            ElseIf Unused_ID = 66 And Network_Client()\Logged_In = 0 And Network_Client()\Disconnect_Time = 0
              ;CPE Enabled Client
              CPE_Send_ExtInfo(Network_Client()\ID, Trim(Player_Name), Player_Pass, Client_Version)
              Log_Add("Network","CPE Client Detected", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
            EndIf
          EndIf
          
        Case 1 ; ############### Ping
          If Network_Client_Input_Available(Network_Client()\ID) >= 1
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            Network_Client()\Ping = Milliseconds() - Network_Client()\Ping_Sent_Time
          EndIf
          
        Case 5 ; ############### Block�nderung / Block Change"
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 8
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            X = Network_Client_Input_Read_Byte(Network_Client()\ID) * 256
            X + (Network_Client_Input_Read_Byte(Network_Client()\ID) & 255)
            Z = Network_Client_Input_Read_Byte(Network_Client()\ID) * 256
            Z + (Network_Client_Input_Read_Byte(Network_Client()\ID) & 255)
            Y = Network_Client_Input_Read_Byte(Network_Client()\ID) * 256
            Y + (Network_Client_Input_Read_Byte(Network_Client()\ID) & 255)
            Mode = (Network_Client_Input_Read_Byte(Network_Client()\ID) & 255)
            Type = (Network_Client_Input_Read_Byte(Network_Client()\ID) & 255)
            

            If Network_Client()\Logged_In = 1
              If Network_Client()\Player\Entity
                If Network_Client()\Player\Entity\Map_ID = Network_Client()\Player\Map_ID
                  Build_Mode_Distribute(Network_Client()\ID, -1, X, Y, Z, Mode, Type)
                EndIf
              EndIf
            EndIf
          EndIf
          
        Case 8 ; ############### Spielerbewegung / Player Movement
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 1 + 8
            
            If Network_Client()\HeldBlock = #True
              Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
              
              If Network_Client()\Player\Entity
                Network_Client()\Player\Entity\Held_Block = Network_Client_Input_Read_Byte(Network_Client()\ID) ; Update the CPE Held_Block for this client.
              Else
                Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
              EndIf
              
            Else
              Network_Client_Input_Add_Offset(Network_Client()\ID, 2)
            EndIf
          
            
            *Temp_Buffer = AllocateMemory(8)
            If *Temp_Buffer
              Network_Client_Input_Read_Buffer(Network_Client()\ID, *Temp_Buffer, 8)
              X = PeekB(*Temp_Buffer)* 256
              X + PeekB(*Temp_Buffer+1)& 255
              Z = PeekB(*Temp_Buffer+2)* 256
              Z + PeekB(*Temp_Buffer+3)& 255
              Y = PeekB(*Temp_Buffer+4)* 256
              Y + PeekB(*Temp_Buffer+5)& 255
              R = PeekB(*Temp_Buffer+6)
              L = PeekB(*Temp_Buffer+7)
            EndIf
            
            If Network_Client()\Logged_In = 1
              If Network_Client()\Player\Entity
                If Network_Client()\Player\Entity\Map_ID = Network_Client()\Player\Map_ID
                  Entity_Position_Set(Network_Client()\Player\Entity\ID, Network_Client()\Player\Entity\Map_ID, X/32, Y/32, (Z-51)/32, R * 360 / 256, L * 360 / 256, 1, 0)
                EndIf
              EndIf
            EndIf
          EndIf
          
        Case 13 ; ############### Nachricht kommt herein
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 1 + 64
            Network_Client_Input_Add_Offset(Network_Client()\ID, 2)
            Text.s = Trim(Network_Client_Input_Read_String(Network_Client()\ID, 64))
            
            If Network_Client()\Logged_In = 1
              If Network_Client()\Player\Entity
                If Left(Text, 1) = "/"
                  Command_Do(Network_Client()\ID, Mid(Text, 2))
                ElseIf Left(Text, 1) = "#"
                  If (Network_Client()\GlobalChat)
                    Chat_Message_Network_Send_2_Map(Network_Client()\Player\Entity\ID, Mid(Text, 2))
                  Else
                    Chat_Message_Network_Send_2_All(Network_Client()\Player\Entity\ID, Mid(Text, 2))
                  EndIf
                  
                ElseIf Left(Text, 1) = "@"
                  Private_Message_Name.s = Mid(StringField(Text, 1, " "), 2)
                  Chat_Message_Network_Send(Network_Client()\Player\Entity\ID, Private_Message_Name, Mid(Text, 2+Len(Private_Message_Name)))
                Else
                  If (Network_Client()\GlobalChat)
                    Chat_Message_Network_Send_2_All(Network_Client()\Player\Entity\ID, Text)
                  Else
                    Chat_Message_Network_Send_2_Map(Network_Client()\Player\Entity\ID, Text)
                  EndIf
                  
                EndIf
              EndIf
            EndIf
          EndIf
          
        Case 16 ; CPE ExtInfo Packet
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 64 + 2
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            
            AppName.s = Trim(Network_Client_Input_Read_String(Network_Client()\ID, 64))
            
            *Temp_Buffer = AllocateMemory(2)
            If *Temp_Buffer
                Network_Client_Input_Read_Buffer(Network_Client()\ID, *Temp_Buffer, 2)
                Extensions = PeekW(*Temp_Buffer)
                Extensions = EndianW(Extensions)
            EndIf
            
            FreeMemory(*Temp_Buffer)
            
            Network_Client()\CPE = #True
            Network_Client()\CustomExtensions = Extensions
            
            If Extensions = 0
                CPE_Send_Extensions(Network_Client()\ID)
                
                If Network_Client()\TextHotkey = #True
                    CPE_Client_Send_Hotkeys(Network_Client()\ID)
                EndIf
            EndIf

            Log_Add("CPE","Client supports " + Str(Extensions) + " extensions", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
                       
          EndIf
          
        Case 17 ; CPE ExtEntry Packet
          If Network_Client_Input_Available(Network_Client()\ID) >= 1 + 64 + 4
            
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            
            ExtName.s = Trim(Network_Client_Input_Read_String(Network_Client()\ID, 64))
            
            *Temp_Buffer = AllocateMemory(4) ; Read extVersion.
            
            If *Temp_Buffer
              Network_Client_Input_Read_Buffer(Network_Client()\ID, *Temp_Buffer, 4)
              extVersion = Endian(PeekL(*Temp_Buffer))
            EndIf
            
            FreeMemory(*Temp_Buffer)
            
            AddElement(Network_Client()\Extensions())
            Network_Client()\Extensions() = ExtName
            
            AddElement(Network_Client()\ExtensionVersions())
            Network_Client()\ExtensionVersions() = extVersion
            
            Select LCase(ExtName)
                Case "customblocks"
                    Network_Client()\CustomBlocks = #True  
                Case "heldblock"
                    Network_Client()\HeldBlock = #True  
                Case "clickdistance"
                    Network_Client()\ClickDistance = #True
                Case "selectioncuboid"
                    Network_Client()\SelectionCuboid = #True
                Case "extplayerlist"
                    Network_Client()\ExtPlayerList = #True
                Case "changemodel"
                    Network_Client()\ChangeModel = #True
                Case "envweathertype"
                    Network_Client()\CPEWeather = #True
                Case "envcolors"
                    Network_Client()\EnvColors = #True  
                Case "messagetypes"
                    Network_Client()\MessageTypes = #True
                Case "blockpermissions"
                    Network_Client()\BlockPermissions = #True
                Case "envmapappearance"
                    Network_Client()\EnvMapAppearance = #True
                Case "hackcontrol"
                    Network_Client()\HackControl = #True
                Case "texthotkey"
                    Network_Client()\TextHotkey = #True
                Case "emotefix"
                    Network_Client()\EmoteFix = #True
            EndSelect
            
            Network_Client()\CustomExtensions - 1
            
            If Network_Client()\CustomExtensions = 0
                CPE_Send_Extensions(Network_Client()\ID)
                
                If Network_Client()\TextHotkey = #True
                    CPE_Client_Send_Hotkeys(Network_Client()\ID)
                EndIf
                
            EndIf
            
          EndIf
        
        Case 19
          If Network_Client_Input_Available(Network_Client()\ID) >= 2
            ;Client just confirming it supports CustomBlocks.
            Network_Client_Input_Add_Offset(Network_Client()\ID, 1)
            Level = Network_Client_Input_Read_Byte(Network_Client()\ID)
            
            Network_Client()\CustomBlocks_Level = Level
            Network_Client()\CustomBlocks = #True
            
            Log_Add("CPE","CPE Process Complete.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
            Client_Login(Network_Client()\ID, Network_Client()\Player\Login_Name, Network_Client()\Player\MPPass, Network_Client()\Player\Client_Version)
          EndIf
          
        Default ; Wenn Befehl nicht gefunden
          Log_Add("Network", Lang_Get("", "Unknown data", Str(Network_Client()\ID), Str(Command_Byte)), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          Network_Client_Kick(Network_Client()\ID, Lang_Get("", "Networkerror"), 0)
          
      EndSelect
      
      Repeat_Max - 1
    Wend
    
  List_Restore(*Network_Client_Old, Network_Client())
    
  Next
EndProcedure

Procedure Network_Output_Do()  ; Erstellt zu sendende Daten
  ForEach Network_Client()
    If Network_Client()\Ping_Time < Milliseconds()
      Network_Client()\Ping_Time = Milliseconds() + 5000
      Network_Client()\Ping_Sent_Time  = Milliseconds()
      Network_Client_Ping(Network_Client()\ID)
    EndIf
  Next
EndProcedure

Procedure Network_Output_Send() ; Sendet Daten vom Sendebuffer
  ; Kleinere Datenmengen zuerst senden. Verhindert Lag durch Senden der Karte
  ;SortStructuredList(Network_Client(), #PB_Sort_Ascending, OffsetOf(Network_Client\Buffer_Output_Available), #PB_Integer)
  
  ForEach Network_Client()
    While Network_Client_Output_Available(Network_Client()\ID)
      Data_Size = Network_Client_Output_Available(Network_Client()\ID)
      If Data_Size > #Network_Packet_Size : Data_Size = #Network_Packet_Size : EndIf
      If Data_Size > #Network_Temp_Buffer_Size : Data_Size = #Network_Temp_Buffer_Size : EndIf
      
      Network_Client_Output_Read_Buffer(Network_Client()\ID, Network_Main\Buffer_Temp, Data_Size)
      Network_Client_Output_Add_Offset(Network_Client()\ID, -Data_Size)
      
      Bytes_Sent = SendNetworkData(Network_Client()\ID, Network_Main\Buffer_Temp, Data_Size)
      
      If Bytes_Sent > 0
        Network_Client_Output_Add_Offset(Network_Client()\ID, Bytes_Sent)
        Network_Client()\Upload_Rate_Counter + Bytes_Sent
        Network_Main\Upload_Rate_Counter + Bytes_Sent
      ElseIf Bytes_Sent = 0
        Log_Add("Network", Lang_Get("", "Can't send data", Str(Network_Client()\ID), Str(Bytes_Sent)), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        Network_Client_Kick(Network_Client()\ID, Lang_Get("", "Networkerror"), 0)
        Break
      ElseIf Bytes_Sent = -1
        ;Log_Add("Network", Lang_Get("", "Fehler beim Senden beim Klient [Field_0]. Ergebnis der Funktion: [Field_1]", Str(Network_Client()\ID), Str(Bytes_Sent)), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        Break
      EndIf
    Wend
  Next
EndProcedure

Procedure Network_Events()
  
  Watchdog_Watch("Network", "Begin Events", 0)
  
  Repeat
    Server_Event = NetworkServerEvent()
    Select Server_Event
      
      Case 0
        Break
        
      Case #PB_NetworkEvent_Connect
        Client_ID = EventClient()
        If Client_ID
          If Network_Client_Select(Client_ID, 0) = #False
            Network_Client_Add(Client_ID)
          Else
            Log_Add("Network", Lang_Get("", "Network_Client()\ID exists already", Str(Client_ID)), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          EndIf
        Else
          Log_Add("Network", Lang_Get("", "Network_Client()\ID = 0"), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        EndIf
        
      Case #PB_NetworkEvent_Data
        Client_ID = EventClient()
        Data_Size = ReceiveNetworkData(Client_ID, Network_Main\Buffer_Temp, #Network_Temp_Buffer_Size)
        If Data_Size > 0
          Network_Client_Input_Write_Buffer(Client_ID, Network_Main\Buffer_Temp, Data_Size)
          If Network_Client_Select(Client_ID)
            Network_Client()\Download_Rate_Counter + Data_Size
          EndIf
          Network_Main\Download_Rate_Counter + Data_Size
          ;WriteData(tempfile, *Temp_Buffer, Data_Size)
        ElseIf Data_Size = -1
          Network_Client_Delete(Client_ID, Lang_Get("", "Networkerror"), 1)
        EndIf
        
      Case #PB_NetworkEvent_Disconnect
        Client_ID = EventClient()
        Network_Client_Delete(Client_ID, Lang_Get("", "Disconnected"), 1)
        
    EndSelect
  ForEver
  
  ForEach Network_Client()
    Client_ID = Network_Client()\ID
    If Network_Client()\Disconnect_Time > 0 And Network_Client()\Disconnect_Time < Milliseconds()
      Network_Client_Delete(Client_ID, Lang_Get("", "Forced disconnect"), 1)
      CloseNetworkConnection(Client_ID)
    ElseIf Network_Client()\Last_Time_Event + #Network_Client_Timeout < Milliseconds()
      Network_Client_Delete(Client_ID, Lang_Get("", "Timeout"), 1)
      CloseNetworkConnection(Client_ID)
    EndIf
  Next
  
  Watchdog_Watch("Network", "End Events", 2)
  
EndProcedure

Procedure Network_Main()
  Watchdog_Watch("Main", "Before: Network_Main()", 1)
  
  If Network_Main\Save_File
    Network_Main\Save_File = 0
    Network_Save(Files_File_Get("Network"))
  EndIf
  

  File_Date = GetFileDate(Files_File_Get("Network"), #PB_Date_Modified)
  
  If Network_Main\File_Date_Last <> File_Date
    Network_Load(Files_File_Get("Network"))
  EndIf
  
  If Network_Main\Timer_Rate < Milliseconds()
    Network_Main\Timer_Rate = Milliseconds() + 5000
    
    ForEach Network_Client()
      Network_Client()\Download_Rate = Network_Client()\Download_Rate_Counter / 5
      Network_Client()\Upload_Rate = Network_Client()\Upload_Rate_Counter / 5
      Network_Client()\Download_Rate_Counter = 0
      Network_Client()\Upload_Rate_Counter = 0
    Next
    
    Network_Main\Download_Rate = Network_Main\Download_Rate_Counter / 5
    Network_Main\Upload_Rate = Network_Main\Upload_Rate_Counter / 5
    Network_Main\Download_Rate_Counter = 0
    Network_Main\Upload_Rate_Counter = 0
    
    Network_HTML_Stats()
    
  EndIf
EndProcedure

RegisterCore("Network_Main", 1000, #Null, #Null, @Network_Main())
RegisterCore("Network_Events", 1, #Null, #Null, @Network_Events())
RegisterCore("Network_Output_Send", 0, #Null, #Null, @Network_Output_Send())
RegisterCore("Network_Output_Do", 0, #Null, #Null, @Network_Output_Do())
RegisterCore("Network_Input_Do", 0, #Null, #Null, @Network_Input_Do())
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 460
; FirstLine = 431
; Folding = ---P5
; EnableXP
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0