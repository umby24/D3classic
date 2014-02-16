; ################################################### Documentation #########################################
; 
; Todo:
;  - 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; ################################################### Includes ##############################################

XIncludeFile "/../Include/Include.pbi"

; ################################################### Inits #################################################

; ################################################### Konstants #############################################

#Plugin_Name = "ScreenCap"
#Plugin_Author = "David Vogel"

Global ScreenCap_Map_ID = 7
Global ScreenCap_Offset_X = 0     ; Offset der Eingabe
Global ScreenCap_Offset_Y = 130   ; Offset der Eingabe
Global ScreenCap_Scale = 2        ; Skalierung der Eingabe
Global ScreenCap_Size_X = 200     ; Ausgabegr��e (Eingabegro�e = Size_X * Scale)
Global ScreenCap_Size_Y = 150     ; Ausgabegr��e (Eingabegro�e = Size_X * Scale)
Global ScreenCap_Time = 250

; ################################################### Variables #############################################

Structure RGB_2_Type_Element
  R.a
  G.a
  B.a
  Shadow.a
  Type.a
EndStructure
Global NewList RGB_2_Type_Element.RGB_2_Type_Element()

Global Dim RGB_2_Type.a(255,255,255)

Global Dim Pow_2(512)

; ################################################### Declares ##############################################

; ################################################### Prototypes ############################################

; ################################################### Procedures ############################################

Procedure Pow_2_Create()
  For i = 0 To 255
    Pow_2(255+i) = Pow(i, 2)
    Pow_2(255-i) = Pow(i, 2)
  Next
EndProcedure

Procedure RGB_2_Type_Add(Type.a, R.a, G.a, B.a)
  AddElement(RGB_2_Type_Element())
  RGB_2_Type_Element()\R = R
  RGB_2_Type_Element()\G = G
  RGB_2_Type_Element()\B = B
  RGB_2_Type_Element()\Shadow = 0
  RGB_2_Type_Element()\Type = Type
  
  AddElement(RGB_2_Type_Element())
  RGB_2_Type_Element()\R = R * 0.61
  RGB_2_Type_Element()\G = G * 0.61
  RGB_2_Type_Element()\B = B * 0.61
  RGB_2_Type_Element()\Shadow = 1
  RGB_2_Type_Element()\Type = Type
EndProcedure

Procedure RGB_2_Type_Generate()
  PrintN(LSet("",32, "#"))
  For R.a = 0 To 255
    If R % 8 = 0
      Print("#")
    EndIf
    For G.a = 0 To 255
      For B.a = 0 To 255
        Max_Dist = 200000
        ForEach RGB_2_Type_Element()
          Dist = Pow_2(255+R-RGB_2_Type_Element()\R)+Pow_2(255+G-RGB_2_Type_Element()\G)+Pow_2(255+B-RGB_2_Type_Element()\B)
          If Max_Dist > Dist
            Max_Dist = Dist
            RGB_2_Type(R,G,B) = RGB_2_Type_Element()\Type + RGB_2_Type_Element()\Shadow * 128
          EndIf
        Next
      Next
    Next
  Next
  PrintN("")
EndProcedure

ProcedureCDLL Init(*Plugin_Info.Plugin_Info, *Plugin_Function.Plugin_Function) ; Aufgerufen beim Laden der Library / Called with the loading of the library
  *Plugin_Info\Name = #Plugin_Name
  *Plugin_Info\Version = #Plugin_Version
  *Plugin_Info\Author = #Plugin_Author
  
  Define_Prototypes(*Plugin_Function)
  
  ; #############
  
  OpenConsole()
  
  Pow_2_Create()
  
  RGB_2_Type_Add(1 , 101,101,101)    ; Stone        ; 60,40%
  RGB_2_Type_Add(3 , 107,078,055)    ; Dirt         ; 61,68% 61,54% 61,82%
  RGB_2_Type_Add(4 , 095,095,095)    ; Cobble       ; 61,05%
  RGB_2_Type_Add(5 , 125,103,064)    ; Wood         ; 60,80% 60,19% 60,94%
  RGB_2_Type_Add(7 , 069,069,069)    ; Solid        ; 60,87%
  RGB_2_Type_Add(12, 174,168,128)    ; Sand
  RGB_2_Type_Add(13, 110,102,102)    ; Gravel
  RGB_2_Type_Add(14, 116,113,101)    ; Gold ore
  RGB_2_Type_Add(15, 110,106,103)    ; Iron ore
  RGB_2_Type_Add(16, 093,093,093)    ; Coal ore
  RGB_2_Type_Add(17, 082,066,041)    ; Log
  RGB_2_Type_Add(19, 146,146,047)    ; Sponge
  RGB_2_Type_Add(21, 178,042,042)    ; Red          ; 60,11% 61,90% 61,90%
  RGB_2_Type_Add(22, 178,109,042)    ; Orange
  RGB_2_Type_Add(23, 178,178,042)    ; Yellow
  RGB_2_Type_Add(24, 109,178,042)    ; Lime
  RGB_2_Type_Add(25, 042,178,042)    ; Green
  RGB_2_Type_Add(26, 042,178,110)    ; Aqua Green
  RGB_2_Type_Add(27, 042,178,178)    ; Cyan
  RGB_2_Type_Add(28, 085,131,178)    ; Blue
  RGB_2_Type_Add(29, 097,097,178)    ; Purple
  RGB_2_Type_Add(30, 109,042,178)    ; Indigo
  RGB_2_Type_Add(31, 140,060,178)    ; Violet
  RGB_2_Type_Add(32, 178,042,178)    ; Magenta
  RGB_2_Type_Add(33, 178,042,109)    ; Pink
  RGB_2_Type_Add(34, 063,063,063)    ; Black        ; 60,32%
  RGB_2_Type_Add(35, 115,115,115)    ; Gray
  RGB_2_Type_Add(36, 178,178,178)    ; White        ; 60,11% ...
  RGB_2_Type_Add(41, 186,133,039)    ; Gold Block
  RGB_2_Type_Add(42, 153,154,154)    ; Iron Block   ; 60,13% ...
  RGB_2_Type_Add(45, 158,086,065)    ; Brick        ; 60,76% ...
  RGB_2_Type_Add(46, 135,076,060)    ; TNT
  RGB_2_Type_Add(47, 085,070,047)    ; Bookcase
  RGB_2_Type_Add(48, 073,088,073)    ; Mossy Cobble
  RGB_2_Type_Add(49, 018,018,026)    ; Obsidian     ; 61,11% 61,11% 61,54%
  
  RGB_2_Type_Generate()
EndProcedure

Procedure Click(X.w, Y.w, Time_Down, Time_Up)
  SetCursorPos_(X, Y)
  mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
  Delay(Time_Down)
  mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
  Delay(Time_Up)
EndProcedure

Procedure MakeDesktopScreenshot(ImageNr,x,y,Width,Height) 
   hImage = CreateImage(ImageNr,Width,Height) 
   hDC    = StartDrawing(ImageOutput(ImageNr)) 
   DeskDC = GetDC_(GetDesktopWindow_()) 
      BitBlt_(hDC,0,0,Width,Height,DeskDC,x,y,#SRCCOPY) 
   StopDrawing() 
   ReleaseDC_(GetDesktopWindow_(),DeskDC) 
   ProcedureReturn hImage 
EndProcedure

ProcedureCDLL Event_Map_Block_Change_Client(*Client.Network_Client, *Map_Data.Map_Data, X, Y, Z, Mode.a, Type.a)
  If *Client And *Map_Data
    If *Map_Data\ID = ScreenCap_Map_ID
      If Mode = 0
        If X >= 0 And X <= ScreenCap_Size_X-1
          If Z >= 1 And Z <= ScreenCap_Size_Y
            If Y >= 0 And Y <= 1
              ;Click(ScreenCap_Offset_X+(X*ScreenCap_Scale), ScreenCap_Offset_Y+(ScreenCap_Size_Y-Z)*ScreenCap_Scale, 50, 50)
              ;System_Message_Network_Send_2_All(*Map_Data\ID, "X"+Str(X)+" Y"+Str(Y-1))
              ;System_Message_Network_Send_2_All(-1, PeekS(Lang_Get("", "ZZZZZ", "meh")))
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn #True
EndProcedure

ProcedureCDLL Main()
  Static Timer
  
  If GetAsyncKeyState_(#VK_LCONTROL) And GetAsyncKeyState_(#VK_LSHIFT)
    ScreenCap_Offset_X = DesktopMouseX()
    ScreenCap_Offset_Y = DesktopMouseY()
  EndIf
  
  If Timer < ElapsedMilliseconds()
    Timer = ElapsedMilliseconds() + ScreenCap_Time
    
    Start_Time = ElapsedMilliseconds()
    
    *Map_Data = Map_Get_Pointer(ScreenCap_Map_ID)
    If *Map_Data
      MakeDesktopScreenshot(0, ScreenCap_Offset_X, ScreenCap_Offset_Y, ScreenCap_Size_X*ScreenCap_Scale, ScreenCap_Size_Y*ScreenCap_Scale) 
      If StartDrawing(ImageOutput(0))
        For ix = 0 To ScreenCap_Size_X-1
          For iy = 0 To ScreenCap_Size_Y-1
            Color = Point(ix*ScreenCap_Scale, iy*ScreenCap_Scale)
            If Color <> Color_Old
              R.a = Red(Color)
              G.a = Green(Color)
              B.a = Blue(Color)
              Block.a = RGB_2_Type(R,G,B)
              If Block >= 128
                Block - 128
                Shadow = 1
              Else
                Shadow = 0
              EndIf
            EndIf
            Color_Old = Color
            
            If Shadow
              Map_Block_Change(-1, *Map_Data, ix, 0, (ScreenCap_Size_Y-iy), Block, 0, 0, 1, 2)
              Map_Block_Change(-1, *Map_Data, ix, 1, (ScreenCap_Size_Y-iy), 0, 0, 0, 1, 2)
            Else
              Map_Block_Change(-1, *Map_Data, ix, 1, (ScreenCap_Size_Y-iy), Block, 0, 0, 1, 2)
            EndIf
          Next
        Next
        StopDrawing()
      EndIf
      FreeImage(0)
    EndIf
    
    ;System_Message_Network_Send_2_All(#ScreenCap_Map_ID, "&e"+StrF((ElapsedMilliseconds()-Start_Time)/1000, 3)+"s")
    
  EndIf
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 31
; Folding = --
; EnableXP
; EnableOnError
; Executable = C:\Users\Tommy\Desktop\Screenap.x86.dll
; DisableDebugger