@REM - FindRecentFiles2.BAT (21 Oct 2024 // 21 Oct 2024): Find files that are no more than 48 hours (2 days) old
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1g94c24/comment/lt40xus/
@ECHO OFF

 :::  This script will find all files in a given folder that are no more than 2 days
 :::  old, but is based on the FILEHASH.EXE utility.  It is faster than the script 
 :::  based on FORFILES:
 :::
 :::    FILEHASH.EXE - https://www.majorgeeks.com/files/details/filehash.html
 :::
 :::  You would call this from the command-line as:
 :::    FindRecentFiles2.BAT [path_to_check]  [max_age]
 :::
 :::  If no parameter is provided, it will check the current directory tree for 
 :::  files up to 2 days old
 ::: -----------------------------------------------
 :::
 :::  Both scripts can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/FindRecentFiles.BAT
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/FindRecentFiles2.BAT
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
 SET #FOLDER=%~1& IF "%~1"=="" SET #FOLDER=%CD%
 SET #FOLDER=%#FOLDER:\\=\%
 SET #FOLDER=%#FOLDER%?
 SET #FOLDER=%#FOLDER:\?=%
 SET #FOLDER=%#FOLDER:?=%
 SET #RECENT=%~2& IF "%~2"=="" SET #RECENT=2
 SET #DATE_TIME=mm/dd/yyyy hh:nn:ss AM/PM


:Main -- Generate the List of Recent Files using FILEHASH
 ECHO Searching for Recently Changed Files...
 ECHO:
 ECHO  --- Start Search In .... "%#FOLDER%"
 ECHO  --- Maximum File Age ... %#RECENT% days
 ECHO:
 FILEHASH --XX64 -C -# -Z -S --NEWER-THAN=%#RECENT% --DF="%#DATE_TIME%" -R -D "%#FOLDER%" 2>NUL


:ExitBatch -- Reset Environment Variables and Exit Batch File
 ENDLOCAL
 POPD
 EXIT /B 
                                                                           