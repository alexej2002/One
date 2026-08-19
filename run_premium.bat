@echo off
chcp 65001 > nul
echo =======================================================
echo [ONE] Запуск PREMIUM (разблокированной) версии на устройстве
echo =======================================================
echo.

echo Проверка подключенных устройств:
flutter devices
echo.

echo Запуск приложения ONE со всеми разблокированными функциями...
flutter run --dart-define=FORCE_PREMIUM=true -d android

pause
