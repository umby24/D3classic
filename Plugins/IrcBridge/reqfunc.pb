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
          If *thisBot\Mode = 1 Or *thisBot\Mode = 3
            System_Message_Network_Send_2_All(-1, "&eIRC <" + name + "> &f" + message)
            Log_Add("Irc", "Message: <" + name + "> " + message, 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
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
; CursorPosition = 118
; FirstLine = 110
; Folding = -
; EnableThread
; EnableXP
; EnableOnError