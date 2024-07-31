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
 ::: The :FoundParam routine is just here for testing.  Not needed for production at all.
 ::: All you need for this to work is the variable block, and EITHER :GetParams OR :GetParams2
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


 rem ----------------------------------------------------------------------------------------------
 rem -- Process Special Command-line Parameters Natively
 rem ----------------------------------------------------------------------------------------------

 ::: Loop through all provided command-line parameters, and run the native
 ::: subroutine to see if that parameter is a valid one
 FOR %%P IN (%#ALL_PARAMS%) DO CALL :GetParams %%P

 ::: Check through the %#SYNTAX% variable when all parameter parsing is done,
 ::: and if there are any "F" entries set, then you received a bad parameter.
 ::: You can decide if you actually want to do anything about that.
 FOR %%S IN (%#SYNTAX%) DO IF "%%~S"=="F" (ECHO *** ERROR: Invalid parameters provided ***)

 ::: If the %#LOGFILE% variable wasn't set by specific parameter, set it to
 ::: the first parameter.  You can test its validity later.
 IF NOT DEFINED #LOGFILE (SET #LOGFILE="%~1")
 ECHO %#DIVIDER%


 rem ----------------------------------------------------------------------------------------------
 rem -- Process Special Command-line Parameters via CHECKPARAMS.EXE
 rem ----------------------------------------------------------------------------------------------

 ::: The paradigm for using CHECKPARAMS.EXE is different.  Here, you're going
 ::: to call the subroutine once for each valid option that you want to search
 ::: for, and if it is found in the list, then %#OK% will be set to some value,
 ::: and you can check for that immediately after you make that call.  It's a
 ::: little easier to control precedence of selected parameters this way.
 CALL :GetParams2 "S SHOW"   & IF DEFINED #OK (SET #SHOW=TRUE)
 CALL :GetParams2 "H HELP ?" & IF DEFINED #OK (SET #HELP=TRUE)

 ::: The following syntax allows you to not only check for specific parameters,
 ::: but it captures the provided value into a specific variable, which you can
 ::: then test for immediately.
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

 ::: If you decide to use this routine, be sure to remove every instance of the
 ::: following:   '& CALL :FoundParam GetParams "%#PREFIX%" "%#SUFFIX%"'   from
 ::: the lines below (after testing), or just look at the production (non-debug)
 ::: version of the script found here: https://pastebin.com/5zAGAyrL

 SET #OK=
 SET #PREFIX=%~1
 SET #SUFFIX=
 IF NOT DEFINED #PREFIX GOTO :EOF

 ::: With each parameter you parse, start by stripping all doublequotes from
 ::: the parameter.  Next, attempt to determine if it is a compound parameter
 ::: by searching for a ":" character, and making the part before the ":" as
 ::: the prefix, and the portion after the ":" as the suffix.
 SET #PREFIX=!#PREFIX:"=!
 FOR /F "TOKENS=1* DELIMS=:" %%a IN ('ECHO !#PREFIX!') DO (
	 SET #PREFIX=%%~a
	 SET #SUFFIX=%%~b
 )

 ::: Now, check for both a leading "/" or "-", compare the parameter you are
 ::: currently evaluating, with one of the valid parameters (case-insensitive)
 ::: and decide what you will do if it is the one you have found.
 FOR %%d IN (/ -) DO (
	 FOR %%O IN (S SHOW) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #SUFFIX=.& SET #SHOW=TRUE& CALL :FoundParam GetParams "%#PREFIX%" "%#SUFFIX%")
	 )

	 FOR %%O IN (H HELP) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #SUFFIX=.& SET #HELP=TRUE& CALL :FoundParam GetParams "%#PREFIX%" "%#SUFFIX%")
	 )

	 FOR %%O IN (L LOGFILE) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #LOGFILE=%#SUFFIX%& CALL :FoundParam GetParams "%#PREFIX%" "%#SUFFIX%")
	 )

	 FOR %%O IN (D DIR DIRECTORY) DO (
		 IF /I "%#PREFIX%"=="%%d%%O" (SET #OK=T& SET #DIRECTORY=%#SUFFIX%& CALL :FoundParam GetParams "%#PREFIX%" "%#SUFFIX%")
	 )
 )

 ::: If you get to the end of the valid parameter list, and %#OK% has not yet
 ::: been set to "T", then this means that the parameter you have just parsed
 ::: is an invalid one. You'll get to deal with this when all parameter
 ::: processing has been completed.
 IF NOT DEFINED #SUFFIX SET #OK=F
 SET #SYNTAX=%#OK%;%#SYNTAX%
 GOTO :EOF


 rem -- SUBROUTINE: Use CheckParams.exe (3rd party util) to Capture Selected Parameters
 rem -- https://www.majorgeeks.com/files/details/checkparams.html
:GetParams2
 rem %1 = Parameters to Search For
 rem %2 = Variable to Set

 SET #OK=& IF "%~1"=="" GOTO :EOF

 ::: As mentioned earlier, this subroutine is called with one valid entry that
 ::: needs to be searched for from the entire list of parameters provided by
 ::: the user at the command-line.  For more explanation of CHECKPARAMS, type
 ::: the following at a command prompt:  CHECKPARAMS /??
 FOR /F "TOKENS=2-3*" %%v IN ('CHECKPARAMS -q -a -c "%~1" -s %#ALL_PARAMS% 2^>NUL') DO IF /I "%%~v"=="TRUE" (
	 SET #OK=T
	 IF NOT "%~2"=="" SET %~2=%%~x

	 rem ::: This following call to :FoundParam is just here for testing, and
	 rem ::: should be removed for production purposes, or the production
	 rem ::: version of the script be used instead...
	 CALL :FoundParam GetParams2 "%%~w" "%%~x"
 )
 GOTO :EOF


 rem -- SUBROUTINE: Display What Parameter You Found
:FoundParam
 rem %1 = Subroutine called from
 rem %2 = Parameter Found
 rem %3 = Parameter Value Found

 SET #ZZ=%~2
 SET #ZZ=!#ZZ:[=!
 SET #ZZ=!#ZZ:]=!

 ECHO:
 ECHO Subroutine being tested ....... %~1
 ECHO Parameters you provided ....... %#ALL_PARAMS%
 ECHO Valid parameter found ......... !#ZZ!
 ECHO Valid parameter value found ... %3
 GOTO :EOF
