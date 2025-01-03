@echo off

set runlib="%cd%"

set releaselib=%runlib%\grub-2.12-for-windows
set targetgrub=C:\grub2

set runok=yes

set efimods=
set efimods=%efimods% fat
set efimods=%efimods% exfat
set efimods=%efimods% ntfs
set efimods=%efimods% ntfscomp
set efimods=%efimods% part_gpt
set efimods=%efimods% part_msdos
set efimods=%efimods% probe
set efimods=%efimods% search
set efimods=%efimods% ext2 
set efimods=%efimods% efifwsetup
set efimods=%efimods% usb
set efimods=%efimods% echo
set efimods=%efimods% eval
set efimods=%efimods% read
set efimods=%efimods% test
set efimods=%efimods% true
set efimods=%efimods% tr
set efimods=%efimods% chain
set efimods=%efimods% date
set efimods=%efimods% help
set efimods=%efimods% halt
set efimods=%efimods% sleep
set efimods=%efimods% cat
set efimods=%efimods% cpuid
set efimods=%efimods% configfile
set efimods=%efimods% normal


set biosmods=
set biosmods=%biosmods%  biosdisk
set biosmods=%biosmods%  fat
set biosmods=%biosmods%  ntfs
set biosmods=%biosmods%  ntfscomp
set biosmods=%biosmods%  part_gpt
set biosmods=%biosmods%  part_msdos
set biosmods=%biosmods%  usb
set biosmods=%biosmods%  search

cd %releaselib%

set genparmsefi32=--config=%runlib%/gnugrub.efi.boot.sh --output=%runlib%\gnugrub.kernel32.efi --verbose
set genparmsefi32=%genparmsefi32% --format=i386-efi --prefix=/grub2  %efimods%

set genparmsefi64=--config=%runlib%/gnugrub.efi.boot.sh --output=%runlib%\gnugrub.kernel64.efi --verbose
set genparmsefi64=%genparmsefi64% --format=x86_64-efi --prefix=/grub2  %efimods%

set genparmsbios=--config=%runlib%/gnugrub.bios.boot.sh   --output=%runlib%\gnugrub.temp.bios --verbose
set genparmsbios=%genparmsbios% --format=i386-pc --prefix=/grub2  %biosmods%

if exist %runlib%\gnugrub.kernel32.efi erase %runlib%\gnugrub.kernel32.efi 
if exist %runlib%\gnugrub.kernel64.efi erase %runlib%\gnugrub.kernel64.efi
if exist %runlib%\gnugrub.temp.bios    erase %runlib%\gnugrub.temp.bios 
if exist %runlib%\gnugrub.kernel.bios  erase %runlib%\gnugrub.kernel.bios 
if exist %runlib%\output.genefi32.txt  erase %runlib%\output.genefi32.txt
if exist %runlib%\output.genefi64.txt  erase %runlib%\output.genefi64.txt
if exist %runlib%\output.genbios.txt   erase %runlib%\output.genbios.txt
if exist %runlib%\output.update.txt    erase %runlib%\output.update.txt

cls
echo.
echo.

grub-mkimage %genparmsefi32% 2> %runlib%\output.genefi32.txt
if "%errorlevel%" equ "0" (
    echo.
    echo    Generate EFI 32 Bit was successful
) else (
    echo.
    echo *** Generate EFI 32 Bit failed with return code% errorlevel%
    echo.
    set runok=no
    pause
    echo.
    if exist %runlib%\output.genefi32.txt erase %runlib%\output.genefi32.txt
    echo.
)


grub-mkimage %genparmsefi64% 2> %runlib%\output.genefi64.txt
if "%errorlevel%" equ "0" (
    echo.
    echo    Generate EFI 64 Bit was successful
    echo.
) else (
    echo.
    echo *** Generate EFI 64 Bit failed with return code %errorlevel%
    echo.
    set runok=no
    pause
    echo.
    if exist %runlib%\output.genefi64.txt erase %runlib%\output.genefi64.txt
    echo.
)

grub-mkimage %genparmsbios% 2> %runlib%\output.genbios.txt
if "%errorlevel%" equ "0" (
    echo    Generate BIOS phase 1 was successful
    echo.
) else (
    echo.
    echo *** Generate BIOS phase 1 failed with return code %errorlevel%
    echo.
    set runok=no
    pause
    echo.
    if exist %runlib%\output.genbios.txt erase %runlib%\output.genbios.txt
    echo.
)
copy /y %releaselib%\i386-pc\lnxboot.img /b + %runlib%\gnugrub.temp.bios /b %runlib%\gnugrub.kernel.bios 1>> %runlib%\output.genbios.txt
if "%errorlevel%" equ "0" (
    echo.
    echo    Generate BIOS phase 2 was successful
    echo.
) else (
    echo.
    echo *** Generate BIOS phase 2 with return code %errorlevel%
    echo.
    set runok=no
    pause
    echo.
    if exist %runlib%\gnugrub.kernel.bios erase %runlib%\gnugrub.kernel.bios
    echo.
)

echo.

if exist %runlib%\gnugrub.temp.bios erase %runlib%\gnugrub.temp.bios 

cd %runlib%
if "%runok%" equ "yes" (
    echo.
    echo.
    echo    gen-image completed with no errors
    echo.
) else (
    echo.
    echo.
    echo.
    echo    **  gen-image failed *** 
    echo.
    echo.
    echo.
    pause
    exit
)

echo.
set /p resp=  Do you want to update %targetgrub%?  (y or n) 

if "%resp%" equ "y" ( call :updatetarg
) else (
    echo.
    echo.
    echo.
    echo    **  The update of %targetgrub% was declined  *** 
    echo.
    echo.
    echo.
    pause
)
goto :eof

:updatetarg
    echo.
    echo.
    echo    Now updating %targetgrub%
    echo.

    if exist %targetgrub%\i386-pc    rmdir /q /s %targetgrub%\i386-pc
    if exist %targetgrub%\i386-efi   rmdir /q /s %targetgrub%\i386-efi
    if exist %targetgrub%\x86_64-efi rmdir /q /s %targetgrub%\x86_64-efi

    copy  /y %runlib%\gnugrub.kernel*    %targetgrub%\g2bootmgr\      >  %runlib%\output.update.txt
    if ERRORLEVEL 1 (
        echo.
        echo  *** The copy of the new boot modules to %targetgrub%\g2bootmgr\ failed ***
        set runok=no
        pause
        goto :eof 
    ) else (
        echo.
        echo      The copy of the new boot modules to %targetgrub%\g2bootmgr\ was successful
        echo.
    echo.
    )
    
    echo.                                                             >> %runlib%\output.update.txt
    echo.                                                             >> %runlib%\output.update.txt
    xcopy /y /i /s %releaselib%\i386-pc       %targetgrub%\i386-pc    >> %runlib%\output.update.txt
    if ERRORLEVEL 1 (
        echo.
        echo  *** The copy of the Grub2 i386-pc library to %targetgrub% failed ***
        set runok=no
        pause
        echo.
        goto :eof
    ) else (
        echo.
        echo      The copy of the Grub2 i386-pc library to %targetgrub% was successful
        echo.
    )
    echo.
    echo.                                                             >> %runlib%\output.update.txt
    xcopy /y /i /s %releaselib%\i386-efi      %targetgrub%\i386-efi   >> %runlib%\output.update.txt
    if ERRORLEVEL 1 (
        echo.
        echo  *** The copy of the Grub2 i386-efi library to %targetgrub% failed ***
        set runok=no
        pause
        echo.
        goto :eof
    ) else (
        echo.
        echo      The copy of the Grub2 i386-efi library to %targetgrub% was successful
        echo.
    )   
    echo.
    echo.                                                             >> %runlib%\output.update.txt
    xcopy /y /i /s %releaselib%\x86_64-efi    %targetgrub%\x86_64-efi >> %runlib%\output.update.txt
    if ERRORLEVEL 1 (
        echo.
        echo  *** The copy of the Grub2 X86-64 library to %targetgrub% failed ***
        set runok=no
        pause
        echo.
        goto :eof
    ) else (
        echo.
        echo      The copy of the Grub2 X86-64 library to %targetgrub% was successful
        echo.
    )    
    echo.
    echo.
    echo.
    echo. ** The update of %targetgrub% completed successfully
    echo.
    echo.
    echo.
    echo Press enter to list the output files
    echo.  
pause

dir

echo.
echo.

pause