; ########################################## Documentation ##########################################

; Physikalische Eigenschaften:
; 0 = No physics
; 10 = Falls straight down
; 11 = Falls in 45 degree bevels (Builds a pyramid)
; 20 = Minecraft original fluid physics (Block duplicates itself laterally and downwardly)
; 21 = More realistic fluid (Block F�llt nach unten und f�llt fl�chen aus)

; ########################################## Variables ##########################################

Structure Block_Main
    Save_File.b             ; Indicates when to save the file
    File_Date_Last.l        ; Date of last change, save on change.
    Timer_File_Check.l      ; Timer for checking for file changes.
EndStructure
Global Block_Main.Block_Main

; #################################################################
; !!! Structure defined in Main_Structures.pbi !!!
; #################################################################
Global Dim Block.Block(255) ; - Array of blocks, easily accessible by index.

; ########################################## Constants ############################################

; ########################################## Declares ############################################

; ########################################## Proceduren ##########################################

Procedure Block_Load(Filename.s) ; - Loads the Blocks.txt file, which contains all blocks the server recognizes and its respective settings.
    If Not OpenPreferences(Filename.s)
        ProcedureReturn
    EndIf
    
    For i = 0 To 255
        PreferenceGroup(Str(i))
        Block(i)\Name = ReadPreferenceString("Name", "")
        Block(i)\On_Client = ReadPreferenceLong("On_Client", 46)
        Block(i)\Physic = ReadPreferenceLong("Physic", 0)
        Block(i)\Physic_Plugin = ReadPreferenceString("Physic_Plugin", "")
        Block(i)\Do_Time = ReadPreferenceLong("Do_Time", 1000)
        Block(i)\Do_Time_Random = ReadPreferenceLong("Do_Time_Random", 100)
        Block(i)\Do_Repeat = ReadPreferenceLong("Do_Repeat", 0)
        Block(i)\Do_By_Load = ReadPreferenceLong("Do_By_Load", 0)
        Block(i)\Create_Plugin = ReadPreferenceString("Create_Plugin", "")
        Block(i)\Delete_Plugin = ReadPreferenceString("Delete_Plugin", "")
        Block(i)\Replace_By_Load = ReadPreferenceLong("Replace_By_Load", -1)
        Block(i)\Rank_Place = ReadPreferenceLong("Rank_Place", 32767)
        Block(i)\Rank_Delete = ReadPreferenceLong("Rank_Delete", 0)
        Block(i)\After_Delete = ReadPreferenceLong("After_Delete", 0)
        Block(i)\Killer = ReadPreferenceLong("Killer", 0)
        Block(i)\Special = ReadPreferenceLong("Special", 0)
        Block(i)\Color_Overview = ReadPreferenceLong("Color_Overview", RGB(i,i,i))
        Block(i)\CPE_Level = ReadPreferenceLong("CPE_Level",0)
        Block(i)\CPE_Replace = ReadPreferenceLong("CPE_Replace",1)
    Next
    
    Block_Main\Save_File = 1
    
    Block_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Block", Lang_Get("", "File loaded", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    ClosePreferences()
EndProcedure

Procedure Block_Save(Filename.s) ; - Saves the blocks and all block data.
    Protected File_ID.l
    
    File_ID = CreateFile(#PB_Any, Filename)
    
    If Not IsFile(File_ID)
        ProcedureReturn
    EndIf
    
    WriteStringN(File_ID, "; Physic: 0  = Physic Off")
    WriteStringN(File_ID, ";         10 = Original Sand (Falling)")
    WriteStringN(File_ID, ";         11 = New Sand")
    WriteStringN(File_ID, ";         20 = Infinite Water")
    WriteStringN(File_ID, ";         21 = Finite Water")
    WriteStringN(File_ID, "")
    
    For i = 0 To 255
        WriteStringN(File_ID, "["+Str(i)+"]")
        
        If Block(i)\Name = ""
            Continue
        EndIf
        
        WriteStringN(File_ID, "Name = "+Block(i)\Name)
        WriteStringN(File_ID, "On_Client = "+Str(Block(i)\On_Client))
        WriteStringN(File_ID, "Physic = "+Str(Block(i)\Physic))
        WriteStringN(File_ID, "Physic_Plugin = "+Block(i)\Physic_Plugin)
        WriteStringN(File_ID, "Do_Time = "+Str(Block(i)\Do_Time))
        WriteStringN(File_ID, "Do_Time_Random = "+Str(Block(i)\Do_Time_Random))
        WriteStringN(File_ID, "Do_Repeat = "+Str(Block(i)\Do_Repeat))
        WriteStringN(File_ID, "Do_By_Load = "+Str(Block(i)\Do_By_Load))
        WriteStringN(File_ID, "Create_Plugin = "+Block(i)\Create_Plugin)
        WriteStringN(File_ID, "Delete_Plugin = "+Block(i)\Delete_Plugin)
        WriteStringN(File_ID, "Rank_Place = "+Str(Block(i)\Rank_Place))
        WriteStringN(File_ID, "Rank_Delete = "+Str(Block(i)\Rank_Delete))
        WriteStringN(File_ID, "After_Delete = "+Str(Block(i)\After_Delete))
        WriteStringN(File_ID, "Killer = "+Str(Block(i)\Killer))
        WriteStringN(File_ID, "Special = "+Str(Block(i)\Special))
        WriteStringN(File_ID, "Color_Overview = "+Str(Block(i)\Color_Overview))
        WriteStringN(File_ID, "CPE_Level = " + Str(Block(i)\CPE_Level))
        WriteStringN(File_ID, "CPE_Replace = " + Str(Block(i)\CPE_Replace))
        
        If Block(i)\Replace_By_Load <> -1
            WriteStringN(File_ID, "Replace_By_Load = "+Str(Block(i)\Replace_By_Load))
        EndIf
        
        WriteStringN(File_ID, "")
    Next
    
    Block_Main\File_Date_Last = GetFileDate(Filename, #PB_Date_Modified)
    Log_Add("Block", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    
    CloseFile(File_ID)
EndProcedure

;-######################################################################################

Procedure Block_Get_Pointer(Number) ; Specifices a pointer back to the element.
    If Number >= 0 And Number <= 255
        ProcedureReturn @Block(Number)
    EndIf
    
    ProcedureReturn 0
EndProcedure

;-######################################################################################

Procedure Block_Main()
    Protected File_Date.l
    
    If Block_Main\Save_File
        Block_Main\Save_File = 0
        Block_Save(Files_File_Get("Block"))
    EndIf
    
    File_Date = GetFileDate(Files_File_Get("Block"), #PB_Date_Modified)
    
    If Block_Main\File_Date_Last <> File_Date
        Block_Load(Files_File_Get("Block"))
    EndIf
EndProcedure

Procedure BlockShutdown()
    Block_Save(Files_File_Get("Block")) 
EndProcedure

RegisterCore("Block", 1000, #Null, @BlockShutdown(), @Block_Main())
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 151
; FirstLine = 8
; Folding = 5
; EnableXP
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0