# Скрипт сборки и установки Premium-версии ONE на телефон (Android)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🚀 ONE: Сборка и установка PREMIUM версии" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Проверяем подключенные устройства
Write-Host "`n📱 Проверка подключенных устройств..." -ForegroundColor Yellow
$devices = flutter devices
Write-Host $devices

# 2. Собираем и устанавливаем с флагом --dart-define=FORCE_PREMIUM=true
Write-Host "`n📦 Запуск установки с разблокированными Premium-функциями..." -ForegroundColor Yellow
flutter run --dart-define=FORCE_PREMIUM=true -d android

Write-Host "`n✅ Готово! Premium-версия запущена на устройстве." -ForegroundColor Green
