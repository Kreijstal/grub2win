@echo off
setlocal enableextensions enabledelayedexpansion

set uppercase=ABCDEFGHIJKLMNOPQRSTUVWXYZ
set lowercase=abcdefghijklmnopqrstuvwxyz

if "%diagauto%" equ "yes" call :autorun
if "%diagauto%" equ ""    call :normalrun
goto :eof

:autorun
	echo.
	echo               Now running Grub2Win diagnostics
	echo. 
	echo.
	call :sleeper 1
	call :runit
	call :sleeper 1
	exit
	goto :eof

:normalrun
	call :getadmin
	call :checkbase
	if "%baseok%"  equ "yes" call :runit
	pause
	goto :eof

:checkbase
	cls
	set baseok=
	set basedir=C:\grub2
	echo.
	echo.
	echo               Starting Grub2Win diagnostic creation
	echo.
	echo.
	echo.
	set /p basedir= Please enter the Grub2Win base directory or press enter for default (%basedir%)   
	if exist %basedir% (set baseok=yes
			    goto :EOF)
	cls
	echo.
	echo.
	echo.
	echo               The base directory you entered (%basedir%) was not found
	echo                               ** Run Cancelled **
	echo.
	echo.
	echo.
	goto :eof

:stampit
	echo %~1  >  %~2
	date /t   >> %~2
	time /t   >> %~2
	goto :eof

:sleeper
	set /a seconds = %1 + 1
	ping -n %seconds% 127.0.0.1 >nul 2>&1 
	goto :eof

:runit
	cls
	echo.
	echo               The Grub2Win base directory is %basedir%
	set diagdir=%basedir%\diagnose
	set partdir=%diagdir%\partitions
	set tempdir=%ProgramData%\grub2win
	if  exist   %diagdir% rd /s /q %diagdir%
	md          %diagdir%
	md          %partdir%

	rem If XP then run the XP Runs otherwise run the BCD routines and SystemInfo
	ver | find "5.1" 2>nul
	if "%errorlevel%" equ "0" (call :xpruns) else (call :nonxpruns)

	echo.
	echo               Copying files
	echo.
	echo.
	if exist     %basedir%\windata\storage\tempfiles      rd /s /q        %basedir%\windata\storage\tempfiles 
	if exist     %basedir%\windata                        xcopy /y /q /e  %basedir%\windata        %diagdir%\
	if exist     %basedir%\miscfiles                      xcopy /y /q /e  %basedir%\miscfiles      %diagdir%\miscfiles\
	if exist     %basedir%\miscfiles                      rd /s /q        %basedir%\miscfiles    
	if exist     %diagdir%\backups\efi.partitions         rd /s /q        %diagdir%\backups\efi.partitions
	if exist     %diagdir%\backups\bcds                   rd /s /q        %diagdir%\backups\bcds
	if exist     %basedir%\grub.cfg                       copy  /y        %basedir%\grub.cfg       %diagdir%\
        if exist     %basedir%\update.log                     copy  /y        %basedir%\update.log     %diagdir%\
	if exist     %basedir%\userfiles                      xcopy /y /q /e  %basedir%\userfiles      %diagdir%\userfiles\
	if exist     %diagdir%\userfiles\user.backgrounds     rd /s /q        %diagdir%\userfiles\user.backgrounds
	if exist     %basedir%\windata\storage\diskreport.txt copy  /y        %basedir%\windata\storage\diskreport.txt   %partdir%\
	if exist     %ProgramData%\grub2win\commands          xcopy /y /q /e  %ProgramData%\grub2win\commands %diagdir%\commands\
	if exist     %basedir%\update.log                     copy  /y        %basedir%\update.log     %diagdir%\update.log
	if exist     %tempdir%\temp.log                       copy  /y        %tempdir%\temp.log       %diagdir%\update.diagtemp.log
	if not exist %diagdir%\update.log (
 	   if exist %basedir%\windata\backups\update.previous-1.log (
   	     copy /y %basedir%\windata\backups\update.previous-1.log %diagdir%\update.log
   	     ) else (
     	   call :stampit "Grub2Win has not yet been run" %diagdir%\update.log
     	   ))
	md %diagdir%\themes
	if exist     %basedir%\themes\*.txt    copy /y          %basedir%\themes\*.txt   %diagdir%\themes

	set partin=%partdir%\part.input.txt
	set partout=%partdir%\part.output.txt
	set errorout=%diagdir%\error.code.txt

	if defined errorcode (
  	  if "%errorcode%" neq "OnRequest"  (
  	     call :stampit "The Grub2Win diagnostic error code is  -  %errorcode%" %errorout%
	))

	echo.
	echo     Running the Diskpart diagnostics (This may take up to 60 seconds)
	echo. 

	call :stampit "DiskPart diagnostic starts" %partout%

	echo   List   Disk		>>  %partin%
	echo   List   Volume		>>  %partin%

	echo   Select Disk 0		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 1		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 2		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 3		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 4		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 5		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 6		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 7		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 8		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Select Disk 9		>>  %partin% 
	echo   Detail Disk		>>  %partin%
	echo   List   Partition		>>  %partin%

	echo   Exit			>>  %partin%

	diskpart /s %partin%		>>  %partout%

	dir /s /O:GN %basedir%           >  %diagdir%\dirlisting.grub.txt

	for /L %%A in (0,1,25) do (
	   rem echo !uppercase:~%%A,1!
	   call :efilist !uppercase:~%%A,1! 
	)

	cls
	echo.
	echo.
	echo.
	echo.
	echo                    The diagnostic files are in directory
	echo.
	echo                            %diagdir%
	echo.
	echo.
	echo               ** Grub2Win diagnostic creation has completed **
	echo.
	echo.
	echo.
	goto :eof

:efilist
	if not exist %1:\efi goto :eof
	set upperin=%1
	set lowerout=%1
	for /L %%A in (0,1,25) do (if "%upperin%" equ "!uppercase:~%%A,1!" set lowerout=!lowercase:~%%A,1!)
  	 dir /a    /O:GN %1:          >  %diagdir%\dirlisting.efi.%lowerout%.txt
 	  for /d %%G in (%1:\*.*) do (
		dir /a /s /O:GN %%G    >>  %diagdir%\dirlisting.efi.%lowerout%.txt
	   )
	)
	goto :eof

:xpruns
	echo.
	echo               Running XP MSInfo32
	echo.
	"C:\Program Files\Common Files\Microsoft Shared\MSInfo\MSInfo32.exe" /Report %diagdir%\system.detail.txt
	goto :eof


:nonxpruns
	echo.
	echo               Running the BCD diagnostics
	echo. 

	set bcddir=%diagdir%\bcdlists
	set bcdeditout=%bcddir%\bcdedit.output.txt
	set bcdeditoutverb=%bcddir%\bcdedit.verbose.txt
	set bcdfirmout=%bcddir%\bcdfirmware.output.txt
	set bcdfirmoutverb=%bcddir%\Diagnostic.BCDRaw.verbose.txt
	set mountvol=%bcddir%\mountvol.listing.txt
	md %bcddir%

	if exist %diagdir%\backups\*.bcd   erase /q         %diagdir%\backups\*.bcd
	call :stampit "BCDEdit diagnostic starts"           %bcdeditout%
	echo The command is - bcdedit                   >>  %bcdeditout%                                  
	bcdedit.exe                                     >>  %bcdeditout%  2>nul
	C:\windows\sysnative\bcdedit.exe                >>  %bcdeditout%  2>nul
	call :stampit "BCDEdit Verbose diagnostic starts"   %bcdeditoutverb%
	echo The command is - bcdedit /v                >>  %bcdeditoutverb% 
	bcdedit.exe /v                                  >>  %bcdeditoutverb%  2>nul
	C:\windows\sysnative\bcdedit.exe   /v           >>  %bcdeditoutverb%  2>nul

	call :stampit "BCD Firmware diagnostic starts"      %bcdfirmout%
	echo The command is - bcdedit /enum all         >>  %bcdfirmout% 
	bcdedit.exe /enum all                           >>  %bcdfirmout%  2>nul
	C:\windows\sysnative\bcdedit.exe /enum all      >>  %bcdfirmout%  2>nul

	call :stampit "BCD Firmware Verbose diagnostic starts" %bcdfirmoutverb%
	echo The command is - bcdedit /v /enum all      >>  %bcdfirmoutverb% 
	bcdedit.exe /v /enum all                        >>  %bcdfirmoutverb%  2>nul
	C:\windows\sysnative\bcdedit.exe /v /enum all   >>  %bcdfirmoutverb%  2>nul

	call :stampit "MountVol diagnostic starts"          %mountvol%
	echo The command is - mountvol                  >>  %mountvol% 
	mountvol.exe                                    >>  %mountvol%  2>nul

	if exist %basedir%\windata\storage\tempfiles    copy %basedir%\windata\storage\tempfiles %bcddir%
	
	systeminfo                                      >   %diagdir%\system.detail.txt
   
	goto :eof

:getadmin
	ver | find "5.1" 2>nul
	if "%errorlevel%" equ "0" ( goto :gotadmin )
	net session >nul 2>&1
	REM --> If error flag set, we do not have admin.
	if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	call :uacprompt )

:gotadmin
	pushd "%CD%"
	CD /D "%~dp0"
	goto :EOF

:uacprompt
	echo Set UAC = CreateObject^("Shell.Application"^) > "%ProgramData%\getadmin.vbs"
	set params = %*:"=""
	echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%ProgramData%\getadmin.vbs"
	"%ProgramData%\getadmin.vbs"
	del "%ProgramData%\getadmin.vbs"
	exit