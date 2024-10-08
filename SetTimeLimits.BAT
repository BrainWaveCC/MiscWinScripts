@REM - SetTimeLimits.BAT (04 Aug 2024 // 04 Aug 2024): Wait for input until a particular time in the future
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1eiqd2i/comment/lgihm4b/
@ECHO OFF

 :::  The goal of this script is to offer the user a limited time to provide input
 :::  via a process that would otherwise wait indefinitely.  This works by spawning
 :::  a process with a unique name, and tracking its runtime for a defined window of
 :::  time with a random script that is also spawned.  If the time has passed, the
 :::  second script will kill the unique process name, and the first script will be
 :::  able to continue with input failure, and will update the user accordingly.
 :::
 :::  To make it more concise, the first script both generates and spawns the second
 :::  script that performs the watchdog functions.
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
 :::  Full scripts can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/SetTimeLimits.BAT
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/SetTimeLimits2.BAT
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Check4Essentials -- Check for Essential Utilities
 FINDFILES -w -m -f DATEINFO.EXE GETINPUT.EXE SLEEP.EXE TASKKILL.EXE TASKLIST.EXE TIMEOUT.EXE
 IF ERRORLEVEL 64 GOTO :ExitBatch


:Variables -- Initialize Environment Variables
 SETLOCAL
 SET "#ERRORMSG1=Wrong answer, buddy!"            // Default Error message for wrong input
 SET "#ERRORMSG2=You ran out of time, buddy!"     // Error message for waiting too long
 SET "#PROCHEADER=## Process Watchdog ##"         // Header for Process Watchdog CMD Window
 SET "#TIMEOUT_FLAG=%TEMP%\TooSlow-%RANDOM%.$$$"  // Flag to generate when time has expired
 SET "#VBSCRIPT=%TEMP%\ErrorMsg.vbs"              // VB Scripts that will display the message box
 SET "#TIMER_SCRIPT=%TEMP%\%~n0-%RANDOM%.BAT"     // Temporary script to generate for checking waiting time
 SET "#GETINPUT_RND=GetInput-%RANDOM%.EXE"        // Temporary Edition of GetInput.exe to be tracked by WatchDog process
 SET "#DATEFMT=-F "mm/dd/yyyy hh:nn:ss""          // date/time format for routines

 rem -- Get the time or date/time when the script should continue after waiting; if no value, set 5 min from now
 FOR /F "TOKENS=*" %%D IN ('DATEINFO -S %#DATEFMT% -Q 2^>NUL') DO SET "#START_TIME=%%D"
 FOR /F "TOKENS=*" %%D IN ('DATEINFO -Z "00:05:01" %#DATEFMT% -Q 2^>NUL') DO SET "#DEFAULT_TIME=%%D"
 IF "%~1"=="" (
	 SET "#WAITUNTIL=%#DEFAULT_TIME%"
 ) ELSE (
	 FOR /F "TOKENS=1-3" %%D IN ('DATEINFO -S "%~1" %#DATEFMT% -Q 2^>NUL') DO (
		 IF "%%~F"=="" (SET "#WAITUNTIL=%%D %%E") ELSE (SET "#WAITUNTIL=%#DEFAULT_TIME%")
	 )
 )

 rem -- Determine if supplied time is in the future or past
 IF "%#START_TIME%" GEQ "%#WAITUNTIL%" (
	 SET "#DURATION=0"
 ) ELSE (
	 FOR /F "TOKENS=*" %%T IN ('DATEINFO -T "%#WAITUNTIL%" -E "minutes" -Q 2^>NUL') DO SET /A "#DURATION=%%T"
 )


:GenerateTempScript -- Generate TimerScript to track waiting time
 ( ECHO @rem -- Generated on %DATE% at %TIME: =0% by %~n0
   ECHO @ECHO OFF
   ECHO  TITLE %#PROCHEADER%
   ECHO  SLEEP 1
   ECHO :WaitUntil
   ECHO  IF NOT "%#DURATION%"=="0" SLEEP 5
   ECHO  FOR /F "TOKENS=*" %%%%d IN ^('DATEINFO -S %#DATEFMT% -Q 2^^^>NUL'^) DO SET "#CURRENT_TIME=%%%%d"
   ECHO  TASKLIST /FI "IMAGENAME EQ %#GETINPUT_RND%" ^| FIND /I "%#GETINPUT_RND%"
   ECHO  IF ERRORLEVEL 1 EXIT
   ECHO  IF "%%#CURRENT_TIME%%" LSS "%#WAITUNTIL%" GOTO :WaitUntil
   ECHO :Continue
   ECHO  ECHO Too Slow... ^>"%#TIMEOUT_FLAG%"
   ECHO  TASKKILL /F /IM %#GETINPUT_RND% /T
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
 ECHO Today is %DATE% at %TIME%
 ECHO You have about %#DURATION% minute(s) -- until %#WAITUNTIL% -- to type in the pass code.
 ECHO:
 START /MIN "%#PROCHEADER%" "%#TIMER_SCRIPT%"
 FOR /F "TOKENS=*" %%I IN ('%TEMP%\%#GETINPUT_RND% -p "Please enter the pass code: " -Q 2^>NUL') DO SET "#QQ=%%I"
 IF "%#QQ%"=="5minleft" GOTO :Success

 rem -- Generate Error Message via VBScript
 IF EXIST "%#TIMEOUT_FLAG%" ( SET "#ERRORMSG=%#ERRORMSG2%" ) ELSE ( SET "#ERRORMSG=%#ERRORMSG1%" )
 ECHO Msgbox "Acess Denied", vbcritical, "%#ERRORMSG%" >"%#VBSCRIPT%"
 START /MIN "Error Message" "%#VBSCRIPT%"
 GOTO :CleanUp


:Success -- Execute commands related to mission success
 ECHO Congratulations!!! You have met with success!!!
 ECHO:
 REM Info from original script follows below...
 REM  cd /D C:\Users\%username%\Desktop
 REM  echo https://www.reddit.com/?feed=home >> "1.txt"
 REM  echo.
 REM  echo.
 REM  echo GOTCHA! Check your desktop.
 REM  echo.
 REM  echo.
 REM  etc....


:CleanUp -- Get Rid of Temp Files Unless in Debug Mode
 IF NOT DEFINED DEBUG (
	 ECHO Cleaning Up Temp Files/Processes...  Please Wait...
	 FOR /F "TOKENS=2" %%P IN ('TASKLIST /V ^| FIND "%#PROCHEADER%"') DO TASKKILL /PID %%P /T /F >NUL 2>&1
	 FOR %%V IN ("%#GETINPUT_RND%" "%#TIMER_SCRIPT%" "%#VBSCRIPT%" "%#TIMEOUT_FLAG%") DO IF EXIST "%%~V" DEL "%%~V" >NUL 2>&1
 )


:ExitBatch
 TIMEOUT 60
 ENDLOCAL
 EXIT /B
