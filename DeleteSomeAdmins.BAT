@REM - DeleteSomeAdmins.BAT (02 Aug 2024 // 02 Aug 2024): Delete some users from the local Administrators group
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1eieloj/comment/lg6tq0k/
@ECHO OFF
 
 :::  This script will delete all the accounts from the local Administrators group 
 :::  except for accounts listed in the #KEEP_USERS variable.  Use with caution.
 :::
 :::  You would call this from the command-line as:
 :::    DeleteSomeAdmins.BAT [optional_parameter]
 :::
 :::  If no parameter is provided, it will only list the status, but not actually 
 :::  delete anything.
 ::: -----------------------------------------------
 :::
 :::  Full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/DeleteSomeAdmins.BAT
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables
 SETLOCAL

 rem -- Define exemption list of users to remain in the Administrators group
 SET #KEEP_USERS="domain\admin_name" "keep_this_admin" "Administrator"

 rem -- Provide any parameter to actually delete the accounts
 SET "#ECHO="
 SET "#DELETE=%1" & IF "%~1"=="" SET "#ECHO=ECHO"


:ProcessAccounts -- Enumerate local Adminstrator accounts and process accordingly
 FOR /F "SKIP=6 TOKENS=*" %%A IN ('NET LOCALGROUP Administrators ^| FIND /I /V "The command completed successfully." ') DO (
	 SET "#EXEMPT="
	 FOR %%K IN (%#KEEP_USERS%) DO IF /I "%%~K"=="%%~A" SET "#EXEMPT=TRUE"
	 IF DEFINED #EXEMPT (
		 ECHO  *** NO DELETION: %%~A is an exempt account...
		 ECHO:
	 ) ELSE (
        REM Remove the user if it's not in the KEEP_USERS list
        ECHO Preparing to delete "%%~A" from the Administrators group
        %#ECHO% NET LOCALGROUP Administrators "%%~A" /DELETE 
		ECHO:
	 )
 )

 
:ExitBatch
 TIMEOUT 60
 ENDLOCAL
 EXIT /B 
