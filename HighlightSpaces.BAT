@REM - HighlightSpaces.BAT (13 Aug 2024 // 13 Aug 2024): Expose Spaces in File Paths
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1er3nvj/comment/lhwofz5/
@ECHO OFF

 :::  The purpose of this script is to highlight the spaces which exist anywhere in 
 :::  the file or folder path, using exclamation points "!"   This script will not 
 :::  handle exclamation points properly if ENABLEDELAYEDEXPANSION is turned on.
 :::
 :::  Most file paths should be 256 characters or less, but it is possible to have 
 :::  longer file paths in Windows, so the script checks up to 999 characters. If it 
 :::  finds a space, it changes the corresponding character in a new string to "!"
 :::  while turning every other character into a space (" ").
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/HighlightSpaces.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.0
 SETLOCAL
 SET "#FILEPATH=C:\Users\t\Downloads\KEEP FOR TESTING\"
 SET "#NEWSTR="


:MainTest -- Loop through the current filepath and check each character to substitute as outlined above
 IF DEFINED #FILEPATH FOR /L %%C IN (0,1,999) DO CALL :BuildNewStr "%%#FILEPATH:~%%C,1%%"


:ExitBatch -- Display final product and exit
 ECHO The current filepath is: "%#FILEPATH%"
 ECHO                           %#NEWSTR%
 ECHO:
 ECHO Exclamation points mark a space ^^ 
 TIMEOUT 60
 ENDLOCAL
 EXIT /B


:BuildNewStr -- SUBROUTINE: %1 = Current character to evaluate
 IF "%~1"=="" GOTO :EOF
 IF "%~1"==" " (SET "#CHAR=!") ELSE (SET "#CHAR= ")
 SET "#NEWSTR=%#NEWSTR%%#CHAR%"
 GOTO :EOF
