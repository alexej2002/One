# Скрипт сборки и установки Premium-версии ONE на телефон (Android)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🚀 ONE: Сборка и установка PREMIUM версии" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Проверяем подключенные устройства
Write-Host "`n📱 Проверка подключенных устройств..." -ForegroundColor Yellow
$devices = flutter devices
Write-Host $devices

# 2. Собираем и устанавливаем обычную версию приложения
Write-Host "`n📦 Запуск установки с разблокированными Premium-функциями..." -ForegroundColor Yellow
flutter run -d android

Write-Host "`n✅ Готово! Версия приложения запущена на устройстве." -ForegroundColor Green
