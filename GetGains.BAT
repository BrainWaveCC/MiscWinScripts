@REM - ASB (08 Jun 2024 // 08 Jun 2024): Get Gains Transferred from One Config File to Another
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dba92w/comment/l7rbihh/
@ECHO OFF


 rem -- Initialize Environment Variables
:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION

 SET "@MAX=99"
 SET "@ROOT_DIR=%SystemDrive%\Temp\%~n0"
 SET "@SOURCE=%@ROOT_DIR%\GetGains-Input.TXT"
 SET "@DEST=%@ROOT_DIR%\GetGains-Configuration.TXT"
 SET "@BACKUP=%@ROOT_DIR%\Configuration.Backup.TXT"
 SET "@SEARCH=Filter"


 rem -- Get Values from Source File
:GetValues
 FOR /F "TOKENS=2,9 DELIMS=: " %%L IN ('TYPE "%@SOURCE%" ^| FIND "%@SEARCH% " 2^>NUL') DO SET @GAIN%%~L=%%~M


 rem -- Set Values into Configuration File
:SetValues
 IF NOT DEFINED @GAIN1 GOTO :ExitBatch

 rem -- Next 4 Lines are Just Some Housekeeping for Testing
 ECHO Creating Backup of Configuration File
 COPY "%@DEST%" "%@BACKUP%" /Y
 IF EXIST "%@DEST:TXT=OLD%" DEL "%@DEST:TXT=OLD%"
 RENAME "%@DEST%" *.OLD

 rem -- Loop through Backup Copy of the Config File and search for "[Gains]" or "Gain#"
 FOR /F "USEBACKQ TOKENS=*" %%V IN ("%@BACKUP%") DO (
	 SET @HEADING=%%V
	 SET @HEADING=!@HEADING:~0,7!
	 SET @PREFIX=!@HEADING:~0,4!
	 IF NOT "!@PREFIX!"=="Gain" ECHO %%V>>"%@DEST%"

	 rem -- When you get to the "[Gains]" section, just replace all the Gain#= entries with @GAIN# variables
	 IF "!@HEADING!"=="[Gains]" FOR /L %%G IN (1,1,%@MAX%) DO IF DEFINED @GAIN%%~G ECHO Gain%%~G=!@GAIN%%~G!>>"%@DEST%"
 )


 rem -- Reset Environment Variables and Exit Batch File
:ExitBatch
 FOR %%V IN ("%@SOURCE%" "%@DEST%") DO TYPE %%V
 ENDLOCAL
 EXIT /B
