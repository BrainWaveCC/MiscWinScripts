@REM - MoveDatedFolders.BAT (03 Feb 2025 // 03 Feb 2025): Move mm.dd.yy folders into yyyy folders
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1igptua/is_there_a_way_to_move_multiple_subfolders_to/
@ECHO OFF

 :::  This script will search the specified source folder for dated folders with
 :::  a format of mm.dd.yy and move them into a 4-digit year folder instead (yyyy).
 :::
 :::  You can run it at the command-line or directly in explorer:
 :::    MoveDatedFolders.BAT 
 :::
 ::: -----------------------------------------------
 :::  This script can be found in the followig locations:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/MoveDatedFolders.BAT
 :::      https://pastebin.com/VGDyXt9d
 :::
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.1
 SETLOCAL
 SET "#N=[0-9][0-9]"
 SET "#MMDDYY=%#N%.%#N%.%#N%"
 SET "#YYYY=%#N%%#N%"
 SET "#ROOT=C:\Temp\Testing"
 

:Main
 rem -- Cycle through folders for names with mm.dd.yy format, but not inside yyyy folders
 FOR /F "TOKENS=*" %%F IN ('DIR /S /B "%#ROOT%" ^| FINDSTR /R "%#MMDDYY%" ^| FINDSTR /V /R "%#YYYY%"') DO CALL :MoveFolders "%%~F"

 
:ExitBatch
 TREE "%#ROOT%"
 ENDLOCAL
 EXIT /B


:MoveFolders -- Move to appropriate destination folder, based on current folder name (%1 = current folder)
 SET "#DEST=%~1"
 SET "#DEST=%~1\..\20%#DEST:~-2%"
 ECHO Moving "%~1" to "%#DEST%"
 MOVE "%~1" "%#DEST%"
 GOTO :EOF
     