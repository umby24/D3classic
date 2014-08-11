;Done!
; ########################################## Variablen ##########################################

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure Teleporter_Select(*Map_Data.Map_Data, ID.s) ; Wählt das Linked-List-Objekt
  If *Map_Data
    If *Map_Data\Teleporter()\ID = LCase(ID)
      ProcedureReturn #True
    Else
      If FindMapElement(*Map_Data\Teleporter(), LCase(ID))
        *Map_Data\Teleporter(LCase(ID))
        ProcedureReturn #True
      EndIf
    EndIf
    
    Log_Add("Teleporter", Lang_Get("", "Can't find *Map_Data\Teleporter()\ID = [Field_0]", ID), 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure Teleporter_Get_Pointer(*Map_Data.Map_Data, ID.s)
  ProcedureReturn FindMapElement(*Map_Data\Teleporter(), LCase(ID))
EndProcedure

Procedure Teleporter_Add(*Map_Data.Map_Data, ID.s, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Dest_Map_Unique_ID.s, Dest_Map_ID, X.f, Y.f, Z.f, Rot.f, Look.f) 
  If *Map_Data
    If X_0 > X_1
      X_2 = X_0
      X_0 = X_1
      X_1 = X_2
    EndIf
    
    If Y_0 > Y_1
      Y_2 = Y_0
      Y_0 = Y_1
      Y_1 = Y_2
    EndIf
    
    If Z_0 > Z_1
      Z_2 = Z_0
      Z_0 = Z_1
      Z_1 = Z_2
    EndIf

    AddMapElement(*Map_Data\Teleporter(), LCase(ID), #PB_Map_ElementCheck)
    *Map_Data\Teleporter()\ID = ID
    *Map_Data\Teleporter()\X_0 = X_0
    *Map_Data\Teleporter()\Y_0 = Y_0
    *Map_Data\Teleporter()\Z_0 = Z_0
    *Map_Data\Teleporter()\X_1 = X_1
    *Map_Data\Teleporter()\Y_1 = Y_1
    *Map_Data\Teleporter()\Z_1 = Z_1
    *Map_Data\Teleporter()\Dest_Map_ID = Dest_Map_ID
    *Map_Data\Teleporter()\Dest_Map_Unique_ID = Dest_Map_Unique_ID
    *Map_Data\Teleporter()\Dest_X = X
    *Map_Data\Teleporter()\Dest_Y = Y
    *Map_Data\Teleporter()\Dest_Z = Z
    *Map_Data\Teleporter()\Dest_Rot = Rot
    *Map_Data\Teleporter()\Dest_Look = Look
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure Teleporter_Delete(*Map_Data.Map_Data, ID.s)
  If Teleporter_Select(*Map_Data, ID)
    DeleteMapElement(*Map_Data\Teleporter())
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x64)
; Folding = -
; EnableXP
; DisableDebugger
; EnableCompileCount = 0
; EnableBuildCount = 0