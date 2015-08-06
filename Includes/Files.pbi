;Complete!
; ########################################## Variablen ##########################################

Structure Files_Main
    Mutex_ID.i                      ; Mutex, um doppelte Zugriffe zu verhindern.
EndStructure

Global Files_Main.Files_Main

Global NewMap Files_File.s()
;Global NewList Files_File.Files_File()

Global NewMap Files_Folder.s()
;Global NewList Files_Folder.Files_Folder()

; ########################################## Declares ############################################

Declare Files_Load(Filename.s)
Declare Files_Save(Filename.s)

Declare.s Files_File_Get(File.s)
Declare.s Files_Folder_Get(Name.s)

; ########################################## Loading ############################################

Files_Main\Mutex_ID = CreateMutex()

AddMapElement(Files_File(), "Files")
Files_File() = "Files.txt"

Files_Load(Files_File_Get("Files"))

; ########################################## Proceduren ##########################################

Procedure Files_Save(Filename.s)
    File_ID = CreateFile(#PB_Any, Filename)
    
    If IsFile(File_ID)
        
        WriteStringN(File_ID, "; You have to restart if you change this file.")
        WriteStringN(File_ID, "; ")
        WriteStringN(File_ID, "; How it works:")
        WriteStringN(File_ID, ";   [Folder]")
        WriteStringN(File_ID, ";   Main = ../")
        WriteStringN(File_ID, ";   Data = Data/")
        WriteStringN(File_ID, ";   ")
        WriteStringN(File_ID, ";   [Files]")
        WriteStringN(File_ID, ";   Answer = [Main][Data]Answer.txt")
        WriteStringN(File_ID, "; ")
        WriteStringN(File_ID, "; Means that the File Answer is in '../Data/Answer.txt'.")
        WriteStringN(File_ID, "; You can create your own folders if you want:")
        WriteStringN(File_ID, ";   Example: [Folder]")
        WriteStringN(File_ID, ";            Log = Log/")
        WriteStringN(File_ID, ";            ")
        WriteStringN(File_ID, ";            [Files]")
        WriteStringN(File_ID, ";            Log = [Main][Log]Log_[i].txt")
        WriteStringN(File_ID, "; ")
        WriteStringN(File_ID, "; You can also use [date] instead of [i] for the Logfile.")
        
        WriteStringN(File_ID, "")
        
        WriteStringN(File_ID, "[Folder]")
        
        ForEach Files_Folder()
            WriteStringN(File_ID, MapKey(Files_Folder()) + " = " + Files_Folder())
        Next
        
        WriteStringN(File_ID, "")
        
        WriteStringN(File_ID, "[Files]")
        
        ForEach Files_Folder()
            If MapKey(Files_File()) <> "Files"
                WriteStringN(File_ID, MapKey(Files_File()) + " = " + Files_File())
            EndIf
        Next
        
        Log_Add("Files", Lang_Get("", "File saved", Filename), 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
        
        CloseFile(File_ID)
    EndIf
EndProcedure

Procedure Files_Load(Filename.s)
    Opened = OpenPreferences(Filename.s)
    
    ClearMap(Files_Folder())
    
    PreferenceGroup("Folder")
    
    ; Load folders
    If ExaminePreferenceKeys()
        While NextPreferenceKey()
            AddMapElement(Files_Folder(), PreferenceKeyName())
            Files_Folder() = PreferenceKeyValue()
        Wend
    EndIf
    
    ClearMap(Files_File())
    
    PreferenceGroup("Files")
    
    ; Load files (which will include folder mashups..
    If ExaminePreferenceKeys()
        While NextPreferenceKey()
            AddMapElement(Files_File(), PreferenceKeyName())
            Files_File() = PreferenceKeyValue()
        Wend
    EndIf
    
    If Opened
        ClosePreferences()
    EndIf
    
    ; Create Directories
    Working.s = GetCurrentDirectory()
    
    ForEach Files_File()
        Temp.s = Files_File()
        Temp = ReplaceString(Temp, "[i]", "")
        Temp = ReplaceString(Temp, "[date]", "")
        Prepend.s = ""
        
        While Temp <> ""
            First = FindString(Temp, "[")
            Second = FindString(Temp, "]")
            
            If First And Second
                Directory.s = Mid(Temp, First + 1, (Second - (First + 1)))
                Realdir.s = Files_Folder_Get(Directory)
                CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                    Realdir = ReplaceString(Realdir, "/", "\")
                CompilerElse
                    Realdir = ReplaceString(Realdir, "\", "/")
                CompilerEndIf
                If FileSize(Working + Prepend + Realdir) = -1
                    CreateDirectory(Working + Prepend + Realdir)
                EndIf
                
                Prepend + Realdir
                Temp = Mid(Temp, Second + 1, Len(Temp) - Second)
            Else
                Temp = ""
            EndIf
        Wend
    Next
    
    ;Directories created :)
EndProcedure

Threaded Files_File_Get_Return_String.s = ""

Procedure.s Files_File_Get(Name.s)
    LockMutex(Files_Main\Mutex_ID)
    
    Files_File_Get_Return_String.s = ""
    
    If FindMapElement(Files_File(), Name) = 0
        Log_Add("Files", Lang_Get("", "Path to file not defined", Name), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    Else
        Files_File_Get_Return_String = Files_File()
        
        ForEach Files_Folder()
            Files_File_Get_Return_String = ReplaceString(Files_File_Get_Return_String, "["+MapKey(Files_Folder())+"]", Files_Folder())
        Next
    EndIf
    
    UnlockMutex(Files_Main\Mutex_ID)
    
    ProcedureReturn Files_File_Get_Return_String
EndProcedure

Threaded Files_Folder_Get_Return_String.s = ""

Procedure.s Files_Folder_Get(Name.s)
    LockMutex(Files_Main\Mutex_ID)
    
    Files_Folder_Get_Return_String = ""
    
    If FindMapElement(Files_Folder(), Name) = 0
        Log_Add("Files", Lang_Get("", "Path to folder not defined", Name), 10, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
    Else
        Files_Folder_Get_Return_String = Files_Folder(Name)
    EndIf
    
    UnlockMutex(Files_Main\Mutex_ID)
    
    ProcedureReturn Files_Folder_Get_Return_String
EndProcedure
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 133
; FirstLine = 103
; Folding = -
; EnableXP
; Executable = ../Minecraft-Server.x86.exe
; DisableDebugger
; CompileSourceDirectory
; EnableCompileCount = 0
; EnableBuildCount = 0