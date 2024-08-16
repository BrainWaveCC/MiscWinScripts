@REM - MakeShortcuts.BAT (16 Aug 2024 // 16 Aug 2024): Create Shortcuts on the Public Desktop
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1etrbdx/comment/ligfkqx/
@ECHO OFF

 :::  This script will create desktop shortcuts to Internet resources and 
 :::  write them to the public desktop.  Individual destinations should
 :::  be stored in the #SHORTCUTxx variables.  The format of the variables
 :::  is #SHORTCUTxx={name of shortcut file};{the destination url}
 :::
 :::  Notice that the #SHORTCUTxx variable must be uniquely named, and that 
 :::  a semicolon is the delimiter between the filename and the destination url.
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/MakeShortcuts.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.0
 SETLOCAL
 SET "#DESTINATION=%SystemDrive%\Users\Public\Desktop"
 SET "#SHORTCUT01=Google Chrome;https://googlechromelabs.github.io/chrome-for-testing/"
 SET "#SHORTCUT02=Microsoft;https://www.microsoft.com/"
 SET "#SHORTCUT03=Wikipedia;https://www.wikipedia.com/"
 SET "#SHORTCUT04=M365;https://office.microsoft.com/"
 SET "#SHORTCUT05=Somewhere Else;https://www.google.com/"


:MakeShortcuts -- Parse Shortcut Variables and Generate New Shortcuts
 FOR /F "TOKENS=2-3 DELIMS=;=" %%U IN ('SET #SHORTCUT 2^>NUL') DO (
	 ECHO Saving "%%~V" as "%#DESTINATION%\%%~U.url" ...
	 ( ECHO [InternetShortcut]& ECHO URL=%%~V) >"%#DESTINATION%\%%~U.url" 
 )


:ExitBatch -- Wrap things up and exit
 TIMEOUT 60
 ENDLOCAL
 EXIT /B
