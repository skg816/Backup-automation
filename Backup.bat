
@echo off
title Backup %1
setlocal enabledelayedexpansion

rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
rem *+*+*+*+* Backup.bat v 2.0 authored by STARODUBCEV K.G. *+*+*+*+*
rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*




rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
rem **********************************************************************************************************
rem * Универсальный командный файл для создания бакапов                                                      *
rem * Параметр 1 - Имя шареной папки с бакапами на сервере резервного копирования                            *
rem * Параметр 2 - Тип бакапа, возможные варианты <BACKUP_TYPE> \ метка для перехода:                        *
rem *               1   - System_image - бакап системного раздела \ SI;                                      *
rem *               2   - UG_config - бакап конфигурации UserGate \ UGC;                                     *
rem *               3   - UG_log - бакап логов UserGate \ UGL;                                               *
rem *               4   - MD_config - бакап конфигурации MDaemon \ MDC;                                      *
rem *               5   - MD_log - бакап логов MDaemon \ MDL;                                                *
rem *               6   - ISA_log - бакап логов ISA \ ISAL;                                                  *
rem *               7   - System_state - бакап System state на сервере Active Directory \ SS;                *
rem *               8   - Archive_full - полный бакап папки "Архив" \ FFB;                                   *
rem *               9   - Archive_daily - ежедневный бакап папки "Архив" \ DFB;                              *
rem *               10  - TechArchive_full - полный бакап папки "ТехАрхив" \ FFB;                            *
rem *               11  - TechArchive_daily - ежедневный бакап папки "ТехАрхив" \ DFB;                       *
rem *               12  - CPPOA_full - полный бакап папки "ЦППОА" \ FFB;                                     *
rem *               13  - CPPOA_daily - ежедневный бакап папки "ЦППОА" \ DFB;                                *
rem *               14  - ABN_full - полный бакап папки "ABN" \ FFB;                                         *
rem *               15  - Papki_obshego_dostupa_full - полный бакап папки "Папки_общего_доступа" \ FFB;      *
rem *               16  - Papki_obshego_dostupa_daily - ежедневный бакап папки "Папки_общего_доступа" \ DFB; *
rem *               17  - Kamzin_full - полный бакап папки "Камзин_Ж.Ж" \ FFB;                               *
rem *               18  - Kamzin_daily - ежедневный бакап папки "Камзин_Ж.Ж" \ DFB;                          *
rem *               19  - SQL - бакап баз данных \ SQL;                                                      *
rem *               20  - WSUS - бакап сервера обновлений Windows \ WSUS;                                    *
rem *               21  - MySQL - бакап базы данных \ MySQL;                                                 *
rem *               22  - KAV - бакап Kaspersky Administration Kit \ KAV.                                    *
rem * Параметр 3 - Где сохранять бакап, возможные значения <STORAGE>:                                        *
rem *               1   - server - только на сервере резервного копирования;                                 *
rem *               2   - both - и на локальном компьютере и на сервере резервного копирования.              *
rem * Системные требования:                                                                                  *
rem *               Региональные параметры - Русский                                                         *
rem *               Формат времени - H:mm:ss                                                                 *
rem **********************************************************************************************************
rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ВЫПОЛНЕНИЕ КАКОГО-ЛИБО БАКАПА В ДАННЫЙ МОМЕНТ - НАЧАЛО * // *
if exist run.txt exit
rem * // * КОНТРОЛЬ НА ВЫПОЛНЕНИЕ КАКОГО-ЛИБО БАКАПА В ДАННЫЙ МОМЕНТ - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ПРИСУТСТВИЕ ВСЕХ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - НАЧАЛО * // *
set WRONG=0
set PAR_1=%1
set PAR_2=%2
set PAR_3=%3
if not defined PAR_1 set WRONG=1
if not defined PAR_2 set WRONG=1
if not defined PAR_3 set WRONG=1
if %WRONG%==1 echo Ошибка выполнения бакапа, указаны не все необходимые параметры !
if %WRONG%==1 goto :EOF
rem * // * КОНТРОЛЬ НА ПРИСУТСТВИЕ ВСЕХ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ПРАВИЛЬНОСТЬ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - НАЧАЛО * // *
set WRONG=2
for %%i in (System_image UG_config UG_log MD_config MD_log ISA_log System_state Archive_full Archive_daily TechArchive_full TechArchive_daily CPPOA_full CPPOA_daily ABN_full Papki_obshego_dostupa_full Papki_obshego_dostupa_daily Kamzin_full Kamzin_daily SQL WSUS MySQL KAV) do if /i %%i==%1 set WRONG=0
if !WRONG!==2 echo Ошибка выполнения бакапа, второй параметр указан неверно !
if !WRONG!==2 goto :EOF
set WRONG=3
for %%i in (server both) do if /i %%i==%3 set WRONG=0
if !WRONG!==3 echo Ошибка выполнения бакапа, третий параметр указан неверно !
if !WRONG!==3 goto :EOF
rem * // * КОНТРОЛЬ НА ПРАВИЛЬНОСТЬ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * ОПРЕДЕЛЕНИЕ ПЕРЕМЕННЫХ - НАЧАЛО * // *
set NOW=%TIME:~0,-6%
set NOW=%NOW::=.%
set NOW=%NOW: =_%
set DISK_LETTER=
for %%i in (C D E F G H I G K L M N O P) do (
    if exist %%i:\PPR\Backup\BAT\Backup.bat set DISK_LETTER=%%i
)
set STORAGE=%3
if /i %STORAGE%==both set FIRST_BACKUP_PATH=%DISK_LETTER%:\PPR\Backup
if /i %STORAGE%==both set SECOND_BACKUP_PATH=\\10.167.31.8\%2\%COMPUTERNAME%
if /i %STORAGE%==server set FIRST_BACKUP_PATH=\\10.167.31.8\%2\%COMPUTERNAME%
set BACKUP_TYPE=%1
set YYYY=%DATE:~-4%
set LOG_FILE=%DISK_LETTER%:\PPR\Backup\LOG\%COMPUTERNAME%_%BACKUP_TYPE%.log
rem * // * ОПРЕДЕЛЕНИЕ ПЕРЕМЕННЫХ - КОНЕЦ * // *




rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
echo Пожалуйста подождите, выполняется резервное копирование %BACKUP_TYPE% ...
echo. >> %LOG_FILE%
echo %DATE% %TIME% НАЧАЛО ВЫПОЛНЕНИЯ БАКАПА *********************************************************************** >> %LOG_FILE%
if /i %STORAGE%==server if not exist %FIRST_BACKUP_PATH%\%BACKUP_PATH% echo %DATE% %TIME% Папка %FIRST_BACKUP_PATH%\%BACKUP_PATH% недоступна >> %LOG_FILE%
if /i %STORAGE%==server if not exist %FIRST_BACKUP_PATH%\%BACKUP_PATH% set FIRST_BACKUP_PATH=\\10.167.31.9\%2\%COMPUTERNAME%
if /i %STORAGE%==server if not exist %FIRST_BACKUP_PATH%\%BACKUP_PATH% echo %DATE% %TIME% Папка %FIRST_BACKUP_PATH%\%BACKUP_PATH% недоступна >> %LOG_FILE%
if /i %STORAGE%==server if not exist %FIRST_BACKUP_PATH%\%BACKUP_PATH% goto :ERR
if /i %BACKUP_TYPE%==System_image goto :SI
if /i %BACKUP_TYPE%==UG_config goto :UGC
if /i %BACKUP_TYPE%==UG_log goto :UGL
if /i %BACKUP_TYPE%==MD_config goto :MDC
if /i %BACKUP_TYPE%==MD_log goto :MDL
if /i %BACKUP_TYPE%==ISA_log goto :ISAL
if /i %BACKUP_TYPE%==System_state goto :SS
if /i %BACKUP_TYPE%==Archive_full goto :FFB
if /i %BACKUP_TYPE%==Archive_daily goto :DFB
if /i %BACKUP_TYPE%==TechArchive_full goto :FFB
if /i %BACKUP_TYPE%==TechArchive_daily goto :DFB
if /i %BACKUP_TYPE%==CPPOA_full goto :FFB
if /i %BACKUP_TYPE%==CPPOA_daily goto :DFB
if /i %BACKUP_TYPE%==ABN_full goto :FFB
if /i %BACKUP_TYPE%==Papki_obshego_dostupa_full goto :FFB
if /i %BACKUP_TYPE%==Papki_obshego_dostupa_daily goto :DFB
if /i %BACKUP_TYPE%==Kamzin_full goto :FFB
if /i %BACKUP_TYPE%==Kamzin_daily goto :DFB
if /i %BACKUP_TYPE%==SQL goto :SQL
if /i %BACKUP_TYPE%==WSUS goto :WSUS
if /i %BACKUP_TYPE%==MySQL goto :MySQL
if /i %BACKUP_TYPE%==KAV goto :KAV

:SI
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.tib
set SI_OK=1
echo %DATE% %TIME% Создаем образ системного раздела %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
"%ACRONIS_PATH%\TrueImageCmd.exe" /create /filename:%FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% /partition:1-1 /progress:off > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set SI_OK=0
if %SI_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %SI_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %SI_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %SI_OK%==0 goto :ERR
set SI_OK=1
echo %DATE% %TIME% Проверяем образ %NEW_BACKUP_NAME% на ошибки >> %LOG_FILE%
"%ACRONIS_PATH%\TrueImageCmd.exe" /verify /filename:%FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% /progress:off > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set SI_OK=0
if %SI_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %SI_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %SI_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %SI_OK%==0 goto :ERR
goto :C_D

:UGC
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.ini
set UGC_OK=1
echo %DATE% %TIME% Копируем файл C:\Windows\Usergate.ini в папку %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
copy /v /y C:\Windows\Usergate.ini %FIRST_BACKUP_PATH%\%BACKUP_TYPE% > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set UGC_OK=0
if %UGC_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %UGC_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %UGC_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %UGC_OK%==0 goto :ERR
set UGC_OK=1
echo %DATE% %TIME% Переименовываем файл %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\Usergate.ini в %NEW_BACKUP_NAME% >> %LOG_FILE%
rename %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\Usergate.ini %NEW_BACKUP_NAME% > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set UGC_OK=0
if %UGC_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %UGC_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %UGC_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %UGC_OK%==0 goto :ERR
goto :C_D

:UGL
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.rar
set DD=%DATE:~0,-8%
set MM=%DATE:~3,-5%
set YY=%DATE:~-2%
set CURRENT_LOG_NAME=%DD%-%MM%-%YY%-UserGate.*
set UGL_OK=1
echo %DATE% %TIME% Переносим все лог-файлы, кроме текущих, из папки C:\Program Files\UserGate\Logging в архив %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% >> %LOG_FILE%
"C:\Program Files\WinRAR\rar.exe" a -df -ep -t -x"C:\Program Files\UserGate\Logging\%CURRENT_LOG_NAME%" %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% "C:\Program Files\UserGate\Logging\*.*" > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set UGL_OK=0
if %UGL_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %UGL_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %UGL_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %UGL_OK%==0 goto :ERR
goto :C_D

:MDC
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.rar
set MDC_OK=1
echo %DATE% %TIME% Переносим все конфигурационные файлы из папки C:\MDaemon\Backup в архив %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% >> %LOG_FILE%
"C:\Program Files\WinRAR\rar.exe" a -m0 -df -ep -t %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% "C:\MDaemon\Backup\*.*" > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set MDC_OK=0
if %MDC_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %MDC_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %MDC_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %MDC_OK%==0 goto :ERR
goto :C_D

:MDL
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.rar
set MDL_OK=1
echo %DATE% %TIME% Переносим все лог-файлы из папки C:\MDaemon\Logs\OldLogs в архив %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% >> %LOG_FILE%
"C:\Program Files\WinRAR\rar.exe" a -m0 -df -ep -t %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% "C:\MDaemon\Logs\OldLogs\*.*" > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set MDL_OK=0
if %MDL_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %MDL_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %MDL_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %MDL_OK%==0 goto :ERR
goto :C_D

:ISAL
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.rar
set DD=%DATE:~0,-8%
set MM=%DATE:~3,-5%
set CURRENT_LOG_NAME=*%YYYY%%MM%%DD%.log
set ISAL_OK=1
echo %DATE% %TIME% Переносим все лог-файлы, кроме текущих, из папки C:\Program Files\Microsoft ISA Server\ISALogs в архив %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% >> %LOG_FILE%
"C:\Program Files\WinRAR\rar.exe" a -df -ep -t -x"C:\Program Files\Microsoft ISA Server\ISALogs\%CURRENT_LOG_NAME%" %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% "C:\Program Files\Microsoft ISA Server\ISALogs\*.*" > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set ISAL_OK=0
if %ISAL_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %ISAL_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %ISAL_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %ISAL_OK%==0 goto :ERR
goto :C_D

:SS
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.bkf
set SS_OK=1
echo %DATE% %TIME% Создаем и проверяем бакап состояния системы %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
C:\WINDOWS\system32\ntbackup.exe backup systemstate /v:yes /r:no /rs:no /hc:off /m copy /l:s /f "%FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME%"
if not %ERRORLEVEL%==0 set SS_OK=0
if %SS_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %SS_OK%==0 for %%i in ("!USERPROFILE!\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\*") do find "!NEW_BACKUP_NAME!" "%%i" && type "%%i" > Output_backup.txt
if %SS_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %SS_OK%==0 goto :ERR
set SS_OK=1
dir /-C %FIRST_BACKUP_PATH%\%BACKUP_TYPE% > Output_backup.txt
for /F "eol=; tokens=3,4 skip=7" %%i in (Output_backup.txt) do if %%j==!NEW_BACKUP_NAME! if %%i LEQ 2048 set SS_OK=0
if %SS_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %SS_OK%==0 echo %DATE% %TIME% ОШИБКА - файл %NEW_BACKUP_NAME% меньше 2 КБ >> %LOG_FILE%
if %SS_OK%==0 goto :ERR
goto :C_D

:FFB
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.bkf
set FFB_OK=1
echo %DATE% %TIME% Создаем и проверяем бакап %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
C:\WINDOWS\system32\ntbackup.exe backup "@%DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks" /v:yes /r:no /rs:no /hc:off /m normal /l:s /f "%FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME%"
if not %ERRORLEVEL%==0 set FFB_OK=0
if %FFB_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %FFB_OK%==0 for %%i in ("!USERPROFILE!\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\*") do find "!NEW_BACKUP_NAME!" "%%i" && type "%%i" > Output_backup.txt
if %FFB_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %FFB_OK%==0 goto :ERR
set FFB_OK=1
dir /-C %FIRST_BACKUP_PATH%\%BACKUP_TYPE% > Output_backup.txt
for /F "eol=; tokens=3,4 skip=7" %%i in (Output_backup.txt) do if %%j==!NEW_BACKUP_NAME! if %%i LEQ 2048 set FFB_OK=0
if %FFB_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %FFB_OK%==0 echo %DATE% %TIME% ОШИБКА - файл %NEW_BACKUP_NAME% меньше 2 КБ >> %LOG_FILE%
if %FFB_OK%==0 goto :ERR
goto :C_D

:DFB
if not exist Backup_schtasks_2.txt goto :E
set DFB_OK=1
set TASK_NAME_1=%BACKUP_TYPE:~0,-5%
set TASK_NAME_1=%TASK_NAME_1%full
set CUR_DATE=%DATE%
for /f "delims=* tokens=2,3 skip=1" %%i in (Backup_schtasks_2.txt) do (
    set TASK_NAME_2=%%i
    set TASK_NAME_2=!TASK_NAME_2:~10!
    set NEXT_RUN_DATE=%%j
    set NEXT_RUN_DATE=!NEXT_RUN_DATE:~-10!
if /i !TASK_NAME_1!==!TASK_NAME_2! if !CUR_DATE!==!NEXT_RUN_DATE! set DFB_OK=0
)
if %DFB_OK%==0 echo %DATE% %TIME% Дневной бакап не требуется, так как сегодня запланирован полный бакап данной папки >> %LOG_FILE%
if %DFB_OK%==0 goto :EXT
:E
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.bkf
set DFB_OK=1
echo %DATE% %TIME% Создаем и проверяем бакап %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
C:\WINDOWS\system32\ntbackup.exe backup "@%DISK_LETTER%:\PPR\Backup\BKS\%BACKUP_TYPE%.bks" /v:yes /r:no /rs:no /hc:off /m incremental /l:s /f "%FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME%"
if not %ERRORLEVEL%==0 set DFB_OK=0
if %DFB_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %DFB_OK%==0 for %%i in ("!USERPROFILE!\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\*") do find "!NEW_BACKUP_NAME!" "%%i" && type "%%i" > Output_backup.txt
if %DFB_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %DFB_OK%==0 goto :ERR
set DFB_OK=1
dir /-C %FIRST_BACKUP_PATH%\%BACKUP_TYPE% > Output_backup.txt
for /F "eol=; tokens=3,4 skip=7" %%i in (Output_backup.txt) do if %%j==!NEW_BACKUP_NAME! if %%i LEQ 2048 set DFB_OK=0
if %DFB_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %DFB_OK%==0 echo %DATE% %TIME% ОШИБКА - файл %NEW_BACKUP_NAME% меньше 2 КБ >> %LOG_FILE%
if %DFB_OK%==0 goto :ERR
goto :C_D

:SQL
set SQL_OK_2=1
echo %DATE% %TIME% Создаем и проверяем бакап баз данных в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
if exist Output_backup_2.txt del /q Output_backup_2.txt
if /i !COMPUTERNAME!==SRV3  "C:\Program Files\Microsoft SQL Server\80\Tools\Binn\osql.exe" -E -S SRV3\srv3 -Q "select catalog_name from information_schema.SCHEMATA" > Output_backup.txt
if /i !COMPUTERNAME!==SRV10 "C:\Program Files\Microsoft SQL Server\90\Tools\Binn\OSQL.EXE" -E -S SRV10 -Q "select name from sysdatabases" > Output_backup.txt
if /i !COMPUTERNAME!==SRV22 "C:\Program Files\Microsoft SQL Server\100\Tools\Binn\OSQL.EXE" -E -S SRV22\SRV22 -Q "select name from sysdatabases" > Output_backup.txt
for /f "skip=4 eol=(" %%a in (Output_backup.txt) do (
    set SQL_OK_1=1
    set NOW=!TIME:~0,-6!
    set NOW=!NOW::=.!
    set NOW=!NOW: =_!
    if /i not %%a==tempdb if /i !COMPUTERNAME!==SRV3  "C:\Program Files\Microsoft SQL Server\80\Tools\Binn\osql.exe" -E -S SRV3\srv3  -Q "BACKUP DATABASE [%%a] TO  DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH  INIT,  NOUNLOAD,  NAME = N'%%a_!COMPUTERNAME!_!DATE!_!NOW!',  NOSKIP,  STATS = 10,  NOFORMAT DECLARE @i INT select @i = position from msdb..backupset where database_name='%%a'and type<>'F' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name='%%a') RESTORE VERIFYONLY FROM   DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH FILE = @i" > Output_backup_1.txt
    if /i not %%a==tempdb if /i !COMPUTERNAME!==SRV10 "C:\Program Files\Microsoft SQL Server\90\Tools\Binn\OSQL.EXE" -E -S SRV10 -Q "BACKUP DATABASE [%%a] TO  DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH NOFORMAT, NOINIT,  NAME = N'%%a_!COMPUTERNAME!_!DATE!_!NOW!', SKIP, NOREWIND, NOUNLOAD,  STATS = 10 declare @backupSetId as int select @backupSetId = position from msdb..backupset where database_name=N'%%a' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'%%a' ) RESTORE VERIFYONLY FROM  DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND" > Output_backup_1.txt
    if /i not %%a==tempdb if /i !COMPUTERNAME!==SRV22 "C:\Program Files\Microsoft SQL Server\100\Tools\Binn\OSQL.EXE" -E -S SRV22\SRV22 -Q "BACKUP DATABASE [%%a] TO  DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH NOFORMAT, NOINIT,  NAME = N'%%a_!COMPUTERNAME!_!DATE!_!NOW!', SKIP, NOREWIND, NOUNLOAD,  STATS = 10 declare @backupSetId as int select @backupSetId = position from msdb..backupset where database_name=N'%%a' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'%%a' ) RESTORE VERIFYONLY FROM  DISK = N'!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\%%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND" > Output_backup_1.txt
    if not !ERRORLEVEL!==0 set SQL_OK_1=0
    if not !ERRORLEVEL!==0 set SQL_OK_2=0
    if !SQL_OK_1!==1 echo !DATE! !TIME! Резервная копия базы данных %%a создана >> %LOG_FILE%
    if !SQL_OK_1!==1 echo %%a_!COMPUTERNAME!_!DATE!_!NOW!.bkf >> Output_backup_2.txt
    if !SQL_OK_1!==0 echo !DATE! !TIME! База данных %%a ОШИБКА >> %LOG_FILE%
    if !SQL_OK_1!==0 type Output_backup_1.txt >> %LOG_FILE%
)
if %SQL_OK_2%==0 goto :ERR
goto :C_D

:WSUS
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.cab
set WSUS_OK=1
echo %DATE% %TIME% Создаем и проверяем бакап %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
"C:\Program Files\Update Services\Tools\wsusutil.exe" export %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% %DISK_LETTER%:\PPR\Backup\LOG\WSUS.log > Output_backup.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Backup\LOG\WSUS.log del /q %DISK_LETTER%:\PPR\Backup\LOG\WSUS.log
if not %ERRORLEVEL%==0 WSUS_OK=0
if %WSUS_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %WSUS_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %WSUS_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %WSUS_OK%==0 goto :ERR
goto :C_D

:MySQL
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%.txt
set MySQL_OK=1
echo %DATE% %TIME% Создаем бакап %NEW_BACKUP_NAME% в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
D:\mysql\bin\mysqldump -r %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% --add-drop-table measdevice > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set MySQL_OK=0
if %MySQL_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %MySQL_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %MySQL_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %MySQL_OK%==0 goto :ERR
goto :C_D

:KAV
set NEW_BACKUP_NAME=%BACKUP_TYPE%_%COMPUTERNAME%_%DATE%_%NOW%
set KAV_OK=1
echo %DATE% %TIME% Создаем бакап в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% >> %LOG_FILE%
"C:\Program Files\Kaspersky Lab\Kaspersky Administration Kit\klbackup.exe" -path %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% -password 123 > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set KAV_OK=0
if %KAV_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %KAV_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %KAV_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %KAV_OK%==0 goto :ERR
set KAV_OK=1
echo %DATE% %TIME% Переносим все файлы из папки %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% в архив %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME%.rar >> %LOG_FILE%
"C:\Program Files\WinRAR\rar.exe" a -m0 -df -ep1 -t %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME%.rar %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% > Output_backup.txt 2>>&1
if not %ERRORLEVEL%==0 set KAV_OK=0
if %KAV_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %KAV_OK%==1 set NEW_BACKUP_NAME=%NEW_BACKUP_NAME%.rar
if %KAV_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %KAV_OK%==0 type Output_backup.txt >> %LOG_FILE%
if %KAV_OK%==0 goto :ERR
goto :C_D

:C_D
set C_D_OK_1=1
if not exist %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% echo %DATE% %TIME% Файл %NEW_BACKUP_NAME% отсутствует в папке %FIRST_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
if not exist %FIRST_BACKUP_PATH%\%BACKUP_TYPE%\%NEW_BACKUP_NAME% goto :ERR
if /i %STORAGE%==server goto :OK
if not exist %SECOND_BACKUP_PATH%\%BACKUP_PATH% echo %DATE% %TIME% Папка %SECOND_BACKUP_PATH%\%BACKUP_PATH% недоступна >> %LOG_FILE%
if not exist %SECOND_BACKUP_PATH%\%BACKUP_PATH% set SECOND_BACKUP_PATH=\\10.167.31.9\%2\%COMPUTERNAME%
if not exist %SECOND_BACKUP_PATH%\%BACKUP_PATH% echo %DATE% %TIME% Папка %SECOND_BACKUP_PATH%\%BACKUP_PATH% недоступна >> %LOG_FILE%
if not exist %SECOND_BACKUP_PATH%\%BACKUP_PATH% goto :ERR
echo %DATE% %TIME% Копируем файлы из папки %FIRST_BACKUP_PATH%\%BACKUP_TYPE% в папку %SECOND_BACKUP_PATH%\%BACKUP_TYPE% >> %LOG_FILE%
for %%i in ("!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\*") do (
    set C_D_OK_2=1
    set C_D_OK_3=1
    if not exist !SECOND_BACKUP_PATH!\!BACKUP_TYPE!\%%~nxi set C_D_OK_2=0
    if not exist !SECOND_BACKUP_PATH!\!BACKUP_TYPE!\%%~nxi copy /v /y %%i !SECOND_BACKUP_PATH!\!BACKUP_TYPE! > Output_backup.txt 2>>&1
    if not !ERRORLEVEL!==0 set C_D_OK_1=0
    if not !ERRORLEVEL!==0 set C_D_OK_3=0
    if !C_D_OK_2!==0 if !C_D_OK_3!==1 echo !DATE! !TIME! Файл %%~nxi скопирован >> %LOG_FILE%
    if !C_D_OK_2!==0 if !C_D_OK_3!==0 echo !DATE! !TIME! Файл %%~nxi ОШИБКА >> %LOG_FILE%
    if !C_D_OK_2!==0 if !C_D_OK_3!==0 type Output_backup.txt >> %LOG_FILE%
)
if %C_D_OK_1%==0 goto :ERR
echo %DATE% %TIME% Очищаем папку %FIRST_BACKUP_PATH%\%BACKUP_TYPE% от всех файлов кроме только созданных >> %LOG_FILE%
set C_D_OK_1=1
for %%i in ("!FIRST_BACKUP_PATH!\!BACKUP_TYPE!\*") do (
    set C_D_OK_2=1
    set C_D_OK_3=1
    set C_D_OK_4=1
    if exist !SECOND_BACKUP_PATH!\!BACKUP_TYPE!\%%~nxi set C_D_OK_2=0
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if /i not !NEW_BACKUP_NAME!==%%~nxi del /q %%i > Output_backup.txt 2>>&1
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if not !ERRORLEVEL!==0 set C_D_OK_1=0
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if not !ERRORLEVEL!==0 set C_D_OK_3=0
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_3!==1 if /i not !NEW_BACKUP_NAME!==%%~nxi echo !DATE! !TIME! Файл %%~nxi удален >> %LOG_FILE%
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_3!==0 if /i not !NEW_BACKUP_NAME!==%%~nxi echo !DATE! !TIME! Файл %%~nxi ОШИБКА >> %LOG_FILE%
    if /i not !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_3!==0 if /i not !NEW_BACKUP_NAME!==%%~nxi type Output_backup.txt >> %LOG_FILE%
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 find "%%~nxi" "Output_backup_2.txt" && set C_D_OK_4=0
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 del /q %%i > Output_backup.txt 2>>&1
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 if not !ERRORLEVEL!==0 set C_D_OK_1=0
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 if not !ERRORLEVEL!==0 set C_D_OK_3=0
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 if !C_D_OK_3!==1 echo !DATE! !TIME! Файл %%~nxi удален >> %LOG_FILE%
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 if !C_D_OK_3!==0 echo !DATE! !TIME! Файл %%~nxi ОШИБКА >> %LOG_FILE%
    if /i !BACKUP_TYPE!==SQL if !C_D_OK_2!==0 if !C_D_OK_4!==1 if !C_D_OK_3!==0 type Output_backup.txt >> %LOG_FILE%
)
if %C_D_OK_1%==0 goto :ERR

:OK
echo %DATE% %TIME% Результат выполнения бакапа - OK >> %LOG_FILE%
goto :EXT

:ERR
echo %DATE% %TIME% Результат выполнения бакапа - ОШИБКА >> %LOG_FILE%
C:\Windows\Blat\blat.exe -tf C:\Windows\Blat\address.txt -subject "Ошибка выполнения бакапа %BACKUP_TYPE% на %COMPUTERNAME%" -body " " -charset UTF-32 -log C:\Windows\Blat\mail.log

:EXT
echo %DATE% %TIME% КОНЕЦ ВЫПОЛНЕНИЯ БАКАПА ************************************************************************ >> %LOG_FILE%
echo. >> %LOG_FILE%
if exist %LOG_FILE% if /i not %STORAGE%==server copy /v /y %LOG_FILE% %SECOND_BACKUP_PATH%\Backup_log
if exist %LOG_FILE% if /i %STORAGE%==server copy /v /y %LOG_FILE% %FIRST_BACKUP_PATH%\Backup_log
if exist Output_backup.txt   del /q Output_backup.txt
if exist Output_backup_1.txt del /q Output_backup_1.txt
if exist Output_backup_2.txt del /q Output_backup_2.txt
rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *
