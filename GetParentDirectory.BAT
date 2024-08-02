@REM - ASB (20 Jun 2024 // 20 Jun 2024): Determine Parent Directory
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dk8r9z/comment/l9gf24e/
@ECHO OFF

:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION

 SET "#INPUT=%~1"
 IF NOT DEFINED #INPUT SET /P "#INPUT=Enter a filename or folder name: "
 SET #INPUT=%#INPUT:"=%

 rem -- Is Current Input a File or Directory?
:Main
 DIR /AD "%#INPUT%" >NUL 2>NUL
 IF ERRORLEVEL 1 (SET #DIR=%#INPUT%\..) ELSE (SET #DIR=%#INPUT%)
 FOR %%D IN ("%#DIR%") DO SET #PARENTDIR=%%~fD

 ECHO:
 ECHO -- You entered ...............: "%#INPUT%"
 ECHO -- The associated folder is ..: "%#PARENTDIR%"
 TIMEOUT 60


:ExitBatch
 ENDLOCAL
 EXIT /B
