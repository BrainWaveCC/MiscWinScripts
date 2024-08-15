@REM - GetChoices.BAT (15 Aug 2024 // 15 Aug 2024): Get Choice Values via ERRORLEVEL in multiple ways
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1esifp6/comment/li65frx/
@ECHO OFF

 :::  This script captures the ERRORLEVEL from the CHOICE command in a variety
 :::  of ways, when compound statements are involved.  Only one method relies
 :::  on ENABLEDELAYEDEXPANSION.
 :::
 :::  For more info, see: https://ss64.com/nt/delayedexpansion.html
 :::
 :::  The script can be run at the CMD prompt, or directly via Windows Explorer.
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/GetChoices.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:OriginalNotes
 :::  When the script is run with ANY parameter, the variables A, B and C are all set to 1
 :::  When the script is run without a parameter, the variables A, B and C will be set based on user response to Y/N questions


:Variables -- v1.0.0
 SETLOCAL
 SET "#CHOICE=CHOICE /T 10 /C YN /D Y /M"
 

:Method-1 -- Get Choice with ERRORLEVEL command, not environment variable
 SETLOCAL
 IF NOT "%~1"=="" (
	 SET "A=1"
	 SET "B=1"
	 SET "C=1"
 ) ELSE (
	 %#CHOICE% "A? " & IF NOT ERRORLEVEL 2 (SET "A=1") ELSE (SET "A=2")
	 %#CHOICE% "B? " & IF NOT ERRORLEVEL 2 (SET "B=1") ELSE (SET "B=2")
	 %#CHOICE% "C? " & IF NOT ERRORLEVEL 2 (SET "C=1") ELSE (SET "C=2")
 )	 
 CALL :DisplayVars 1
 ENDLOCAL


:Method-2 -- Get Choice with %ERRORLEVEL% variable, via CALL
 SETLOCAL
 IF NOT "%~1"=="" (
	 SET "A=1"
	 SET "B=1"
	 SET "C=1"
 ) ELSE (
	 %#CHOICE% "A? " & CALL SET "A=%%ERRORLEVEL%%"
	 %#CHOICE% "B? " & CALL SET "B=%%ERRORLEVEL%%"
	 %#CHOICE% "C? " & CALL SET "C=%%ERRORLEVEL%%"
 )	 
 CALL :DisplayVars 2
 ENDLOCAL


:Method-3 -- Get Choice with !ERRORLEVEL1 variable, via CALL
 SETLOCAL ENABLEDELAYEDEXPANSION
 IF NOT "%~1"=="" (
	 SET "A=1"
	 SET "B=1"
	 SET "C=1"
 ) ELSE (
	 %#CHOICE% "A? " & CALL SET "A=!ERRORLEVEL!"
	 %#CHOICE% "B? " & CALL SET "B=!ERRORLEVEL!"
	 %#CHOICE% "C? " & CALL SET "C=!ERRORLEVEL!"
 )	 
 CALL :DisplayVars 3
 ENDLOCAL


:Method-4 -- Get Choice via SUBROUTINE and %ERRORLEVEL% variable
 SETLOCAL 
 IF NOT "%~1"=="" (
	 SET "A=1"
	 SET "B=1"
	 SET "C=1"
 ) ELSE (
	 CALL :GetMyChoices
 )	 
 CALL :DisplayVars 4
 ENDLOCAL


:ExitBatch
 ENDLOCAL
 EXIT /B

 
:DisplayVars
 ECHO:
 ECHO *** Method #%1 ***
 ECHO A=%A%
 ECHO B=%B%
 ECHO C=%C%
 ECHO:
 TIMEOUT 30
 GOTO :EOF 


:GetMyChoices -- SUBROUTINE: Get CHOICE and evaluate with normal %ERRORLEVEL% vars
 %#CHOICE% "A? " & SET "A=%ERRORLEVEL%"
 %#CHOICE% "B? " & SET "B=%ERRORLEVEL%"
 %#CHOICE% "C? " & SET "C=%ERRORLEVEL%"
 GOTO :EOF
