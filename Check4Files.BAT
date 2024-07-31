@REM - Check4Files.BAT (31 Jul 2024 // 31 Jul 2024): Check for specific files and send alert
@ECHO OFF
 
 ::: This script will search a folder and its subfolders for any files matching a specific 
 ::: pattern that you supply.  If any files are found, they will be mailed via a Notification
 ::: alert.
 :::
 ::: You would call this from the command-line as:
 :::   Check4Files.BAT [starting_search_folder] [search_pattern(s)] [logfile_to_capture_search_info]
 ::: -----------------------------------------------
 :::
 :::
 ::: Full script can be found here:
 :::     https://github.com/BrainWaveCC/MiscWinScripts/blob/main/Check4Files.BAT
 :::
 ::: Running Check4Files without any parameters, is equivalent to the following:
 :::     Check4Files.BAT "D:\LogFiles" "*(by* *(from*" "D:\Temp\Logs\FoundFiles.TXT" 
 :::


:Variables
 SETLOCAL
 SET "#ROOTDIR=%~1"& IF "%~1"=="" SET "#ROOTDIR=D:\LogFiles"
 SET "#SEARCH=%~2"&  IF "%~2"=="" SET "#SEARCH=*(by* *(from*"
 SET "#LOGFILE=%~3"& IF "%~3"=="" SET "#LOGFILE=D:\Temp\Logs\FoundFiles.TXT"
 SET "#MAILSERVER=mail.somedomain.local 
 SET "#MAILSENDER=Notification@somedomain.local
 SET "#RECIPIENTS=Me@mydomain.com, You@mydomain.com
 SET "#MAILPORT=25"
 SET "#SUBJECT=Notification Email: Files Found"


:Search4Files
 IF EXIST "%#LOGFILE%" DEL "%#LOGFILE%"
 FOR /R "%#ROOTDIR%" %%F IN (%#SEARCH%) DO ECHO FILE FOUND: "%%~F" >>"%#LOGFILE%"


:SendNotification -- using BLAT.EXE
 IF EXIST "%#LOGFILE%" (
	 BLAT -install %@MAILSERVER% %@MAILSENDER% 2 %@MAILPORT%
	 BLAT "%#LOGFILE%" -f %#MAILSENDER% -to %%~V -s "%#SUBJECT%"
 )

 
:ExitBatch
 IF EXIST "%#LOGFILE%" TYPE "%#LOGFILE%"
 TIMEOUT 60
 ENDLOCAL
 EXIT /B 
