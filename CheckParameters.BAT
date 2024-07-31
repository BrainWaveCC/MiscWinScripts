@REM - CheckParameters.BAT (23 Jun 2024 // 30 Jun 2024 / 23 Jun 2024): How to Check Parameters -- Native vs 3rd Party
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dmhacd/comment/l9x1lfh/
@ECHO OFF

 ::: If you want to check for a parameter of /X or -X, the use the following format:
 :::   CALL :GetParams "X EXTENDED" & IF DEFINED #OK (execute whatever commands you want here)
 :::
 ::: You would call this from the command-line as:
 :::   CheckParameters.BAT /X
 :::   CheckParameters.BAT -X
 ::: -----------------------------------------------
 :::
 ::: If you want to check for a parameter of /X or -X that contains a value, then use the following format:
 :::   CALL :GetParams "X EXTENDED" #X_VARIABLE & IF DEFINED #X_VARIABLE (execute whatever commands you want here)
 :::
 ::: You would call this from the command-line as:
 :::   CheckParameters.BAT /X:1
 :::   CheckParameters.BAT /X:NoSpaces
 :::   CheckParameters.BAT /X:"Value with Spaces"
 :::
 ::: You can do this natively or with a 3rd party utility that really streamlines the process.
 ::: I use this for pretty much all of my major scripts.
 :::
 ::: Full script can be found here .....  https://pastebin.com/wjs4Hz5k
 ::: Script without debug info .........  https://pastebin.com/5zAGAyrL
 :::
 ::: I started my testing with: CheckParameters.BAT /H /S /SHOW /L:C:\TEMP\TEST.TXT
 :::


:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #ALL_PARAMS=%*
 SET #DIVIDER=--------------------------------------------------------------------


 rem -- Process Special Command-line Parameters Natively
 FOR %%P IN (%#ALL_PARAMS%) DO CALL :GetParams %%P
 FOR %%S IN (%#SYNTAX%) DO IF "%%~S"=="F" (ECHO *** ERROR: Invalid parameters provided ***)
 IF NOT DEFINED #LOGFILE (SET #LOGFILE="%~1")
 ECHO %#DIVIDER%

 rem -- Process Special Command-line Parameters via CHECKPARAMS.EXE
 CALL :GetParams2 "S SHOW"   & IF DEFINED #OK (SET #SHOW=TRUE)
 CALL :GetParams2 "H HELP ?" & IF DEFINED #OK (SET #HELP=TRUE)
 CALL :GetParams2 "L LOGFILE"       #LOGFILE   & IF NOT DEFINED #LOGFILE (SET #LOGFILE="%~1")
 CALL :GetParams2 "D DIR DIRECTORY" #DIRECTORY & IF NOT DEFINED #DIRECTORY (ECHO No Directory was selected)
 ECHO %#DIVIDER%


 rem -- Test Your Parameters
:Testing
 ECHO:
 ECHO Setup your parameters above, and then test them by calling this script
 ECHO with your desired parameters.  Remember that "-" and "/" are both valid
 ECHO option delimiters.  For compound options, use ":" as the separator
 ECHO between the option and the value.
 ECHO:
 ECHO Valid parameters for this test are as follows:
 ECHO   %~n0 /S
 ECHO   %~n0 /SHOW
 ECHO   %~n0 /H
 ECHO   %~n0 /?
 ECHO   %~n0 /HELP
 ECHO   %~n0 /L:C:\Temp\LogFile.TXT
 ECHO   %~n0 /LOGFILE:"%TEMP%\LogFile.TXT"
 ECHO   %~n0 "%TEMP%\LogFile.TXT"
 ECHO        {you can make the logfile take on the 1st param if not /L is found}
 ECHO   %~n0 /D:%WINDIR%
 ECHO   %~n0 /DIR:"%WINDIR%"
 ECHO   %~n0 /DIRECTORY:"%~dp0"
 ECHO:
 FOR %%P IN (LOGFILE DIRECTORY) DO IF NOT DEFINED #%%P ECHO *** ERROR: #%%P was not defined


:ExitBatch
 ENDLOCAL
 EXIT /B  


 rem -- SUBROUTINE: Use Native Batch Commands to Capture Selected Parameters
:GetParams
 rem %1 = Parameter to Evaluate

 SET #OK=
 SET #PREFIX=%~1
 SET #SUFFIX=
 IF NOT DEFINED #PREFIX GOTO :EOF
 SET #PREFIX=!#PREFIX:"=!
 FOR /F "TOKENS=1* DELIMS=:" %%a IN ('ECHO !#PREFIX!') DO (
	 SET #PREFIX=%%~a
	 SET #SUFFIX=%%~b
 )

 FOR %%d IN (/ -) DO (
	 FOR %%O IN (S SHOW) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #SUFFIX=.& SET #SHOW=TRUE)
	 )

	 FOR %%O IN (H HELP) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #SUFFIX=.& SET #HELP=TRUE)
	 )

	 FOR %%O IN (L LOGFILE) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #LOGFILE=%#SUFFIX%)
	 )

	 FOR %%O IN (D DIR DIRECTORY) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #DIRECTORY=%#SUFFIX%)
	 )
 )
 IF NOT DEFINED #SUFFIX SET #OK=F
 SET #SYNTAX=%#OK%;%#SYNTAX%
 GOTO :EOF


 rem -- SUBROUTINE: Use CheckParams.exe (3rd party util) to Capture Selected Parameters
 rem -- https://www.majorgeeks.com/files/details/checkparams.html
:GetParams2
 rem %1 = Parameters to Search For
 rem %2 = Variable to Set

 SET #OK=& IF "%~1"=="" GOTO :EOF
 FOR /F "TOKENS=2-3*" %%v IN ('CHECKPARAMS -q -a -c "%~1" -s %#ALL_PARAMS% 2^>NUL') DO IF /I "%%~v"=="TRUE" (
	 SET #OK=T
	 IF NOT "%~2"=="" SET %~2=%%~x
 )
 GOTO :EOF
