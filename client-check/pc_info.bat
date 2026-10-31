@echo off
chcp 65001 >nul

REM Тема: Диагностика клиентского компьютера
REM Фамилия: Жбанникова
REM Дата: 31.10.2026

set "REPORT=%~dp0pc_report.txt"
if exist "%REPORT%" del "%REPORT%"

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
wmic product get name /format:list | findstr "=" > temp_programs.txt
for /f "tokens=2 delims==" %%a in (temp_programs.txt) do (
    echo %%a
    echo %%a >> "%REPORT%"
)
del temp_programs.txt

echo.
echo ========================================
echo Отчёт сохранён в файл: pc_report.txt
echo ========================================
echo. >> "%REPORT%"
echo Отчёт сохранён. >> "%REPORT%"

pause