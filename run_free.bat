@echo off
setlocal
echo =======================================================
echo ONE: Launching FREE version on phone
echo =======================================================
echo.

call flutter run -d 8e39c743
if %errorlevel% neq 0 (
    echo.
    echo Trying default connected device...
    call flutter run
)

pause
