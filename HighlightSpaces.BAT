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


:Variables -- v1.1.0
 SETLOCAL
 SET "#FILEPATH1=C:\Users\t\Downloads\KEEP FOR TESTING\"
 SET "#FILEPATH2=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\Common Extensions"
 SET "#FILEPATH3=D:\Some Random Path\That Contains Lots\Of Spaces\For Absolutely No Reason\Even a Double  Space Here"
 SET "#MAXLEN=999"


:MainTest -- Loop through multiple filepath variables, and create/display new variables as outlined above
 FOR %%P IN ("#FILEPATH1 #HIGHLIGHT1"; "#FILEPATH2 #HIGHLIGHT2"; "#FILEPATH3 #HIGHLIGHT3") DO CALL :MakeNewVar %%~P


:ExitBatch -- Display final product and exit
 rem SET #
 TIMEOUT 60
 ENDLOCAL
 EXIT /B


:MakeNewVar -- SUBROUTINE: Create Secondary Variable from Primary {%1 = source var} {%2 = dest var}
 SET "%~2="
 CALL SET "#OLDSTR=%%%~1%%"
 IF DEFINED %~1 FOR /L %%C IN (0,1,%#MAXLEN%) DO IF "%%#OLDSTR:~%%C,1%%"=="" (
	 GOTO :Continue 
 ) ELSE (
	 CALL :BuildNewStr "%%#OLDSTR:~%%C,1%%" "%~2"
 )
:Continue
 CALL SET "#NEWSTR=%%%~2%%"
 ECHO:
 ECHO The current filepath is: "%#OLDSTR%"
 ECHO                           %#NEWSTR%
 ECHO:
 ECHO Exclamation points mark a space ^^ 
 ECHO ------------------------------------------------------------------------------------------
 ECHO:
 GOTO :EOF


:BuildNewStr -- SUBROUTINE: Evaluate Characters in Old for New {%1 = Current character to evaluate}  {%2 = New Var}
 IF "%~1"=="" GOTO :EOF
 IF "%~1"==" " (SET "#CHAR=!") ELSE (SET "#CHAR= ")
 CALL SET "%~2=%%%~2%%%#CHAR%"
 GOTO :EOF
