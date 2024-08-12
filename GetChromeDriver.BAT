@REM - GetChromeDriver.BAT (12 Aug 2024 // 12 Aug 2024): Get Latest Version of Chrome Driver via JSON endpoints list
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1eqa99v/comment/lhrdlbu/
@ECHO OFF

 :::  This script will return the URL to download the most current version of
 :::  the Chrome Driver. It relies on a 3rd party utility: READABLE.EXE
 :::  (https://www.majorgeeks.com/files/details/readable.html)
 :::
 :::  The URL for the Chrome Driver has to be extracted from this seriously minified
 :::  URL: https://googlechromelabs.github.io/chrome-for-testing/ 
 :::
 :::  The first valid entry in the list is the stable ones. After that, you'll see
 :::  Beta, Dev and Canary editions.  The #DOWNLOAD_URL variable will contain the 
 :::  first entry found in the list.
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/GetChromeDriver.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables
 SETLOCAL

 SET "#SOURCE=https://googlechromelabs.github.io/chrome-for-testing/"
 SET "#HTML=%TEMP%\HTML_Contents.TXT"
 SET "#REPLACE=%TEMP%\Replacement.TXT"
 SET "#SEARCHFOR=win32/chromedriver"


:MakeReplacement -- Generate Replacement Config File for READABLE
 (	 ECHO ^<;\n^<
	 ECHO ^>;^>\n
 ) >"%#REPLACE%"


:GetLatestURL -- Parse the URL contents using READABLE and FINDSTR to isolate the desired URLs
 CURL "%#SOURCE%" -o "%#HTML%"
 FOR /F "TOKENS=*" %%U IN ('READABLE "%#HTML%" -f "stable" -x -r "%#REPLACE%" ^| FINDSTR /I "%#SEARCHFOR%"') DO IF NOT DEFINED #DOWNLOAD_URL SET "#DOWNLOAD_URL=%%~U"
 ECHO:
 ECHO Latest Stable Chrome Driver is: "%#DOWNLOAD_URL%"


:ExitBatch
 TIMEOUT 60
 ENDLOCAL
 EXIT /B
