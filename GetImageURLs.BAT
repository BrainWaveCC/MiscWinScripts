@REM - GetImageURLs.BAT (23 Jun 2024 // 24 Jun 2024): Get Image URLs from HTML Download
@ECHO OFF

 ::: This script will return the image URLs from an HTML page.  
 ::: I performed rudimentary testing only.  It relies on a 3rd party utility:
 ::: READABLE.EXE (https://www.majorgeeks.com/files/details/readable.html)
 ::: 
 ::: I tested https://www.newgrounds.com/art/view/thewendigo/tree and
 ::: https://www.newgrounds.com/art/view/missandydandy/punch-punch-forever
 :::
 ::: Rather than supply multiple files, I just had the script generate the 
 ::: search/replace config file used by READABLE.   
 ::: 
 ::: Once the files have been parsed, I download them to the %#SAVEDIR% folder.


:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION
 
 SET #SOURCE1=https://www.newgrounds.com/art/view/thewendigo/tree
 SET #SOURCE2=https://www.newgrounds.com/art/view/missandydandy/punch-punch-forever
 SET #HTML=%TEMP%\HTML_Contents.TXT
 SET #OUTPUT=%TEMP%\Final_Output.TXT
 SET #REPLACE=%TEMP%\Replacement.TXT
 SET #SAVEDIR=%TEMP%\%~n0


 rem -- Generate Replacement Config File for READABLE
:MakeReplacement
 IF NOT EXIST "%#REPLACE%" ( 
	 ECHO \/;/
	 ECHO \";"
	 ECHO =;\n
	 ECHO ?;\n
	 ECHO ";\n
 ) >"%#REPLACE%"

 
 rem -- Download HTML and parse it using READABLE and FINDSTR; ignore icons and thumbnails
:ProcessFile
 ( FOR /F "TOKENS=1* DELIMS==" %%V IN ('SET #SOURCE 2^>NUL') DO (
	 CURL "!%%~V!" -o "%#HTML%"
	 READABLE "%#HTML%" -f "http:;https:" -x -r "%#REPLACE%" --sk "/thumb;/icons;-icon" | FINDSTR /i ".png .jpg .jpeg" 
 )) >"%#OUTPUT%"


 rem -- Download Images to Save Directory
:DownloadImages
 IF NOT EXIST "%#SAVEDIR%" MD "%#SAVEDIR%" >NUL 2>NUL
 FOR /F "USEBACKQ TOKENS=*" %%F IN ("%#OUTPUT%") DO IF NOT DEFINED #%%~nxF (
	 CURL "%%~F" -o "%#SAVEDIR%\%%~nxF"
	 SET #%%~nxF=TRUE
 )


:ExitBatch
 ECHO:
 IF EXIST "%#OUTPUT%" TYPE "%#OUTPUT%"
 IF EXIST "%#SAVEDIR%" DIR "%#SAVEDIR%"
 TIMEOUT 60
 ENDLOCAL 
