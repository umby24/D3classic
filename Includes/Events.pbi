Global NewMap CoreEvents.EventStruct()
Prototype.i Core_Function()

Procedure UnregisterCore(Name.s)
    If FindMapElement(CoreEvents(), LCase(Name))
        DeleteMapElement(CoreEvents())
        ProcedureReturn
    EndIf
EndProcedure

Procedure RegisterCore(Name.s, Timer.i, *InitFunction, *ShutdownFunction, *MainFunction)
  If Not AddMapElement(CoreEvents(), LCase(Name), #PB_Map_ElementCheck)
        Log_Add("Events","Failed to create a new Core Event (ID: " + Name + ")", 1, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        ProcedureReturn
    EndIf
    
    CoreEvents()\ID = Name
    CoreEvents()\InitFunction = *InitFunction
    CoreEvents()\ShutdownFunciton = *ShutdownFunction
    CoreEvents()\MainFunction = *MainFunction
    CoreEvents()\Time = 0
    CoreEvents()\Timer = Timer
EndProcedure

Procedure CoreLoop()
    Protected myfun.Core_Function
    
    ForEach CoreEvents()
      If (ElapsedMilliseconds() - CoreEvents()\Time) >= CoreEvents()\Timer
        If CoreEvents()\MainFunction
                myfun = CoreEvents()\MainFunction
                myfun()
              EndIf
              
            CoreEvents()\Time = ElapsedMilliseconds()
        EndIf
    Next
EndProcedure

Procedure CoreInit()
    Protected myfun.Core_Function
    
    ForEach CoreEvents()
        If CoreEvents()\InitFunction
            myfun = CoreEvents()\InitFunction
            myfun()
        EndIf
    Next
    
EndProcedure

Procedure CoreShutdown()
    Protected myfun.Core_Function
    
    ForEach CoreEvents()
        If CoreEvents()\ShutdownFunciton
            myfun = CoreEvents()\ShutdownFunciton
            myfun()
        EndIf
    Next
    
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 32
; FirstLine = 5
; Folding = -
; EnableThread
; EnableXP
; EnableOnError
; CompileSourceDirectory