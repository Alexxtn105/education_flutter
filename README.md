# Система тестирования Education

## Команды
Обновить зависимости
```bash
flutter pub get
```
Запуск Flutter приложения:
```bash
flutter run
```

Запуск dev-сервера
```bash
flutter run -d web-server --web-port=8086
```


Билд релизной веб-версии
```bash
flutter build web --release
```

## Если нужна поддержка Windows как целевой платформы:

```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
flutter run -d windows
```

## Запустить в Windows

```bash
flutter run -d windows
```

## Полезные команды

### Проверить установку

```bash
flutter doctor
```

### Запустить приложение

```bash
flutter run
```

### Собрать APK

```bash
flutter build apk
```

### Обновить зависимости

```bash
flutter pub get
```

### Запустить в режиме горячей перезагрузки

```bash
flutter run --hot
```

# Компиляция проекта для Windows

1. Включите поддержку Windows
   Сначала убедитесь, что поддержка Windows desktop включена:

    ```bash
    flutter config --enable-windows-desktop
    ```
   Проверьте доступные устройства:

    ```bash
    flutter devices
    ```
   Вы должны увидеть что-то вроде:

    ```text
    Windows (desktop) • windows • windows-x64 • Microsoft Windows [Version 10.0.19045.3803]
    Chrome (web)      • chrome  • web-javascript • Google Chrome 140.0.7339.128
    Edge (web)        • edge    • web-javascript • Microsoft Edge 140.0.3485.66
    ```
2. Соберите исполняемый файл
   Для отладочной сборки (debug):
   ```bash
   flutter build windows
   ```

   Для production-сборки (release):
   ```bash
   flutter build windows --release
   ```
3. Где найти исполняемый файл
   После сборки файлы будут находиться в папке:

    ```text
    build\windows\runner\<build_mode>\
    ```
   Где `<build_mode>` это:

   `debug` - для отладочной версии

   `release` - для production версии

   Для production-версии путь будет:
    ```text
    build\windows\runner\Release\
   ```
   В этой папке вы найдете:

   `your_app_name.exe` - главный исполняемый файл

   Папка `data` - с ресурсами приложения

   Несколько `.dll` файлов - необходимые библиотеки

4. Создание установщика (опционально)
   Способ 1: Простое распространение
   Скопируйте всю содержимое папки Release и распространяйте как есть.

   Способ 2: Создание MSI установщика
   Установите необходимые инструменты:

    ```bash
    # Установите WiX Toolset (если нет)
    # Скачайте с: https://wixtoolset.org/docs/wix3/
    
    # Соберите установщик
    flutter build windows --release
    cd build\windows
    # Далее нужно настроить WiX для создания MSI
   ```
   Способ 3: Использование `Inno Setup` (рекомендуется)
   Скачайте `Inno Setup`
   Создайте скрипт установщика:

    ```iss
    ; script.iss
    [Setup]
    AppName=Termius Like App
    AppVersion=1.0.0
    DefaultDirName={pf}\TermiusLikeApp
    DefaultGroupName=Termius Like App
    OutputDir=output
    OutputBaseFilename=TermiusLikeApp_Setup
    
    [Files]
    Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
    
    [Icons]
    Name: "{group}\Termius Like App"; Filename: "{app}\your_app_name.exe"
    Name: "{commondesktop}\Termius Like App"; Filename: "{app}\your_app_name.exe"
   ```
5. Полный пример процесса
   ```bash
    # 1. Перейдите в папку проекта
    cd your_project_folder
    
    # 2. Убедитесь, что Windows поддержка включена
    flutter config --enable-windows-desktop
    
    # 3. Получите зависимости
    flutter pub get
    
    # 4. Соберите production версию
    flutter build windows --release

    # 5. Перейдите в папку с собранным приложением
    explorer build\windows\runner\Release
   ```
6. Дополнительная настройка (по желанию)
   Изменить иконку приложения:
   Добавьте файл `windows\runner\resources\app_icon.ico`

   Изменить информацию о приложении:
   Отредактируйте файл `windows\runner\Runner.rc`

   Настройка манифеста:
   Файл `windows\runner\Runner.manifest` содержит настройки совместимости.

7. Проверка совместимости
   Перед распространением проверьте приложение на других Windows компьютерах. Убедитесь, что:

    - .NET Framework не требуется (Flutter самодостаточен)
    - Все DLL файлы включены в поставку
    - Приложение работает без установки дополнительных компонентов

8. Автоматизация сборки
   Создайте batch-файл для автоматизации:

   ```batch
   @echo off
   echo Building Termius-like app...
   flutter clean
   flutter pub get
   flutter build windows --release
   echo Build completed!
   echo Files are in: build\windows\runner\Release
   pause
   ```
   Сохраните как `build.bat` и запускайте двойным кликом.

