@echo off
setlocal
echo =======================================================
echo ONE: Launching PREMIUM UNLOCKED version on phone
echo =======================================================
echo.

call flutter run --dart-define=FORCE_PREMIUM=true -d 8e39c743
if %errorlevel% neq 0 (
    echo.
    echo Trying default connected device...
    call flutter run --dart-define=FORCE_PREMIUM=true
)

pause
