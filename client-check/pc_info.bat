@echo off
chcp 65001 >nul

REM Тема: Диагностика клиентского компьютера (Часть 2 - Анализ)
REM Фамилия: Жбанникова
REM Дата: 31.10.2026

REM ============================================
REM ПОДПРОГРАММА ДЛЯ ВЫВОДА (устраняем дублирование)
REM Вызывается как: call :log "текст сообщения"
REM ============================================
:log
echo %~1
echo %~1 >> "%REPORT%"
exit /b

REM ============================================
REM НАЧАЛО ОСНОВНОЙ ПРОГРАММЫ
REM ============================================

REM Создаём файл отчёта рядом с этим скриптом
set "REPORT=%~dp0pc_report.txt"
if exist "%REPORT%" del "%REPORT%"

REM Выводим заголовок
call :log "========================================"
call :log "       Диагностика компьютера"
call :log "========================================"

REM Добавляем дату и время
for /f "tokens=2 delims==" %%a in ('wmic OS get LocalDateTime /value ^| find "="') do set "DT=%%a"
set "DT=%DT:~0,8% %DT:~8,6%"
call :log ""
call :log "Дата проверки: %DT%"

REM ============================================
REM ОПЕРАЦИОННАЯ СИСТЕМА
REM ============================================
call :log ""
call :log "[Операционная система]"

set "OS_NAME="
set "OS_VER="
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value ^| find "="') do set "OS_NAME=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /value ^| find "="') do set "OS_VER=%%a"
set "OS_NAME=%OS_NAME: =%"
set "OS_VER=%OS_VER: =%"

if defined OS_NAME (
    call :log "Название: %OS_NAME%"
    call :log "Версия: %OS_VER%"
) else (
    call :log "Не удалось получить сведения об ОС"
)

REM ============================================
REM ПРОЦЕССОР
REM ============================================
call :log ""
call :log "[Процессор]"

set "CPU_NAME="
for /f "tokens=2 delims==" %%a in ('wmic cpu get name /value ^| find "="') do set "CPU_NAME=%%a"
set "CPU_NAME=%CPU_NAME: =%"

if defined CPU_NAME (
    call :log "%CPU_NAME%"
) else (
    call :log "Не удалось получить сведения о процессоре"
)

REM ============================================
REM ОПЕРАТИВНАЯ ПАМЯТЬ
REM ============================================
call :log ""
call :log "[Оперативная память]"

set "RAM_TOTAL_KB="
set "RAM_FREE_KB="
for /f "tokens=2 delims==" %%a in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set "RAM_TOTAL_KB=%%a"
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set "RAM_FREE_KB=%%a"
set "RAM_TOTAL_KB=%RAM_TOTAL_KB: =%"
set "RAM_FREE_KB=%RAM_FREE_KB: =%"

if defined RAM_TOTAL_KB (
    set /a RAM_TOTAL_GB=%RAM_TOTAL_KB% / 1048576
    set /a RAM_FREE_GB=%RAM_FREE_KB% / 1048576
    call :log "Всего памяти (ГБ): %RAM_TOTAL_GB%"
    call :log "Свободно памяти (ГБ): %RAM_FREE_GB%"
) else (
    call :log "Не удалось получить сведения о памяти"
)

REM ============================================
REM ДИСК C
REM ============================================
call :log ""
call :log "[Диск C]"

set "DISK_SIZE_B="
set "DISK_FREE_B="
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size /value ^| find "="') do set "DISK_SIZE_B=%%a"
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| find "="') do set "DISK_FREE_B=%%a"
set "DISK_SIZE_B=%DISK_SIZE_B: =%"
set "DISK_FREE_B=%DISK_FREE_B: =%"

if defined DISK_SIZE_B (
    set /a DISK_SIZE_GB=%DISK_SIZE_B% / 1073741824
    set /a DISK_FREE_GB=%DISK_FREE_B% / 1073741824
    call :log "Всего на диске C (ГБ): %DISK_SIZE_GB%"
    call :log "Свободно на диске C (ГБ): %DISK_FREE_GB%"
) else (
    call :log "Не удалось получить сведения о диске C"
)

REM ============================================
REM УСТАНОВЛЕННЫЕ ПРОГРАММЫ
REM ============================================
call :log ""
call :log "========================================"
call :log "       Установленные программы"
call :log "========================================"

call :log ""
call :log "Идёт поиск программ, это может занять несколько минут..."

REM Создаём временный файл со списком программ
set "APPS_FILE=%TEMP%\apps_list.txt"
if exist "%APPS_FILE%" del "%APPS_FILE%"

REM Получаем список программ через wmic
wmic product get name /value | findstr "=" > "%APPS_FILE%"

REM Выводим программы
for /f "tokens=2 delims==" %%a in ("%APPS_FILE%") do (
    call :log "%%a"
)

REM ============================================
REM АНАЛИЗ: НЕДОСТАЮЩЕЕ ПО
REM ============================================
call :log ""
call :log "========================================"
call :log "   АНАЛИЗ: НЕДОСТАЮЩЕЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ"
call :log "========================================"

REM Проверяем наличие офисного пакета
set "HAS_OFFICE=0"
findstr /I /C:"Office" /C:"LibreOffice" /C:"OpenOffice" /C:"МойОфис" "%APPS_FILE%" >nul 2>&1 && set "HAS_OFFICE=1"

if %HAS_OFFICE%==0 (
    call :log ""
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Офисный пакет"
    call :log "Не обнаружен офисный пакет. Рекомендуется установить Microsoft Office, LibreOffice или другой офисный пакет для работы с документами."
) else (
    call :log ""
    call :log "[OK] Офисный пакет найден"
)

REM Проверяем наличие браузера
set "HAS_BROWSER=0"
findstr /I /C:"Chrome" /C:"Firefox" /C:"Yandex" /C:"Edge" /C:"Opera" "%APPS_FILE%" >nul 2>&1 && set "HAS_BROWSER=1"

if %HAS_BROWSER%==0 (
    call :log ""
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Веб-браузер"
    call :log "Не обнаружен веб-браузер. Рекомендуется установить Google Chrome, Mozilla Firefox или Яндекс.Браузер."
) else (
    call :log ""
    call :log "[OK] Веб-браузер найден"
)

REM Проверяем наличие PDF-ридера
set "HAS_PDF=0"
findstr /I /C:"Acrobat" /C:"Foxit" /C:"SumatraPDF" /C:"PDF" "%APPS_FILE%" >nul 2>&1 && set "HAS_PDF=1"

if %HAS_PDF%==0 (
    call :log ""
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Программа для чтения PDF"
    call :log "Не обнаружена программа для чтения PDF. Рекомендуется установить Adobe Acrobat Reader, Foxit Reader или SumatraPDF."
) else (
    call :log ""
    call :log "[OK] Программа для чтения PDF найдена"
)

REM Проверяем наличие архиватора
set "HAS_ARCHIVER=0"
findstr /I /C:"7-Zip" /C:"WinRAR" /C:"WinZip" /C:"7zip" /C:"7z" "%APPS_FILE%" >nul 2>&1 && set "HAS_ARCHIVER=1"

if %HAS_ARCHIVER%==0 (
    call :log ""
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Архиватор"
    call :log "Не обнаружен архиватор. Для работы с вложениями в почте и сжатыми файлами рекомендуется установить 7-Zip или WinRAR."
) else (
    call :log ""
    call :log "[OK] Архиватор найден"
)

REM ============================================
REM АНАЛИЗ: ИЗЛИШНЕЕ ПО
REM ============================================
call :log ""
call :log "========================================"
call :log "   АНАЛИЗ: ПРОГРАММЫ, ТРЕБУЮЩИЕ ПРОВЕРКИ"
call :log "========================================"

REM Игровые платформы
call :log ""
call :log "[ИГРОВЫЕ ПЛАТФОРМЫ]"
set "HAS_GAMES=0"
findstr /I /C:"Steam" /C:"Epic Games" /C:"GOG" /C:"Origin" /C:"Ubisoft" /C:"Battle.net" /C:"Riot" /C:"Game" /C:"Gaming" "%APPS_FILE%" >nul 2>&1 && set "HAS_GAMES=1"

if %HAS_GAMES%==1 (
    call :log "Найдены игровые платформы или игры:"
    findstr /I /C:"Steam" /C:"Epic Games" /C:"GOG" /C:"Origin" /C:"Ubisoft" /C:"Battle.net" /C:"Riot" /C:"Game" /C:"Gaming" "%APPS_FILE%" | findstr "="
    call :log "Рекомендуется проверить, установлены ли они по согласованию с руководством."
) else (
    call :log "Игровые платформы не найдены"
)

REM Торрент-клиенты
call :log ""
call :log "[ТОРРЕНТ-КЛИЕНТЫ]"
set "HAS_TORRENT=0"
findstr /I /C:"uTorrent" /C:"BitTorrent" /C:"qBittorrent" /C:"Vuze" /C:"Torrent" "%APPS_FILE%" >nul 2>&1 && set "HAS_TORRENT=1"

if %HAS_TORRENT%==1 (
    call :log "Найдены торрент-клиенты:"
    findstr /I /C:"uTorrent" /C:"BitTorrent" /C:"qBittorrent" /C:"Vuze" /C:"Torrent" "%APPS_FILE%" | findstr "="
    call :log "Внимание: такие программы создают нагрузку на сеть и могут быть источником нежелательного ПО."
) else (
    call :log "Торрент-клиенты не найдены"
)

REM Мессенджеры
call :log ""
call :log "[МЕССЕНДЖЕРЫ]"
set "HAS_MESSENGER=0"
findstr /I /C:"Discord" /C:"Telegram" /C:"WhatsApp" /C:"Viber" /C:"Skype" "%APPS_FILE%" >nul 2>&1 && set "HAS_MESSENGER=1"

if %HAS_MESSENGER%==1 (
    call :log "Найдены мессенджеры:"
    findstr /I /C:"Discord" /C:"Telegram" /C:"WhatsApp" /C:"Viber" /C:"Skype" "%APPS_FILE%" | findstr "="
    call :log "Рекомендуется проверить, используются ли они для рабочих задач."
) else (
    call :log "Мессенджеры не найдены"
)

REM ============================================
REM ЗАВЕРШЕНИЕ
REM ============================================
call :log ""
call :log "========================================"
call :log "Отчёт сохранён в файл: %REPORT%"
call :log "========================================"

REM Удаляем временный файл
if exist "%APPS_FILE%" del "%APPS_FILE%"

pause
