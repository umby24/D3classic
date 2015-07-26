Structure pureBot ;Define our settings container
  Server.s
  Port.i
  Channel.s
  Botname.s
  Ident.s
  Realname.s
  Quit.b
  Socket.l ;Fun fact, Not an OO-Language, so this is just a number.
  Running.b
  Mode.i
  Raw.b
  NickPass.s
EndStructure

XIncludeFile "../Include/Include.pbi" ;Include the D3 SDK
XIncludeFile "reqfunc.pb" ;Include IRC Bot required functions.


#Plugin_Name = "IRC Bridge" ;Information for the server
#Plugin_Author = "Umby24"

Global thisBot.pureBot ;Init our settings
thisBot\Running = 0

;Now, must include some required functions for the server to reconize our plugin.
ProcedureCDLL Init(*Plugin_Info.Plugin_Info, *Plugin_Function.Plugin_Function) ; Called with the loading of the library
  *Plugin_Info\Name = #Plugin_Name
  *Plugin_Info\Version = #Plugin_Version
  *Plugin_Info\Author = #Plugin_Author
  
  Define_Prototypes(*Plugin_Function)
  
  OpenConsole()
  System_Message_Network_Send_2_All(-1, "&eIRC Plugin Initialized")
EndProcedure

ProcedureCDLL Deinit() ; Called with the unloading of the library
  If thisBot\Running = 1 ; If the bot is running, close it gracefully.
    thisBot\Quit = 1
    send_raw("QUIT " + thisBot\Botname + " :Plugin closing", thisBot\Socket)
    CloseNetworkConnection(thisBot\Socket)
  EndIf
EndProcedure

ProcedureCDLL Main()
  ;This gets run constantly, its quite fast.
  
EndProcedure

Procedure saveSettings()
  If CreatePreferences("Data\Irc.txt")
    
    WritePreferenceString("Server", thisBot\Server)
    WritePreferenceInteger("Port", thisBot\Port)
    WritePreferenceString("Channel", thisBot\Channel)
    WritePreferenceString("Botname", thisBot\Botname)
    WritePreferenceString("Ident", thisBot\Ident)
    WritePreferenceString("Realname", thisBot\Realname)
    WritePreferenceString("NickPass", thisBot\NickPass)
    
    Log_Add("Irc", "Settings Saved.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
  EndIf
EndProcedure

Procedure loadSettings()
  If FileSize("Data\Irc.txt") = -1
    If CreateFile(0, "Data\Irc.txt")
      CloseFile(0)
      thisBot\server = "irc.esper.net"
      thisBot\port = 6667
      thisBot\channel = "#nothere"
      thisBot\botname = "D3"
      thisBot\ident = "D3"
      thisBot\realname = "Pure"
      thisBot\quit = 0
      thisBot\NickPass = ""
      saveSettings()
    Else
      Log_Add("Irc", "Couldn't create settings file", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      ProcedureReturn -1
    EndIf
  Else
    If OpenPreferences("Data\Irc.txt")
      thisBot\Server = ReadPreferenceString("Server","irc.esper.net")
      thisBot\Port = ReadPreferenceInteger("Port",6667)
      thisBot\Channel = ReadPreferenceString("Channel","#nothere")
      thisBot\Botname = ReadPreferenceString("Botname","D3")
      thisBot\Ident = ReadPreferenceString("Ident","D3")
      thisBot\Realname = ReadPreferenceString("Realname","Pure")
      thisBot\NickPass = ReadPreferenceString("NickPass", "")
      
      Log_Add("Irc", "Settings Loaded.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)

      ClosePreferences()
    EndIf
    
  EndIf
  
EndProcedure

Procedure initBot() ;Put this in a function so it can be called by command.
  If thisBot\Running = 1
    ProcedureReturn -1  
  EndIf
  
  If InitNetwork() = 0
    Log_Add("Irc", "Failed to connect to IRC Server.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    ProcedureReturn -1
  EndIf
   
  loadSettings()
  
  thisBot\Raw = 0
  thisBot\socket = OpenNetworkConnection(thisBot\server, thisBot\port)
  
  If thisBot\socket
    send_raw("NICK " + thisBot\botname, thisBot\socket)
    send_raw("USER " + thisBot\ident + " Pure Pure :" + thisBot\realname, thisBot\socket)
    send_raw("MODE " + thisBot\botname + " +B-x", thisBot\socket)
    
    mainThread = CreateThread(@ircLoop(), @thisBot)
    
    thisBot\Running = 1
  Else
    PrintN("Failed to connect to server!")
  EndIf
EndProcedure

;The below function will handle our incoming IRC commands.
ProcedureCDLL Event_Chat_Map(*Entity.Entity, Message.s)
  Result = 1
  
  If thisBot\Running = 1 And (thisBot\Mode = 2 Or thisBot\Mode = 3)
    mapname.s = ""
    
    *Pointer.Map_Data = Map_Get_Pointer(*Entity\Map_ID)
    If *Pointer
      mapname = *Pointer\Name
    EndIf
    ircMessage.s = Chr(3) + "07[" + Chr(3) + "06" + mapname + Chr(3) + "07] " + Chr(3) + *Entity\Name + ": " + Message
    
    send_raw("PRIVMSG " + thisBot\Channel + " :" + ircMessage, thisBot\Socket)
  EndIf
  
  ProcedureReturn Result
EndProcedure

ProcedureCDLL Event_Chat_All(*Entity.Entity, Message.s)
  Result = 1
    If thisBot\Running = 1 And (thisBot\Mode = 2 Or thisBot\Mode = 3)
    ircMessage.s = Chr(3) + "07[" + Chr(3) + "06Global" + Chr(3) + "07] " + Chr(3) + *Entity\Name + ": " + Message
    send_raw("PRIVMSG " + thisBot\Channel + " :" + ircMessage, thisBot\Socket)
  EndIf
  ProcedureReturn Result
EndProcedure

ProcedureCDLL Event_Client_Login(*Client.Network_Client)
  Result = 1
  If *Client
    cname.s = *Client\Player\Login_Name
    
    If thisBot\Running = 1 And (thisBot\Mode = 2 Or thisBot\Mode = 3)
      ircMessage.s = Chr(3) + "07[" + Chr(3) + "06Global" + Chr(3) + "07] " + Chr(3) + cname + " Joined."
      send_raw("PRIVMSG " + thisBot\Channel + " :" + ircMessage, thisBot\Socket)
    EndIf 
  EndIf
  ProcedureReturn Result
EndProcedure

ProcedureCDLL Event_Client_Delete(*Client.Network_Client)
  Result = 1
  
  If *Client
    cname.s = *Client\Player\Login_Name
    
    If thisBot\Running = 1 And (thisBot\Mode = 2 Or thisBot\Mode = 3)
      ircMessage.s = Chr(3) + "07[" + Chr(3) + "06Global" + Chr(3) + "07] " + Chr(3) + cname + " Left."
      send_raw("PRIVMSG " + thisBot\Channel + " :" + ircMessage, thisBot\Socket)
    EndIf 
  EndIf
  
  ProcedureReturn Result
EndProcedure

ProcedureCDLL Event_Command(Argument.s, *Client.Network_Client, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
  If *Client
    Select LCase(Command)
      Case "server"
        thisBot\Server = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
      Case "port"
        thisBot\Port = Val(Arg_0)
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
      Case "botname"
        thisBot\Botname = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
      Case "ident"
        thisBot\Ident = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
      Case "realname"
        thisBot\Realname = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
      Case "channel"
        thisBot\Channel = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSetting updated. If IRC is running, restart it.")
        
      Case "ircload"
        loadSettings()
        System_Message_Network_Send(*Client\ID, "&eIRC Settings loaded.")
        
      Case "ircsave"
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eIRC Settings saved.")
      Case "NickPass"
        thisBot\NickPass = Arg_0
        saveSettings()
        System_Message_Network_Send(*Client\ID, "&eSettings updated. If IRC is running, restart it.")
        
      Case "irc" ;Control the IRC bot!
        Select Arg_0 ;Selectception!
          Case "0" ;Turn the bot off.
            If thisBot\Running = 1
              thisBot\Quit = 1
              thisBot\Running = 0
              send_raw("QUIT " + thisBot\Botname + " :Plugin closing", thisBot\Socket)
              CloseNetworkConnection(thisBot\Socket)
              Log_Add("Irc", "IRC Client Closed.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
              System_Message_Network_Send(*Client\ID, "&eIRC Client closed.")
              thisBot\Quit = 0
            EndIf
          Case "1" ; IRC <- Server only.
            If thisBot\Running = 1
              thisBot\Mode = 1
            Else
              thisBot\Mode = 1
              initBot()
            EndIf
            
            System_Message_Network_Send(*Client\ID, "&eIRC Mode is now Receive.")
            Log_Add("Irc", "IRC Enabled. Mode: Receive", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          Case "2" ; Server -> IRC only.
            If thisBot\Running = 1
              thisBot\Mode = 2
            Else
              thisBot\Mode = 2
              initBot()
            EndIf
            
            System_Message_Network_Send(*Client\ID, "&eIRC Mode is now Send.")
            Log_Add("Irc", "IRC Enabled. Mode: Send", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          Case "3" ; Server <-> IRC.
            If thisBot\Running = 1
              thisBot\Mode = 3
            Else
              thisBot\Mode = 3
              initBot()
            EndIf
            
            System_Message_Network_Send(*Client\ID, "&eIRC Mode is now Bidirectional.")
            Log_Add("Irc", "IRC Enabled. Mode: Bidirectional", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          Default
            System_Message_Network_Send(*Client\ID, "&4Error: &fInvalid Arguments!")
            
          EndSelect
          
        
    EndSelect
  EndIf
EndProcedure

; IDE Options = PureBasic 5.30 (Linux - x64)
; ExecutableFormat = Shared .so
; CursorPosition = 243
; FirstLine = 221
; Folding = --
; EnableThread
; EnableXP
; EnableOnError
; Executable = irc.x64.so
; Compiler = PureBasic 5.30 (Linux - x64)