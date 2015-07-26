XIncludeFile "Includes/ZLib.pbi" ;Include D3's zlib..
OpenConsole()

;Load a file into memory for compression..
Size = FileSize("Find_Language_Strings.pb")
Result = OpenFile(#PB_Any, "Find_Language_Strings.pb")

If Result = #False
  PrintN("Failed to open file.")
EndIf
Debug SizeOf(z_stream)

*Buf = AllocateMemory(Size)
ReadData(Result, *Buf, Size)
CloseFile(Result)

; Spin up ZLib..
*BufOut = AllocateMemory(Size)

PrintN(Str(GZip_Compress(*BufOut, Size, *Buf, Size)))
; asdf.z_stream
; 
; asdf\avail_in = Size
; asdf\avail_out = Size
; asdf\next_in = *Buf
; asdf\next_out = *BufOut
; 
; inflResult.b = deflateInit2_(asdf, #Z_DEFAULT_COMPRESSION, #Z_DEFLATED, 15+16, 8, #Z_DEFAULT_STRATEGY, zlibVersion(), SizeOf(z_stream))
; 
; If Not inflResult = #Z_OK
;   PrintN("Error inflate init: " + Str(inflResult))
; EndIf
; 
; aResult.b = deflate(asdf, #Z_FINISH)
; 
; If Not aResult = #Z_STREAM_END
;   PrintN("Error deflating.. " + Str(aResult))
; EndIf
; 
; outSize = asdf\total_out
; deflateEnd(asdf)
FreeMemory(*Buf)
FreeMemory(*BufOut)
PrintN("Done")
Input()
CloseConsole()
; IDE Options = PureBasic 5.00 (Windows - x64)
; CursorPosition = 19
; FirstLine = 8
; EnableXP