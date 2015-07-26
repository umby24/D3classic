
; ########################################## Konstanten ########################################

;option for multiple returns in `lua_pcall' and `lua_call' 
#LUA_MULTRET 					  =	-1

;  pseudo-indices 
#LUA_REGISTRYINDEX 			=	(-10000)
#LUA_ENVIRONINDEX 			=	(-10001)
#LUA_GLOBALSINDEX 			=	(-10002)

;  thread status; 0 is OK  
#LUA_YIELD 						  =	1
#LUA_ERRRUN 					  =	2
#LUA_ERRSYNTAX 				  =	3
#LUA_ERRMEM 					  =	4
#LUA_ERRERR 					  =	5

;  basic types 
#LUA_TNONE						  =	-1
#LUA_TNIL						    =	0
#LUA_TBOOLEAN					  =	1
#LUA_TLIGHTUSERDATA 	  =	2
#LUA_TNUMBER					  =	3
#LUA_TSTRING					  =	4
#LUA_TTABLE						  =	5
#LUA_TFUNCTION					=	6
#LUA_TUSERDATA					=	7
#LUA_TTHREAD					  =	8

;  minimum Lua stack available to a C function 
#LUA_MINSTACK 					=	20

;  garbage-collection function and options 
#LUA_GCSTOP						  =	0
#LUA_GCRESTART					=	1
#LUA_GCCOLLECT					=	2
#LUA_GCCOUNT					  =	3
#LUA_GCCOUNTB					  =	4
#LUA_GCSTEP						  =	5
#LUA_GCSETPAUSE				  =	6
#LUA_GCSETSTEPMUL 			=	7
																	
;  Event codes 																	
#LUA_HOOKCALL 					=	0
#LUA_HOOKRET 					  =	1
#LUA_HOOKLINE 					=	2
#LUA_HOOKCOUNT 				  =	3
#LUA_HOOKTAILRET 				=	4

;  Event masks 
#LUA_MASKCALL 					=	1 << #LUA_HOOKCALL
#LUA_MASKRET 					  =	1 << #LUA_HOOKRET
#LUA_MASKLINE 					=	1 << #LUA_HOOKLINE
#LUA_MASKCOUNT 				  =	1 << #LUA_HOOKCOUNT

; ########################################## Variablen ##########################################

Structure Lua_Main
  State.i                     ; Lua-State von Lua_LuaL_NewState()
  Timer_File_Check.l          ; Timer f�r das �berpr�fen der Dateigr��e
EndStructure
Global Lua_Main.Lua_Main

Structure Lua_File
  Filename.s
  File_Date_Last.l            ; Datum letzter �nderung
EndStructure
Global NewList Lua_File.Lua_File()

; ########################################## Ladekram ############################################

; ########################################## Declares ############################################

Declare Lua_Register_All()

; ########################################## Imports ##########################################

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86  
    ImportC "Librarys/lib/lua5.1(x86).lib" ; Windows x86
  CompilerElse
    ImportC "Librarys/lib/lua5.1(x64).lib" ; Windows x64
  CompilerEndIf
CompilerElse
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86  
    ImportC "Librarys/lib/lua5.1(x86).a" ;     Linux x86
  CompilerElse
    ImportC "Librarys/lib/lua5.1(x64).a" ;     Linux x64
  CompilerEndIf
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows And #PB_Compiler_Processor = #PB_Processor_x86
  ; lua.h
  ; /*
  ; ** state manipulation
  ; */
  Lua_lua_newstate(*lua_Alloc.l, *ud.l)              As "_lua_newstate"
  Lua_lua_close(*lua_State.l)                        As "_lua_close"
  Lua_lua_newthread(*lua_State.l)                    As "_lua_newthread"
  Lua_lua_atpanic(*lua_State.l, *lua_CFunction.l)    As "_lua_atpanic"

  ; /*
  ; ** basic stack manipulation
  ; */
  Lua_lua_gettop(*lua_State.l)                       As "_lua_gettop"
  Lua_lua_settop(*lua_State.l, idx.l)                As "_lua_settip"
  Lua_lua_pushvalue(*lua_State.l, idx.l)             As "_lua_pushvalue"
  Lua_lua_remove(*lua_State.l, idx.l)                As "_lua_remove"
  Lua_lua_insert(*lua_State.l, idx.l)                As "_lua_insert"
  Lua_lua_replace(*lua_State.l, idx.l)               As "_lua_replace"
  Lua_lua_checkstack(*lua_State.l, sz.l)             As "_lua_checkstack"

  Lua_lua_xmove(*lua_State_from.l, *lua_State_to.l, n.l) As "_lua_xmove"

  ; /*
  ; ** access functions (stack -> C)
  ; */
  Lua_lua_isnumber(*lua_State.l, idx.l)              As "_lua_isnumber"
  Lua_lua_isstring(*lua_State.l, idx.l)              As "_lua_isstring"
  Lua_lua_iscfunction(*lua_State.l, idx.l)           As "_lua_iscfunction"
  Lua_lua_isuserdata(*lua_State.l, idx.l)            As "_lua_isuserdata"
  Lua_lua_type(*lua_State.l, idx.l)                  As "_lua_type"
  Lua_lua_typename(*lua_State.l, tp.l)               As "_lua_typename"

  Lua_lua_equal(*lua_State.l, idx1.l, idx2.l)        As "_lua_equal"
  Lua_lua_rawequal(*lua_State.l, idx1.l, idx2.l)     As "_lua_rawequal"
  Lua_lua_lessthan(*lua_State.l, idx1.l, idx2.l)     As "_lua_lessthan"

  Lua_lua_tonumber.d(*lua_State.l, idx.l)            As "_lua_tonumber"
  Lua_lua_tointeger(*lua_State.l, idx.l)             As "_lua_tointeger"
  Lua_lua_toboolean(*lua_State.l, idx.l)             As "_lua_toboolean"
  Lua_lua_tolstring(*lua_State.l, idx.l, len.l)      As "_lua_tolstring"
  Lua_lua_objlen(*lua_State.l, idx.l)                As "_lua_objlen"
  Lua_lua_tocfunction(*lua_State.l, idx.l)           As "_lua_tocfunction"
  Lua_lua_touserdata(*lua_State.l, idx.l)            As "_lua_touserdata"
  Lua_lua_tothread(*lua_State.l, idx.l)              As "_lua_tothread"
  Lua_lua_topointer(*lua_State.l, idx.l)             As "_lua_topointer"

  ; /*
  ; ** push functions (C -> stack)
  ; */
  Lua_lua_pushnil(*lua_State.l)                        As "_lua_pushnil"
  Lua_lua_pushnumber(*lua_State.l, LUA_NUMBER.d)       As "_lua_pushnumber"
  Lua_lua_pushinteger(*lua_State.l, LUA_INTEGER.l)     As "_lua_pushinteger"
  Lua_lua_pushlstring(*lua_State.l, string.s, size.l)  As "_lua_pushlstring"
  Lua_lua_pushstring(*lua_State.l, string.s)           As "_lua_pushstring"
  ;lua_pushvfstring(*lua_State.L, const char *fmt, va_list argp)
  ;lua_pushfstring(*lua_State.L, const char *fmt, ...)
  Lua_lua_pushcclosure(*lua_State.l, *fn.l, n.l)       As "_lua_pushcclosure"
  Lua_lua_pushboolean(*lua_State.l, b.l)               As "_lua_pushboolean"
  Lua_lua_pushlightuserdata(*lua_State.l, *p.l)        As "_lua_pushlightuserdata"
  Lua_lua_pushthread(*lua_State.l)                     As "_lua_pushthread"

  ; /*
  ; ** get functions (Lua -> stack)
  ; */
  Lua_lua_gettable(*lua_State.l, idx.l)                As "_lua_gettable"
  Lua_lua_getfield(*lua_State.l, idx.l, k.s)           As "_lua_getfield"
  Lua_lua_rawget(*lua_State.l, idx.l)                  As "_lua_rawget"
  Lua_lua_rawgeti(*lua_State.l, idx.l, n.l)            As "_lua_rawgeti"
  Lua_lua_createtable(*lua_State.l, narr.l, nrec.l)    As "_lua_createtable"
  Lua_lua_newuserdata(*lua_State.l, sz.l)              As "_lua_newuserdata"
  Lua_lua_getmetatable(*lua_State.l, objindex.l)       As "_lua_getmetatable"
  Lua_lua_getfenv(*lua_State.l, idx.l)                 As "_lua_getfenv"

  ; /*
  ; ** set functions (stack -> Lua)
  ; */
  Lua_lua_settable(*lua_State.l, idx.l)                As "_lua_settable"
  Lua_lua_setfield(*lua_State.l, idx.l, k.s)           As "_lua_setfield"
  Lua_lua_rawset(*lua_State.l, idx.l)                  As "_lua_rawset"
  Lua_lua_rawseti(*lua_State.l, idx.l, n.l)            As "_lua_rawseti"
  Lua_lua_setmetatable(*lua_State.l, objindex.l)       As "_lua_setmetatable"
  Lua_lua_setfenv(*lua_State.l, idx.l)                 As "_lua_setfenv"

  ; /*
  ; ** `load' and `call' functions (load and run Lua code)
  ; */
  Lua_lua_call(*lua_State.l, nargs.l, nresults.l)                        As "_lua_call"
  Lua_lua_pcall(*lua_State.l, nargs.l, nresults.l, *lua_errCFunction.l)  As "_lua_pcall"
  Lua_lua_cpcall(*lua_State.l, *lua_CFunction.l, *ud.l)                  As "_lua_cpcall"
  Lua_lua_load(*lua_State.l, lua_Reader.l, *dt.l, chunkname.s)           As "_lua_load"

  Lua_lua_dump(*lua_State.l, lua_Writer.l, *vdata.l)   As "_lua_dump"

  ; /*
  ; ** coroutine functions
  ; */
  Lua_lua_yield(*lua_State.l, nresults.l)    As "_lua_yield"
  Lua_lua_resume(*lua_State.l, narg.l)       As "_lua_resume"
  Lua_lua_status(*lua_State.l)               As "_lua_status"

  ; /*
  ; ** garbage-collection function And options
  ; */
  Lua_lua_gc(*lua_State.l, what.l, idata.l)  As "_lua_gc"

  ; /*
  ; ** miscellaneous functions
  ; */
  Lua_lua_error(*lua_State.l)                           As "_lua_error"

  Lua_lua_next(*lua_State.l, idx.l)                     As "_lua_next"

  Lua_lua_concat(*lua_State.l, n.l)                     As "_lua_concat"

  Lua_lua_getallocf(*lua_State.l, *p_ud.l)              As "_lua_getallocf"
  Lua_lua_setallocf(*lua_State.l, lua_Alloc.l, *ud.l)   As "_lua_setallocf"

  ; lualib.h
  Lua_luaopen_base(*lua_State.l)    As "_luaopen_base"
  Lua_luaopen_table(*lua_State.l)   As "_luaopen_table"
  Lua_luaopen_io(*lua_State.l)      As "_luaopen_io"
  Lua_luaopen_os(*lua_State.l)      As "_luaopen_os"
  Lua_luaopen_string(*lua_State.l)  As "_luaopen_string"
  Lua_luaopen_math(*lua_State.l)    As "_luaopen_math"
  Lua_luaopen_debug(*lua_State.l)   As "_luaopen_debug"
  Lua_luaopen_package(*lua_State.l) As "_luaopen_package"

  ; /* open all previous libraries */
  Lua_luaL_openlibs(*lua_State.l)   As "_luaL_openlibs"

  ;lauxlib_h
  Lua_luaI_openlib(*lua_State.l, libname.s, *luaL_Reg.l, nup.l)  As "_luaI_openlib"
  Lua_luaL_register(*lua_State.l, libname.s, *luaL_Reg.l)        As "_luaL_register"
  Lua_luaL_getmetafield(*lua_State.l, obj.l, e.s)                As "_luaL_getmetafield"
  Lua_luaL_callmeta(*lua_State.l, obj.l, e.s)                    As "_luaL_callmeta"
  Lua_luaL_typerror(*lua_State.l, narg.l, tname.s)               As "_luaL_typerror"
  Lua_luaL_argerror(*lua_State.l, numarg.l, extramsg.s)          As "_luaL_argerror"
  Lua_luaL_checklstring(*lua_State.l, numarg.l, size.l)          As "_luaL_checklstring"
  Lua_luaL_optlstring(*lua_State.l, numarg.l, def.s, size.l)     As "_luaL_optlstring"
  Lua_luaL_checknumber(*lua_State.l, numarg.l)                   As "_luaL_checknumber"
  Lua_luaL_optnumber(*lua_State.l, narg, LUA_NUMBER.d)           As "_luaL_optnumber"

  Lua_luaL_checkinteger(*lua_State.l, numarg.l)                  As "_luaL_checkinteger"
  Lua_luaL_optinteger(*lua_State.l, narg.l, LUA_INTEGER.l)       As "_luaL_optinteger"

  Lua_luaL_checkstack(*lua_State.l, sz.l, msg.s)                 As "_luaL_checkstack"
  Lua_luaL_checktype(*lua_State.l, narg.l, t.l)                  As "_luaL_checktype"
  Lua_luaL_checkany(*lua_State.l, narg.l)                        As "_luaL_checkany"

  Lua_luaL_newmetatable(*lua_State.l, tname.s)                   As "_luaL_newmetatable"
  Lua_luaL_checkudata(*lua_State.l, ud.l, tname.s)               As "_luaL_checkudata"

  Lua_luaL_where(*lua_State.l, lvl.l)                            As "_luaL_where"
  ;luaL_error(*lua_State.L, const char *fmt, ...)

  Lua_luaL_checkoption(*lua_State.l, narg.l, def.s, *string_array.l)  As "_luaL_checkoption"

  Lua_luaL_ref(*lua_State.l, t.l)           As "_luaL_ref"
  Lua_luaL_unref(*lua_State.l, t.l, ref.l)  As "_luaL_unref"

  Lua_luaL_loadfile(*lua_State.l, filename.s)                As "_luaL_loadfile"
  Lua_luaL_loadbuffer(*lua_State.l, buff.l, size.l, name.s)  As "_luaL_loadbuffer"
  Lua_luaL_loadstring(*lua_State.l, string.s)                As "_luaL_loadstring"

  Lua_luaL_newstate() As "_luaL_newstate"


  Lua_luaL_gsub(*lua_State.l, s.s, p.s, r.s)       As "_luaL_gsub"

  Lua_luaL_findtable(*lua_State.l, idx.l, fname.s) As "_luaL_findtable"

  Lua_luaL_buffinit(*lua_State.l, *luaL_Buffer.l)  As "_luaL_buffinit"
  Lua_luaL_prepbuffer(*luaL_Buffer.l)              As "_luaL_prepbuffer"
  Lua_luaL_addlstring(*luaL_Buffer.l, s.s, size.l) As "_luaL_addlstring"
  Lua_luaL_addstring(*luaL_Buffer.l, s.s)          As "_luaL_addstring"
  Lua_luaL_addvalue(*luaL_Buffer.l)                As "_luaL_addvalue"
  Lua_luaL_pushresult(*luaL_Buffer.l)              As "_luaL_pushresult"
EndImport
CompilerElse
  ; lua.h
  ; /*
  ; ** state manipulation
  ; */
  Lua_lua_newstate(*lua_Alloc.l, *ud.l)              As "lua_newstate"
  Lua_lua_close(*lua_State.l)                        As "lua_close"
  Lua_lua_newthread(*lua_State.l)                    As "lua_newthread"
  Lua_lua_atpanic(*lua_State.l, *lua_CFunction.l)    As "lua_atpanic"

  ; /*
  ; ** basic stack manipulation
  ; */
  Lua_lua_gettop(*lua_State.l)                       As "lua_gettop"
  Lua_lua_settop(*lua_State.l, idx.l)                As "lua_settip"
  Lua_lua_pushvalue(*lua_State.l, idx.l)             As "lua_pushvalue"
  Lua_lua_remove(*lua_State.l, idx.l)                As "lua_remove"
  Lua_lua_insert(*lua_State.l, idx.l)                As "lua_insert"
  Lua_lua_replace(*lua_State.l, idx.l)               As "lua_replace"
  Lua_lua_checkstack(*lua_State.l, sz.l)             As "lua_checkstack"

  Lua_lua_xmove(*lua_State_from.l, *lua_State_to.l, n.l) As "lua_xmove"

  ; /*
  ; ** access functions (stack -> C)
  ; */
  Lua_lua_isnumber(*lua_State.l, idx.l)              As "lua_isnumber"
  Lua_lua_isstring(*lua_State.l, idx.l)              As "lua_isstring"
  Lua_lua_iscfunction(*lua_State.l, idx.l)           As "lua_iscfunction"
  Lua_lua_isuserdata(*lua_State.l, idx.l)            As "lua_isuserdata"
  Lua_lua_type(*lua_State.l, idx.l)                  As "lua_type"
  Lua_lua_typename(*lua_State.l, tp.l)               As "lua_typename"

  Lua_lua_equal(*lua_State.l, idx1.l, idx2.l)        As "lua_equal"
  Lua_lua_rawequal(*lua_State.l, idx1.l, idx2.l)     As "lua_rawequal"
  Lua_lua_lessthan(*lua_State.l, idx1.l, idx2.l)     As "lua_lessthan"

  Lua_lua_tonumber.d(*lua_State.l, idx.l)            As "lua_tonumber"
  Lua_lua_tointeger(*lua_State.l, idx.l)             As "lua_tointeger"
  Lua_lua_toboolean(*lua_State.l, idx.l)             As "lua_toboolean"
  Lua_lua_tolstring(*lua_State.l, idx.l, len.l)      As "lua_tolstring"
  Lua_lua_objlen(*lua_State.l, idx.l)                As "lua_objlen"
  Lua_lua_tocfunction(*lua_State.l, idx.l)           As "lua_tocfunction"
  Lua_lua_touserdata(*lua_State.l, idx.l)            As "lua_touserdata"
  Lua_lua_tothread(*lua_State.l, idx.l)              As "lua_tothread"
  Lua_lua_topointer(*lua_State.l, idx.l)             As "lua_topointer"

  ; /*
  ; ** push functions (C -> stack)
  ; */
  Lua_lua_pushnil(*lua_State.l)                        As "lua_pushnil"
  Lua_lua_pushnumber(*lua_State.l, LUA_NUMBER.d)       As "lua_pushnumber"
  Lua_lua_pushinteger(*lua_State.l, LUA_INTEGER.l)     As "lua_pushinteger"
  Lua_lua_pushlstring(*lua_State.l, string.s, size.l)  As "lua_pushlstring"
  Lua_lua_pushstring(*lua_State.l, string.s)           As "lua_pushstring"
  ;lua_pushvfstring(*lua_State.L, const char *fmt, va_list argp)
  ;lua_pushfstring(*lua_State.L, const char *fmt, ...)
  Lua_lua_pushcclosure(*lua_State.l, *fn.l, n.l)       As "lua_pushcclosure"
  Lua_lua_pushboolean(*lua_State.l, b.l)               As "lua_pushboolean"
  Lua_lua_pushlightuserdata(*lua_State.l, *p.l)        As "lua_pushlightuserdata"
  Lua_lua_pushthread(*lua_State.l)                     As "lua_pushthread"

  ; /*
  ; ** get functions (Lua -> stack)
  ; */
  Lua_lua_gettable(*lua_State.l, idx.l)                As "lua_gettable"
  Lua_lua_getfield(*lua_State.l, idx.l, k.s)           As "lua_getfield"
  Lua_lua_rawget(*lua_State.l, idx.l)                  As "lua_rawget"
  Lua_lua_rawgeti(*lua_State.l, idx.l, n.l)            As "lua_rawgeti"
  Lua_lua_createtable(*lua_State.l, narr.l, nrec.l)    As "lua_createtable"
  Lua_lua_newuserdata(*lua_State.l, sz.l)              As "lua_newuserdata"
  Lua_lua_getmetatable(*lua_State.l, objindex.l)       As "lua_getmetatable"
  Lua_lua_getfenv(*lua_State.l, idx.l)                 As "lua_getfenv"

  ; /*
  ; ** set functions (stack -> Lua)
  ; */
  Lua_lua_settable(*lua_State.l, idx.l)                As "lua_settable"
  Lua_lua_setfield(*lua_State.l, idx.l, k.s)           As "lua_setfield"
  Lua_lua_rawset(*lua_State.l, idx.l)                  As "lua_rawset"
  Lua_lua_rawseti(*lua_State.l, idx.l, n.l)            As "lua_rawseti"
  Lua_lua_setmetatable(*lua_State.l, objindex.l)       As "lua_setmetatable"
  Lua_lua_setfenv(*lua_State.l, idx.l)                 As "lua_setfenv"

  ; /*
  ; ** `load' and `call' functions (load and run Lua code)
  ; */
  Lua_lua_call(*lua_State.l, nargs.l, nresults.l)                        As "lua_call"
  Lua_lua_pcall(*lua_State.l, nargs.l, nresults.l, *lua_errCFunction.l)  As "lua_pcall"
  Lua_lua_cpcall(*lua_State.l, *lua_CFunction.l, *ud.l)                  As "lua_cpcall"
  Lua_lua_load(*lua_State.l, lua_Reader.l, *dt.l, chunkname.s)           As "lua_load"

  Lua_lua_dump(*lua_State.l, lua_Writer.l, *vdata.l)   As "lua_dump"

  ; /*
  ; ** coroutine functions
  ; */
  Lua_lua_yield(*lua_State.l, nresults.l)    As "lua_yield"
  Lua_lua_resume(*lua_State.l, narg.l)       As "lua_resume"
  Lua_lua_status(*lua_State.l)               As "lua_status"

  ; /*
  ; ** garbage-collection function And options
  ; */
  Lua_lua_gc(*lua_State.l, what.l, idata.l)  As "lua_gc"

  ; /*
  ; ** miscellaneous functions
  ; */
  Lua_lua_error(*lua_State.l)                           As "lua_error"

  Lua_lua_next(*lua_State.l, idx.l)                     As "lua_next"

  Lua_lua_concat(*lua_State.l, n.l)                     As "lua_concat"

  Lua_lua_getallocf(*lua_State.l, *p_ud.l)              As "lua_getallocf"
  Lua_lua_setallocf(*lua_State.l, lua_Alloc.l, *ud.l)   As "lua_setallocf"

  ; lualib.h
  Lua_luaopen_base(*lua_State.l)    As "luaopen_base"
  Lua_luaopen_table(*lua_State.l)   As "luaopen_table"
  Lua_luaopen_io(*lua_State.l)      As "luaopen_io"
  Lua_luaopen_os(*lua_State.l)      As "luaopen_os"
  Lua_luaopen_string(*lua_State.l)  As "luaopen_string"
  Lua_luaopen_math(*lua_State.l)    As "luaopen_math"
  Lua_luaopen_debug(*lua_State.l)   As "luaopen_debug"
  Lua_luaopen_package(*lua_State.l) As "luaopen_package"

  ; /* open all previous libraries */
  Lua_luaL_openlibs(*lua_State.l)   As "luaL_openlibs"

  ;lauxlib_h
  Lua_luaI_openlib(*lua_State.l, libname.s, *luaL_Reg.l, nup.l)  As "luaI_openlib"
  Lua_luaL_register(*lua_State.l, libname.s, *luaL_Reg.l)        As "luaL_register"
  Lua_luaL_getmetafield(*lua_State.l, obj.l, e.s)                As "luaL_getmetafield"
  Lua_luaL_callmeta(*lua_State.l, obj.l, e.s)                    As "luaL_callmeta"
  Lua_luaL_typerror(*lua_State.l, narg.l, tname.s)               As "luaL_typerror"
  Lua_luaL_argerror(*lua_State.l, numarg.l, extramsg.s)          As "luaL_argerror"
  Lua_luaL_checklstring(*lua_State.l, numarg.l, size.l)          As "luaL_checklstring"
  Lua_luaL_optlstring(*lua_State.l, numarg.l, def.s, size.l)     As "luaL_optlstring"
  Lua_luaL_checknumber(*lua_State.l, numarg.l)                   As "luaL_checknumber"
  Lua_luaL_optnumber(*lua_State.l, narg, LUA_NUMBER.d)           As "luaL_optnumber"

  Lua_luaL_checkinteger(*lua_State.l, numarg.l)                  As "luaL_checkinteger"
  Lua_luaL_optinteger(*lua_State.l, narg.l, LUA_INTEGER.l)       As "luaL_optinteger"

  Lua_luaL_checkstack(*lua_State.l, sz.l, msg.s)                 As "luaL_checkstack"
  Lua_luaL_checktype(*lua_State.l, narg.l, t.l)                  As "luaL_checktype"
  Lua_luaL_checkany(*lua_State.l, narg.l)                        As "luaL_checkany"

  Lua_luaL_newmetatable(*lua_State.l, tname.s)                   As "luaL_newmetatable"
  Lua_luaL_checkudata(*lua_State.l, ud.l, tname.s)               As "luaL_checkudata"

  Lua_luaL_where(*lua_State.l, lvl.l)                            As "luaL_where"
  ;luaL_error(*lua_State.L, const char *fmt, ...)

  Lua_luaL_checkoption(*lua_State.l, narg.l, def.s, *string_array.l)  As "luaL_checkoption"

  Lua_luaL_ref(*lua_State.l, t.l)           As "luaL_ref"
  Lua_luaL_unref(*lua_State.l, t.l, ref.l)  As "luaL_unref"

  Lua_luaL_loadfile(*lua_State.l, filename.s)                As "luaL_loadfile"
  Lua_luaL_loadbuffer(*lua_State.l, buff.l, size.l, name.s)  As "luaL_loadbuffer"
  Lua_luaL_loadstring(*lua_State.l, string.s)                As "luaL_loadstring"

  Lua_luaL_newstate() As "luaL_newstate"


  Lua_luaL_gsub(*lua_State.l, s.s, p.s, r.s)       As "luaL_gsub"

  Lua_luaL_findtable(*lua_State.l, idx.l, fname.s) As "luaL_findtable"

  Lua_luaL_buffinit(*lua_State.l, *luaL_Buffer.l)  As "luaL_buffinit"
  Lua_luaL_prepbuffer(*luaL_Buffer.l)              As "luaL_prepbuffer"
  Lua_luaL_addlstring(*luaL_Buffer.l, s.s, size.l) As "luaL_addlstring"
  Lua_luaL_addstring(*luaL_Buffer.l, s.s)          As "luaL_addstring"
  Lua_luaL_addvalue(*luaL_Buffer.l)                As "luaL_addvalue"
  Lua_luaL_pushresult(*luaL_Buffer.l)              As "luaL_pushresult"
EndImport
CompilerEndIf

; ########################################## Macros #############################################

Macro Lua_lua_register(Lua_State, Name, Adress)
	Lua_lua_pushstring(Lua_State, Name)
  Lua_lua_pushcclosure(Lua_State, Adress, 0)
  Lua_lua_settable(Lua_State, #LUA_GLOBALSINDEX)
EndMacro

Macro Lua_luaL_dofile(Lua_State, Filename)
	Lua_luaL_loadfile(Lua_State, Filename)
	Lua_lua_pcall(Lua_State, 0, #LUA_MULTRET, 0)
EndMacro

Macro Lua_luaL_dostring(Lua_State, String)
	Lua_luaL_loadstring(Lua_State, String)
	Lua_lua_pcall(Lua_State, 0, #LUA_MULTRET, 0)
EndMacro

Macro Lua_lua_setglobal(Lua_State, String) 
	Lua_lua_setfield(Lua_State, #LUA_GLOBALSINDEX, String)
EndMacro

Macro Lua_lua_getglobal(Lua_State, String) 
	Lua_lua_getfield(Lua_State, #LUA_GLOBALSINDEX, String)
EndMacro

; #################################### Initkram ###############################################

Lua_Main\State = Lua_luaL_newstate()

If Lua_Main\State
  Lua_luaopen_base(Lua_Main\State)
  Lua_luaopen_table(Lua_Main\State)
  
	;Lua_luaopen_io(Lua_Main\State)
	Lua_lua_pushcclosure(Lua_Main\State, @Lua_luaopen_io(), 0)
  Lua_lua_call(Lua_Main\State, 0, 0)
  
	Lua_luaopen_os(Lua_Main\State)
	Lua_luaopen_string(Lua_Main\State)
	Lua_luaopen_math(Lua_Main\State)
	;Lua_luaopen_debug(Lua_Main\State)
	;Lua_luaopen_package(Lua_Main\State)
	Lua_lua_pushcclosure(Lua_Main\State, @Lua_luaopen_package(), 0)
  Lua_lua_call(Lua_Main\State, 0, 0)
  
EndIf
Lua_Register_All()

;-################################## Proceduren in Lua ##########################################

ProcedureC Lua_CMD_Client_Get_Map_ID(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result = Network_Client()\Player\Map_ID
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_X(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.f = 0;Network_Client()\Player\X
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Y(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.f = 0;Network_Client()\Player\Y
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Z(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.f = 0;Network_Client()\Player\Z
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Rotation(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.f = 0;Network_Client()\Player\Rotation
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Look(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.f = 0;Network_Client()\Player\Look
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_IP(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.s = ""
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.s = Network_Client()\IP
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Name(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.s = ""
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result.s = Network_Client()\Player\Login_Name
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Player_Number(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    If Player_List_Select(Network_Client()\Player\Login_Name)
      Result = 0;Player_List()\Number
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_Logged_In(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    Result = Network_Client()\Logged_In
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Examine(Lua_State)
  
  ResetList(Network_Client())
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Next(Lua_State)
  
  Result = NextElement(Network_Client())
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Get_ID(Lua_State)
  
  Result = 0
  
  If ListIndex(Network_Client()) <> -1
    Result = Network_Client()\ID
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Position_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X.f = Lua_lua_tonumber(Lua_State, 3)
  Y.f = Lua_lua_tonumber(Lua_State, 4)
  Z.f = Lua_lua_tonumber(Lua_State, 5)
  Rotation.f = Lua_lua_tonumber(Lua_State, 6)
  Look.f = Lua_lua_tonumber(Lua_State, 7)
  Send_Own = Lua_lua_tointeger(Lua_State, 8)
  Priority = Lua_lua_tointeger(Lua_State, 9)
  
  ;Client_Position_Set(Client_ID, Map_ID, X, Y, Z, Rotation, Look, Send_Own, Priority)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Kick(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Message.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  Hide = Lua_lua_tointeger(Lua_State, 3)
  
  Network_Client_Kick(Client_ID, Message, Hide)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Kill(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  ;Client_Kill(Client_ID)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Fake_Add(Lua_State)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  Hide_Mode = Lua_lua_tointeger(Lua_State, 2)
  
  ;Result = Client_Fake_Add(Name, Hide_Mode)
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Build_Mode = Lua_lua_tointeger(Lua_State, 2)
  
  Build_Mode_Set(Client_ID, Build_Mode)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_State_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  State = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\Player\Entity
      Network_Client()\Player\Entity\Build_State = State
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_State_Get(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID)
    If Network_Client()\Player\Entity
      Result = Network_Client()\Player\Entity\Build_State
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Point_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  Value_X = Lua_lua_tointeger(Lua_State, 3)
  Value_Y = Lua_lua_tointeger(Lua_State, 4)
  Value_Z = Lua_lua_tointeger(Lua_State, 5)
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Network_Client()\Player\Entity\Build_Variable[Position]\X = Value_X
      Network_Client()\Player\Entity\Build_Variable[Position]\Y = Value_Y
      Network_Client()\Player\Entity\Build_Variable[Position]\Z = Value_Z
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Point_Get(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  
  Result_X = -1
  Result_Y = -1
  Result_Z = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Result_X = Network_Client()\Player\Entity\Build_Variable[Position]\X
      Result_Y = Network_Client()\Player\Entity\Build_Variable[Position]\Y
      Result_Z = Network_Client()\Player\Entity\Build_Variable[Position]\Z
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result_X)
  Lua_lua_pushinteger(Lua_State, Result_Y)
  Lua_lua_pushinteger(Lua_State, Result_Z)
  
  ProcedureReturn 3 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Long_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  Value = Lua_lua_tointeger(Lua_State, 3)
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Network_Client()\Player\Entity\Build_Variable[Position]\Long = Value
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Long_Get(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  
  Result = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Result = Network_Client()\Player\Entity\Build_Variable[Position]\Long
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Float_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  Value.f = Lua_lua_tonumber(Lua_State, 3)
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Network_Client()\Player\Entity\Build_Variable[Position]\Float = Value
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_Float_Get(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  
  Result.f = -1
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Result = Network_Client()\Player\Entity\Build_Variable[Position]\Float
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_String_Set(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  Value.s = PeekS(Lua_lua_tolstring(Lua_State, 3, #Null))
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Network_Client()\Player\Entity\Build_Variable[Position]\String = Value
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Client_Buildmode_String_Get(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Position = Lua_lua_tointeger(Lua_State, 2)
  
  Result.s = ""
  
  If ListIndex(Network_Client()) <> -1
    *Network_Client_Old = Network_Client()
  Else
    *Network_Client_Old = 0
  EndIf
  
  If Network_Client_Select(Client_ID) And Position >= 0 And Position < #Client_Player_Buildmode_Variables
    If Network_Client()\Player\Entity
      Result = Network_Client()\Player\Entity\Build_Variable[Position]\String
    EndIf
  EndIf
  
  If *Network_Client_Old
    ChangeCurrentElement(Network_Client(), *Network_Client_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Player_Get_Name(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result.s = ""
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\Name
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_IP(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result.s = ""
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\IP
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_Rank(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\Rank
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_Online(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\Online
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_Ontime(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\Ontime_Counter
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_Mute_Time(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Result = Player_List()\Time_Muted
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Set_Rank(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Rank = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select_Number(Player_Number)
    Player_List()\Rank = Rank
    Player_List()\Save = 1
    Player_List_Main\Save_File = 1
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Attribute_Long_Set(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Attribute.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  Value = Lua_lua_tointeger(Lua_State, 3)
  
  Player_Attribute_Long_Set(Player_Number, Attribute, Value)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Attribute_Long_Get(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Attribute.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  Result = Player_Attribute_Long_Get(Player_Number, Attribute)
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Attribute_String_Set(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Attribute.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  String.s = PeekS(Lua_lua_tolstring(Lua_State, 3, #Null))
  
  Player_Attribute_String_Set(Player_Number, Attribute, String)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Attribute_String_Get(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Attribute.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  Result.s = Player_Attribute_String_Get(Player_Number, Attribute)
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Inventory_Set(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Material = Lua_lua_tointeger(Lua_State, 2)
  Number = Lua_lua_tointeger(Lua_State, 3)
  
  Player_Inventory_Set(Player_Number, Material, Number)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Inventory_Get(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Material = Lua_lua_tointeger(Lua_State, 2)
  
  Result = Player_Inventory_Get(Player_Number, Material)
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Examine(Lua_State)

  ResetList(Player_List())
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Next(Lua_State)

  Result = NextElement(Player_List())
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Get_Number(Lua_State)
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    Result = Player_List()\Number
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Player_Name_2_Number(Lua_State)
  Player_Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  
  Result = -1
  
  If ListIndex(Player_List()) <> -1
    *Player_List_Old = Player_List()
  Else
    *Player_List_Old = 0
  EndIf
  
  If Player_List_Select(Player_Name)
    Result = Player_List()\Number
  EndIf
  
  If *Player_List_Old
    ChangeCurrentElement(Player_List(), *Player_List_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Build_Client_Line(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X_0 = Lua_lua_tointeger(Lua_State, 3)
  Y_0 = Lua_lua_tointeger(Lua_State, 4)
  Z_0 = Lua_lua_tointeger(Lua_State, 5)
  X_1 = Lua_lua_tointeger(Lua_State, 6)
  Y_1 = Lua_lua_tointeger(Lua_State, 7)
  Z_1 = Lua_lua_tointeger(Lua_State, 8)
  Material = Lua_lua_tointeger(Lua_State, 9)
  Priority = Lua_lua_tointeger(Lua_State, 10)
  Undo = Lua_lua_tointeger(Lua_State, 11)
  Physic = Lua_lua_tointeger(Lua_State, 12)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Build_Player_Line(Client_ID, Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Material, Priority, Undo, Physic)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Build_Client_Box(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X_0 = Lua_lua_tointeger(Lua_State, 3)
  Y_0 = Lua_lua_tointeger(Lua_State, 4)
  Z_0 = Lua_lua_tointeger(Lua_State, 5)
  X_1 = Lua_lua_tointeger(Lua_State, 6)
  Y_1 = Lua_lua_tointeger(Lua_State, 7)
  Z_1 = Lua_lua_tointeger(Lua_State, 8)
  Material = Lua_lua_tointeger(Lua_State, 9)
  Replace_Material = Lua_lua_tointeger(Lua_State, 10)
  Hollow = Lua_lua_tointeger(Lua_State, 11)
  Priority = Lua_lua_tointeger(Lua_State, 12)
  Undo = Lua_lua_tointeger(Lua_State, 13)
  Physic = Lua_lua_tointeger(Lua_State, 14)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Build_Player_Box(Client_ID, Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Material, Replace_Material, Hollow, Priority, Undo, Physic)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Build_Client_Sphere(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X = Lua_lua_tointeger(Lua_State, 3)
  Y = Lua_lua_tointeger(Lua_State, 4)
  Z = Lua_lua_tointeger(Lua_State, 5)
  R.d = Lua_lua_tonumber(Lua_State, 6)
  Material = Lua_lua_tointeger(Lua_State, 7)
  Replace_Material = Lua_lua_tointeger(Lua_State, 8)
  Hollow = Lua_lua_tointeger(Lua_State, 9)
  Priority = Lua_lua_tointeger(Lua_State, 10)
  Undo = Lua_lua_tointeger(Lua_State, 11)
  Physic = Lua_lua_tointeger(Lua_State, 12)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Build_Player_Sphere(Client_ID, Map_ID, X, Y, Z, R.d, Material, Replace_Material, Hollow, Priority, Undo, Physic)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Build_Rank_Box(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X_0 = Lua_lua_tointeger(Lua_State, 2)
  Y_0 = Lua_lua_tointeger(Lua_State, 3)
  Z_0 = Lua_lua_tointeger(Lua_State, 4)
  X_1 = Lua_lua_tointeger(Lua_State, 5)
  Y_1 = Lua_lua_tointeger(Lua_State, 6)
  Z_1 = Lua_lua_tointeger(Lua_State, 7)
  Rank = Lua_lua_tointeger(Lua_State, 8)
  Max_Rank = Lua_lua_tointeger(Lua_State, 9)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Build_Rank_Box(Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Rank, Max_Rank)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Map_Block_Change(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X = Lua_lua_tointeger(Lua_State, 3)
  Y = Lua_lua_tointeger(Lua_State, 4)
  Z = Lua_lua_tointeger(Lua_State, 5)
  Mode = Lua_lua_tointeger(Lua_State, 6)
  Type = Lua_lua_tointeger(Lua_State, 7)
  Priority = Lua_lua_tointeger(Lua_State, 8)
  Undo = Lua_lua_tointeger(Lua_State, 9)
  Physic = Lua_lua_tointeger(Lua_State, 10)
  Placed_By_Client.a = Lua_lua_tointeger(Lua_State, 11)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  ;Map_Block_Change(Client_ID, Map_ID, X, Y, Z, Mode, Type, Priority, Undo, Physic, Placed_By_Client)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Change_Fast(Lua_State)
  Player_Number = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X = Lua_lua_tointeger(Lua_State, 3)
  Y = Lua_lua_tointeger(Lua_State, 4)
  Z = Lua_lua_tointeger(Lua_State, 5)
  Type = Lua_lua_tointeger(Lua_State, 6)
  Priority = Lua_lua_tointeger(Lua_State, 7)
  Undo = Lua_lua_tointeger(Lua_State, 8)
  Physic = Lua_lua_tointeger(Lua_State, 9)
  Send = Lua_lua_tointeger(Lua_State, 10)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  ;Map_Block_Change_Fast(Player_Number, Map_ID, X, Y, Z, Type, Priority, Undo, Physic, Send)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Move(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X_0 = Lua_lua_tointeger(Lua_State, 2)
  Y_0 = Lua_lua_tointeger(Lua_State, 3)
  Z_0 = Lua_lua_tointeger(Lua_State, 4)
  X_1 = Lua_lua_tointeger(Lua_State, 5)
  Y_1 = Lua_lua_tointeger(Lua_State, 6)
  Z_1 = Lua_lua_tointeger(Lua_State, 7)
  Priority = Lua_lua_tointeger(Lua_State, 8)
  Undo = Lua_lua_tointeger(Lua_State, 9)
  Physic = Lua_lua_tointeger(Lua_State, 10)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  ;Map_Block_Move(Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Priority, Undo, Physic)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Send(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Map_ID = Lua_lua_tointeger(Lua_State, 2)
  X = Lua_lua_tointeger(Lua_State, 3)
  Y = Lua_lua_tointeger(Lua_State, 4)
  Z = Lua_lua_tointeger(Lua_State, 5)
  Type.a = Lua_lua_tointeger(Lua_State, 6)
  
  Network_Out_Block_Set(Client_ID, X, Y, Z, Type)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Get_Type(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X = Lua_lua_tointeger(Lua_State, 2)
  Y = Lua_lua_tointeger(Lua_State, 3)
  Z = Lua_lua_tointeger(Lua_State, 4)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Type = -1
  If Map_Select_ID(Map_ID)
    Type = Map_Block_Get_Type(Map_Data(), X, Y, Z)
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Type)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Get_Rank(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X = Lua_lua_tointeger(Lua_State, 2)
  Y = Lua_lua_tointeger(Lua_State, 3)
  Z = Lua_lua_tointeger(Lua_State, 4)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Rank = 0
  If Map_Select_ID(Map_ID)
    Rank = Map_Block_Get_Rank(Map_Data(), X, Y, Z)
  EndIf
  
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Rank)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Block_Get_Player_Last(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X = Lua_lua_tointeger(Lua_State, 2)
  Y = Lua_lua_tointeger(Lua_State, 3)
  Z = Lua_lua_tointeger(Lua_State, 4)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Player_Last = -1
  If Map_Select_ID(Map_ID)
    Player_Last = Map_Block_Get_Player_Number(Map_Data(), X, Y, Z)
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Player_Last)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Name(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result.s = ""
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Name
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Directory(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result.s = ""
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Directory
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Rank_Build(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = 0
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Rank_Build
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Rank_Join(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = 0
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Rank_Join
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Rank_Show(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = 0
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Rank_Show
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Dimensions(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result_X = 0
  Result_Y = 0
  Result_Z = 0
  
  If Map_Select_ID(Map_ID)
    Result_X = Map_Data()\Size_X
    Result_Y = Map_Data()\Size_Y
    Result_Z = Map_Data()\Size_Z
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result_X)
  Lua_lua_pushinteger(Lua_State, Result_Y)
  Lua_lua_pushinteger(Lua_State, Result_Z)
  
  ProcedureReturn 3 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Spawn(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result_X.f = 0
  Result_Y.f = 0
  Result_Z.f = 0
  Result_Rot.f = 0
  Result_Look.f = 0
  
  If Map_Select_ID(Map_ID)
    Result_X = Map_Data()\Spawn_X
    Result_Y = Map_Data()\Spawn_Y
    Result_Z = Map_Data()\Spawn_Z
    Result_Rot = Map_Data()\Spawn_Rot
    Result_Look = Map_Data()\Spawn_Look
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushnumber(Lua_State, Result_X)
  Lua_lua_pushnumber(Lua_State, Result_Y)
  Lua_lua_pushnumber(Lua_State, Result_Z)
  Lua_lua_pushnumber(Lua_State, Result_Rot)
  Lua_lua_pushnumber(Lua_State, Result_Look)
  
  ProcedureReturn 5 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_Save_Intervall(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = -1
  
  If Map_Select_ID(Map_ID)
    Result = Map_Data()\Save_Intervall
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Name(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Name = Input
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Directory(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    If LCase(Right(Input, 1)) <> "/"
      Input + "/"
    EndIf
    Map_Data()\Directory = Input
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Rank_Build(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Rank_Build = Input
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Rank_Join(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Rank_Join = Input
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Rank_Show(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Rank_Show = Input
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Spawn(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Input_X.f = Lua_lua_tonumber(Lua_State, 2)
  Input_Y.f = Lua_lua_tonumber(Lua_State, 3)
  Input_Z.f = Lua_lua_tonumber(Lua_State, 4)
  Input_Rot.f = Lua_lua_tonumber(Lua_State, 5)
  Input_Look.f = Lua_lua_tonumber(Lua_State, 6)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Spawn_X = Input_X
    Map_Data()\Spawn_Y = Input_Y
    Map_Data()\Spawn_Z = Input_Z
    Map_Data()\Spawn_Rot = Input_Rot
    Map_Data()\Spawn_Look = Input_Look
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Set_Save_Intervall(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Intervall = Lua_lua_tointeger(Lua_State, 2)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  If Map_Select_ID(Map_ID)
    Map_Data()\Save_Intervall = Intervall
    
    Map_Main\Save_File = 1
  EndIf
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Add(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X = Lua_lua_tointeger(Lua_State, 2)
  Y = Lua_lua_tointeger(Lua_State, 3)
  Z = Lua_lua_tointeger(Lua_State, 4)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 5, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Map_Add(Map_ID, X, Y, Z, Name.s)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Delete(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = Map_Action_Add_Delete(0, Map_ID) ; Action Delete
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Resize(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X = Lua_lua_tointeger(Lua_State, 2)
  Y = Lua_lua_tointeger(Lua_State, 3)
  Z = Lua_lua_tointeger(Lua_State, 4)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = Map_Action_Add_Resize(0, Map_ID, X, Y, Z)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Resend(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Map_Resend(Map_ID)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Fill(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Function.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  Argument_String.s = PeekS(Lua_lua_tolstring(Lua_State, 3, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = Map_Action_Add_Fill(0, Map_ID, Function.s, Argument_String)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Save(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Directory.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = Map_Action_Add_Save(0, Map_ID, Directory.s)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Load(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  Directory.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Result = Map_Action_Add_Load(0, Map_ID, Directory.s)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Export(Lua_State)
  Map_ID = Lua_lua_tointeger(Lua_State, 1)
  X_0 = Lua_lua_tointeger(Lua_State, 2)
  Y_0 = Lua_lua_tointeger(Lua_State, 3)
  Z_0 = Lua_lua_tointeger(Lua_State, 4)
  X_1 = Lua_lua_tointeger(Lua_State, 5)
  Y_1 = Lua_lua_tointeger(Lua_State, 6)
  Z_1 = Lua_lua_tointeger(Lua_State, 7)
  Filename.s = PeekS(Lua_lua_tolstring(Lua_State, 8, #Null))
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Map_Export(Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Filename)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Client_Import(Lua_State)
  Client_ID = Lua_lua_tointeger(Lua_State, 1)
  Filename.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  Map_ID = Lua_lua_tointeger(Lua_State, 3)
  X = Lua_lua_tointeger(Lua_State, 4)
  Y = Lua_lua_tointeger(Lua_State, 5)
  Z = Lua_lua_tointeger(Lua_State, 6)
  SX = Lua_lua_tointeger(Lua_State, 7)
  SY = Lua_lua_tointeger(Lua_State, 8)
  SZ = Lua_lua_tointeger(Lua_State, 9)
  
  If ListIndex(Map_Data()) <> -1
    *Map_Data_Old = Map_Data()
  Else
    *Map_Data_Old = 0
  EndIf
  
  Map_Import_Player(Player_Number, Filename, Map_ID, X, Y, Z, SX, SY, SZ)
  
  If *Map_Data_Old
    ChangeCurrentElement(Map_Data(), *Map_Data_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Examine(Lua_State)
  
  ResetList(Map_Data())
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Next(Lua_State)

  Result = NextElement(Map_Data())
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Map_Get_ID(Lua_State)
  
  Result = -1
  
  If ListIndex(Map_Data()) <> -1
    Result = Map_Data()\ID
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Block_Get_Name(Lua_State)
  Block_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result.s = ""
  
  If Block_ID >= 0 And Block_ID <= 255
    Result = Block(Block_ID)\Name
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Block_Get_Rank_Place(Lua_State)
  Block_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -32769
  
  If Block_ID >= 0 And Block_ID <= 255
    Result = Block(Block_ID)\Rank_Place
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Block_Get_Rank_Delete(Lua_State)
  Block_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -32769
  
  If Block_ID >= 0 And Block_ID <= 255
    Result = Block(Block_ID)\Rank_Delete
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Block_Get_Client_Type(Lua_State)
  Block_ID = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -1
  
  If Block_ID >= 0 And Block_ID <= 255
    Result = Block(Block_ID)\On_Client
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Rank_Get_Name(Lua_State)
  Rank = Lua_lua_tointeger(Lua_State, 1)
  Exact = Lua_lua_tointeger(Lua_State, 2)
  
  Result.s = ""
  
  If ListIndex(Rank()) <> -1
    *Rank_Old = Rank()
  Else
    *Rank_Old = 0
  EndIf
  
  If Rank_Select(Rank, Exact)
    Result = Rank()\Name
  EndIf
  
  If *Rank_Old
    ChangeCurrentElement(Rank(), *Rank_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Get_Color(Lua_State)
  Rank = Lua_lua_tointeger(Lua_State, 1)
  Exact = Lua_lua_tointeger(Lua_State, 2)
  
  Result.s = ""
  
  If ListIndex(Rank()) <> -1
    *Rank_Old = Rank()
  Else
    *Rank_Old = 0
  EndIf
  
  If Rank_Select(Rank, Exact)
    Result = "&"+Chr(Rank()\Color_Code)
  EndIf
  
  If *Rank_Old
    ChangeCurrentElement(Rank(), *Rank_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Get_Root(Lua_State)
  Rank = Lua_lua_tointeger(Lua_State, 1)
  
  Result = -32769
  
  If ListIndex(Rank()) <> -1
    *Rank_Old = Rank()
  Else
    *Rank_Old = 0
  EndIf
  
  If Rank_Select(Rank)
    Result = Rank()\Rank
  EndIf
  
  If *Rank_Old
    ChangeCurrentElement(Rank(), *Rank_Old)
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Add(Lua_State)
  Rank = Lua_lua_tointeger(Lua_State, 1)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  Color.s = PeekS(Lua_lua_tolstring(Lua_State, 3, #Null))
    
  Rank_Add(Rank, Name, Val(ReplaceString(Color, "&", "")))
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Delete(Lua_State)
  Rank = Lua_lua_tointeger(Lua_State, 1)
  Exact = Lua_lua_tointeger(Lua_State, 2)
  
  Rank_Delete(Rank, Exact)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Examine(Lua_State)
  
  ResetList(Rank())
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Next(Lua_State)
  
  Result = NextElement(Rank())
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Rank_Get_Rank(Lua_State)
  
  Result = -32769
  
  If ListIndex(Rank()) <> -1
    Result = Rank()\Rank
  EndIf
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Teleporter_Get_Box(Lua_State)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  
  Result_Map_ID.s = ""
  Result_X_0 = -1
  Result_Y_0 = -1
  Result_Z_0 = -1
  Result_X_1 = -1
  Result_Y_1 = -1
  Result_Z_1 = -1
  
  If ListIndex(Teleporter()) <> -1
    *Teleporter_Old = Teleporter()
  Else
    *Teleporter_Old = 0
  EndIf
  
  If Teleporter_Select(Name)
    Result_Map_ID.s = Teleporter()\Map_ID
    Result_X_0 = Teleporter()\X_0
    Result_Y_0 = Teleporter()\Y_0
    Result_Z_0 = Teleporter()\Z_0
    Result_X_1 = Teleporter()\X_1
    Result_Y_1 = Teleporter()\Y_1
    Result_Z_1 = Teleporter()\Z_1
  EndIf
  
  If *Teleporter_Old
    ChangeCurrentElement(Teleporter(), *Teleporter_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result_Map_ID)
  Lua_lua_pushinteger(Lua_State, Result_X_0)
  Lua_lua_pushinteger(Lua_State, Result_Y_0)
  Lua_lua_pushinteger(Lua_State, Result_Z_0)
  Lua_lua_pushinteger(Lua_State, Result_X_1)
  Lua_lua_pushinteger(Lua_State, Result_Y_1)
  Lua_lua_pushinteger(Lua_State, Result_Z_1)
  
  ProcedureReturn 7 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Get_Destination(Lua_State)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  
  Result_Map_ID.s = ""
  Result_X.f = 0
  Result_Y.f = 0
  Result_Z.f = 0
  Result_Rot.f = 0
  Result_Look.f = 0
  
  If ListIndex(Teleporter()) <> -1
    *Teleporter_Old = Teleporter()
  Else
    *Teleporter_Old = 0
  EndIf
  
  If Teleporter_Select(Name)
    Result_Map_ID.s = Teleporter()\Dest_Map_ID
    Result_X = Teleporter()\Dest_X
    Result_Y = Teleporter()\Dest_Y
    Result_Z = Teleporter()\Dest_Z
    Result_Rot = Teleporter()\Dest_Rot
    Result_Look = Teleporter()\Dest_Look
  EndIf
  
  If *Teleporter_Old
    ChangeCurrentElement(Teleporter(), *Teleporter_Old)
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result_Map_ID)
  Lua_lua_pushnumber(Lua_State, Result_X)
  Lua_lua_pushnumber(Lua_State, Result_Y)
  Lua_lua_pushnumber(Lua_State, Result_Z)
  Lua_lua_pushnumber(Lua_State, Result_Rot)
  Lua_lua_pushnumber(Lua_State, Result_Look)
  
  ProcedureReturn 6 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Add(Lua_State)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  Map_ID.s = PeekS(Lua_lua_tolstring(Lua_State, 2, #Null))
  X_0 = Lua_lua_tointeger(Lua_State, 3)
  Y_0 = Lua_lua_tointeger(Lua_State, 4)
  Z_0 = Lua_lua_tointeger(Lua_State, 5)
  X_1 = Lua_lua_tointeger(Lua_State, 6)
  Y_1 = Lua_lua_tointeger(Lua_State, 7)
  Z_1 = Lua_lua_tointeger(Lua_State, 8)
  Dest_Map_ID.s = PeekS(Lua_lua_tolstring(Lua_State, 9, #Null))
  X.f = Lua_lua_tonumber(Lua_State, 10)
  Y.f = Lua_lua_tonumber(Lua_State, 11)
  Z.f = Lua_lua_tonumber(Lua_State, 12)
  Rot.f = Lua_lua_tonumber(Lua_State, 13)
  Look.f = Lua_lua_tonumber(Lua_State, 14)
  
  If ListIndex(Teleporter()) <> -1
    *Teleporter_Old = Teleporter()
  Else
    *Teleporter_Old = 0
  EndIf
  
  Teleporter_Add(Name.s, Map_ID, X_0, Y_0, Z_0, X_1, Y_1, Z_1, Dest_Map_ID, X.f, Y.f, Z.f, Rot.f, Look.f) 
  
  If *Teleporter_Old
    ChangeCurrentElement(Teleporter(), *Teleporter_Old)
  EndIf
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Delete(Lua_State)
  Name.s = PeekS(Lua_lua_tolstring(Lua_State, 1, #Null))
  
  Teleporter_Delete(Name.s)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Examine(Lua_State)
  
  ResetList(Teleporter())
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Next(Lua_State)
  
  Result = NextElement(Teleporter())
  
  Lua_lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Teleporter_Get_Name(Lua_State)
  
  Result.s = ""
  
  If ListIndex(Teleporter()) <> -1
    Result = Teleporter()\Name
  EndIf
  
  Lua_lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_System_Message_Network_Send_2_All(Lua_State)
  Map_ID = lua_tointeger(Lua_State, 1)
  lua_tostring(Message.s, Lua_State, 2) ;Message.s = PeekS(lua_tolstring(Lua_State, 2, #Null))
  
  If lua_isnumber(Lua_State, 3)
    MessageType = lua_tointeger(Lua_State, 3)
  EndIf
  
  If MessageType
    System_Message_Network_Send_2_All(Map_ID, Message.s, MessageType)
  Else
    System_Message_Network_Send_2_All(Map_ID, Message.s)
  EndIf
  
  
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_System_Message_Network_Send(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  lua_tostring(Message.s, Lua_State, 2) ;Message.s = PeekS(lua_tolstring(Lua_State, 2, #Null))
  
  If lua_isnumber(Lua_State, 3)
    MessageType = lua_tointeger(Lua_State, 3)
  EndIf
  
  If MessageType
    System_Message_Network_Send(Client_ID, Message.s, MessageType)
  Else
    System_Message_Network_Send(Client_ID, Message.s)
  EndIf

  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Network_Out_Block_Set(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  X = lua_tointeger(Lua_State, 2)
  Y = lua_tointeger(Lua_State, 3)
  Z = lua_tointeger(Lua_State, 4)
  Type = lua_tointeger(Lua_State, 5)
  
  Network_Out_Block_Set(Client_ID, X, Y, Z, Type)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Language_Get(Lua_State)
  lua_tostring(Language.s, Lua_State, 1) ;Language.s = PeekS(lua_tolstring(Lua_State, 1, #Null))
  lua_tostring(Input.s, Lua_State, 2) ;Input.s = PeekS(lua_tolstring(Lua_State, 2, #Null))
  lua_tostring(Field_0.s, Lua_State, 3) ;
  lua_tostring(Field_1.s, Lua_State, 4) ;
  lua_tostring(Field_2.s, Lua_State, 5) ;
  lua_tostring(Field_3.s, Lua_State, 6) ;
  ;*String_0 = lua_tolstring(Lua_State, 3, #Null)
  ;If *String_0 : Field_0.s = PeekS(*String_0) : EndIf
  ;*String_1 = lua_tolstring(Lua_State, 4, #Null)
  ;If *String_0 : Field_1.s = PeekS(*String_1) : EndIf
  ;*String_2 = lua_tolstring(Lua_State, 5, #Null)
  ;If *String_2 : Field_2.s = PeekS(*String_2) : EndIf
  ;*String_3 = lua_tolstring(Lua_State, 6, #Null)
  ;If *String_3 : Field_3.s = PeekS(*String_3) : EndIf
  
  Result.s = PeekS(Lang_Get(Language, Input, Field_0, Field_1, Field_2, Field_3))
  
  lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Files_File_Get(Lua_State)
  lua_tostring(File.s, Lua_State, 1) ;File.s = PeekS(lua_tolstring(Lua_State, 1, #Null))
  
  Result.s = PeekS(Files_File_Get(File.s))
  
  lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Files_Folder_Get(Lua_State)
  lua_tostring(Name.s, Lua_State, 1) ;Name.s = PeekS(lua_tolstring(Lua_State, 1, #Null))
  
  Result.s = PeekS(Files_Folder_Get(Name.s))
  
  lua_pushstring(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

;-############################################################

ProcedureC Lua_CMD_Event_Add(Lua_State)
  lua_tostring(ID.s, Lua_State, 1) ;ID.s = PeekS(lua_tolstring(Lua_State, 1, #Null))
  lua_tostring(Function.s, Lua_State, 2) ;Function.s = PeekS(lua_tolstring(Lua_State, 2, #Null))
  lua_tostring(Type.s, Lua_State, 3) ;Type.s = PeekS(lua_tolstring(Lua_State, 3, #Null))
  Set_Or_Check.a = lua_tointeger(Lua_State, 4)
  Time.l = lua_tointeger(Lua_State, 5)
  Map_ID.l = lua_tointeger(Lua_State, 6)
  
  Result = Lua_Event_Add(ID.s, Function.s, Type.s, Set_Or_Check.a, Time.l, Map_ID.l)
  
  lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1 ; Anzahl der R�ckgabeargumente
EndProcedure

ProcedureC Lua_CMD_Event_Delete(Lua_State)
  lua_tostring(ID.s, Lua_State, 1) ;ID.s = PeekS(lua_tolstring(Lua_State, 1, #Null))
  
  Lua_Event_Delete(ID.s)
  
  ProcedureReturn 0 ; Anzahl der R�ckgabeargumente
EndProcedure
;-###########################################################
; CPE Extensions

ProcedureC Lua_CMD_Server_Get_Extensions(Lua_State)
  lua_newtable(Lua_State)
  
    Elements = 11
  
    ;lua_pushinteger(Lua_State, 1)
    lua_pushstring(Lua_State, "CustomBlocks")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    ;lua_pushinteger(Lua_State, 2)
    lua_pushstring(Lua_State, "EmoteFix")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    ;lua_pushinteger(Lua_State, 3)
    lua_pushstring(Lua_State, "HeldBlock")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "ClickDistance")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "ChangeModel")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "ExtPlayerList")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "EnvWeatherType")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "EnvMapAppearance")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "MessageTypes")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "BlockPermissions")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    lua_pushstring(Lua_State, "EnvMapAppearance")
    lua_pushinteger(Lua_State, 1)
    lua_rawset(Lua_State, -3)
    
    ProcedureReturn 2
EndProcedure

ProcedureC Lua_CMD_Server_Get_Extension(Lua_State)
  lua_tostring(Extension.s, Lua_State, 1)
  
  result.i = 0
  Select LCase(Extension)
    Case "customblocks"
      result = 1
    Case "emotefix"
      result = 1
    Case "heldblock"
        result = 1
    Case "clickdistance"
        result = 1
    Case "changemodel"
        result = 1
    Case "extplayerlist"
        result = 1
    Case "envweathertype"
        result = 1
    Case "envmapappearance"
        result = 1
    Case "messagetypes"
        result = 1
    Case "blockpermissions"
        result = 1
    Case "envmapappearance"
        result = 1
  EndSelect
  
  lua_pushinteger(Lua_State, result)
  
  ProcedureReturn result
EndProcedure

ProcedureC Lua_CMD_Client_Get_Extensions(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  
  Elements = 0
  
  *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
  If *Pointer
    If *Pointer\CPE = #True
      lua_newtable(Lua_State)
      
      Elements = ListSize(*Pointer\Extensions())
      
      ResetList(*Pointer\Extensions())
      ResetList(*Pointer\ExtensionVersions())
      
      While NextElement(*Pointer\Extensions()) And NextElement(*Pointer\ExtensionVersions())
        lua_pushstring(Lua_State, *Pointer\Extensions())
        lua_pushinteger(Lua_State, *Pointer\ExtensionVersions())
        lua_rawset(Lua_State, -3)
      Wend
      
    EndIf
    
  EndIf
  
  lua_pushinteger(Lua_State, Elements)
  
  ProcedureReturn 2
EndProcedure

ProcedureC Lua_CMD_Client_Get_Extension(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  lua_tostring(Extension.s, Lua_State, 2)
  
  Result.i = 0
  
  *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
  If *Pointer
    If *Pointer\CPE = #True
      ResetList(*Pointer\Extensions())
      ResetList(*Pointer\ExtensionVersions())
      
      While NextElement(*Pointer\Extensions()) And NextElement(*Pointer\ExtensionVersions())
        If *Pointer\Extensions() = Extension
          result = *Pointer\ExtensionVersions()
        EndIf
      Wend
    EndIf
    
  EndIf
  
  lua_pushinteger(Lua_State, Result)
  
  ProcedureReturn 1
EndProcedure

;################################

ProcedureC Lua_CMD_CPE_Selection_Cuboid_Add(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  Selection_ID = lua_tointeger(Lua_State, 2)
  lua_tostring(Label.s, Lua_State, 3)
  Start_X = lua_tointeger(Lua_State, 4)
  Start_Y = lua_tointeger(Lua_State, 5)
  Start_Z = lua_tointeger(Lua_State, 6)
  End_X = lua_tointeger(Lua_State, 7)
  End_Y = lua_tointeger(Lua_State, 8)
  End_Z = lua_tointeger(Lua_State, 9)
  Red = lua_tointeger(Lua_State, 10)
  Green = lua_tointeger(Lua_State, 11)
  Blue = lua_tointeger(Lua_State, 12)
  Opacity = lua_tointeger(Lua_State, 13)
  
  CPE_Selection_Cuboid_Add(Client_ID, Selection_ID, Label, Start_X, Start_Y, Start_Z, End_X, End_Y, End_Z, Red, Green, Blue, Opacity)
  
  ProcedureReturn 1
EndProcedure

ProcedureC Lua_CMD_CPE_Selection_Cuboid_Delete(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  Selection_ID = lua_tointeger(Lua_State, 2)
  
  CPE_Selection_Cuboid_Delete(Client_ID, Selection_ID)
    
  ProcedureReturn 1
EndProcedure

ProcedureC Lua_CMD_CPE_Get_Held_Block(Lua_State)
  Client_ID = lua_tointeger(Lua_state, 1)
  
  *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
  If *Pointer
    If *Pointer\CPE = #True
      If *Pointer\Player\Entity
        lua_pushinteger(Lua_State, *Pointer\Player\Entity\Held_Block)
      EndIf
    EndIf
  EndIf
EndProcedure

ProcedureC Lua_CMD_CPE_Set_Held_Block(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  Block_ID = lua_tointeger(Lua_State, 2)
  Can_Change = lua_tointeger(Lua_State, 3)
  
  *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
  If *Pointer
    If *Pointer\CPE = #True
      If *Pointer\Player\Entity
        CPE_HoldThis(Client_ID, Block_ID, Can_Change)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn 0
EndProcedure

ProcedureC Lua_CMD_CPE_Change_Model(Lua_State)
  Client_ID = lua_tointeger(Lua_State, 1)
  lua_tostring(Model.s, Lua_State, 2)
  
  *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
  If *Pointer
    If *Pointer\CPE = #True
      If *Pointer\Player\Entity
        CPE_Model_Change(Client_ID, Model)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn 0
EndProcedure

ProcedureC Lua_CMD_CPE_Set_Weather(Lua_State)
    Client_ID = lua_tointeger(Lua_State, 1)
    WeatherType.b = lua_tointeger(Lua_State, 2)
    
    If WeatherType <> 0 And WeatherType <> 1 And WeatherType <> 2
        ProcedureReturn 1 ; Error.    
    EndIf
    
    *Pointer.Network_Client = Client_Get_Pointer(Client_ID)
    If *Pointer
        If *Pointer\CPE = #True
            If *Pointer\Player\Entity
                CPE_Set_Weather(Client_ID, WeatherType)
            EndIf
        EndIf
    EndIf
    
    ProcedureReturn 0
EndProcedure

ProcedureC Lua_CMD_CPE_Map_Set_Env_Colors(Lua_State)
    Map_ID.i = lua_tointeger(Lua_State, 1)
    Red.b = lua_tointeger(Lua_State, 2)
    Green.b = lua_tointeger(Lua_State, 3)
    Blue.b = lua_tointeger(Lua_State, 4)
    Type.b = lua_tointeger(Lua_State, 5)
    
    *ThisMap = Map_Get_Pointer(Map_ID)
    If *ThisMap
        Map_Env_Colors_Change(*ThisMap, Red, Green, Blue, Type)
    EndIf
    
    ProcedureReturn 0
EndProcedure
ProcedureC Lua_CMD_CPE_Client_Set_Block_Permissions(Lua_State)
    Client_ID = lua_tointeger(Lua_State, 1)
    Block_ID = lua_tointeger(Lua_State, 2)
    Can_Place = lua_tointeger(Lua_State, 3)
    Can_Delete = lua_tointeger(Lua_State, 4)
    
    CPE_Client_Set_Block_Permissions(Client_ID, Block_ID, Can_Place, Can_Delete)
    
    ProcedureReturn 0    
EndProcedure
ProcedureC Lua_CMD_Map_Env_Apperance_Set(Lua_State)
    Map_ID = lua_tointeger(Lua_State, 1)
    lua_tostring(CustomURL.s, Lua_State, 2)
    Side_Block = lua_tointeger(Lua_State, 3)
    Edge_Block = lua_tointeger(Lua_State, 4)
    Side_Level = lua_tointeger(Lua_State, 5)
    
    *ThisMap = Map_Get_Pointer(Map_ID)
    If *ThisMap
        Map_Env_Appearance_Set(*ThisMap, CustomURL, Side_Block, Edge_Block, Side_Level)
    EndIf
    
    ProcedureReturn 0
EndProcedure ; 
ProcedureC Lua_CMD_Client_Send_Map_Appearence(Lua_State)
    Client_ID = lua_tointeger(Lua_State, 1)
    lua_tostring(CustomURL.s, Lua_State, 2)
    Side_Block = lua_tointeger(Lua_State, 3)
    Edge_Block = lua_tointeger(Lua_State, 4)
    Side_Level = lua_tointeger(Lua_State, 5)
    
    
    CPE_Client_Send_Map_Appearence(Client_ID, CustomURL, Side_Block, Edge_Block, Side_Level)
    
    ProcedureReturn 0
EndProcedure
ProcedureC Lua_CMD_CPE_Client_Hackcontrol_Send(Lua_State)
    Client_ID = lua_tointeger(Lua_State, 1)
    Flying = lua_tointeger(Lua_State, 2)
    Noclip = lua_tointeger(Lua_State, 3)
    Speeding = lua_tointeger(Lua_State, 4)
    SpawnControl = lua_tointeger(Lua_State, 5)
    ThirdPerson = lua_tointeger(Lua_State, 6)
    WeatherControl = lua_tointeger(Lua_State, 7)
    Jumpheight.w = lua_tointeger(Lua_State, 8)
    
    CPE_Client_Hackcontrol_Send(Client_ID, Flying, Noclip, Speeding, SpawnControl, ThirdPerson, WeatherControl, Jumpheight)
    ProcedureReturn 0
EndProcedure
ProcedureC Lua_CMD_Hotkey_Add(Lua_State)
    lua_tostring(Label.s, Lua_State, 1)
    lua_tostring(Action.s, Lua_State, 2)
    Keycode.l = lua_tointeger(Lua_State, 3)
    Keymods = lua_tointeger(Lua_State, 4)
    
    Hotkey_Add(Label, Action, Keycode, Keymods)
    ProcedureReturn 0
EndProcedure
ProcedureC Lua_CMD_Hotkey_Remove(Lua_State)
    lua_tostring(Label.s, Lua_State, 1)
    
    Hotkey_Remove(Label)
    ProcedureReturn 0
EndProcedure
ProcedureC Lua_CMD_Map_Hackcontrol_Set(Lua_State)
    Map_ID = lua_tointeger(Lua_State, 1)
    Flying = lua_tointeger(Lua_State, 2)
    Noclip = lua_tointeger(Lua_State, 3)
    Speeding = lua_tointeger(Lua_State, 4)
    SpawnControl = lua_tointeger(Lua_State, 5)
    ThirdPerson = lua_tointeger(Lua_State, 6)
    WeatherControl = lua_tointeger(Lua_State, 7)
    Jumpheight.w = lua_tointeger(Lua_State, 8)
    
    *MapData = Map_Get_Pointer(Map_ID)
    If *MapData
        Map_HackControl_Set(*MapData, Flying, Noclip, Speeding, SpawnControl, ThirdPerson, WeatherControl, Jumpheight)
    EndIf
    
    ProcedureReturn 0
EndProcedure

;-########################################## Event-Proceduren ####################################

Procedure Lua_Event_Select(ID.s, Log.a=0)
  If ListIndex(Lua_Event()) <> -1 And Lua_Event()\ID = ID
    ProcedureReturn #True
  Else
    ForEach Lua_Event()
      If Lua_Event()\ID = ID
        ProcedureReturn #True
      EndIf
    Next
  EndIf
  
  If Log
    Temp.s = PeekS(Lang_Get("", "Can't find Lua_Event()\ID = '[Field_0]'", ID))
    Log_Add("Lua_Event", Temp.s, 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure Lua_Event_Add(ID.s, Function.s, Type.s, Set_Or_Check.a, Time.l, Map_ID.l)
  If ID <> ""
    
    Select LCase(Type)
      Case "timer"                    : Type_Enumeration = #Lua_Event_Timer
      Case "client_add"               : Type_Enumeration = #Lua_Event_Client_Add
      Case "client_delete"            : Type_Enumeration = #Lua_Event_Client_Delete
      Case "client_login"             : Type_Enumeration = #Lua_Event_Client_Login
      Case "client_logout"            : Type_Enumeration = #Lua_Event_Client_Logout
      Case "entity_add"               : Type_Enumeration = #Lua_Event_Entity_Add
      Case "entity_delete"            : Type_Enumeration = #Lua_Event_Entity_Delete
      Case "entity_position_set"      : Type_Enumeration = #Lua_Event_Entity_Position_Set
      Case "entity_die"               : Type_Enumeration = #Lua_Event_Entity_Die
      Case "map_add"                  : Type_Enumeration = #Lua_Event_Map_Add
      Case "map_action_delete"        : Type_Enumeration = #Lua_Event_Map_Action_Delete
      Case "map_action_resize"        : Type_Enumeration = #Lua_Event_Map_Action_Resize
      Case "map_action_fill"          : Type_Enumeration = #Lua_Event_Map_Action_Fill
      Case "map_action_save"          : Type_Enumeration = #Lua_Event_Map_Action_Save
      Case "map_action_load"          : Type_Enumeration = #Lua_Event_Map_Action_Load
      Case "map_block_change"         : Type_Enumeration = #Lua_Event_Map_Block_Change
      Case "map_block_change_client"  : Type_Enumeration = #Lua_Event_Map_Block_Change_Client
      Case "map_block_change_player"  : Type_Enumeration = #Lua_Event_Map_Block_Change_Player
      Case "chat_map"                 : Type_Enumeration = #Lua_Event_Chat_Map
      Case "chat_all"                 : Type_Enumeration = #Lua_Event_Chat_All
      Case "chat_private"             : Type_Enumeration = #Lua_Event_Chat_Private
      Case "entity_map_change"        : Type_Enumeration = #Lua_Event_Entity_Map_Change
      Default                         : ProcedureReturn #False
    EndSelect
    
    If Lua_Event_Select(ID.s)
      Lua_Event()\Function = Function
      Lua_Event()\Type = Type_Enumeration
      
      Lua_Event()\Time = Time
      Lua_Event()\Map_ID = Map_ID
      ProcedureReturn #True
    Else
      If Set_Or_Check = 0
        FirstElement(Lua_Event())
        If InsertElement(Lua_Event())
          Lua_Event()\ID = ID
          Lua_Event()\Function = Function
          Lua_Event()\Type = Type_Enumeration
          
          Lua_Event()\Time = Time
          Lua_Event()\Map_ID = Map_ID
          ProcedureReturn #True
        EndIf
      Else
        LastElement(Lua_Event())
        If AddElement(Lua_Event())
          Lua_Event()\ID = ID
          Lua_Event()\Function = Function
          Lua_Event()\Type = Type_Enumeration
          
          Lua_Event()\Time = Time
          Lua_Event()\Map_ID = Map_ID
          ProcedureReturn #True
        EndIf
      EndIf
      
    EndIf
    
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure Lua_Event_Delete(ID.s)
  If Lua_Event_Select(ID.s)
    DeleteElement(Lua_Event())
  EndIf
EndProcedure

; ################

Procedure Lua_Do_Function_Event_Timer(Function_Name.s, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 1, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Event_Client_Add(Result, Function_Name.s, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Client_Delete(Result, Function_Name.s, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Client_Login(Result, Function_Name.s, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Client_Logout(Result, Function_Name.s, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Entity_Add(Result, Function_Name.s, Entity_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Entity_Delete(Result, Function_Name.s, Entity_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Entity_Position_Set(Result, Function_Name.s, Entity_ID, Map_ID, X.f, Y.f, Z.f, Rotation.f, Look.f, Priority.a, Send_Own_Client.a)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushnumber(Lua_Main\State, X)
    lua_pushnumber(Lua_Main\State, Y)
    lua_pushnumber(Lua_Main\State, Z)
    lua_pushnumber(Lua_Main\State, Rotation)
    lua_pushnumber(Lua_Main\State, Look)
    lua_pushinteger(Lua_Main\State, Priority)
    lua_pushinteger(Lua_Main\State, Send_Own_Client)
    Lua_Do_Function(Function_Name, 10, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Entity_Die(Result, Function_Name.s, Entity_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Add(Result, Function_Name.s, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 2, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Action_Delete(Result, Function_Name.s, Action_ID, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Action_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Action_Resize(Result, Function_Name.s, Action_ID, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Action_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Action_Fill(Result, Function_Name.s, Action_ID, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Action_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Action_Save(Result, Function_Name.s, Action_ID, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Action_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Action_Load(Result, Function_Name.s, Action_ID, Map_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Action_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Block_Change(Result, Function_Name.s, Player_Number, Map_ID, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Player_Number)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Type)
    lua_pushinteger(Lua_Main\State, Undo)
    lua_pushinteger(Lua_Main\State, Physic)
    lua_pushinteger(Lua_Main\State, Send)
    lua_pushinteger(Lua_Main\State, Send_Priority)
    Lua_Do_Function(Function_Name, 11, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Block_Change_Client(Result, Function_Name.s, Client_ID, Map_ID, X, Y, Z, Mode.a, Type.a)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Client_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Mode)
    lua_pushinteger(Lua_Main\State, Type)
    Lua_Do_Function(Function_Name, 8, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Map_Block_Change_Player(Result, Function_Name.s, Player_Number, Map_ID, X, Y, Z, Type.a, Undo.a, Physic.a, Send.a, Send_Priority.a)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Player_Number)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Type)
    lua_pushinteger(Lua_Main\State, Undo)
    lua_pushinteger(Lua_Main\State, Physic)
    lua_pushinteger(Lua_Main\State, Send)
    lua_pushinteger(Lua_Main\State, Send_Priority)
    Lua_Do_Function(Function_Name, 11, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Chat_Map(Result, Function_Name.s, Entity_ID, Message.s)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    lua_pushstring(Lua_Main\State, Message)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Chat_All(Result, Function_Name.s, Entity_ID, Message.s)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    lua_pushstring(Lua_Main\State, Message)
    Lua_Do_Function(Function_Name, 3, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Event_Chat_Private(Result, Function_Name.s, Entity_ID, Player_Name.s, Message.s)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Result)
    lua_pushinteger(Lua_Main\State, Entity_ID)
    lua_pushstring(Lua_Main\State, Player_Name)
    lua_pushstring(Lua_Main\State, Message)
    Lua_Do_Function(Function_Name, 4, 1)
    Result = lua_tointeger(Lua_Main\State, -1)
    lua_pop(Lua_Main\State, 1)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure Lua_Do_Function_Command(Function_Name.s, Client_ID, Command.s, Text_0.s, Text_1.s, Arg_0.s, Arg_1.s, Arg_2.s, Arg_3.s, Arg_4.s)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Client_ID)
    lua_pushstring(Lua_Main\State, Command)
    lua_pushstring(Lua_Main\State, Text_0)
    lua_pushstring(Lua_Main\State, Text_1)
    lua_pushstring(Lua_Main\State, Arg_0)
    lua_pushstring(Lua_Main\State, Arg_1)
    lua_pushstring(Lua_Main\State, Arg_2)
    lua_pushstring(Lua_Main\State, Arg_3)
    lua_pushstring(Lua_Main\State, Arg_4)
    Lua_Do_Function(Function_Name, 9, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Event_Entity_Map_Change(Result, Function_Name.s, Entity_ID, New_Map_ID, Old_Map_ID)
    If Lua_Main\State
        lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
        lua_pushinteger(Lua_Main\State, Entity_ID)
        lua_pushinteger(Lua_Main\State, New_Map_ID)
        lua_pushinteger(Lua_Main\State, Old_Map_ID)
        Lua_Do_Function(Function_Name, 3, 1)
        Result = lua_tointeger(Lua_Main\State, -1)
        lua_pop(Lua_Main\State, 1)
    EndIf
    
    ProcedureReturn Result
EndProcedure


Procedure Lua_Do_Function_Map_Block_Physics(Function_Name.s, Map_ID, X, Y, Z)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    Lua_Do_Function(Function_Name, 4, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Map_Block_Create(Function_Name.s, Map_ID, X, Y, Z, Old_Block.a, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Old_Block)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 6, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Map_Block_Delete(Function_Name.s, Map_ID, X, Y, Z, Old_Block.a, Client_ID)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Old_Block)
    lua_pushinteger(Lua_Main\State, Client_ID)
    Lua_Do_Function(Function_Name, 6, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Map_Fill(Function_Name.s, Map_ID, Size_X, Size_Y, Size_Z, Argument_String.s)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, Size_X)
    lua_pushinteger(Lua_Main\State, Size_Y)
    lua_pushinteger(Lua_Main\State, Size_Z)
    lua_pushstring(Lua_Main\State, Argument_String)
    Lua_Do_Function(Function_Name, 5, 0)
  EndIf
EndProcedure

Procedure Lua_Do_Function_Build_Mode(Function_Name.s, Client_ID, Map_ID, X, Y, Z, Mode, Block_Type)
  If Lua_Main\State
    lua_getfield(Lua_Main\State, #LUA_GLOBALSINDEX, Function_Name)
    lua_pushinteger(Lua_Main\State, Client_ID)
    lua_pushinteger(Lua_Main\State, Map_ID)
    lua_pushinteger(Lua_Main\State, X)
    lua_pushinteger(Lua_Main\State, Y)
    lua_pushinteger(Lua_Main\State, Z)
    lua_pushinteger(Lua_Main\State, Mode)
    lua_pushinteger(Lua_Main\State, Block_Type)
    Lua_Do_Function(Function_Name, 7, 0)
  EndIf
EndProcedure

;-########################################## Proceduren ##########################################

Procedure Lua_Init()
  Lua_Main\State = luaL_newstate()
  
  If Lua_Main\State
    luaopen_base(Lua_Main\State)
    luaopen_table(Lua_Main\State)
    
  	;luaopen_io(Lua_Main\State)
  	lua_pushcclosure(Lua_Main\State, @luaopen_io(), 0)
    lua_call(Lua_Main\State, 0, 0)
    
  	luaopen_os(Lua_Main\State)
  	luaopen_string(Lua_Main\State)
  	luaopen_math(Lua_Main\State)
  	;luaopen_debug(Lua_Main\State)
  	;luaopen_package(Lua_Main\State)
  	lua_pushcclosure(Lua_Main\State, @luaopen_package(), 0)
    lua_call(Lua_Main\State, 0, 0)
    
    
    Lua_Register_All()
    
    Log_Add("Lua-Plugin", "Lua loaded", 0, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  Else
    Log_Add("Lua-Plugin", "Lua-State = 0", 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
  EndIf
  
EndProcedure

Procedure Lua_Register_All()
  If Lua_Main\State
    lua_register(Lua_Main\State, "Client_Get_Table", @Lua_CMD_Client_Get_Table())
    lua_register(Lua_Main\State, "Client_Get_Map_ID", @Lua_CMD_Client_Get_Map_ID())
    lua_register(Lua_Main\State, "Client_Get_IP", @Lua_CMD_Client_Get_IP())
    lua_register(Lua_Main\State, "Client_Get_Login_Name", @Lua_CMD_Client_Get_Login_Name())
    lua_register(Lua_Main\State, "Client_Get_Logged_In", @Lua_CMD_Client_Get_Logged_In())
    lua_register(Lua_Main\State, "Client_Get_Entity", @Lua_CMD_Client_Get_Entity())
    
    lua_register(Lua_Main\State, "Build_Mode_Set", @Lua_CMD_Build_Mode_Set())
    lua_register(Lua_Main\State, "Build_Mode_Get", @Lua_CMD_Build_Mode_Get())
    lua_register(Lua_Main\State, "Build_Mode_State_Set", @Lua_CMD_Build_Mode_State_Set())
    lua_register(Lua_Main\State, "Build_Mode_State_Get", @Lua_CMD_Build_Mode_State_Get())
    lua_register(Lua_Main\State, "Build_Mode_Coordinate_Set", @Lua_CMD_Build_Mode_Coordinate_Set())
    lua_register(Lua_Main\State, "Build_Mode_Coordinate_Get", @Lua_CMD_Build_Mode_Coordinate_Get())
    lua_register(Lua_Main\State, "Build_Mode_Long_Set", @Lua_CMD_Build_Mode_Long_Set())
    lua_register(Lua_Main\State, "Build_Mode_Long_Get", @Lua_CMD_Build_Mode_Long_Get())
    lua_register(Lua_Main\State, "Build_Mode_Float_Set", @Lua_CMD_Build_Mode_Float_Set())
    lua_register(Lua_Main\State, "Build_Mode_Float_Get", @Lua_CMD_Build_Mode_Float_Get())
    lua_register(Lua_Main\State, "Build_Mode_String_Set", @Lua_CMD_Build_Mode_String_Set())
    lua_register(Lua_Main\State, "Build_Mode_String_Get", @Lua_CMD_Build_Mode_String_Get())
    
    lua_register(Lua_Main\State, "Build_Line_Player", @Lua_CMD_Build_Line_Player())
    lua_register(Lua_Main\State, "Build_Box_Player", @Lua_CMD_Build_Box_Player())
    lua_register(Lua_Main\State, "Build_Sphere_Player", @Lua_CMD_Build_Sphere_Player())
    lua_register(Lua_Main\State, "Build_Rank_Box", @Lua_CMD_Build_Rank_Box())
    
    lua_register(Lua_Main\State, "Font_Draw_Text", @Lua_CMD_Font_Draw_Text())
    lua_register(Lua_Main\State, "Font_Draw_Text_Player", @Lua_CMD_Font_Draw_Text_Player())
    
    lua_register(Lua_Main\State, "Entity_Get_Table", @Lua_CMD_Entity_Get_Table())
    lua_register(Lua_Main\State, "Entity_Add", @Lua_CMD_Entity_Add())
    lua_register(Lua_Main\State, "Entity_Delete", @Lua_CMD_Entity_Delete())
    lua_register(Lua_Main\State, "Entity_Get_Player", @Lua_CMD_Entity_Get_Player())
    lua_register(Lua_Main\State, "Entity_Get_Map_ID", @Lua_CMD_Entity_Get_Map_ID())
    lua_register(Lua_Main\State, "Entity_Get_X", @Lua_CMD_Entity_Get_X())
    lua_register(Lua_Main\State, "Entity_Get_Y", @Lua_CMD_Entity_Get_Y())
    lua_register(Lua_Main\State, "Entity_Get_Z", @Lua_CMD_Entity_Get_Z())
    lua_register(Lua_Main\State, "Entity_Get_Rotation", @Lua_CMD_Entity_Get_Rotation())
    lua_register(Lua_Main\State, "Entity_Get_Look", @Lua_CMD_Entity_Get_Look())
    lua_register(Lua_Main\State, "Entity_Resend", @Lua_CMD_Entity_Resend())
    lua_register(Lua_Main\State, "Entity_Message_2_Clients", @Lua_CMD_Entity_Message_2_Clients())
    lua_register(Lua_Main\State, "Entity_Displayname_Get", @Lua_CMD_Entity_Displayname_Get())
    lua_register(Lua_Main\State, "Entity_Displayname_Set", @Lua_CMD_Entity_Displayname_Set())
    lua_register(Lua_Main\State, "Entity_Position_Set", @Lua_CMD_Entity_Position_Set())
    lua_register(Lua_Main\State, "Entity_Kill", @Lua_CMD_Entity_Kill())
    
    lua_register(Lua_Main\State, "Player_Get_Table", @Lua_CMD_Player_Get_Table())
    lua_register(Lua_Main\State, "Player_Attribute_Long_Set", @Lua_CMD_Player_Attribute_Long_Set())
    lua_register(Lua_Main\State, "Player_Attribute_Long_Get", @Lua_CMD_Player_Attribute_Long_Get())
    lua_register(Lua_Main\State, "Player_Attribute_String_Set", @Lua_CMD_Player_Attribute_String_Set())
    lua_register(Lua_Main\State, "Player_Attribute_String_Get", @Lua_CMD_Player_Attribute_String_Get())
    lua_register(Lua_Main\State, "Player_Inventory_Set", @Lua_CMD_Player_Inventory_Set())
    lua_register(Lua_Main\State, "Player_Inventory_Get", @Lua_CMD_Player_Inventory_Get())
    lua_register(Lua_Main\State, "Player_Get_Prefix", @Lua_CMD_player_Get_Prefix())
    lua_register(Lua_Main\State, "Player_Get_Name", @Lua_CMD_player_Get_Name())
    lua_register(Lua_Main\State, "Player_Get_Suffix", @Lua_CMD_player_Get_Suffix())
    lua_register(Lua_Main\State, "Player_Get_IP", @Lua_CMD_Player_Get_IP())
    lua_register(Lua_Main\State, "Player_Get_Rank", @Lua_CMD_Player_Get_Rank())
    lua_register(Lua_Main\State, "Player_Get_Online", @Lua_CMD_Player_Get_Online())
    lua_register(Lua_Main\State, "Player_Get_Ontime", @Lua_CMD_Player_Get_Ontime())
    lua_register(Lua_Main\State, "Player_Get_Mute_Time", @Lua_CMD_Player_Get_Mute_Time())
    lua_register(Lua_Main\State, "Player_Set_Rank", @Lua_CMD_Player_Set_Rank())
    lua_register(Lua_Main\State, "Player_Kick", @Lua_CMD_Player_Kick())
    lua_register(Lua_Main\State, "Player_Ban", @Lua_CMD_Player_Ban())
    lua_register(Lua_Main\State, "Player_Unban", @Lua_CMD_Player_Unban())
    lua_register(Lua_Main\State, "Player_Stop", @Lua_CMD_Player_Stop())
    lua_register(Lua_Main\State, "Player_Unstop", @Lua_CMD_Player_Unstop())
    lua_register(Lua_Main\State, "Player_Mute", @Lua_CMD_Player_Mute())
    lua_register(Lua_Main\State, "Player_Unmute", @Lua_CMD_Player_Unmute())

    
    lua_register(Lua_Main\State, "Map_Get_Table", @Lua_CMD_Map_Get_Table())
    lua_register(Lua_Main\State, "Map_Block_Change", @Lua_CMD_Map_Block_Change())
    lua_register(Lua_Main\State, "Map_Block_Change_Client", @Lua_CMD_Map_Block_Change_Client())
    lua_register(Lua_Main\State, "Map_Block_Change_Player", @Lua_CMD_Map_Block_Change_Player())
    lua_register(Lua_Main\State, "Map_Block_Move", @Lua_CMD_Map_Block_Move())
    ;lua_register(Lua_Main\State, "Map_Block_Send", @Lua_CMD_Map_Block_Send())
    lua_register(Lua_Main\State, "Map_Block_Get_Type", @Lua_CMD_Map_Block_Get_Type())
    lua_register(Lua_Main\State, "Map_Block_Get_Rank", @Lua_CMD_Map_Block_Get_Rank())
    lua_register(Lua_Main\State, "Map_Block_Get_Player_Last", @Lua_CMD_Map_Block_Get_Player_Last())
    lua_register(Lua_Main\State, "Map_Get_Name", @Lua_CMD_Map_Get_Name())
    lua_register(Lua_Main\State, "Map_Get_Unique_ID", @Lua_CMD_Map_Get_Unique_ID())
    lua_register(Lua_Main\State, "Map_Get_Directory", @Lua_CMD_Map_Get_Directory())
    lua_register(Lua_Main\State, "Map_Get_Rank_Build", @Lua_CMD_Map_Get_Rank_Build())
    lua_register(Lua_Main\State, "Map_Get_Rank_Join", @Lua_CMD_Map_Get_Rank_Join())
    lua_register(Lua_Main\State, "Map_Get_Rank_Show", @Lua_CMD_Map_Get_Rank_Show())
    lua_register(Lua_Main\State, "Map_Get_Dimensions", @Lua_CMD_Map_Get_Dimensions())
    lua_register(Lua_Main\State, "Map_Get_Spawn", @Lua_CMD_Map_Get_Spawn())
    lua_register(Lua_Main\State, "Map_Get_Save_Intervall", @Lua_CMD_Map_Get_Save_Intervall())
    lua_register(Lua_Main\State, "Map_Set_Name", @Lua_CMD_Map_Set_Name())
    lua_register(Lua_Main\State, "Map_Set_Directory", @Lua_CMD_Map_Set_Directory())
    lua_register(Lua_Main\State, "Map_Set_Rank_Build", @Lua_CMD_Map_Set_Rank_Build())
    lua_register(Lua_Main\State, "Map_Set_Rank_Join", @Lua_CMD_Map_Set_Rank_Join())
    lua_register(Lua_Main\State, "Map_Set_Rank_Show", @Lua_CMD_Map_Set_Rank_Show())
    lua_register(Lua_Main\State, "Map_Set_Spawn", @Lua_CMD_Map_Set_Spawn())
    lua_register(Lua_Main\State, "Map_Set_Save_Intervall", @Lua_CMD_Map_Set_Save_Intervall())
    lua_register(Lua_Main\State, "Map_Add", @Lua_CMD_Map_Add())
    lua_register(Lua_Main\State, "Map_Action_Add_Resize", @Lua_CMD_Map_Action_Add_Resize())
    lua_register(Lua_Main\State, "Map_Action_Add_Fill", @Lua_CMD_Map_Action_Add_Fill())
    lua_register(Lua_Main\State, "Map_Action_Add_Save", @Lua_CMD_Map_Action_Add_Save())
    lua_register(Lua_Main\State, "Map_Action_Add_Load", @Lua_CMD_Map_Action_Add_Load())
    lua_register(Lua_Main\State, "Map_Action_Add_Delete", @Lua_CMD_Map_Action_Add_Delete())
    lua_register(Lua_Main\State, "Map_Resend", @Lua_CMD_Map_Resend())
    lua_register(Lua_Main\State, "Map_Export", @Lua_CMD_Map_Export())
    
    lua_register(Lua_Main\State, "Map_Export_Get_Size", @Lua_CMD_Map_Export_Get_Size())
    
    lua_register(Lua_Main\State, "Map_Import_Player", @Lua_CMD_Map_Import_Player())
    
    lua_register(Lua_Main\State, "Block_Get_Table", @Lua_CMD_Block_Get_Table())
    lua_register(Lua_Main\State, "Block_Get_Name", @Lua_CMD_Block_Get_Name())
    lua_register(Lua_Main\State, "Block_Get_Rank_Place", @Lua_CMD_Block_Get_Rank_Place())
    lua_register(Lua_Main\State, "Block_Get_Rank_Delete", @Lua_CMD_Block_Get_Rank_Delete())
    lua_register(Lua_Main\State, "Block_Get_Client_Type", @Lua_CMD_Block_Get_Client_Type())
    
    lua_register(Lua_Main\State, "Rank_Get_Table", @Lua_CMD_Rank_Get_Table())
    lua_register(Lua_Main\State, "Rank_Add", @Lua_CMD_Rank_Add())
    lua_register(Lua_Main\State, "Rank_Delete", @Lua_CMD_Rank_Delete())
    lua_register(Lua_Main\State, "Rank_Get_Name", @Lua_CMD_Rank_Get_Name())
    lua_register(Lua_Main\State, "Rank_Get_Prefix", @Lua_CMD_Rank_Get_Prefix())
    lua_register(Lua_Main\State, "Rank_Get_Suffix", @Lua_CMD_Rank_Get_Suffix())
    lua_register(Lua_Main\State, "Rank_Get_Root", @Lua_CMD_Rank_Get_Root())
    
    
    lua_register(Lua_Main\State, "Teleporter_Get_Table", @Lua_CMD_Teleporter_Get_Table())
    lua_register(Lua_Main\State, "Teleporter_Add", @Lua_CMD_Teleporter_Add())
    lua_register(Lua_Main\State, "Teleporter_Delete", @Lua_CMD_Teleporter_Delete())
    lua_register(Lua_Main\State, "Teleporter_Get_Box", @Lua_CMD_Teleporter_Get_Box())
    lua_register(Lua_Main\State, "Teleporter_Get_Destination", @Lua_CMD_Teleporter_Get_Destination())
    
    lua_register(Lua_Main\State, "System_Message_Network_Send_2_All", @Lua_CMD_System_Message_Network_Send_2_All())
    lua_register(Lua_Main\State, "System_Message_Network_Send", @Lua_CMD_System_Message_Network_Send())
    
    lua_register(Lua_Main\State, "Network_Out_Block_Set", @Lua_CMD_Network_Out_Block_Set())
    
    lua_register(Lua_Main\State, "Lang_Get", @Lua_CMD_Language_Get())
    
    lua_register(Lua_Main\State, "Files_File_Get", @Lua_CMD_Files_File_Get())
    lua_register(Lua_Main\State, "Files_Folder_Get", @Lua_CMD_Files_Folder_Get())
    
    lua_register(Lua_Main\State, "Event_Add", @Lua_CMD_Event_Add())
    lua_register(Lua_Main\State, "Event_Delete", @Lua_CMD_Event_Delete())
    
    lua_register(Lua_Main\State, "Server_Get_Extensions", @Lua_CMD_Server_Get_Extensions())
    lua_register(Lua_Main\State, "Server_Get_Extension", @Lua_CMD_Server_Get_Extension())
    lua_register(Lua_Main\State, "Client_Get_Extensions", @Lua_CMD_Client_Get_Extensions())
    lua_register(Lua_Main\State, "Client_Get_Extension", @Lua_CMD_Client_Get_Extension())
    
    lua_register(Lua_Main\State, "CPE_Selection_Cuboid_Add",@Lua_CMD_CPE_Selection_Cuboid_Add())
    lua_register(Lua_Main\State, "CPE_Selection_Cuboid_Delete", @Lua_CMD_CPE_Selection_Cuboid_Delete())
    
    lua_register(Lua_Main\State, "CPE_Get_Held_Block", @Lua_CMD_CPE_Get_Held_Block())
    lua_register(Lua_Main\State, "CPE_Set_Held_Block", @Lua_CMD_CPE_Set_Held_Block())
    lua_register(Lua_Main\State, "CPE_Model_Change", @Lua_CMD_CPE_Change_Model())
    lua_register(Lua_Main\State, "CPE_Set_Weather", @Lua_CMD_CPE_Set_Weather())
    lua_register(Lua_Main\State, "CPE_Map_Set_Env_Colors", @Lua_CMD_CPE_Map_Set_Env_Colors())
    lua_register(Lua_Main\State, "CPE_Client_Set_Block_Permissions", @Lua_CMD_CPE_Client_Set_Block_Permissions())
    lua_register(Lua_Main\State, "Map_Env_Apperance_Set", @Lua_CMD_Map_Env_Apperance_Set())
    lua_register(Lua_Main\State, "Client_Send_Map_Appearence", @Lua_CMD_Client_Send_Map_Appearence())
    lua_register(Lua_Main\State, "CPE_Client_Hackcontrol_Send", @Lua_CMD_CPE_Client_Hackcontrol_Send())
    lua_register(Lua_Main\State, "Hotkey_Add", @Lua_CMD_Hotkey_Add())
    lua_register(Lua_Main\State, "Hotkey_Remove", @Lua_CMD_Hotkey_Remove())
    lua_register(Lua_Main\State, "Map_Hackcontrol_Set", @Lua_CMD_Map_Hackcontrol_Set())
  EndIf
EndProcedure

Procedure Lua_SetVariable_String(Name.s, String.s)
  If Lua_Main\State
  	lua_pushstring(Lua_Main\State, String)
  	lua_setglobal(Lua_Main\State, Name)
	EndIf
EndProcedure 

Procedure Lua_SetVariable_Integer(Name.s, Value)
  If Lua_Main\State
  	lua_pushinteger(Lua_Main\State, Value)
  	lua_setglobal(Lua_Main\State, Name)
	EndIf
EndProcedure

Procedure.s Lua_GetVariable_String(Name.s)
  If Lua_Main\State
  	lua_getglobal(Lua_Main\State, Name)
  	If lua_tolstring(Lua_Main\State, -1, #Null)
  	  String.s = PeekS(lua_tolstring(Lua_Main\State, -1, #Null))
  	  lua_pop(Lua_Main\State, 1)
  	  ProcedureReturn String
  	EndIf
	EndIf
EndProcedure

Procedure Lua_GetVariable_Integer(Name.s)
  If Lua_Main\State
  	lua_getglobal(Lua_Main\State, Name)
  	Value = lua_tointeger(Lua_Main\State, -1)
  	lua_pop(Lua_Main\State, 1)
  	ProcedureReturn Value
	EndIf
EndProcedure

Procedure Lua_Do_Function(Function.s, Arguments, Results)
  If Lua_Main\State
    
    Result = lua_pcall(Lua_Main\State, Arguments, Results, 0)
    
    Select Result
      Case #LUA_ERRRUN
        Error.s = PeekS(lua_tolstring(Lua_Main\State, -1, #Null))
        Temp.s = PeekS(Lang_Get("", "Runtimeerror in [Field_0]", Function, Error))
        Log_Add("Lua-Plugin", Temp.s, 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Case #LUA_ERRMEM
        Temp.s = PeekS(Lang_Get("", "Memoryallocationerror in [Field_0]", Function))
        Log_Add("Lua-Plugin", Temp.s, 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      Case #LUA_ERRERR
        Temp.s = PeekS(Lang_Get("", "Error in [Field_0]", Function))
        Log_Add("Lua-Plugin", Temp.s, 5, #PB_Compiler_File, #PB_Compiler_Line, #PB_Compiler_Procedure)
      
    EndSelect
    
  EndIf
EndProcedure

Procedure Lua_Do_String(String.s)
  If Lua_Main\State
    
    luaL_dostring(Lua_Main\State, String)
    
  EndIf
EndProcedure

Procedure Lua_Do_File(Filename.s)
  If Lua_Main\State
    
    luaL_dofile(Lua_Main\State, Filename)
    
  EndIf
EndProcedure

Procedure Lua_Check_New_Files(Directory.s)
  
  If Right(Directory, 1) = "/" Or Right(Directory, 1) = "\"
    Directory = Left(Directory, Len(Directory)-1)
  EndIf
  
  Directory_ID = ExamineDirectory(#PB_Any, Directory, "*.*")
  If Directory_ID
    While NextDirectoryEntry(Directory_ID)
      Entry_Name.s = DirectoryEntryName(Directory_ID)
      Filename.s = Directory + "/" + Entry_Name
      
      If Entry_Name <> "." And Entry_Name <> ".."
        
        If DirectoryEntryType(Directory_ID) = #PB_DirectoryEntry_File
          If LCase(Right(Entry_Name, 4)) = ".lua"
            Found = 0
            ForEach Lua_File()
              If Lua_File()\Filename = Filename
                Found = 1
                Break
              EndIf
            Next
            If Found = 0
              AddElement(Lua_File())
              Lua_File()\Filename = Filename
            EndIf
          EndIf
        Else
          Lua_Check_New_Files(Filename)
        EndIf
        
      EndIf
      
    Wend
    FinishDirectory(Directory_ID)
  EndIf
  
EndProcedure
; IDE Options = PureBasic 5.30 (Linux - x64)
; CursorPosition = 3860
; FirstLine = 3817
; Folding = ------------------------------
; EnableXP
; DisableDebugger
; EnableCompileCount = 0
; EnableBuildCount = 0