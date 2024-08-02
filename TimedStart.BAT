@REM - ASB (06 Jun 2024 // 06 Jun 2024): Check for Earliest Start Date
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1d9etv4/comment/l7e1t57/
@ECHO OFF


 rem -- Initialize Environment Variables
:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION

 rem -- Main Variables
 SET "@INTERVAL=28"
 SET "@R_KEY=HKCU\Software\BWCC\%~n0"
 SET "@R_VAL=NextRunTime"
 SET "@R_TYPE=REG_SZ"
 SET "@METHOD=REGISTRY"
 SET "@ROOTDIR=%SystemDrive%\Temp"
 SET "@FLAG=%@ROOTDIR%\NextDate.TXT"


 rem -- Get Date Info (using DateInfo.exe)
 rem -- https://www.majorgeeks.com/files/details/dateinfo.html
 rem -- Yes, you can do the date manipulation 100% natively, but I hated date calculations enough to write a utility to not have to deal with them any more.  LOL.  So I don't.
 FOR /F "TOKENS=1" %%N IN ('DATEINFO -s -a %@INTERVAL% -f "yyyy-mm-dd" -q') DO SET "@NEXTRUN=%%N"
 FOR /F "TOKENS=1-4" %%D IN ('DATEINFO -s -f "yyyy-mm-dd yyyy mm dd" -q') DO (
	 SET "@TODAY=%%D"
	 SET "@YYYY=%%E"
	 SET "@MM=%%F"
	 SET "@DD=%%G"
 )


 rem -- Check for Valid Date Entry
:CheckDateEntry
 FOR /F "TOKENS=3" %%R IN ('REG QUERY "%@R_KEY%" /V "%@R_VAL%" 2^>NUL') DO SET @COMPARE=%%~R

 rem -- Check for Registry Key, and if not exist, fall-back to File-based Flag
 IF NOT DEFINED @COMPARE (
	 SET @METHOD=FILE-BASED FLAG
	 IF NOT EXIST "%@ROOTDIR%" MD "%@ROOTDIR%" >NUL 2>NUL
	 IF NOT EXIST "%@FLAG%" GOTO :DoWork

	 rem -- Read Date from Flag File
	 rem -- Valid File Format = "Next-Run-Date: yyyy-mm-dd"
	 FOR /F "TOKENS=2 USEBACKQ DELIMS=|" %%D IN ("%@FLAG%") DO SET @COMPARE=%%D
 )

 rem -- This next command is just there to force testing without having to change date/time on the computer.
 rem -- Run it as BATCH-NAME 2024-01-01 and it will pretend that the date it read from the file is 2024-01-01 and run accordingly
 rem -- You will want to remove it in production
 IF NOT "%~1"=="" SET @COMPARE=%~1

 rem -- If File is Empty or Not Formatted Properly, Go Do Regular Work
 IF NOT DEFINED @COMPARE GOTO :DoWork

 rem -- Once you have the new date, compare it (@COMPARE) against the current date in the same format (@TODAY)
 IF "%@TODAY%" LSS "%@COMPARE%" (
	 ECHO Not valid for execution before "%@COMPARE%" via %@METHOD%
	 GOTO :ExitBatch
 )


 rem -- Do Main Work
:DoWork
 ECHO DO WORK HERE...
 ECHO DO WORK HERE...
 ECHO DO WORK HERE...
 ECHO DO WORK HERE...
 ECHO DO WORK HERE...
 ECHO DO WORK HERE...
 ECHO:


 rem -- Save Next Earliest Date for Execution (Try Registry, then fall-back to File-based Flag as Needed)
:SaveNextDate
 REG ADD "%@R_KEY%" /V %@R_VAL% /T %@R_TYPE% /D %@NEXTRUN% /F

 rem -- If you don't care about a fall-back to file-based Flag, then the next two commands are unnecessary
 FOR /F "TOKENS=3" %%R IN ('REG QUERY "%@R_KEY%" /V "%@R_VAL%" 2^>NUL') DO SET @REG_QUERY=%%~R
 IF NOT DEFINED @REG_QUERY ECHO Next-Run-Date^|%@NEXTRUN%>"%@FLAG%"
 rem -- You don't have to make the date as the second parameter in the FLAG file, but it helps to ensure that it was your script that wrote the file.

 rem -- The next three lines are just debug lines to verify the output for testing
 ECHO NEXT EARLIEST RUN DATE ... %@NEXTRUN%
 ECHO REGISTRY VALUE ........... %@REG_QUERY%
 DIR "%@FLAG%" | FIND /I "%@FLAG:~-4%"
 TYPE "%@FLAG%"


 rem -- Reset Environment Variables and Exit Batch File
:ExitBatch
 ENDLOCAL
 EXIT /B
