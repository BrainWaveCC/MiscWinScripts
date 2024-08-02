@REM - GetDateBWCC.BAT (01 Aug 2024 // 01 Aug 2024): Get Current Date via WMIC and Calculate Last Month/Year
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1ehrikt/comment/lg23tze/
@ECHO OFF

 :::  This is a modified version of the GetDateWMIC.BAT script that uses my DATEINFO
 :::  utility to do date and time calculations, avoiding fun with octal math, among
 :::  other things, which can manifest you get to August and September (08 and 09).
 :::
 :::  I ran into this some years ago, and it was one of the catalysts FOR me creating
 :::  the DATEINFO.EXE utility: https://www.majorgeeks.com/files/details/dateinfo.html
 :::
 :::  See GetDateWMIC.BAT at my GitHub scripts repository FOR the originalversion:
 :::  https://github.com/BrainWaveCC/MiscWinScripts
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple SET @ or SET # 
 :::        command will expose all my variables at one time.
 :::


:Variables -- Initialize Environment Variables
 SETLOCAL

 rem -- LONG METHOD: Get the current year and month (this is only to provide calculations for the next DATEINFO call)
 FOR /F "TOKENS=1-2" %%D IN ('DATEINFO -S -F "yyyy mm" -Q') DO (
	 SET "#CURRENT_YEAR=%%D"
	 SET "#CURRENT_MONTH=%%E"
	 SET "#CURRENT_YYYY_MM=%%D-%%E"
 )

 rem -- LONG METHOD: Get the previous year and month (by selecting the first day of the current month, then going back one day)
 FOR /F "TOKENS=1-2" %%D IN ('DATEINFO -S "%#CURRENT_MONTH%/01/%#CURRENT_YEAR%" -P 1 -F "yyyy mm" -Q') DO (
	 SET "#PREVIOUS_YEAR=%%D"
	 SET "#PREVIOUS_MONTH=%%E"
	 SET "#PREVIOUS_YYYY_MM=%%D-%%E"
 )

 rem -- SHORT METHOD: Here's a more concise way to end up with just the #PREVIOUS_YYYY_MM variable)
 FOR /F %%D IN ('DATEINFO -S -F "mm/01/yyyy" -Q') DO SET "#FIRST_DAY_OF_MONTH=%%D"
 FOR /F %%D IN ('DATEINFO -S "%#FIRST_DAY_OF_MONTH%" -P 1 -F "yyyy-mm" -Q') DO SET "#PREVIOUS_YYYY_MM=%%D"

 rem -- set Source and Destination folder names
 SET "#SOURCE_FOLDER=TEMPLATE_FOLDER"
 SET "#DEST_FOLDER=%#PREVIOUS_YYYY_MM%"


:ProcessFolders -- Validate existence of destination folder, and create if necessary
 IF EXIST "%#DEST_FOLDER%\*" (
	 ECHO Destination folder already exists. Skipping duplication.
 ) ELSE (
	 rem -- Duplicate the source folder to the destination folder
	 ECHO *** XCOPY /E /I "%#SOURCE_FOLDER%" "%#DEST_FOLDER%" ***
	 ECHO Folder duplicated and renamed to "%#PREVIOUS_YYYY_MM%".
 )


:ExitBatch
 TIMEOUT 60
 ENDLOCAL 
 EXIT /B
