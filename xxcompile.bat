@echo off
cls
echo.
echo     ** Note: This compile script requires the installation of the AutoIt compiler package.
echo     ** AutoIt is freely available for download here:
echo.
echo             https://www.autoitscript.com/site/autoit/downloads/
echo.
pause

set normalbase="%~dp0"
set autoitcompiler="C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe.exe"

if not exist %autoitcompiler% (echo. 
                           echo The AutoIt compiler is not installed - Run cancelled
                           echo.
                           pause
		           goto :EOF)

call :normalrun
pause
goto :eof

:normalrun
	call :checkbase
	if "%baseok%"  equ "yes" call :runit
	goto :eof


:runit
	cls
	echo.
	echo               The Grub2Win base directory is %basedir%
	echo.
	echo.
	set sourcelib=%basedir%
	set sourcefile=%sourcelib%grub2win.au3
	set outexe=%basedir%grub2win.exe
	set icon=%sourcelib%xxgrub2win.ico
	if not exist %sourcefile% (echo. 
		echo Source file %sourcefile% is missing - Run cancelled
		echo.
		goto :EOF)
	%autoitcompiler% /in %sourcefile% /out %outexe% /icon %icon% /x86 /pack /comp 4

	cls
	echo.
	echo.
	echo.
	echo               The Grub2Win base directory is %basedir%
	echo.
	echo.
	echo                 The compile of Grub2Win source file
	echo                    %sourcefile% 
	echo                            is complete
	echo.
	echo.
	echo                The new Grub2Win executable file is
	echo                       %outexe%
	echo.
	echo.
	echo.
	goto :eof

:checkbase
	cls
	set baseok=
	set basedir=%normalbase%
	echo.
	echo.
	echo               Starting Grub2Win compile from source code
	echo.
	echo.
	echo.
	set /p basedir= Please enter the source directory for the gub2win.au3 file or press enter for default (%basedir%)   
	if exist %basedir% (set baseok=yes
			    goto :EOF)
	cls
	echo.
	echo.
	echo.
	echo               The directory you entered (%basedir%) was not found
	echo                               ** Run Cancelled **
	echo.
	echo.
	echo.
	goto :eof