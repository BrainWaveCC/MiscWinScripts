@REM - RemoveOldAdmins.BAT (16 Aug 2024 // 16 Aug 2024): Remove unwanted users from local Administrators group
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1etyska/comment/ligtxf4/
@ECHO OFF

 :::  This script will delete all the accounts from the local Administrators group
 :::  except for accounts listed in the #KEEP_USERS variable.  Use with caution.
 :::
 :::  You would call this from the command-line as:
 :::    RemoveOldAdmins.BAT [optional_parameter]
 :::
 :::  If no parameter is provided, it will only list the status, but not actually
 :::  delete anything.
 ::: -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/RemoveOldAdmins.BAT
 :::
 :::  Related scripts include:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/DeleteSomeAdmins.BAT
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables - v1.0.0
 SETLOCAL

 rem -- Define exemption list of users to remain in the Administrators group
 SET "#KEEP_USERS="domain\admin_name" "keep_this_admin" "Administrator" "Domain\TheAdmin""
 SET "#LOGFILE=%TEMP%\Cleanup.log"

 rem -- Provide any parameter to actually delete the accounts
 rem -- (uncomment this SET command to gain some protection)  SET "#ECHO=" & IF "%~1"=="" SET "#ECHO=ECHO"


:ProcessAccounts -- Enumerate local Adminstrator accounts and process accordingly
 ECHO Admin cleanup started at %date% %time% >>"%#LOGFILE%"

 FOR /F "SKIP=6 TOKENS=*" %%A IN ('NET LOCALGROUP Administrators ^| FIND /I /V "The command completed successfully." ') DO (
	 SET "#EXEMPT="
	 FOR %%K IN (%#KEEP_USERS%) DO IF /I "%%~K"=="%%~A" SET "#EXEMPT=TRUE"
	 IF DEFINED #EXEMPT (
		 ECHO  *** NO DELETION: %%~A is an exempt account...
		 ECHO:
	 ) ELSE ( rem -- Remove the user if it's not in the KEEP_USERS list
		 ECHO Preparing to delete "%%~A" from the Administrators group  >>"%#LOGFILE%"
		 %#ECHO% NET LOCALGROUP Administrators "%%~A" /DELETE          2>>"%#LOGFILE%"
		 ECHO:
	 )
 )
 ECHO Admin cleanup finished at %date% %time% >>"%#LOGFILE%"


:ExitBatch -- Wrap things up and exit
 IF EXIST "%#LOGFILE%" TYPE "%#LOGFILE%"
 TIMEOUT 60
 ENDLOCAL
 EXIT /B
