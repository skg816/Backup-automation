
@echo off
title Install backup
setlocal enabledelayedexpansion

rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
rem *+*+*+*+* Install_backup.bat v1.0 authored by  STARODUBCEV K.G. *+*+*+*+*
rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

echo.
echo КОМАНДНЫЙ ФАЙЛ ДЛЯ РАЗВЕРТЫВАНИЯ СИСТЕМЫ РЕЗЕРВНОГО КОПИРОВАНИЯ
echo.
echo.

rem ********** ОПРЕДЕЛЯЕМ ВЕРСИЮ ОПЕРАЦИОННОЙ СИСТЕМЫ **********
ver > Output.txt
set IS_2003=0
set VERSION=
for /f "tokens=4 skip=1" %%i in (Output.txt) do (
    set VERSION=%%i
)
set VERSION=%VERSION:~0,1%
if %VERSION%==5 set IS_2003=1
if exist Output.txt del /q Output.txt
rem ********** ОПРЕДЕЛЯЕМ ВЕРСИЮ ОПЕРАЦИОННОЙ СИСТЕМЫ **********



rem ********** ОПРЕДЕЛЯЕМ НАСТРОЕНА ЛИ ОБВЯЗКА **********
schtasks > Output.txt
set IS_BASIC_EXIST=0
for /f "skip=3" %%i in (Output.txt) do (
    if /i %%i==01_Start_backup set IS_BASIC_EXIST=1
)
if exist Output.txt del /q Output.txt
rem ********** ОПРЕДЕЛЯЕМ НАСТРОЕНА ЛИ ОБВЯЗКА **********



rem ********** ЧИТАЕМ ЛИБО ЗАПРАШИВАЕМ ПАРАМЕТРЫ ОБВЯЗКИ **********
echo 1. НАЧИНАЕМ СБОР ПЕРВОНАЧАЛЬНЫХ ДАННЫХ
echo.
if %IS_BASIC_EXIST%==1 goto :A
if %IS_BASIC_EXIST%==0 goto :B
:A
set DISK_LETTER=
set START_TIME=
set USER_NAME=
schtasks /query /fo csv /v > Output.txt
set TEMP_1=
set TEMP_2=
for /f "delims=*" %%i in (Output.txt) do (
    set TEMP_1=%%i
    set TEMP_2=!TEMP_1:","","=","TERMINATOR","!
    set TEMP_2=!TEMP_2:","=*!
    echo !TEMP_2! >> Output_2.txt
)
if %IS_2003%==1 goto :C
if %IS_2003%==0 goto :E
:C
for /f "delims=* tokens=2,10,15,20" %%i in (Output_2.txt) do (
    if /i %%i==01_Start_backup set DISK_LETTER=%%j
    if /i %%i==01_Start_backup set START_TIME=%%k
    if /i %%i==01_Start_backup set USER_NAME=%%l
)
goto :F
:E
for /f "delims=* tokens=2,9,15,20" %%i in (Output_2.txt) do (
    if /i %%i==\01_Start_backup set DISK_LETTER=%%j
    if /i %%i==\01_Start_backup set START_TIME=%%l
    if /i %%i==\01_Start_backup set USER_NAME=%%k
)
:F
set DISK_LETTER=%DISK_LETTER:~0,1%
set TEMP_1=%START_TIME:~1,1%
if %TEMP_1%==: set START_TIME=0%START_TIME%
if exist Output.txt del /q Output.txt
if exist Output_2.txt del /q Output_2.txt
:G
set USER_PASS_OK=0
set USER_PASS=
set TASK_NAME=%RANDOM%
set PROC=%PROCESSOR_ARCHITECTURE:~-2%
cd Other
if %PROC%==86 editv32 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
if %PROC%==64 editv64 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
cd ..
if not defined USER_PASS echo *     ОШИБКА. Неверный пароль & goto :G
schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st 23:00 /tn %TASK_NAME% /tr %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat /f > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set USER_PASS_OK=1
    if /i %%i==SUCCESS: set USER_PASS_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set USER_PASS_OK=0
    if /i %%i==WARNING: set USER_PASS_OK=0
)
schtasks /delete /tn %TASK_NAME% /f > Output.txt 2>>&1
if %USER_PASS_OK%==0 echo *     ОШИБКА. Неверный пароль & goto :G
if %USER_PASS_OK%==1 echo *     OK
if exist Output.txt del /q Output.txt
goto :END1
:B
set DISK_LETTER=
set /p DISK_LETTER=*     Введите букву диска, где будет находиться папка PPR (пример D): 
if not defined DISK_LETTER echo *     ОШИБКА. Неверная буква диска & goto :B
if not exist %DISK_LETTER%: echo *     ОШИБКА. Неверная буква диска & goto :B
if exist %DISK_LETTER%: echo *     OK
:H
set ACCOUNT_TYPE=
set ACCOUNT_TYPE_OK=0
echo *     Укажите тип учетной записи, которая будет использоваться в задании по
set /p ACCOUNT_TYPE=*     расписанию: 1 - локальная учетная запись, 2 - доменная учетная запись: 
if not defined ACCOUNT_TYPE echo *     ОШИБКА. Неверное значение & goto :H
for %%i in (1 2) do (if !ACCOUNT_TYPE!==%%i set ACCOUNT_TYPE_OK=1)
if %ACCOUNT_TYPE_OK%==0 echo *     ОШИБКА. Неверное значение & goto :H
if %ACCOUNT_TYPE_OK%==1 echo *     OK
:I
set USER_NAME=
set USER_NAME_OK=0
set /p USER_NAME=*     Введите имя учетной записи: 
if not defined USER_NAME echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %ACCOUNT_TYPE%==1 goto :J
if %ACCOUNT_TYPE%==2 goto :K
:J
net user > Output.txt
for /f "tokens=1,2,3 skip=4" %%i in (Output.txt) do (
    if /i !USER_NAME!==%%i set USER_NAME_OK=1
    if /i !USER_NAME!==%%j set USER_NAME_OK=1
    if /i !USER_NAME!==%%k set USER_NAME_OK=1
)
if %USER_NAME_OK%==0 echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %USER_NAME_OK%==1 echo *     OK
set USER_NAME=%COMPUTERNAME%\%USER_NAME%
if exist Output.txt del /q Output.txt
goto :L
:K
if %IS_2003%==0 servermanagercmd -install RSAT-ADDC -allsubfeatures > Output.txt 2>>&1
if exist Output.txt del /q Output.txt
dsquery user -samid %USER_NAME% -o samid > Output.txt
for /f %%i in (Output.txt) do (if /i "!USER_NAME!"==%%i set USER_NAME_OK=1)
if %USER_NAME_OK%==0 echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %USER_NAME_OK%==1 echo *     OK
set USER_NAME=KAS\%USER_NAME%
if exist Output.txt del /q Output.txt
:L
set USER_PASS=
set USER_PASS_OK=0
set TASK_NAME=%RANDOM%
set PROC=%PROCESSOR_ARCHITECTURE:~-2%
cd Other
if %PROC%==86 editv32 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
if %PROC%==64 editv64 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
cd ..
if not defined USER_PASS echo *     ОШИБКА. Неверный пароль & goto :L
schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st 23:00 /tn %TASK_NAME% /tr %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set USER_PASS_OK=1
    if /i %%i==SUCCESS: set USER_PASS_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set USER_PASS_OK=0
    if /i %%i==WARNING: set USER_PASS_OK=0
)
schtasks /delete /tn %TASK_NAME% /f > Output.txt 2>>&1
if %USER_PASS_OK%==0 echo *     ОШИБКА. Неверный пароль & goto :L
if %USER_PASS_OK%==1 echo *     OK
if exist Output.txt del /Q Output.txt
:M
set START_TIME=
set START_TIME_OK=0
set /p START_TIME=*     Введите время старта резервного копирования (пример ЧЧ:ММ): 
set START_TIME=%START_TIME:~0,5%
set FIRST=%START_TIME:~0,1%
set SECOND=%START_TIME:~1,1%
set THIRD=%START_TIME:~2,1%
set FOURTH=%START_TIME:~3,1%
set FIFTH=%START_TIME:~4,1%
set HH=%START_TIME:~0,2%
set MM=%START_TIME:~3,2%
if not defined FIRST echo *     ОШИБКА. Неверное значение & goto :M
if not defined SECOND echo *     ОШИБКА. Неверное значение & goto :M
if not defined THIRD echo *     ОШИБКА. Неверное значение & goto :M
if not defined FOURTH echo *     ОШИБКА. Неверное значение & goto :M
if not defined FIFTH echo *     ОШИБКА. Неверное значение & goto :M
for %%i in (0 1 2) do (if !FIRST!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
for %%i in (0 1 2 3 4 5 6 7 8 9) do (if !SECOND!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
if not %THIRD%==: echo *     ОШИБКА. Неверное значение & goto :M
for %%i in (0 1 2 3 4 5) do (if !FOURTH!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
for %%i in (0 1 2 3 4 5 6 7 8 9) do (if !FIFTH!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
if %HH% GTR 23 echo *     ОШИБКА. Неверное значение & goto :M
if %MM% GTR 59 echo *     ОШИБКА. Неверное значение & goto :M
echo *     OK
:END1
echo.
echo *     РЕЗЮМЕ:
echo *     Местоположение папки PPR - Диск %DISK_LETTER%
echo *     Запускать резервное копирование от имени пользователя - %USER_NAME%
echo *     Запускать резервное копирование в - %START_TIME%
echo.
rem ********** ЧИТАЕМ ЛИБО ЗАПРАШИВАЕМ ПАРАМЕТРЫ ОБВЯЗКИ **********



rem ********** ПЕРВОНАЧАЛЬНАЯ НАСТРОЙКА **********
echo.
echo 2. НАЧИНАЕМ ПЕРВОНАЧАЛЬНУЮ НАСТРОЙКУ
echo.
if not exist %DISK_LETTER%:\PPR mkdir %DISK_LETTER%:\PPR > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR echo *     Папка %DISK_LETTER%:\PPR - OK
if not exist %DISK_LETTER%:\PPR echo *     Папка %DISK_LETTER%:\PPR - ОШИБКА. Папка не создана & type Output.txt
if not exist %DISK_LETTER%:\PPR\Backup mkdir %DISK_LETTER%:\PPR\Backup > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup echo *     Папка %DISK_LETTER%:\PPR\Backup - OK
if not exist %DISK_LETTER%:\PPR\Backup echo *     Папка %DISK_LETTER%:\PPR\Backup - ОШИБКА. Папка не создана & type Output.txt
if not exist %DISK_LETTER%:\PPR\Backup\BAT mkdir %DISK_LETTER%:\PPR\Backup\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\BAT echo *     Папка %DISK_LETTER%:\PPR\Backup\BAT - OK
if not exist %DISK_LETTER%:\PPR\Backup\BAT echo *     Папка %DISK_LETTER%:\PPR\Backup\BAT - ОШИБКА. Папка не создана & type Output.txt
if exist Output.txt del /q Output.txt
cd BAT
if not exist %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat copy /v /y Backup.bat %DISK_LETTER%:\PPR\Backup\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat echo *     Файл %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat - OK
if not exist %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat echo *     Файл %DISK_LETTER%:\PPR\Backup\BAT\Backup.bat - ОШИБКА. Файл не скопирован & type Output.txt
if not exist %DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat copy /v /y Start_backup.bat %DISK_LETTER%:\PPR\Backup\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat echo *     Файл %DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat - OK
if not exist %DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat echo *     Файл %DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat - ОШИБКА. Файл не скопирован & type Output.txt
if exist Output.txt del /q Output.txt
cd ..
if not exist %DISK_LETTER%:\PPR\Backup\LOG mkdir %DISK_LETTER%:\PPR\Backup\LOG > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\LOG echo *     Папка %DISK_LETTER%:\PPR\Backup\LOG - OK
if not exist %DISK_LETTER%:\PPR\Backup\LOG echo *     Папка %DISK_LETTER%:\PPR\Backup\LOG - ОШИБКА. Папка не создана & type Output.txt
if exist Output.txt del /q Output.txt
cd Blat
if not exist C:\Windows\Blat mkdir C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat echo *     Папка C:\Windows\Blat - OK
if not exist C:\Windows\Blat echo *     Папка C:\Windows\Blat - ОШИБКА. Папка не создана & type Output.txt
if not exist C:\Windows\Blat\address.txt copy /V /Y address.txt C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\address.txt echo *     Файл C:\Windows\Blat\Address.txt - OK
if not exist C:\Windows\Blat\address.txt echo *     Файл C:\Windows\Blat\Address.txt - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.dll copy /V /Y blat.dll C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.dll echo *     Файл C:\Windows\Blat\Blat.dll - OK
if not exist C:\Windows\Blat\blat.dll echo *     Файл C:\Windows\Blat\Blat.dll - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.exe copy /V /Y blat.exe C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.exe echo *     Файл C:\Windows\Blat\Blat.exe - OK
if not exist C:\Windows\Blat\blat.exe echo *     Файл C:\Windows\Blat\Blat.exe - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.lib copy /V /Y blat.lib C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.lib echo *     Файл C:\Windows\Blat\Blat.lib - OK
if not exist C:\Windows\Blat\blat.lib echo *     Файл C:\Windows\Blat\Blat.lib - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\mail.log copy /V /Y mail.log C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\mail.log echo *     Файл C:\Windows\Blat\Mail.log - OK
if not exist C:\Windows\Blat\mail.log echo *     Файл C:\Windows\Blat\Mail.log - ОШИБКА. Файл не создан & type Output.txt
if exist Output.txt del /q Output.txt
set MAIL_OK=0
C:\Windows\Blat\Blat.exe -install 10.167.31.1 PPR@%COMPUTERNAME%.message 5 25 > Output.txt 2>>&1
if not %ERRORLEVEL%==0 set MAIL_OK=1
if %MAIL_OK%==0 echo *     Настройки почты - ОК
if %MAIL_OK%==1 echo *     Настройки почты - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
cd ..
if %IS_BASIC_EXIST%==1 goto :END2
if %IS_2003%==1 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st %START_TIME% /tn 01_Start_backup /tr "%DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat" > Output.txt 2>>&1
if %IS_2003%==0 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st %START_TIME% /tn 01_Start_backup /tr "%DISK_LETTER%:\PPR\Backup\BAT\Start_backup.bat" /rl highest > Output.txt 2>>&1
set IS_BASIC_EXIST=0
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set IS_BASIC_EXIST=1
    if /i %%i==SUCCESS: set IS_BASIC_EXIST=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set IS_BASIC_EXIST=0
    if /i %%i==WARNING: set IS_BASIC_EXIST=0
)
:END2
if %IS_BASIC_EXIST%==1 echo *     Задание по расписанию 01_Start_backup - OK
if %IS_BASIC_EXIST%==0 echo *     Задание по расписанию 01_Start_backup - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
echo.
rem ********** ПЕРВОНАЧАЛЬНАЯ НАСТРОЙКА **********



rem ********** ОКОНЧАТЕЛЬНАЯ НАСТРОЙКА **********
echo.
echo 3. НАЧИНАЕМ ОКОНЧАТЕЛЬНУЮ НАСТРОЙКУ
echo.
:N
set BACKUP_TYPE=
set BACKUP_TYPE_OK=0
echo *     Выберите тип резервного копирования: 
echo *     1  - Резервное копирование системного диска
echo *     2  - Резервное копирование конфигурации UserGate
echo *     3  - Архивирование логов UserGate
echo *     4  - Резервное копирование конфигурации MDaemon
echo *     5  - Архивирование логов MDaemon
echo *     6  - Архивирование логов ISA
echo *     7  - Резервное копирование состояния системы
echo *     8  - Полная резервная копия папки "Архив"
echo *     9  - Дневная резервная копия папки "Архив"
echo *     10 - Полная резервная копия папки "Техархив"
echo *     11 - Дневная резервная копия папки "Техархив"
echo *     12 - Полная резервная копия папки "ЦППОА"
echo *     13 - Дневная резервная копия папки "ЦППОА"
echo *     14 - Полная резервная копия папки "ABN"
echo *     15 - Полная резервная копия папки "Папки общего доступа"
echo *     16 - Дневная резервная копия папки "Папки общего доступа"
echo *     17 - Полная резервная копия папки "Камзин_Ж.Ж"
echo *     18 - Дневная резервная копия папки "Камзин_Ж.Ж"
echo *     19 - Резервное копирование базы данных SQL
echo *     20 - Резервное копирование конфигурации WSUS
echo *     21 - Резервное копирование базы данных MySQL
echo *     22 - Резервное копирование конфигурации Kaspersky Server
set /p BACKUP_TYPE=*     
if not defined BACKUP_TYPE echo *     ОШИБКА. Неверный тип резервного копирования & goto :N
for %%i in (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22) do (if !BACKUP_TYPE!==%%i set BACKUP_TYPE_OK=1)
if %BACKUP_TYPE_OK%==0 echo *     ОШИБКА. Неверный тип резервного копирования & goto :N
schtasks > Output.txt
set TASK_NAME=
set BACKUP_TYPE_OK=1
for /f "skip=3" %%i in (Output.txt) do (
    set TASK_NAME=%%i
    set TASK_NAME=!TASK_NAME:~2!
    if !BACKUP_TYPE!==1 if /i !TASK_NAME!==_Backup_System_image set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==2 if /i !TASK_NAME!==_Backup_UG_config set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==3 if /i !TASK_NAME!==_Backup_UG_log set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==4 if /i !TASK_NAME!==_Backup_MD_config set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==5 if /i !TASK_NAME!==_Backup_MD_log set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==6 if /i !TASK_NAME!==_Backup_ISA_log set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==7 if /i !TASK_NAME!==_Backup_System_state set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==8 if /i !TASK_NAME!==_Backup_Archive_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==9 if /i !TASK_NAME!==_Backup_Archive_daily set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==10 if /i !TASK_NAME!==_Backup_TechArchive_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==11 if /i !TASK_NAME!==_Backup_TechArchive_daily set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==12 if /i !TASK_NAME!==_Backup_CPPOA_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==13 if /i !TASK_NAME!==_Backup_CPPOA_daily set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==14 if /i !TASK_NAME!==_Backup_ABN_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==15 if /i !TASK_NAME!==_Backup_Papki_obshego_dostupa_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==16 if /i !TASK_NAME!==_Backup_Papki_obshego_dostupa_daily set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==17 if /i !TASK_NAME!==_Backup_Kamzin_full set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==18 if /i !TASK_NAME!==_Backup_Kamzin_daily set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==19 if /i !TASK_NAME!==_Backup_SQL set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==20 if /i !TASK_NAME!==_Backup_WSUS set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==21 if /i !TASK_NAME!==_Backup_MySQL set BACKUP_TYPE_OK=0
    if !BACKUP_TYPE!==22 if /i !TASK_NAME!==_Backup_KAV set BACKUP_TYPE_OK=0
)
if %BACKUP_TYPE_OK%==0 echo *     ОШИБКА. Задание по расписанию для данного типа резервного копирования уже существует & goto :N
if %BACKUP_TYPE_OK%==1 echo *     OK
if exist Output.txt del /q Output.txt
:T
set SERVER_FOLDER=
set SERVER_FOLDER_OK=0
set /p SERVER_FOLDER=*     Введите имя шареной папки на сервере резервного копирования: 
if not defined SERVER_FOLDER echo *     ОШИБКА. Неверное имя папки & goto :T
if exist \\10.167.31.8\%SERVER_FOLDER% set SERVER_FOLDER_OK=1
if exist \\10.167.31.9\%SERVER_FOLDER% set SERVER_FOLDER_OK=1
if %SERVER_FOLDER_OK%==0 echo *     ОШИБКА. Имя папки задано неверно либо к папке нет доступа & goto :T
if %SERVER_FOLDER_OK%==1 echo *     OK
:U
set SAVE_LOCALY=
set SAVE_LOCALY_OK=0
echo *     Где сохранять резервные копии:
echo *     1 - только на сервере резервного копирования
echo *     2 - локально и на сервере резервного копирования
set /p SAVE_LOCALY=*     
if not defined SAVE_LOCALY echo *     ОШИБКА. Неверное значение & goto :U
for %%i in (1 2) do (if !SAVE_LOCALY!==%%i set SAVE_LOCALY_OK=1)
if %SAVE_LOCALY_OK%==0 echo *     ОШИБКА. Неверное значение & goto :U
if %SAVE_LOCALY_OK%==1 echo *     OK
if %SAVE_LOCALY%==1 set SAVE_LOCALY=server
if %SAVE_LOCALY%==2 set SAVE_LOCALY=both
if %BACKUP_TYPE%==1 set BACKUP_TYPE=System_image& goto :O
if %BACKUP_TYPE%==2 set BACKUP_TYPE=UG_config& goto :END3
if %BACKUP_TYPE%==3 set BACKUP_TYPE=UG_log& goto :END3
if %BACKUP_TYPE%==4 set BACKUP_TYPE=MD_config& goto :END3
if %BACKUP_TYPE%==5 set BACKUP_TYPE=MD_log& goto :END3
if %BACKUP_TYPE%==6 set BACKUP_TYPE=ISA_log& goto :END3
if %BACKUP_TYPE%==7 set BACKUP_TYPE=System_state& goto :END3
if %BACKUP_TYPE%==8 set BACKUP_TYPE=Archive_full& goto :R
if %BACKUP_TYPE%==9 set BACKUP_TYPE=Archive_daily& goto :R
if %BACKUP_TYPE%==10 set BACKUP_TYPE=TechArchive_full& goto :R
if %BACKUP_TYPE%==11 set BACKUP_TYPE=TechArchive_daily& goto :R
if %BACKUP_TYPE%==12 set BACKUP_TYPE=CPPOA_full& goto :R
if %BACKUP_TYPE%==13 set BACKUP_TYPE=CPPOA_daily& goto :R
if %BACKUP_TYPE%==14 set BACKUP_TYPE=ABN_full& goto :R
if %BACKUP_TYPE%==15 set BACKUP_TYPE=Papki_obshego_dostupa_full& goto :R
if %BACKUP_TYPE%==16 set BACKUP_TYPE=Papki_obshego_dostupa_daily& goto :R
if %BACKUP_TYPE%==17 set BACKUP_TYPE=Kamzin_full& goto :R
if %BACKUP_TYPE%==18 set BACKUP_TYPE=Kamzin_daily& goto :R
if %BACKUP_TYPE%==19 set BACKUP_TYPE=SQL& goto :END3
if %BACKUP_TYPE%==20 set BACKUP_TYPE=WSUS& goto :END3
if %BACKUP_TYPE%==21 set BACKUP_TYPE=MySQL& goto :END3
if %BACKUP_TYPE%==22 set BACKUP_TYPE=KAV& goto :END3
:O
set ACRONIS=
set TEMP_1=
set TEMP_2=
set /p ACRONIS=*     Введите полный путь к файлу TrueImageCmd.exe: 
if not defined ACRONIS echo *     ОШИБКА. Неправильный путь && goto :O
set TEMP_1="%ACRONIS%"
if not exist %TEMP_1% echo *     ОШИБКА. Неправильный путь && goto :O
set TEMP_2=%ACRONIS:~-1%
if /i %TEMP_2%==\ set ACRONIS=%ACRONIS:~,-1%
cd Other
setenv -m ACRONIS_PATH "%ACRONIS%" > Output.txt 2>>&1
if not defined ACRONIS echo *     Переменная окружения ACRONIS_PATH - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
if defined ACRONIS_PATH echo *     OK
cd ..
goto :END3
:R
cd BKS
if not exist %DISK_LETTER%:\PPR\Backup\BKS mkdir %DISK_LETTER%:\PPR\Backup\BKS > Output.txt 2>>&1
if not exist %DISK_LETTER%:\PPR\Backup\BKS echo *     Папка %DISK_LETTER%:\PPR\Backup\BKS - ОШИБКА. Папка не создана & type Output.txt
if exist %DISK_LETTER%:\PPR\Backup\BKS echo *     Папка %DISK_LETTER%:\PPR\Backup\BKS - OK
if not exist %DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks copy /v /y %BACKUP_TYPE%.bks %DISK_LETTER%:\PPR\Backup\BKS > Output.txt 2>>&1
if not exist %DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks echo *     Файл %DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks - ОШИБКА. Папка не создана & type Output.txt
if exist %DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks echo *     Файл %DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks - OK
if exist Output.txt del /q Output.txt
cd ..
:END3
set PERIOD_TYPE=
if /i %BACKUP_TYPE%==System_image set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==UG_config set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==UG_log set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==MD_config set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==MD_log set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==ISA_log set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==System_state set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==Archive_full set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==Archive_daily set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==TechArchive_full set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==TechArchive_daily set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==CPPOA_full set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==CPPOA_daily set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==ABN_full set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==Papki_obshego_dostupa_full set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==Papki_obshego_dostupa_daily set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==Kamzin_full set PERIOD_TYPE=monthly /d 1
if /i %BACKUP_TYPE%==Kamzin_daily set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==SQL set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==WSUS set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==MySQL set PERIOD_TYPE=daily
if /i %BACKUP_TYPE%==KAV set PERIOD_TYPE=daily
if %IS_BASIC_EXIST%==1 set START_TIME=%START_TIME:~0,5%
set START_TIME_OK=0
set FIRST=%START_TIME:~0,1%
set SECOND=%START_TIME:~1,1%
set THIRD=%START_TIME:~3,1%
set FOURTH=%START_TIME:~4,1%
for %%i in (8 7 6 5 4 3 2 1 0) do (
    if %%i==!FOURTH! set START_TIME_OK=1
    if %%i==!FOURTH! set /a FOURTH=!FOURTH!+1
)
if %START_TIME_OK%==1 goto :P
if %FOURTH%==9 set FOURTH=0
for %%i in (4 3 2 1 0) do (
    if %%i==!THIRD! set START_TIME_OK=1
    if %%i==!THIRD! set /a THIRD=!THIRD!+1
)
if %START_TIME_OK%==1 goto :P
if %THIRD%==5 set THIRD=0
for %%i in (2 1 0) do (
    if %%i==!SECOND! set START_TIME_OK=1
    if %%i==!SECOND! set /a SECOND=!SECOND!+1
)
if %START_TIME_OK%==1 goto :P
if %SECOND%==3 set SECOND=0
for %%i in (1 0) do (
    if %%i==!FIRST! set START_TIME_OK=1
    if %%i==!FIRST! set /a FIRST=!FIRST!+1
)
if %START_TIME_OK%==1 goto :P
if %FIRST%==2 set FIRST=0
:P
set START_TIME=%FIRST%%SECOND%:%THIRD%%FOURTH%
if not exist %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% mkdir %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% echo *     Папка %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% - OK
if not exist %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% echo *     Папка %DISK_LETTER%:\PPR\Backup\%BACKUP_TYPE% - ОШИБКА. Папка не создана & type Output.txt
if not exist \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% mkdir \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% > Output.txt 2>>&1
if exist \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% echo *     Папка %BACKUP_TYPE% на сервере резервного копирования - OK & goto :S
if not exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% mkdir \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% > Output.txt 2>>&1
if exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% echo *     Папка %BACKUP_TYPE% на сервере резервного копирования - OK
if not exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\%BACKUP_TYPE% echo *     Папка %BACKUP_TYPE% на сервере резервного копирования - ОШИБКА. & type Output.txt
:S
if not exist \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log mkdir \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log > Output.txt 2>>&1
if exist \\10.167.31.8\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log echo *     Папка Backup_log на сервере резервного копирования - OK & goto :V
if not exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log mkdir \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log > Output.txt 2>>&1
if exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log echo *     Папка Backup_log на сервере резервного копирования - OK
if not exist \\10.167.31.9\%SERVER_FOLDER%\%COMPUTERNAME%\Backup_log echo *     Папка Backup_log на сервере резервного копирования - ОШИБКА. & type Output.txt
:V
set TASK_NAME=
set TEMP_1=
set TEMP_2=
set TEMP_3=
set TEMP_4=
set TEMP_5=
set TEMP_6=
schtasks > Output.txt
for /f "skip=3" %%i in (Output.txt) do (
    set TEMP_1=%%i
    set TEMP_2=!TEMP_1:~2,1!
    if !TEMP_2!==_ set TEMP_3=!TEMP_1:~0,2!
    if !TEMP_2!==_ set TEMP_4=!TEMP_1:~2,7!
    if !TEMP_2!==_ set TEMP_5=!TEMP_1:~0,1!
    if !TEMP_2!==_ set TEMP_6=!TEMP_1:~1,1!
    if !TEMP_2!==_ if /i !TEMP_4!==_Backup if !TEMP_5!==0 set /a TEMP_6=!TEMP_6!+1
    if !TEMP_2!==_ if /i !TEMP_4!==_Backup if !TEMP_5!==0 if not !TEMP_6!==10 set TASK_NAME=0!TEMP_6!!TEMP_4!_!BACKUP_TYPE!
    if !TEMP_2!==_ if /i !TEMP_4!==_Backup if !TEMP_5!==0 if !TEMP_6!==10 set TASK_NAME=!TEMP_6!!TEMP_4!_!BACKUP_TYPE!
    if !TEMP_2!==_ if /i !TEMP_4!==_Backup if not !TEMP_5!==0 set /a TEMP_3=!TEMP_3!+1
    if !TEMP_2!==_ if /i !TEMP_4!==_Backup if not !TEMP_5!==0 set TASK_NAME=!TEMP_3!!TEMP_4!_!BACKUP_TYPE!
)
if not defined TASK_NAME set TASK_NAME=02_Backup_%BACKUP_TYPE%
if exist Output.txt del /q Output.txt
set TASK_CREATE_OK=0
if %IS_2003%==1 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc %PERIOD_TYPE% /st %START_TIME% /tn %TASK_NAME% /tr "%DISK_LETTER%:\PPR\Backup\BAT\Backup.bat %BACKUP_TYPE% %SERVER_FOLDER% %SAVE_LOCALY%" > Output.txt 2>>&1
if %IS_2003%==0 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc %PERIOD_TYPE% /st %START_TIME% /tn %TASK_NAME% /tr "%DISK_LETTER%:\PPR\Backup\BAT\Backup.bat %BACKUP_TYPE% %SERVER_FOLDER% %SAVE_LOCALY%" /rl highest > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set TASK_CREATE_OK=1
    if /i %%i==SUCCESS: set TASK_CREATE_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set TASK_CREATE_OK=0
    if /i %%i==WARNING: set TASK_CREATE_OK=0
)
if %TASK_CREATE_OK%==0 echo *     Задание по расписанию %TASK_NAME% - ОШИБКА. Задание не создано & type Output.txt
if %TASK_CREATE_OK%==1 echo *     Задание по расписанию %TASK_NAME% - OK
if exist Output.txt del /q Output.txt
echo *     НЕ ЗАБУДЬТЕ ВЫСТАВИТЬ НУЖНОЕ РАСПИСАНИЕ ДЛЯ АВТОМАТОВ ...
echo.
rem ********** ОКОНЧАТЕЛЬНАЯ НАСТРОЙКА **********
pause
