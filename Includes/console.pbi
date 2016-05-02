Procedure MainConsole(Nothing)
    Protected Inputline.s
    
    While Running
        Inputline = Input()
        
        If LCase(Inputline) = "q" Or LCase(Inputline) = "quit"
            Running = 0
        EndIf
    Wend
EndProcedure
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 10
; Folding = -
; EnableUnicode
; EnableXP