  ;  zlib.h -- Interface of the 'zlib' general purpose compression library
  ; version 1.2.8, April 28th, 2013
  ; 
  ; Copyright (C) 1995-2013 Jean-loup Gailly And Mark Adler
  ; 
  ; This software is provided 'as-is', without any express Or implied
  ; warranty.  In no event will the authors be held liable For any damages
  ; arising from the use of this software.
  ; 
  ; Permission is granted To anyone To use this software For any purpose,
  ; including commercial applications, And To alter it And redistribute it
  ; freely, subject To the following restrictions:
  ; 
  ; 1. The origin of this software must Not be misrepresented; you must not
  ;    claim that you wrote the original software. If you use this software
  ;    in a product, an acknowledgment in the product documentation would be
  ;    appreciated but is Not required.
  ; 2. Altered source versions must be plainly marked As such, And must Not be
  ;    misrepresented As being the original software.
  ; 3. This notice may Not be removed Or altered from any source distribution.
  ; 
  ; Jean-loup Gailly        Mark Adler
  ; jloup@gzip.org          madler@alumni.caltech.edu
  ; 
  ; 
  ; The Data format used by the zlib library is described by RFCs (Request For
  ; Comments) 1950 To 1952 in the files http://tools.ietf.org/html/rfc1950
  ; (zlib format), rfc1951 (deflate format) And rfc1952 (gzip format).
  
  #ZLIB_VERSION         = "1.2.8"
  #ZLIB_VERNUM          = $1280
  #ZLIB_VER_MAJOR       = 1
  #ZLIB_VER_MINOR       = 2
  #ZLIB_VER_REVISION    = 8
  #ZLIB_VER_SUBREVISION = 0
  
  ;   The 'zlib' compression library provides in-memory compression And
  ; decompression functions, including integrity checks of the uncompressed Data.
  ; This version of the library supports only one compression method (deflation)
  ; but other algorithms will be added later And will have the same stream
  ; Interface.
  ; 
  ;   Compression can be done in a single Step If the buffers are large enough,
  ; Or can be done by repeated calls of the compression function.  In the latter
  ; Case, the application must provide more input And/Or consume the output
  ; (providing more output space) before each call.
  ; 
  ;   The compressed Data format used by Default by the in-memory functions is
  ; the zlib format, which is a zlib wrapper documented in RFC 1950, wrapped
  ; around a deflate stream, which is itself documented in RFC 1951.
  ; 
  ;   The library also supports reading And writing files in gzip (.gz) format
  ; With an Interface similar To that of stdio using the functions that start
  ; With "gz".  The gzip format is different from the zlib format.  gzip is a
  ; gzip wrapper, documented in RFC 1952, wrapped around a deflate stream.
  ; 
  ;   This library can optionally Read And write gzip streams in memory As well.
  ; 
  ;   The zlib format was designed To be compact And fast For use in memory
  ; And on communications channels.  The gzip format was designed For single-
  ; file compression on file systems, has a larger header than zlib To maintain
  ; directory information, And uses a different, slower check method than zlib.
  ; 
  ;   The library does Not install any signal handler.  The decoder checks
  ; the consistency of the compressed Data, so the library should never crash
  ; even in Case of corrupted input.
  
  ; #### Information about the data types:
  ; #### On x64 Windows LLP64 is used. on x64 Linux and MacOS X LP64 is used. The x86 version of Windows, Linux and MacOS use ILP32. Therefore:
  ; ?????????????????????????????????????
  ; ?      | Windows  | Linux, MacOS    ?
  ; ?      |          +--------+--------?
  ; ?      | x86, x64 | x86    | x64    ?
  ; ?------+----------+--------+--------?
  ; ? int  | 32 bit   | 32 bit | 32 bit ?
  ; ?------+----------+--------+--------?
  ; ? long | 32 bit   | 32 bit | 64 bit ?
  ; ?????????????????????????????????????
  ; #### In zlib uInt is defined as "unsigned int" and uLong as "unsigned long".
  Macro C_int : l : EndMacro
  Macro C_uInt : l : EndMacro
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux Or #PB_Compiler_OS = #PB_OS_MacOS
    Macro C_long : i : EndMacro
    Macro C_uLong : i : EndMacro
  CompilerElse
    Macro C_long : l : EndMacro
    Macro C_uLong : l : EndMacro
  CompilerEndIf
  
  ; - Between different OS's Z_stream is a different size.. so this is the
  ; - Unfortunate fix for it. Seems like there should be a single way to do it.
  ; - Oh well.
CompilerIf #PB_Compiler_OS = #PB_OS_Windows ; - COMPILER IF
  Structure z_stream Align #PB_Structure_AlignC ; SizeOf_x64(Z_Stream) = 88, SizeOf_x86(Z_Stream) = 56
    *next_in.Byte     ; next input byte
    avail_in.C_uInt   ; number of bytes available at next_in
    total_in.C_uLong  ; total nb of input bytes read so far
  
    *next_out.Byte    ; next output byte should be put there
    avail_out.C_uInt  ; remaining free space at next_out
    total_out.C_uLong ; total nb of bytes output so far
  
    *msg              ; last error message, NULL if no error
    *state            ; not visible by applications
  
    *zalloc           ; used to allocate the internal state
    *zfree            ; used to free the internal state
    *opaque           ; private data object passed to zalloc and zfree
  
    data_type.C_int   ; best guess about the data type: binary or text
    adler.l           ; adler32 value of the uncompressed data
    reserved.C_uLong  ; reserved for future use
  EndStructure
CompilerElse ; - COMPILER ELSE
    
  Prototype.i z_alloc_func(*opaque, items.i, size.i)
  Prototype.i z_free_func(*opaque, *address)
  
  Structure z_stream Align #PB_Structure_AlignC ; - SizeOf_x64(Z_Stream) = 112
    *next_in;         /* next input byte */
    avail_in.i;       /* number of bytes available at next_in */

    total_in.i;       /* total nb of input bytes read so far */
  
    *next_out;        /* next output byte should be put there */
    avail_out.i;      /* remaining free space at next_out */

    total_out.i;      /* total nb of bytes output so far */
  
    *msg;             /* last error message, NULL if no error */
    *state;           /* not visible by applications */
  
    zalloc.z_alloc_func;  /* used to allocate the internal state */
    zfree.z_free_func;   /* used to free the internal state */
    *opaque;          /* private data object passed to zalloc and zfree */
  
    data_type.i;      /* best guess about the data type: binary or text */

    adler.i;          /* adler32 value of the uncompressed data */
    reserved.i;       /* reserved for future use */
  EndStructure
CompilerEndIf ; - COMPILER END IF
  
  ;     gzip header information passed To And from zlib routines.  See RFC 1952
  ;  For more details on the meanings of these fields.
  
  Structure gz_header Align #PB_Structure_AlignC ; SizeOf_x64(Z_Stream) = 72, SizeOf_x86(Z_Stream) = 52
      text.C_int      ; true if compressed data believed to be text
      time.C_uLong    ; modification time
      xflags.C_int    ; extra flags (not used when writing a gzip file)
      os.C_int        ; operating system
      *extra          ; pointer to extra field or Z_NULL if none
      extra_len.C_uInt; extra field length (valid if extra != Z_NULL)
      extra_max.C_uInt; space at extra (only when reading header)
      *name           ; pointer to zero-terminated file name or Z_NULL
      name_max.C_uInt ; space at name (only when reading header)
      *comment        ; pointer to zero-terminated comment or Z_NULL
      comm_max.C_uInt ; space at comment (only when reading header)
      hcrc.C_int      ; true if there was or will be a header crc
      done.C_int      ; true when done reading gzip header (not used when writing a gzip file)
  EndStructure
  
  Structure gzFile : EndStructure
  
  ;    The application must update next_in And avail_in when avail_in has dropped
  ;  To zero.  It must update next_out And avail_out when avail_out has dropped
  ;  To zero.  The application must initialize zalloc, zfree And opaque before
  ;  calling the init function.  All other fields are set by the compression
  ;  library And must Not be updated by the application.
  ; 
  ;    The opaque value provided by the application will be passed As the first
  ;  parameter For calls of zalloc And zfree.  This can be useful For custom
  ;  memory management.  The compression library attaches no meaning To the
  ;  opaque value.
  ; 
  ;    zalloc must Return Z_NULL If there is Not enough memory For the object.
  ;  If zlib is used in a multi-Threaded application, zalloc And zfree must be
  ;  thread safe.
  ; 
  ;    On 16-bit systems, the functions zalloc And zfree must be able To allocate
  ;  exactly 65536 bytes, but will Not be required To allocate more than this If
  ;  the symbol MAXSEG_64K is Defined (see zconf.h).  WARNING: On MSDOS, pointers
  ;  returned by zalloc For objects of exactly 65536 bytes *must* have their
  ;  offset normalized To zero.  The Default allocation function provided by this
  ;  library ensures this (see zutil.c).  To reduce memory requirements And avoid
  ;  any allocation of 64K objects, at the expense of compression ratio, compile
  ;  the library With -DMAX_WBITS=14 (see zconf.h).
  ; 
  ;    The fields total_in And total_out can be used For statistics Or progress
  ;  reports.  After compression, total_in holds the total size of the
  ;  uncompressed Data And may be saved For use in the decompressor (particularly
  ;  If the decompressor wants To decompress everything in a single Step).
  
  ; #########################
  ;-       constants
  ; #########################
  
  #Z_NO_FLUSH       = 0
  #Z_PARTIAL_FLUSH  = 1
  #Z_SYNC_FLUSH     = 2
  #Z_FULL_FLUSH     = 3
  #Z_FINISH         = 4
  #Z_BLOCK          = 5
  #Z_TREES          = 6
  ; Allowed flush values; see deflate() and inflate() below for details
  
  #Z_OK             =  0
  #Z_STREAM_END     =  1
  #Z_NEED_DICT      =  2
  #Z_ERRNO          = -1
  #Z_STREAM_ERROR   = -2
  #Z_DATA_ERROR     = -3
  #Z_MEM_ERROR      = -4
  #Z_BUF_ERROR      = -5
  #Z_VERSION_ERROR  = -6
  ; Return codes For the compression/decompression functions. Negative values
  ; are errors, positive values are used For special but normal events.
  
  #Z_NO_COMPRESSION       =  0
  #Z_BEST_SPEED           =  1
  #Z_BEST_COMPRESSION     =  9
  #Z_DEFAULT_COMPRESSION  = -1
  ; compression levels
  
  #Z_FILTERED          = 1
  #Z_HUFFMAN_ONLY      = 2
  #Z_RLE               = 3
  #Z_FIXED             = 4
  #Z_DEFAULT_STRATEGY  = 0
  ; compression strategy; see deflateInit2() below for details
  
  #Z_BINARY  = 0
  #Z_TEXT    = 1
  #Z_ASCII   = #Z_TEXT   ; For compatibility With 1.2.2 And earlier
  #Z_UNKNOWN = 2
  ; Possible values of the data_type field (though see inflate())
  
  #Z_DEFLATED  = 8
  ; The deflate compression method (the only one supported in this version)
  
  #Z_NULL = 0  ; For initializing zalloc, zfree, opaque
  
  ImportC "zlib.a"
    zlibVersion           () ; Returns a pointer to a string
    deflateInit_          (*stream.z_stream, level, *version_string, stream_size)
    deflate               (*stream.z_stream, flush)
    deflateEnd            (*stream.z_stream)
    
    inflateInit_          (*stream.z_stream, *version_string, stream_size)
    inflate               (*stream.z_stream, flush)
    inflateEnd            (*stream.z_stream)
    
    deflateInit2_         (*stream.z_stream, level, method, windowBits, memLevel, strategy, *version_string, stream_size)
    deflateSetDictionary  (*stream.z_stream, *dictionary, dictLength)
    deflateCopy           (*dest.z_stream, *source.z_stream)
    deflateReset          (*stream.z_stream)
    deflateParams         (*stream.z_stream, level, strategy)
    deflateTune           (*stream.z_stream, good_length, max_lazy, nice_length, max_chain)
    deflateBound          (*stream.z_stream, sourceLen)
    deflatePending        (*stream.z_stream, *pending, *bits)
    deflatePrime          (*stream.z_stream, bits, value)
    deflateSetHeader      (*stream.z_stream, *head.gz_header)
    
    inflateInit2_         (*stream.z_stream, windowBits, *version_string, stream_size)
    inflateSetDictionary  (*stream.z_stream, *dictionary, dictLength)
    inflateGetDictionary  (*stream.z_stream, *dictionary, *dictLength.Long)
    inflateSync           (*stream.z_stream)
    inflateCopy           (*dest.z_stream, *source.z_stream)
    inflateReset          (*stream.z_stream)
    inflateReset2         (*stream.z_stream, windowBits)
    inflatePrime          (*stream.z_stream, bits, value)
    inflateMark           (*stream.z_stream)
    inflateGetHeader      (*stream.z_stream, *head.gz_header)
    inflateBackInit       (*stream.z_stream, windowBits, *window)
    inflateBack           (*stream.z_stream, *in, *in_desc, *out, *out_desc)
    inflateBackEnd        (*stream.z_stream)
    
    zlibCompileFlags      ()
    
    compress              (*dest, *destLen, *source, sourceLen)
    compress2             (*dest, *destLen, *source, sourceLen, level)
    compressBound         (sourceLen.l)
    
    uncompress            (*dest, *destLen, *source, sourceLen)
    
    gzopen                (path.s, mode.s)
    gzdopen               (fd, mode.s)
    gzbuffer              (*file.gzFile, size)
    gzsetparams           (*file.gzFile, level, strategy)
    gzread                (*file.gzFile, *buf, len)
    gzwrite               (*file.gzFile, *buf, len)
    gzprintf              (*file.gzFile, format.s, text.s)
    gzputs                (*file.gzFile, s.s)
    gzgets                (*file.gzFile, *buf, len)
    gzputc                (*file.gzFile, c)
    gzgetc                (*file.gzFile)
    gzungetc              (c, *file.gzFile)
    gzflush               (*file.gzFile, flush)
    gzseek                (*file.gzFile, offset, whence)
    gzrewind              (*file.gzFile)
    gztell                (*file.gzFile)
    gzoffset              (*file.gzFile)
    gzeof                 (*file.gzFile)
    gzdirect              (*file.gzFile)
    gzclose               (*file.gzFile)
    gzclose_r             (*file.gzFile)
    gzclose_w             (*file.gzFile)
    gzerror               (*file.gzFile, *errnum)
    gzclearerr            (*file.gzFile)
    
    adler32               (adler.l, *buf, len.l)
    adler32_combine       (adler1.l, adler2.l, len2)
    crc32                 (crc.l, *buf, len.l)
    crc32_combine         (crc1.l, crc2.l, len2)
  EndImport
  

Procedure GZip_CompressBound(Input_Len)
    Result = compressBound(Input_Len)
    ProcedureReturn Result
EndProcedure

Procedure GZip_Compress(*Output, Output_Len, *Input, Input_Len)
  Protected asdf.z_stream
  asdf\avail_in = Input_Len
  asdf\avail_out = Output_Len
  asdf\next_in = *Input
  asdf\next_out = *Output
  
  inflResult.b = deflateInit2_(asdf, #Z_DEFAULT_COMPRESSION, #Z_DEFLATED, 15+16, 8, #Z_DEFAULT_STRATEGY, zlibVersion(), SizeOf(z_Stream))
  
  If Not inflResult = #Z_OK
    ProcedureReturn -1
  EndIf
  
  aResult.b = deflate(asdf, #Z_FINISH)
  
  If Not aResult = #Z_STREAM_END
    ProcedureReturn -1
  EndIf
  
  Output_Len = asdf\total_out
  deflateEnd(asdf)
  
  ProcedureReturn Output_Len
EndProcedure

Procedure GZip_Decompress(*Output, Output_Len, *Input, Input_Len)
    Protected asdf.z_stream
    asdf\avail_in = Input_Len
    asdf\avail_out = Output_Len
    asdf\next_in = *Input
    asdf\next_out = *Output
    
    inflResult.b = inflateInit2_(asdf, 15+16, zlibVersion(), SizeOf(z_Stream))
    
    If Not inflResult = #Z_OK
        ProcedureReturn -1
    EndIf
    
    aResult.b = inflate(asdf, #Z_NO_FLUSH)
    
     If aResult <> #Z_STREAM_END And aResult <> #Z_OK
         ProcedureReturn aResult
     EndIf
    
    Output_Len = asdf\total_out
    inflateEnd(@asdf)
    
    ProcedureReturn Output_Len
EndProcedure

Procedure GZip_Compress_2_File(*Input, Input_Len, Filename.s)
    ;Allocate some memory..
    *Compressed = AllocateMemory(Input_Len)
    CompResult = GZip_Compress(*Compressed, Input_Len, *Input, Input_Len)
    
    If CompResult = -1
        ProcedureReturn #False
    EndIf
    
    MyFile = CreateFile(#PB_Any, Filename)
    
    If MyFile = #False
        ProcedureReturn #False
    EndIf
    
    WriteData(MyFile, *Compressed, CompResult)
    CloseFile(MyFile)
    
  ProcedureReturn #True
EndProcedure

Procedure GZip_Decompress_From_File(Filename.s, *Output, Output_Len)
    Protected Size.l
    
    Size = FileSize(Filename)
    Result = ReadFile(#PB_Any, Filename)
    
    If Not Result
        ProcedureReturn #False
    EndIf
    
    *buf = AllocateMemory(Size)
    readResult = ReadData(Result, *Buf, Size)
    CloseFile(Result)
    
    Decomp = GZip_Decompress(*Output, Output_Len, *Buf, Size)
    
    If Decomp = -1
        ProcedureReturn #False
    EndIf
    
    Output_Len = Decomp
    ProcedureReturn Decomp
EndProcedure
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 331
; FirstLine = 325
; Folding = ---
; EnableXP
; DisableDebugger
; CompileSourceDirectory