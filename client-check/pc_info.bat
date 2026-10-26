@echo off
chcp 65001

REM =====================================================
REM Практическая работа 8. Диагностика клиентского ПК
REM Выполнила: Жбанникова
REM Дата: 2026
REM =====================================================

cls

REM Создаём путь к файлу отчёта (рядом с bat-файлом)
set "REPORT_FILE=%~dp0pc_report.txt"

REM Очищаем файл отчёта
echo. > "%REPORT_FILE%"

REM =====================================================
echo ====================================================
echo           ДИАГНОСТИКА КОМПЬЮТЕРА
echo ====================================================
echo.

REM =====================================================
echo ОПЕРАЦИОННАЯ СИСТЕМА
echo =====================================================

for /f "tokens=1,2 delims==" %%a in ('wmic os get Caption^,Version /format:list ^| findstr "="') do (
    if "%%a"=="Caption" set "OS_NAME=%%b"
    if "%%a"=="Version" set "OS_VERSION=%%b"
)

echo Операционная система: %OS_NAME%
echo Версия: %OS_VERSION%
echo.

REM =====================================================
echo ПРОЦЕССОР
echo =====================================================

for /f "skip=1 delims=" %%a in ('wmic cpu get name') do (
    if not defined CPU_NAME set "CPU_NAME=%%a"
)

echo Процессор: %CPU_NAME%
echo.

REM =====================================================
echo ОПЕРАТИВНАЯ ПАМЯТЬ
echo =====================================================

for /f "tokens=1,2 delims= " %%a in ('wmic OS get TotalVisibleMemorySize^,FreePhysicalMemory /format:list ^| findstr "TotalVisibleMemorySize FreePhysicalMemory"') do (
    if "%%a"=="TotalVisibleMemorySize" set "TOTAL_KB=%%b"
    if "%%a"=="FreePhysicalMemory" set "FREE_KB=%%b"
)

set /a TOTAL_GB=%TOTAL_KB% / 1048576
set /a FREE_GB=%FREE_KB% / 1048576

echo Всего памяти: %TOTAL_GB% ГБ
echo Свободно памяти: %FREE_GB% ГБ
echo.

REM =====================================================
echo ДИСК C
echo =====================================================

for /f "tokens=1,2 delims= " %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size^,FreeSpace /format:list ^| findstr "Size FreeSpace"') do (
    if "%%a"=="Size" set "DISK_SIZE=%%b"
    if "%%a"=="FreeSpace" set "DISK_FREE=%%b"
)

set /a DISK_SIZE_GB=%DISK_SIZE% / 1073741824
set /a DISK_FREE_GB=%DISK_FREE% / 1073741824

echo Общий размер: %DISK_SIZE_GB% ГБ
echo Свободно: %DISK_FREE_GB% ГБ
echo.

REM =====================================================
echo УСТАНОВЛЕННЫЕ ПРОГРАММЫ
echo =====================================================
echo.
echo Идёт поиск программ, это может занять несколько минут...
echo.

wmic product get name,version /format:list | findstr "Name=" | findstr /v "Microsoft" | findstr /v "Windows"

echo.
echo ====================================================
echo Отчёт сохранён в файле pc_report.txt
echo ====================================================
echo.

pause
