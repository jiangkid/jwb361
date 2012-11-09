# Microsoft Developer Studio Project File - Name="sc1200" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=sc1200 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "sc1200.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "sc1200.mak" CFG="sc1200 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "sc1200 - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "sc1200 - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "sc1200 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x804 /d "NDEBUG"
# ADD RSC /l 0x804 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "sc1200 - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x804 /d "_DEBUG"
# ADD RSC /l 0x804 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "sc1200 - Win32 Release"
# Name "sc1200 - Win32 Debug"
# Begin Source File

SOURCE=.\classify.c
# End Source File
# Begin Source File

SOURCE=.\coeff.c
# End Source File
# Begin Source File

SOURCE=.\coeff.h
# End Source File
# Begin Source File

SOURCE=.\constant.h
# End Source File
# Begin Source File

SOURCE=.\cprv.h
# End Source File
# Begin Source File

SOURCE=.\dsp_sub.c
# End Source File
# Begin Source File

SOURCE=.\dsp_sub.h
# End Source File
# Begin Source File

SOURCE=.\fec_code.c
# End Source File
# Begin Source File

SOURCE=.\fec_code.h
# End Source File
# Begin Source File

SOURCE=.\fft_lib.c
# End Source File
# Begin Source File

SOURCE=.\fft_lib.h
# End Source File
# Begin Source File

SOURCE=.\fs_lib.c
# End Source File
# Begin Source File

SOURCE=.\fs_lib.h
# End Source File
# Begin Source File

SOURCE=.\fsvq_cb.c
# End Source File
# Begin Source File

SOURCE=.\fsvq_cb.h
# End Source File
# Begin Source File

SOURCE=.\global.c
# End Source File
# Begin Source File

SOURCE=.\global.h
# End Source File
# Begin Source File

SOURCE=.\harm.c
# End Source File
# Begin Source File

SOURCE=.\harm.h
# End Source File
# Begin Source File

SOURCE=.\lpc_lib.c
# End Source File
# Begin Source File

SOURCE=.\lpc_lib.h
# End Source File
# Begin Source File

SOURCE=.\macro.h
# End Source File
# Begin Source File

SOURCE=.\mat_lib.c
# End Source File
# Begin Source File

SOURCE=.\mat_lib.h
# End Source File
# Begin Source File

SOURCE=.\math_lib.c
# End Source File
# Begin Source File

SOURCE=.\math_lib.h
# End Source File
# Begin Source File

SOURCE=.\mathdp31.c
# End Source File
# Begin Source File

SOURCE=.\mathdp31.h
# End Source File
# Begin Source File

SOURCE=.\mathhalf.c
# End Source File
# Begin Source File

SOURCE=.\mathhalf.h
# End Source File
# Begin Source File

SOURCE=.\melp_ana.c
# End Source File
# Begin Source File

SOURCE=.\melp_chn.c
# End Source File
# Begin Source File

SOURCE=.\melp_sub.c
# End Source File
# Begin Source File

SOURCE=.\melp_sub.h
# End Source File
# Begin Source File

SOURCE=.\melp_syn.c
# End Source File
# Begin Source File

SOURCE=.\msvq_cb.c
# End Source File
# Begin Source File

SOURCE=.\msvq_cb.h
# End Source File
# Begin Source File

SOURCE=.\npp.c
# End Source File
# Begin Source File

SOURCE=.\npp.h
# End Source File
# Begin Source File

SOURCE=.\pit_lib.c
# End Source File
# Begin Source File

SOURCE=.\pit_lib.h
# End Source File
# Begin Source File

SOURCE=.\pitch.c
# End Source File
# Begin Source File

SOURCE=.\pitch.h
# End Source File
# Begin Source File

SOURCE=.\postfilt.c
# End Source File
# Begin Source File

SOURCE=.\postfilt.h
# End Source File
# Begin Source File

SOURCE=.\qnt12.c
# End Source File
# Begin Source File

SOURCE=.\qnt12.h
# End Source File
# Begin Source File

SOURCE=.\qnt12_cb.c
# End Source File
# Begin Source File

SOURCE=.\qnt12_cb.h
# End Source File
# Begin Source File

SOURCE=.\sc1200.c
# End Source File
# Begin Source File

SOURCE=.\sc1200.h
# End Source File
# Begin Source File

SOURCE=.\transcode.c
# End Source File
# Begin Source File

SOURCE=.\transcode.h
# End Source File
# Begin Source File

SOURCE=.\vq_lib.c
# End Source File
# Begin Source File

SOURCE=.\vq_lib.h
# End Source File
# Begin Source File

SOURCE=.\wav_header.c
# End Source File
# Begin Source File

SOURCE=.\wave_header.h
# End Source File
# End Target
# End Project
