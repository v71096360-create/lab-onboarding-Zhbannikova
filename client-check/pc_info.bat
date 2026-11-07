@echo off
chcp 65001 >nul

REM Тема: Диагностика клиентского компьютера (Часть 2 - Анализ)
REM Фамилия: Жбанникова
REM Дата: 07.11.2026

set "REPORT=%~dp0pc_report.txt"
if exist "%REPORT%" del "%REPORT%"

REM Создаём временный файл со списком программ для анализа
set "APPS_FILE=%TEMP%\apps_list.txt"
if exist "%APPS_FILE%" del "%APPS_FILE%"

echo ========================================
echo        Диагностика компьютера
echo ========================================
echo ======================================== >> "%REPORT%"
echo        Диагностика компьютера >> "%REPORT%"
echo ======================================== >> "%REPORT%"
echo. >> "%REPORT%"

echo.
echo [Операционная система]
echo [Операционная система] >> "%REPORT%"
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /format:list ^| find "="') do set "OS_NAME=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /format:list ^| find "="') do set "OS_VER=%%a"
set "OS_NAME=%OS_NAME: =%"
set "OS_VER=%OS_VER: =%"
echo Название: %OS_NAME%
echo Версия: %OS_VER%
echo Название: %OS_NAME% >> "%REPORT%"
echo Версия: %OS_VER% >> "%REPORT%"

echo.
echo [Процессор]
echo. >> "%REPORT%"
echo [Процессор] >> "%REPORT%"
for /f "tokens=2 delims==" %%a in ('wmic cpu get name /format:list ^| find "="') do set "CPU_NAME=%%a"
set "CPU_NAME=%CPU_NAME: =%"
echo %CPU_NAME%
echo %CPU_NAME% >> "%REPORT%"

echo.
echo [Оперативная память]
echo. >> "%REPORT%"
echo [Оперативная память] >> "%REPORT%"
for /f "tokens=2 delims==" %%a in ('wmic OS get TotalVisibleMemorySize /format:list ^| find "="') do set "RAM_TOTAL_KB=%%a"
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /format:list ^| find "="') do set "RAM_FREE_KB=%%a"
set "RAM_TOTAL_KB=%RAM_TOTAL_KB: =%"
set "RAM_FREE_KB=%RAM_FREE_KB: =%"
set /a RAM_TOTAL_GB=%RAM_TOTAL_KB% / 1048576
set /a RAM_FREE_GB=%RAM_FREE_KB% / 1048576
echo Всего памяти (ГБ): %RAM_TOTAL_GB%
echo Свободно памяти (ГБ): %RAM_FREE_GB%
echo Всего памяти (ГБ): %RAM_TOTAL_GB% >> "%REPORT%"
echo Свободно памяти (ГБ): %RAM_FREE_GB% >> "%REPORT%"

echo.
echo [Диск C]
echo. >> "%REPORT%"
echo [Диск C] >> "%REPORT%"
for /f %%a in ('powershell -Command "[math]::Round((Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=\"C:\"').Size / 1GB, 0)"') do set "DISK_SIZE_GB=%%a"
for /f %%a in ('powershell -Command "[math]::Round((Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=\"C:\"').FreeSpace / 1GB, 0)"') do set "DISK_FREE_GB=%%a"
echo Всего на диске C (ГБ): %DISK_SIZE_GB%
echo Свободно на диске C (ГБ): %DISK_FREE_GB%
echo Всего на диске C (ГБ): %DISK_SIZE_GB% >> "%REPORT%"
echo Свободно на диске C (ГБ): %DISK_FREE_GB% >> "%REPORT%"

echo.
echo ========================================
echo        Установленные программы
echo ========================================
echo. >> "%REPORT%"
echo ======================================== >> "%REPORT%"
echo        Установленные программы >> "%REPORT%"
echo ======================================== >> "%REPORT%"
echo Идёт поиск программ, это может занять несколько минут...
echo Идёт поиск программ... >> "%REPORT%"
wmic product get name /format:list | findstr "=" > "%APPS_FILE%"
for /f "tokens=2 delims==" %%a in (%APPS_FILE%) do (
    echo %%a
    echo %%a >> "%REPORT%"
)

echo.
echo ========================================
echo Отчёт сохранён в файл: pc_report.txt
echo ========================================
echo. >> "%REPORT%"
echo Отчёт сохранён. >> "%REPORT%"

REM ============================================
REM АНАЛИЗ: НЕДОСТАЮЩЕЕ ПО
REM ============================================
echo.
echo ========================================
echo   АНАЛИЗ: НЕДОСТАЮЩЕЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ
echo ========================================
echo.
echo ======================================== >> "%REPORT%"
echo   АНАЛИЗ: НЕДОСТАЮЩЕЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ >> "%REPORT%"
echo ======================================== >> "%REPORT%"

echo [Проверка офисного пакета]
echo [Проверка офисного пакета] >> "%REPORT%"
findstr /I "Office" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo [ТРЕБУЕТ ВНИМАНИЯ] Офисный пакет не обнаружен. Рекомендуется установить Microsoft Office или LibreOffice.
    echo [ТРЕБУЕТ ВНИМАНИЯ] Офисный пакет не обнаружен. >> "%REPORT%"
) else (
    echo [OK] Офисный пакет найден
    echo [OK] Офисный пакет найден >> "%REPORT%"
)

echo.
echo [Проверка веб-браузера]
echo [Проверка веб-браузера] >> "%REPORT%"
findstr /I "Chrome Firefox Yandex Edge Opera" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo [ТРЕБУЕТ ВНИМАНИЯ] Веб-браузер не обнаружен. Рекомендуется установить Google Chrome или Firefox.
    echo [ТРЕБУЕТ ВНИМАНИЯ] Веб-браузер не обнаружен. >> "%REPORT%"
) else (
    echo [OK] Веб-браузер найден
    echo [OK] Веб-браузер найден >> "%REPORT%"
)

echo.
echo [Проверка программы для чтения PDF]
echo [Проверка программы для чтения PDF] >> "%REPORT%"
findstr /I "Acrobat Foxit SumatraPDF PDF" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo [ТРЕБУЕТ ВНИМАНИЯ] Программа для чтения PDF не обнаружена. Рекомендуется установить Adobe Acrobat Reader.
    echo [ТРЕБУЕТ ВНИМАНИЯ] Программа для чтения PDF не обнаружена. >> "%REPORT%"
) else (
    echo [OK] Программа для чтения PDF найдена
    echo [OK] Программа для чтения PDF найдена >> "%REPORT%"
)

echo.
echo [Проверка архиватора]
echo [Проверка архиватора] >> "%REPORT%"
findstr /I "7-Zip WinRAR WinZip" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo [ТРЕБУЕТ ВНИМАНИЯ] Архиватор не обнаружен. Рекомендуется установить 7-Zip или WinRAR.
    echo [ТРЕБУЕТ ВНИМАНИЯ] Архиватор не обнаружен. >> "%REPORT%"
) else (
    echo [OK] Архиватор найден
    echo [OK] Архиватор найден >> "%REPORT%"
)

REM ============================================
REM АНАЛИЗ: ИЗЛИШНЕЕ ПО
REM ============================================
echo.
echo ========================================
echo   АНАЛИЗ: ПРОГРАММЫ, ТРЕБУЮЩИЕ ПРОВЕРКИ
echo ========================================
echo.
echo ======================================== >> "%REPORT%"
echo   АНАЛИЗ: ПРОГРАММЫ, ТРЕБУЮЩИЕ ПРОВЕРКИ >> "%REPORT%"
echo ======================================== >> "%REPORT%"

echo [Игровые платформы]
echo [Игровые платформы] >> "%REPORT%"
findstr /I "Steam Epic GOG Origin Game Gaming" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo Игровые платформы не найдены
    echo Игровые платформы не найдены >> "%REPORT%"
) else (
    echo Найдены игровые платформы:
    echo Найдены игровые платформы: >> "%REPORT%"
    findstr /I "Steam Epic GOG Origin Game Gaming" "%APPS_FILE%"
    findstr /I "Steam Epic GOG Origin Game Gaming" "%APPS_FILE%" >> "%REPORT%"
    echo Рекомендуется проверить, установлены ли они по согласованию с руководством.
    echo Рекомендуется проверить установку. >> "%REPORT%"
)

echo.
echo [Торрент-клиенты]
echo [Торрент-клиенты] >> "%REPORT%"
findstr /I "uTorrent BitTorrent qBittorrent Torrent" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo Торрент-клиенты не найдены
    echo Торрент-клиенты не найдены >> "%REPORT%"
) else (
    echo Найдены торрент-клиенты:
    echo Найдены торрент-клиенты: >> "%REPORT%"
    findstr /I "uTorrent BitTorrent qBittorrent Torrent" "%APPS_FILE%"
    findstr /I "uTorrent BitTorrent qBittorrent Torrent" "%APPS_FILE%" >> "%REPORT%"
    echo Внимание: такие программы создают нагрузку на сеть.
    echo Внимание: нагрузка на сеть. >> "%REPORT%"
)

echo.
echo [Мессенджеры]
echo [Мессенджеры] >> "%REPORT%"
findstr /I "Discord Telegram WhatsApp Viber Skype" "%APPS_FILE%" >nul
if errorlevel 1 (
    echo Мессенджеры не найдены
    echo Мессенджеры не найдены >> "%REPORT%"
) else (
    echo Найдены мессенджеры:
    echo Найдены мессенджеры: >> "%REPORT%"
    findstr /I "Discord Telegram WhatsApp Viber Skype" "%APPS_FILE%"
    findstr /I "Discord Telegram WhatsApp Viber Skype" "%APPS_FILE%" >> "%REPORT%"
    echo Рекомендуется проверить, используются ли они для рабочих задач.
    echo Рекомендуется проверить использование. >> "%REPORT%"
)

REM Удаляем временный файл
if exist "%APPS_FILE%" del "%APPS_FILE%"

pause