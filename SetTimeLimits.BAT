@REM - SetTimeLimits.BAT (04 Aug 2024 // 04 Aug 2024): Wait for input until a particular time in the future
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1eiqd2i/comment/lgihm4b/
@ECHO OFF
 
 :::  This goal of this script is to offer a user a limited time to provide input via
 :::  a process that would otherwise wait indefinitely.  This works by spawning a
 :::  process with a unique name, and tracking its runtime for a defined window of 
 :::  time with a random script that is also spawned.  If the time has passed, the 
 :::  second script will kill the unique process name, and the first script will be 
 :::  able to continue with failure.
 :::
 :::  To make it more concise, the first script both generates and spawns the second 
 :::  script.  
 :::
 :::  You would call this from the command-line as:
 :::    SetTimeLimits.BAT ["hh:nn:ss"] OR ["mm/dd/yy hh:nn:ss"] -- use 24 hour notation
 :::
 :::  If you do not provide a time or date and time, the script will default to waiting 
 :::  for 5 minutes (00:05:00 in hh:nn:ss) for the user to provide input.
 ::: -----------------------------------------------
 :::
 :::  This script relies on three of my 3rd party utilities:
 :::   - GetInput.exe ...... to get the actual input from the user with a discrete process
 :::   - DateInfo.exe** .... to handle the time calcuations more easily
 :::   - FindFiles.exe** ... to find the executables anywhere in the path.
 :::
 :::  ** = Could be done natively, but I'm biased
 ::: 
 :::  https://www.majorgeeks.com/files/details/getinput.html
 :::  https://www.majorgeeks.com/files/details/dateinfo.html
 :::  https://www.majorgeeks.com/files/details/findfiles.html
 :::
 :::  You can download these files and put them into the folder with the script, 
 :::  or anywhere in your current path.
 :::
 :::  Full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/SetTimeLimits.BAT
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Check4Essentials -- Check for Essential Utilities and/or Scripts
 FINDFILES -w -m -f DATEINFO.EXE GETINPUT.EXE SLEEP.EXE TASKLIST.EXE TASKKILL.EXE
 IF ERRORLEVEL 64 GOTO :ExitBatch


:Variables -- Initialize Environment Variables
 SETLOCAL
 SET "#ERRORMSG1=Wrong answer, buddy!"            // Default Error message for wrong input
 SET "#ERRORMSG2=You ran out of time, buddy!"     // Error message for waiting too long
 SET "#TIMEOUT_FLAG=%TEMP%\TooSlow-%RANDOM%.$$$"  // Flag to generate when time has expired
 SET "#VBSCRIPT=%TEMP%\ErrorMsg.vbs"              // VB Scripts that will display the message box
 SET "#TIMER_SCRIPT=%TEMP%\%~n0-%RANDOM%.BAT"     // Temporary script to generate for checking waiting time
 SET "#GETINPUT_SOURCE=C:\Utils\GetInput.EXE"     // Temporary Edition of GetInput.exe (if you want to set it manally)
 SET "#GETINPUT_RND=GetInput-%RANDOM%.EXE"        // Temporary Edition of GetInput.exe
 SET "#DATEFMT=-F "mm/dd/yyyy hh:nn:ss""          // date/time format for routines

 rem -- Get the time or date/time when the script should continue after waiting; if no value, set 5 min from now
 FOR /F "TOKENS=*" %%D IN ('DATEINFO -Z "00:05:00" %#DATEFMT% -Q 2^>NUL') DO SET "#DEFAULT_TIME=%%D"
 SET "#WAITUNTIL=%~1"
 IF "%~1"=="" (
	 SET "#WAITUNTIL=%#DEFAULT_TIME%"
 ) ELSE (
	 FOR /F "TOKENS=1-3" %%D IN ('DATEINFO -S "%#WAITUNTIL%" %#DATEFMT% -Q 2^>NUL') DO (
		 IF "%%~F"=="" (SET "#WAITUNTIL=%%D %%E") ELSE (SET "#WAITUNTIL=%#DEFAULT_TIME%")
	 )
 )


:GenerateTempScript -- Generate TimerScript to track waiting time
 ( ECHO @rem -- Generated on %DATE% at %TIME: =0% by %~n0
   ECHO @ECHO OFF
   ECHO :WaitUntil
   ECHO  SLEEP 5
   ECHO  FOR /F "TOKENS=*" %%%%d IN ^('DATEINFO -S %#DATEFMT% -Q 2^^^>NUL'^) DO SET "#CURRENT_TIME=%%%%d"
   ECHO  TASKLIST /FI "IMAGENAME EQ %#GETINPUT_RND%" ^| FIND /I "%#GETINPUT_RND%"
   ECHO  IF ERRORLEVEL 1 GOTO :Finish
   ECHO  IF "%%#CURRENT_TIME%%" LSS "%#WAITUNTIL%" GOTO :WaitUntil
   ECHO :Continue
   ECHO  ECHO Too Slow... ^>"%#TIMEOUT_FLAG%"
   ECHO  TASKKILL /F /IM %#GETINPUT_RND% /T
   ECHO :Finish
   ECHO  EXIT
 ) >"%#TIMER_SCRIPT%"


:GenerateUniqueExe -- Generate a Unique Instance of GetInput.exe
 FOR /F "TOKENS=*" %%F IN ('FINDFILES -F GETINPUT.EXE 2^>NUL') DO SET "#GETINPUT_SOURCE=%%~F" // Get the current location automatically from path or current folder
 COPY "%#GETINPUT_SOURCE%" "%TEMP%\%#GETINPUT_RND%" /Y
 IF ERRORLEVEL 1 (
	 ECHO *** ERROR Copying "%#GETINPUT_SOURCE%" to "%TEMP%\%#GETINPUT_RND%"
	 GOTO :ExitBatch
 )


:Ask4Input -- Spawn Temp Script and Ask User for Input
 ECHO:
 ECHO Hello %Username%
 ECHO Today is %DATE% and %TIME%
 ECHO You have 5 minutes (until %#WAITUNTIL%) to type the pass code.
 ECHO:
 START /MIN "Process Watchdog" "%#TIMER_SCRIPT%"
 FOR /F "TOKENS=*" %%I IN ('%TEMP%\%#GETINPUT_RND% -p "Please enter the pass code: " -Q 2^>NUL') DO SET "#QQ=%%I"
 IF "%#QQ%"=="5minleft" GOTO :Success

 rem -- Generate Error Message via VBScript
 IF EXIST "%#TIMEOUT_FLAG%" ( SET "#ERRORMSG=%#ERRORMSG2%" ) ELSE ( SET "#ERRORMSG=%#ERRORMSG1%" )
 ECHO Msgbox "Acess Denied", vbcritical, "%#ERRORMSG%" >"%#VBSCRIPT%"
 START /MIN "Error Message" "%#VBSCRIPT%"
 GOTO :CleanUp


:Success -- Execute commands related to mission success 
 ECHO:
 ECHO Success!!!
 ECHO Success!!!
 REM cd /D C:\Users\%username%\Desktop
 REM echo https://www.reddit.com/?feed=home >> "1.txt"
 REM echo.
 REM echo.
 REM echo GOTCHA! Check your desktop.
 REM echo.
 REM echo.
 REM etc....


:CleanUp -- Get Rid of Temp Files Unless in Debug Mode
 IF NOT DEFINED DEBUG FOR %%V IN ("%#GETINPUT_RND%" "%#TIMER_SCRIPT%" "%#VBSCRIPT%" "%#TIMEOUT_FLAG%") DO IF EXIST "%%~V" DEL "%%~V" >NUL 2>&1


:ExitBatch
 TIMEOUT 60
 ENDLOCAL
 EXIT /B 
