@REM - HighPriority.BAT (15 Jul 2024 // 15 Jul 2024): Start a process (Wordpad) and then elevate its priority via WMIC
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1e3ouqf/comment/ldaomkd/
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET "#EXE_LAUNCH=Write"
 SET "#EXE_VERIFY=Wordpad.exe"
 SET "#PRI_LEVEL=High Priority"
 SET "#PRI_LEVEL=Above Normal"


:LaunchApp - Start up the %#EXE_LAUNCH%
 START "Starting %#EXE_LAUNCH%" %#EXE_LAUNCH%


:Wait4Exe - Wait until %#EXE_LAUNCH% is available
 ECHO Waiting for "%#EXE_VERIFY%" ...
 TASKLIST /FI "IMAGENAME eq %#EXE_VERIFY%" | FIND /v "No tasks" >NUL
 TIMEOUT 5
 IF ERRORLEVEL 1 GOTO :Wait4Exe


:SetPriority - Set priority to High
 WMIC PROCESS WHERE NAME="%#EXE_VERIFY%" CALL SETPRIORITY "%#PRI_LEVEL%"


:ExitBatch
 ENDLOCAL
 TIMEOUT -1
 EXIT /B
