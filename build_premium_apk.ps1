# Скрипт сборки автономного APK файла с разблокированным Premium

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📦 Сборка Release APK (PREMIUM UNLOCKED)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

flutter build apk --release --dart-define=FORCE_PREMIUM=true

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 APK успешно собран!" -ForegroundColor Green
    Write-Host "Файл лежит по пути:" -ForegroundColor Yellow
    Write-Host "build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
} else {
    Write-Host "`n❌ Ошибка при сборке APK" -ForegroundColor Red
}
