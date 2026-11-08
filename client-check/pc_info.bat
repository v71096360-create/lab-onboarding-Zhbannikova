@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM Тема: Диагностика клиентского компьютера (Часть 2 - Анализ)
REM Фамилия: Жбанникова
REM Дата: 08.11.2026

REM ============================================
REM 1. ПОДПРОГРАММА ДЛЯ ВЫВОДА (DRY принцип)
REM Устраняет дублирование: один вызов выводит и на экран, и в файл
REM ============================================
:log
echo(%~1
echo(%~1 >> "%REPORT%"
exit /b

REM ============================================
REM 2. ИНИЦИАЛИЗАЦИЯ И ВРЕМЕННАЯ МЕТКА
REM ============================================
set "REPORT=%~dp0pc_report.txt"
if exist "%REPORT%" del "%REPORT%"

call :log "========================================"
call :log "       Диагностика компьютера"
call :log "========================================"

REM Получаем дату и время (защита от пустых значений)
set "DT="
for /f "tokens=2 delims==" %%a in ('wmic OS get LocalDateTime /value ^| find "="') do set "DT=%%a"
if defined DT (
    set "DT=!DT:~0,8! !DT:~8,6!"
    call :log "Дата и время проверки: !DT!"
) else (
    call :log "Дата и время проверки: не удалось определить"
)

REM ============================================
REM 3. СБОР ДАННЫХ С ЗАЩИТОЙ ОТ ПУСТЫХ ЗНАЧЕНИЙ
REM ============================================

REM Операционная система
call :log ""
call :log "[Операционная система]"
set "OS_NAME="
set "OS_VER="
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value ^| find "="') do set "OS_NAME=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /value ^| find "="') do set "OS_VER=%%a"
set "OS_NAME=!OS_NAME: =!"
set "OS_VER=!OS_VER: =!"
if defined OS_NAME (
    call :log "Название: !OS_NAME!"
    call :log "Версия: !OS_VER!"
) else (
    call :log "Не удалось получить сведения об ОС"
)

REM Процессор
call :log ""
call :log "[Процессор]"
set "CPU_NAME="
for /f "tokens=2 delims==" %%a in ('wmic cpu get name /value ^| find "="') do set "CPU_NAME=%%a"
set "CPU_NAME=!CPU_NAME: =!"
if defined CPU_NAME (
    call :log "!CPU_NAME!"
) else (
    call :log "Не удалось получить сведения о процессоре"
)

REM Оперативная память
call :log ""
call :log "[Оперативная память]"
set "RAM_TOTAL_KB="
set "RAM_FREE_KB="
for /f "tokens=2 delims==" %%a in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set "RAM_TOTAL_KB=%%a"
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set "RAM_FREE_KB=%%a"
set "RAM_TOTAL_KB=!RAM_TOTAL_KB: =!"
set "RAM_FREE_KB=!RAM_FREE_KB: =!"
if defined RAM_TOTAL_KB (
    set /a RAM_TOTAL_GB=!RAM_TOTAL_KB! / 1048576
    set /a RAM_FREE_GB=!RAM_FREE_KB! / 1048576
    call :log "Всего памяти (ГБ): !RAM_TOTAL_GB!"
    call :log "Свободно памяти (ГБ): !RAM_FREE_GB!"
) else (
    call :log "Не удалось получить сведения о памяти"
)

REM Диск C (через PowerShell для избежания переполнения разрядной сетки)
call :log ""
call :log "[Диск C]"
set "DISK_SIZE_GB="
set "DISK_FREE_GB="
for /f %%a in ('powershell -Command "[math]::Round((Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=\"C:\"').Size / 1GB, 0)"') do set "DISK_SIZE_GB=%%a"
for /f %%a in ('powershell -Command "[math]::Round((Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=\"C:\"').FreeSpace / 1GB, 0)"') do set "DISK_FREE_GB=%%a"
if defined DISK_SIZE_GB (
    call :log "Всего на диске C (ГБ): !DISK_SIZE_GB!"
    call :log "Свободно на диске C (ГБ): !DISK_FREE_GB!"
) else (
    call :log "Не удалось получить сведения о диске C"
)

REM ============================================
REM 4. ФОРМИРОВАНИЕ СПИСКА ПРОГРАММ (БЫСТРЫЙ reg query)
REM Опрос обеих веток реестра (64-бит и 32-бит)
REM ============================================
call :log ""
call :log "========================================"
call :log "       Установленные программы"
call :log "========================================"
call :log ""
call :log "Идёт быстрый опрос реестра..."

set "APPS_FILE=%TEMP%\apps_list.txt"
if exist "%APPS_FILE%" del "%APPS_FILE%"

REM 64-битные программы
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul') do (
    echo %%B >> "%APPS_FILE%"
)

REM 32-битные программы (WOW6432Node)
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul') do (
    echo %%B >> "%APPS_FILE%"
)

REM Выводим список программ в отчёт
call :log "Список программ:"
for /f "usebackq delims=" %%A in ("%APPS_FILE%") do (
    call :log "  - %%A"
)

REM ============================================
REM 5. АНАЛИЗ: НЕДОСТАЮЩЕЕ ПО
REM ============================================
call :log ""
call :log "========================================"
call :log "   АНАЛИЗ: НЕДОСТАЮЩЕЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ"
call :log "========================================"

call :log ""
call :log "[Проверка офисного пакета]"
findstr /I "Office LibreOffice OpenOffice" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Офисный пакет не обнаружен. Рекомендуется установить Microsoft Office или LibreOffice."
) else (
    call :log "[OK] Офисный пакет найден"
)

call :log ""
call :log "[Проверка веб-браузера]"
findstr /I "Chrome Firefox Yandex Edge Opera" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Веб-браузер не обнаружен. Рекомендуется установить Google Chrome или Firefox."
) else (
    call :log "[OK] Веб-браузер найден"
)

call :log ""
call :log "[Проверка программы для чтения PDF]"
findstr /I "Acrobat Foxit SumatraPDF PDF" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Программа для чтения PDF не обнаружена. Рекомендуется установить Adobe Acrobat Reader."
) else (
    call :log "[OK] Программа для чтения PDF найдена"
)

call :log ""
call :log "[Проверка архиватора]"
findstr /I "7-Zip WinRAR WinZip" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "[ТРЕБУЕТ ВНИМАНИЯ] Архиватор не обнаружен. Рекомендуется установить 7-Zip или WinRAR."
) else (
    call :log "[OK] Архиватор найден"
)

REM ============================================
REM 6. АНАЛИЗ: ИЗЛИШНЕЕ ПО
REM ============================================
call :log ""
call :log "========================================"
call :log "   АНАЛИЗ: ПРОГРАММЫ, ТРЕБУЮЩИЕ ПРОВЕРКИ"
call :log "========================================"

call :log ""
call :log "[Игровые платформы]"
findstr /I "Steam Epic GOG Origin Game Gaming" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "Игровые платформы не найдены"
) else (
    call :log "Найдены игровые платформы или игры:"
    findstr /I "Steam Epic GOG Origin Game Gaming" "%APPS_FILE%"
    call :log "Рекомендуется проверить, установлены ли они по согласованию с руководством."
)

call :log ""
call :log "[Торрент-клиенты]"
findstr /I "uTorrent BitTorrent qBittorrent Torrent" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "Торрент-клиенты не найдены"
) else (
    call :log "Найдены торрент-клиенты:"
    findstr /I "uTorrent BitTorrent qBittorrent Torrent" "%APPS_FILE%"
    call :log "Внимание: такие программы создают нагрузку на сеть."
)

call :log ""
call :log "[Мессенджеры]"
findstr /I "Discord Telegram WhatsApp Viber Skype" "%APPS_FILE%" >nul 2>&1
if errorlevel 1 (
    call :log "Мессенджеры не найдены"
) else (
    call :log "Найдены мессенджеры:"
    findstr /I "Discord Telegram WhatsApp Viber Skype" "%APPS_FILE%"
    call :log "Рекомендуется проверить, используются ли они для рабочих задач."
)

REM ============================================
REM 7. ЗАВЕРШЕНИЕ И ОЧИСТКА
REM ============================================
call :log ""
call :log "========================================"
call :log "Отчёт сохранён в файл: %REPORT%"
call :log "========================================"

REM Удаление временного файла
if exist "%APPS_FILE%" del "%APPS_FILE%"

pause
