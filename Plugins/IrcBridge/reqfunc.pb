Procedure split(Array a$(1), s$, delimeter$)
  Protected count, i
  count = CountString(s$,delimeter$) + 1
 
  Dim a$(count)
  
  For i = 1 To count
    a$(i - 1) = StringField(s$,i,delimeter$)
  Next
  
  ProcedureReturn count ;return count of substrings
EndProcedure

Procedure send_raw(string$, Socket)
  If Socket
    SendNetworkString(Socket, string$ + Chr(13) + Chr(10))
  EndIf
EndProcedure

Procedure handleCommands(Command.s, Message.s, Array Args.s(1), *thisBot.purebot, Sender.s)
  Command = LCase(Command)
  
  Select Command
    Case ".m"
      
      Elements = Map_Count_Elements()
      thisID = -1
      
      If Elements > 0
        Dim Temp.Plugin_Result_Element(Elements)
        Map_Get_Array(@Temp())
        
        Main_LockMutex()
        
        For i = 0 To Elements-1
          *thisMap.Map_Data = Map_Get_Pointer(Temp(i)\ID)
          If LCase(*thisMap\Name) = LCase(Args(1))
            thisID = Temp(i)\ID
            Break
          EndIf
        Next
        
        Main_UnlockMutex()
        
        If thisID <> -1
          System_Message_Network_Send_2_All(thisID, "&eIRC <" + sender + "> &f" + Message)
        Else
          send_raw("NOTICE " + Sender + " :Map not found.", *thisBot\Socket)
        EndIf
        
      EndIf
      
    Case ".help"
      PrintN(CommAnd + "|")
      send_raw("PRIVMSG " + *thisBot\Channel + " :IRC Bridge commands: .m, .help, .info, .commands, .players, .online.", *thisBot\socket)
      
    Case ".info"
      send_raw("PRIVMSG " + *thisBot\Channel + " :D3 Server IRC Bridge plugin, by Umby24. Version: 2", *thisBot\socket)
      
    Case ".commands"
      send_raw("PRIVMSG " + *thisBot\Channel + " :IRC Bridge commands: .m, .help, .info, .commands, .players, .online.", *thisBot\socket)
      
    Case ".players"
      onlinePlayers = Entity_Count_Elements()
      send_raw("PRIVMSG " + *thisBot\Channel + " :There are " + Str(onlinePlayers) + " players online.", *thisBot\socket)
      
      thisString.s = ""
      
      If onlinePlayers > 0
        ForEach Players()
          thisString = thisString + Players() + ", "  
        Next
        
          
        send_raw("PRIVMSG " + *thisBot\Channel + " :" + thisString, *thisBot\socket)
      EndIf
      
      
    Case ".online"
      onlinePlayers = Entity_Count_Elements()
      send_raw("PRIVMSG " + *thisBot\Channel + " :There are " + Str(onlinePlayers) + " players online.", *thisBot\socket)
      
  EndSelect
  
EndProcedure

Procedure.s getIrcString(Socket)
  BufferSize = 1
  *Buffer = AllocateMemory(1)
  ircString.s = ""
  ircLast.s = ""
  
  While ircLast <> (Chr(13) + Chr(10))
    Readbytes = ReceiveNetworkData(Socket, *Buffer, BufferSize)
    
    If Readbytes = -1
        ircString = "Quittinggg"
        Break
      EndIf
      
      character.s = PeekS(*Buffer)
      ircLast = Right(ircLast, 1) + character
      ircString = ircString + character
    Wend
    
  FreeMemory(*Buffer) ;Free up the memory used in the IRC Process.
  
  ProcedureReturn Left(ircString, Len(ircString) - 2)
EndProcedure

Procedure ircLoop(*thisBot.pureBot)
  Socket = *thisBot\socket
  quit = *thisBot\quit
  
  While quit = 0
    
    raw.s = getIrcString(Socket)
    If raw = "Quitting"
      *thisBot\quit = 1
      Break
    EndIf
    
      host.s = ""
      dat.s = ""
      message.s = ""
      
      
      If Left(raw, 1) = ":"
        host = Mid(raw, 2, FindString(raw, " ", 1) - 2)
      Else
        host = Left(raw, FindString(raw, " ", 1) - 1)
      EndIf
      
      
      dat = Mid(raw, FindString(raw, " ", 1) + 1, Len(raw) - (FindString(raw, " ", 1)))
      
      
      If FindString(dat, ":", 1) <> 0
        message = Mid(dat, FindString(dat, ":", 1) + 1, Len(dat) - (FindString(dat, ":", 1)))
      EndIf
      
      If host = "PING"
        send_raw("PONG " + dat, Socket)
        Continue
      EndIf
      
      second.s = Left(dat, FindString(dat, " ", 1) - 1)
      name.s = Left(host, FindString(host, "!", 1) - 1)
      
      Dim splits.s(0)
      split(splits(), dat, " ")
      
      Select second
        Case "PRIVMSG"
          If (*thisBot\Mode = 1 Or *thisBot\Mode = 3) And Left(message, 1) <> "."
            System_Message_Network_Send_2_All(-1, "&eIRC <" + name + "> &f" + message)
            Log_Add("Irc", "Message: <" + name + "> " + message, 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          EndIf
          
          If Left(message, 1) = "."
            ;Command
            If FindString(message, " ") = 0
              message = message + " "
            EndIf
            
            Command.s = Mid(message, 0, FindString(message, " ") - 1)
            
            Dim args.s(0)
            split(args(),message, " ") ; Gets the args
            
            If (CountString(message, " ")) >= 2
              message = Mid(message, Len(Args(0)) + Len(Args(1)) + 3, Len(message) - (Len(Args(0)) + Len(Args(1)) + 2))
            EndIf
            
            handleCommands(Command, Message, args(), *thisBot, name)
          EndIf
          
          
          Continue
        Case "NOTICE"
          Continue
        Case "QUIT"
          Continue
        Case "JOIN"
          Continue
        Case "MODE" ;AuthServ
          Continue
        Case "PART"
          Continue
        Case "NICK"
          Continue
        Case "307" ;AuthServ
          Continue
        Case "330"; Authserv
          Continue
        Case "332"
          Continue
        Case "353" ;Players list
          Continue
        Case "376"
          send_raw("JOIN " + *thisBot\Channel, Socket)
          Log_Add("Irc", "Connected to IRC Channel.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
          
          If *thisBot\NickPass <> ""
            send_raw("NICKSERV IDENTIFY " + *thisBot\NickPass, Socket)
          EndIf
          
          Continue
        Case "433" ;Nick in use.
          *thisBot\botname = *thisBot\botname + "_" ;Change nick to something else, and resend.
          
          Log_Add("Irc", "Bot name in use, Adding _.", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
                    
          send_raw("NICK " + *thisBot\botname, *thisBot\socket)
          send_raw("USER " + *thisBot\ident + " Pure Pure :" + *thisBot\realname, *thisBot\socket)
          send_raw("MODE " + *thisBot\botname + " +B-x", *thisBot\socket)
          Continue
      EndSelect
      
      quit = *thisBot\quit
      
      If *thisBot\Raw
        PrintN(message)
      EndIf
      
  Wend
  
EndProcedure





; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 47
; FirstLine = 45
; Folding = 4
; EnableThread
; EnableXP
; EnableOnError