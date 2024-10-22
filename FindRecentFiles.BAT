@REM - FindRecentFiles.BAT (21 Oct 2024 // 21 Oct 2024): Find files that are no more than 48 hours (2 days) old
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1g94c24/comment/lt40xus/
@ECHO OFF

 :::  This script will find all files in a given folder that are no more than 2 days
 :::  old. To run this script as is, you will also need the DATEINFO.EXE utility.  You 
 :::  can also perform the date calculations natively, but I prefer to use my utility:
 :::
 :::    DATEINFO.EXE - https://www.majorgeeks.com/files/details/dateinfo.html
 :::
 :::  You would call this from the command-line as:
 :::    FindRecentFiles.BAT [path_to_check]  [max_age]
 :::
 :::  If no parameter is provided, it will check the current directory tree for 
 :::  files up to 2 days old
 ::: -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/FindRecentFiles.BAT
 :::
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.0
 SETLOCAL 
 SET #FILECOUNT=0
 SET #FOLDER=%~1& IF "%~1"=="" SET #FOLDER=%CD%
 SET #FOLDER=%#FOLDER:\\=\%
 SET #FOLDER=%#FOLDER%?
 SET #FOLDER=%#FOLDER:\?=%
 SET #FOLDER=%#FOLDER:?=%
 SET #RECENT=%~2& IF "%~2"=="" SET #RECENT=2
 SET #SEARCHDATE=& FOR /F "TOKENS=2 DELIMS=." %%D IN ('DATEINFO -p %#RECENT% "mm/dd/yyyy"') DO SET #SEARCHDATE=%%D
 SET #DATE_TIME=mm/dd/yyyy hh:mm:ss AM/PM
 SET #FORFILES=FORFILES -p "%#FOLDER%" -m *.* -s -d +%#SEARCHDATE% -c "CMD /C IF @ISDIR==FALSE ECHO	@FDATE	@FTIME	@PATH"


:Main -- Generate the List of Recent Files using FORFILES
 ECHO Searching for Recently Changed Files...
 ECHO:
 ECHO  --- Start Search In .... "%#FOLDER%"
 ECHO  --- Maximum File Age ... %#RECENT% days
 ECHO:
 
 PUSHD %#FOLDER%
 FOR /F "TOKENS=*" %%v IN ('%#FORFILES% 2^>NUL') DO (
	 SET /A #FILECOUNT+=1
	 ECHO     %%~v
 )

 ECHO:
 ECHO Recently Modified Files Found: %#FILECOUNT%


:ExitBatch -- Reset Environment Variables and Exit Batch File
 ENDLOCAL
 POPD
 EXIT /B 
                                                      