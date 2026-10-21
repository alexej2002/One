# Скрипт сборки автономного APK файла

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📦 Сборка Release APK" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 APK успешно собран!" -ForegroundColor Green
    Write-Host "Файл лежит по пути:" -ForegroundColor Yellow
    Write-Host "build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
} else {
    Write-Host "`n❌ Ошибка при сборке APK" -ForegroundColor Red
}
