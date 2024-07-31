@REM - GetFileSize.BAT (18 Jul 2024 // 18 Jul 2024): Get File Size
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #FILE1=D:\Scripts\Bat\Input\[WindowsBuilds-Plus].TXT
 SET #FILE2=D:\Scripts\Bat\Input\[WindowsBuilds-Latest].TXT
 SET #FILE3=%~1


:GetSize -- Obtain the File Sizes Above
 CALL :GetFileSize "%#FILE1%" #M_SIZE
 CALL :GetFileSize "%#FILE2%" #S_SIZE
 CALL :GetFileSize "%#FILE3%" #X_SIZE


:FinalReport
 ECHO:
 SET #
 
 
:ExitBatch
 TIMEOUT 60
 ENDLOCAL 
 EXIT /B 
 

 rem -- SUBROUTINE: Get File Size
:GetFileSize
 rem %1 = Filename to Evaluate
 rem %2 = Variable to store size in

 IF NOT EXIST "%~1"=="" GOTO :EOF
 IF "%~2"=="" GOTO :EOF

 SET %~2=0
 FOR %%S IN ("%~1") DO SET %~2=%%~zS
 %@PRINT_IF_DEBUG%
 GOTO :EOF
