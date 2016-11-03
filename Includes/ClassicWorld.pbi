Prototype.i MetadataFunction()

Structure IMetadataStructure
    ReadFunc.i ; Both read and write are pointers to functions.
    WriteFunc.i 
EndStructure

Structure CPEMetadata
    ClickDistanceVersion.l
    ClickDistance.w
    
    CustomBLocksVersion.l
    CustomBlocksLevel.w
    *CustomBlocksFallback
    
    EnvColorsVersion.l
    SkyColor.l
    CloudColor.l
    FogColor.l
    AmbientColor.l
    SunlightColor.l
    
    EnvMapAppearanceVersion.l
    TextureURL.s
    SideBlock.b
    EdgeBlock.b
    SideLevel.w
EndStructure

Structure ClassicWorld
    FormatVersion.b
    MapName.s
    *UUID
    SizeX.w
    SizeY.w
    SizeZ.w
    
    CreatingService.s
    CreatingUsername.s
    GeneratingSoftware.s
    GeneratorName.s
    
    TimeCreated.d
    LastAccessed.d
    LastModified.d
    
    SpawnX.w
    SpawnY.w
    SpawnZ.w
    SpawnRot.b
    SpawnLook.b
    
    *BlockData
    
    Map MetadataParsers.IMetadataStructure()
    List ForeignMeta.NBT_Tag()
    
    *BaseTag.NBT_Tag
EndStructure

Procedure ClassicWorldCreate(X.w, Y.w, Z.w)
    Protected NewCWMap.ClassicWorld
    
    NewCWMap\UUID = AllocateMemory(16)
    RandomData(NewCWMap\UUID, 16)
    
    NewCWMap\BlockData = AllocateMemory(X * Y * Z)
    NewCWMap\FormatVersion = 1
    NewCWMap\SizeX = X
    NewCWMap\SizeY = Y
    NewCWMap\SizeZ = Z
    
    NewCWMap\TimeCreated = Date()
    NewCWMap\LastAccessed = Date()
    NewCWMap\LastModified = Date()
    
    AddMapElement(NewCWMap\MetadataParsers(), "CPE")
    NewCWMap\MetadataParsers()\ReadFunc = @ReadCPE()
    NewCWMap\MetadataParsers()\WriteFunc = @WriteCPE()
    
    ProcedureReturn NewCWMap
EndProcedure

Procedure ClassicWorldLoad(Filename.s)
    Protected *TopElement.NBT_Element = NBT_Read_File(Filename)
    Protected NewCWMap.ClassicWorld
    
    NewCWMap\BaseTag = *TopElement\NBT_Tag
    
    If NewCWMap\BaseTag\String <> "ClassicWorld"
        PrintN("Error loading " + Filename + ". Basetag name is not ClassicWorld.")
        ProcedureReturn #False
    EndIf
    
    AddMapElement(NewCWMap\MetadataParsers(), "CPE")
    NewCWMap\MetadataParsers()\ReadFunc = @ReadCPE()
    NewCWMap\MetadataParsers()\WriteFunc = @WriteCPE()
    
    ClassicWorldParse(NewCWMap)
    
    ProcedureReturn NewCWMap
EndProcedure

Procedure ClassicWorldParse(CWMap.ClassicWorld)
    If CWMap\BlockData
        FreeMemory(CWMap\BlockData)
    EndIf
    
    
EndProcedure

Procedure ClassicWorldSave(Filename.s, CWMap.ClassicWorld)
    
EndProcedure

Procedure ReadCPE()
EndProcedure

Procedure WriteCPE()
EndProcedure


; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 108
; FirstLine = 65
; Folding = --
; EnableThread
; EnableXP
; EnableOnError
; CompileSourceDirectory