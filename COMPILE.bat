@echo off
set /p id=File: 

echo.
echo Compiling %id%.asm ...

.\nasm -f win32 %id%.asm

.\nlink %id%.obj -lio -lutil -lgfx -o %id%.exe

del -q %id%.obj

echo Done
echo.


pause