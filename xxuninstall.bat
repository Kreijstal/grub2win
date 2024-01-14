@echo off
if not exist grub2win.exe cd ..
if exist grub2win.exe (start  grub2win.exe Uninstall) else (
    cls
    echo.
    echo The Grub2Win base executable
    echo grub2win.exe was not found in this directory
    echo.
    echo "%cd%"
    echo.
    pause
)