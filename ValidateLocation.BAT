@REM - ValidateLocation.BAT (21 Jul 2024 // 23 Jun 2024 / 21 Jul 2024): Verify that your script is only running under an approved folder tree
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1e8u7z1/comment/lejxlct/
@ECHO OFF
 SETLOCAL
 SET "#VALID_DIR=%~1" & IF "%~1"=="" SET "#VALID_DIR=C:\Temp\Junk"


:Main - Select a set of folders to test for
 ECHO VALID SCRIPT ROOT = "%#VALID_DIR%"

 CALL :CheckLocation "C:\Temp"
 CALL :CheckLocation "D:\Scripts\Bat\Input"
 CALL :CheckLocation "C:\Scripts\Bat\Input"
 CALL :CheckLocation "D:\Temp\One\More\Folder"
 CALL :CheckLocation "C:\Temp\Junk\Special!\Other"
 CALL :CheckLocation "C:\Temp\Junk\More\Other"
 CALL :CheckLocation "C:\Temp\Crazy%%%%\Different\Other"
 CALL :CheckLocation "C:\Temp\Junk\Different\Other"
 CALL :CheckLocation "C:\Storage\Work"
 CALL :CheckLocation "D:\Storage\Work"


:ExitBatch
 ENDLOCAL
 TIMEOUT -1
 EXIT /B


:CheckLocation -- SUBROUTINE: If the name of your approved PATH is not a part of the current directory, abort
 rem %1 = Folder to test for validity

 IF NOT EXIST "%~1" (ECHO:& ECHO *** "%~1" is not a valid directory *** & GOTO :EOF)

 rem -- the PUSHD is just to simulate a real script already being in the location specified
 PUSHD "%~1"
 ECHO:
 ECHO :%CD%\ | FIND /I ":%#VALID_DIR%" >NUL
 IF NOT ERRORLEVEL 1 (
	 ECHO This script IS AUTHORIZED to run in "%CD%" ...
 ) ELSE (
	 ECHO This script is NOT authorized to run in "%CD%" -- script aborted
 )
 POPD
 GOTO :EOF
