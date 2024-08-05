@REM - SetTimeLimits2.BAT (04 Aug 2024 // 04 Aug 2024): Wait for input until a particular time in the future
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1eiqd2i/comment/lgihm4b/
@ECHO OFF

 :::  This is a simpler version of the SetTimeLimits.BAT script, which operates more
 :::  like the solution suggested by the following Reddit user:
 :::     https://www.reddit.com/r/Batch/comments/1eiqd2i/comment/lg8hj1x/
 :::
 :::  Instead of picking a time, you just pick the total number of seconds that will
 :::  be allowed for the duration.  A unique process is still spawned, but this time
 :::  we just wait for the duration to expire before attempting to kill the process
 :::  if it is available.  Be advised that the WatchDog process will remain until
 :::  the entire duration has expired.
 :::
 :::  No date/time conversation is necessary.
 :::
 :::  As before, this main script both generates and spawns the second script that will
 :::  wait the appointed time and kill the other process if necessary.
 :::
 :::  You would call this from the command-line as:
 :::    SetTimeLimits2.BAT [time_in_seconds]
 :::
 :::  If you do not provide a time or date and time, the script will default to waiting
 :::  for 5 minutes (300 seconds) for the user to provide input.
 ::: -----------------------------------------------
 :::
 :::  This script relies on three of my 3rd party utilities:
 :::   - GetInput.exe ...... to get the actual input from the user with a discrete process
 :::   - FindFiles.exe** ... to find the executables anywhere in the path.
 :::
 :::  ** = Could be done natively, using WHERE.EXE, but I'm biased
 :::
 :::  https://www.majorgeeks.com/files/details/getinput.html
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
 FINDFILES -w -m -f GETINPUT.EXE SLEEP.EXE TASKKILL.EXE TASKLIST.EXE TIMEOUT.EXE
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

 rem -- Set the duration to user input, unless it is blank or below 60, and then set it to 300
 IF "%~1"=="" ( SET "#WAITFOR=300" ) ELSE ( SET /A "#WAITFOR=%~1" )
 IF %#WAITFOR% LEQ 60 SET "#WAITFOR=300"


:GenerateTempScript -- Generate TimerScript to track waiting time
 ( ECHO @rem -- Generated on %DATE% at %TIME: =0% by %~n0
   ECHO @ECHO OFF
   ECHO  TITLE %#PROCHEADER%
   ECHO  TIMEOUT %#WAITFOR% /NOBREAK
   ECHO  TASKLIST /FI "IMAGENAME EQ %#GETINPUT_RND%" ^| FIND /I "%#GETINPUT_RND%"
   ECHO  IF ERRORLEVEL 1 EXIT
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
 ECHO You have %#WAITFOR% seconds to type in the pass code.
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
