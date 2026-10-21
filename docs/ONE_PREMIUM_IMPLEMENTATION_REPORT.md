# One Premium v1.0 — отчёт реализации

## Что изменено

- RevenueCat и `purchases_flutter` удалены из Flutter-кода, `pubspec.yaml` и lock-файла. Удалены `FORCE_PREMIUM`, offerings, тарифы, цены, покупка и восстановление покупок.
- `AppState` теперь читает локальный статус Premium до `isInitialized`, хранит `premium_access_level`, `premium_grant_source`, `premium_activated_at` и `premium_schema_version` в `shared_preferences` и предоставляет идемпотентный `activateFreePremium()`.
- Экран Premium показывает бесплатное предложение, кнопку «Активировать бесплатно», состояние «Premium активен» и локализованную ошибку сохранения.
- Отложенные действия применяются только при активном локальном Premium; отмена контекстного paywall очищает callback.
- Сохранены правила Free/Premium: `paper`, первые 7 архивных записей и обычное включение уведомлений доступны Free; остальные темы, архив, произвольное время и виджетный контент открываются после активации.
- Android `QuoteWidgetProvider` читает `premium_active`: до активации показывает нейтральное состояние. Flutter-экран виджетов показывает один реально зарегистрированный provider и инструкцию добавления с главного экрана устройства.
- Новые состояния Premium добавлены во все семь локалей. Обновлены `LegalContent`, `terms-of-use.html` и `privacy-policy.html`; из них удалены платные тарифы, Lifetime, автопродление и платежные сценарии.
- Скрипты запуска/сборки больше не используют `FORCE_PREMIUM`.

## Карта файлов

- `lib/state/app_state.dart` — локальное право, активация, загрузка/сохранение, передача статуса виджету.
- `lib/screens/premium_screen.dart` — бесплатный Premium UI.
- `lib/widgets/contextual_paywall.dart` — локализованный CTA и очистка pending action при отмене.
- `lib/screens/feature_detail_screens.dart` — единый экран одного виджета и локализованные подсказки.
- `lib/l10n/strings.dart` — тексты `en`, `ru`, `de`, `es`, `fr`, `pt_BR`, `pt`.
- `lib/l10n/legal_content.dart`, `assets/doc/terms-of-use.html`, `assets/doc/privacy-policy.html` — актуализированные legal-тексты.
- `android/app/src/main/kotlin/com/kindpeople/one/QuoteWidgetProvider.kt` — защита содержимого виджета до активации.
- `pubspec.yaml`, `pubspec.lock` — удаление RevenueCat.
- `run_premium.bat`, `install_premium.ps1`, `build_premium_apk.ps1` — удаление старого обхода `FORCE_PREMIUM`.

## Тесты и команды

- `flutter pub get` — выполнен успешно; lock-файл обновлён, `purchases_flutter` удалён.
- `flutter analyze` — выполнен успешно без ошибок; остались 2 существующих информационных предупреждения deprecated для `Share` в `lib/screens/today_screen.dart:264`.
- Поиск RevenueCat/`purchases_flutter`/`FORCE_PREMIUM` в коде, зависимостях и Android-части — прямых остатков интеграции не найдено. Совпадения слова `package` в служебных комментариях и `MY_PACKAGE_REPLACED` не относятся к платежной интеграции.
- Сборка, unit/widget-тесты и ручная проверка на Android-устройстве не выполнялись.

## Оставшиеся риски

- Android Backup уже разрешён в manifest, но восстановление локального Premium после переустановки или на другом устройстве не гарантируется и зависит от устройства/системы.
- Виджет добавляется системным launcher; Flutter не может надёжно запретить его размещение. Нативный provider скрывает контент до `premium_active`, но ручная проверка launcher-сценария не выполнялась.
- Юридические HTML-страницы могли быть опубликованы вне репозитория; их внешние URL в текущем коде не определены и отдельно обновить их невозможно.
- В текущем проекте остаются два старых analyzer-инфо предупреждения для `share_plus`.

## Статус проекта и вопросы до публикации

В соответствии с подтверждением владельца проект One ещё не публиковался в Google Play, пользователей и реальных покупок нет; миграция RevenueCat-entitlements не требуется. Google Play Console и внешние кабинеты не проверялись.

До будущей платной версии нужно отдельно решить, сохраняется ли бесплатный Premium v1.0 после появления оплаты, требуется ли перенос между устройствами и как будет устроена официальная платежная система. Эти вопросы не блокируют бесплатную локальную активацию v1.0.
