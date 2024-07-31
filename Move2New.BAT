@REM - Move2New.BAT (27 Jul 2024 // 28 Jul 2024): Move files into folder by first two characters
@ECHO OFF
 SETLOCAL
 SET #SOURCE=%~1& IF "%~1"=="" SET "#SOURCE=D:\MyLargeFolder"


:ProcessFolder
 IF NOT EXIST "%#SOURCE%\*.*" ( ECHO INVALID SOURCE FOLDER & GOTO :ExitBatch )
 PUSHD "%#SOURCE%"
 FOR %%F IN (%#SOURCE%\*.*) DO CALL :MoveFile "%%~fF"
 POPD
 TREE /A /F "%#SOURCE%"

 
:ExitBatch
 TIMEOUT 60
 ENDLOCAL
 EXIT /B 


:MoveFile -- Determine file prefix and move accordingly
 rem %1 = full filename

 SET "#PREFIX=%~n1"
 SET "#PREFIX=%#PREFIX:~0,2%"
 ECHO %#PREFIX% | FINDSTR /I /R "[A-Z][A-Z]" >NUL
 IF ERRORLEVEL 1 SET "#PREFIX=%#PREFIX:~0,1%"
 SET "#DEST=%#SOURCE%\%#PREFIX%"
 IF NOT EXIST "%#DEST%" MD "%#DEST%"
 ECHO  - Moving "%~f1" to "%#DEST%"
 MOVE "%~1" "%#DEST%"
 GOTO :EOF
