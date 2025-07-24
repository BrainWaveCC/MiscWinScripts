@REM - FindOldFiles.BAT (24 Jul 2025 // 24 Jul 2025): Find files in any given folder older than xxx days
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1m87xqi/removing_files_and_folders_older_than_x_days/
@ECHO OFF

 :::  This script will search for specific files within a folder tree, and display
 :::  all files that are newer than a specified number of days old.
 :::
 :::  You can run it at the command-line or directly in explorer:
 :::    FindOldFiles.BAT [Folder] [Age to Search] [Extensions]
 :::
 ::: -----------------------------------------------
 :::
 :::  This script relies on two of my 3rd party utilities:
 :::   - DateInfo.exe ....... to handle the time calcuations more easily, especially for FORFILES
 :::   - FileHash.exe ....... as a much faster alternative to the FORFILES command for display only purposes (OPTIONAL)
 :::   - CheckParams.exe .... process syntax parameters, including HELP syntax
 :::
 :::  https://www.majorgeeks.com/files/details/dateinfo.html
 :::  https://www.majorgeeks.com/files/details/filehash.html
 :::  https://www.majorgeeks.com/files/details/checkparams.html
 :::
 :::  You can download these files and put them into the folder with the script,
 :::  or anywhere in your current path.
 :::
 ::: -----------------------------------------------
 :::  This script can be found in the following locations:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/FindOldFiles.BAT
 :::      https://pastebin.com/CuFLWLeB
 :::
 :::
 :::  NOTE: I like prefacing my variables with # or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.0
 SETLOCAL ENABLEDELAYEDEXPANSION

 rem -- List of Default Extensions to Search
 SET "#DEFAULT_EXT=SYS EXE MSC MSI COM DLL OCX BAT CMD VBS WSH PS1 KIX PL PY JAVA"

 rem -- Check for Essential Utilities and/or Scripts
 FINDFILES --bw -w -m -f FORFILES.EXE -o FILEHASH.EXE
 IF ERRORLEVEL 64 GOTO :ExitBatch

 rem -- Display Syntax Help if Required/Requested
 CHECKPARAMS --rc -c "H HELP ?" -x "?? H2" -s %*
 IF ERRORLEVEL 1 IF NOT ERRORLEVEL 16 GOTO :HelpMessage

 rem -- Obtain Date/Time and Supporting Core Variables
 FOR /F "TOKENS=1-2 DELIMS=;" %%P IN ('DATEINFO --Script-Variables --Prefix^=# 2^>NUL') DO SET "%%P=%%~Q"

 rem -- Main Variables
 SET "#SHOWHELP=FALSE"
 SET "#FILECOUNT=0"
 SET "#FOLDER=%~1" & IF "%~1"=="" SET /P "#FOLDER=Please enter the base folder: "
 SET "#FOLDER=%#FOLDER:\\=\%" & SET "#WHICHDIR=!#FOLDER!"
 SET "#FOLDER=%#FOLDER%?"
 SET "#FOLDER=%#FOLDER:\?=%"
 SET "#FOLDER=%#FOLDER:?=%"
 SET "#RECENT=%~2" & IF "%~2"=="" SET /P "#RECENT=Check for files older than XX days: "
 SET "#EXTENSIONS=%~3" & IF "%~3"=="" SET "#EXTENSIONS=%#DEFAULT_EXT%"
                         IF "%#EXTENSIONS:~0,1%"=="*" SET "#EXTENSIONS=%#DEFAULT_EXT% %#EXTENSIONS:~1%"
 SET "#SEARCHDATE=" & FOR /F "TOKENS=2 DELIMS=." %%D IN ('DATEINFO -p %#RECENT% "mm/dd/yyyy"') DO SET "#SEARCHDATE=%%D"
 SET "#DATE_TIME=mm/dd/yyyy hh:nn:ss AM/PM"

 rem -- Determine if FileHash is available
 FINDFILES --RC -F FILEHASH.EXE && SET "#USE_FH= [using FileHash]"


 rem -- Generate the List of Recent Files using FORFILES or FILEHASH
:Main
 ECHO:
 ECHO Searching for Recently Changed Files... %#USE_FH%
 ECHO %#DIVIDER-%
 ECHO  --- Start Search In .... "%#WHICHDIR%"
 ECHO  --- Search For ......... %#EXTENSIONS:+=*%
 ECHO  --- Maximum File Age ... %#RECENT% days
 ECHO %#DIVIDER-%
 ECHO:
 
 IF DEFINED #USE_FH (
	 SET "#FH_EXTENSIONS="
	 FOR %%E IN (%#EXTENSIONS%) DO SET "#FH_EXTENSIONS=!#FH_EXTENSIONS! *.%%~E"
	 FILEHASH --XX64 -C -# -Z -S --NEWER-THAN=%#RECENT% --DF="%#DATE_TIME%" -R -D "%#WHICHDIR%" !#FH_EXTENSIONS!
 ) ELSE (
	 PUSHD %#WHICHDIR%
	 FOR %%E IN (%#EXTENSIONS%) DO (
		 SET #FORFILES=FORFILES -p"%#FOLDER%" -m*.%%~E -s -d+%#SEARCHDATE% -c"CMD /C IF @ISDIR==FALSE ECHO	@FDATE	@FTIME	@PATH\@FILE"
		 IF EXIST "%SystemRoot%\System32\FORFILES.EXE" (
			 SET #FORFILES=%SystemRoot%\System32\FORFILES -p "%#FOLDER%" -m *.%%~E -s -d +%#SEARCHDATE% -c "CMD /C IF @ISDIR==FALSE ECHO	@FDATE	@FTIME	@PATH"
		 )

		 ECHO  -- Searching for recently changed *.%%~E files...
		 FOR /F "TOKENS=*" %%v IN ('!#FORFILES! 2^>NUL') DO (
			 SET /A #FILECOUNT+=1
			 ECHO     %%~v
		 )
		 ECHO:
	 )

	 ECHO:
	 ECHO Recently Modified Files Found: !#FILECOUNT!
 )


 rem -- Reset Environment Variables and Exit Batch File
:ExitBatch
 ENDLOCAL
 POPD
 EXIT /B


 rem -- SUBROUTINE: Display Syntax Help if Required/Requested
:HelpMessage
 ECHO Find New Files in any Given Folder (default = Windows)
 ECHO:
 ECHO ----------
 ECHO YOU TYPED:  %0 %*
 ECHO ----------
 ECHO:
 ECHO -----------
 ECHO CMD SYNTAX:
 ECHO -----------
 ECHO  %~n0  [Folder] [Age to Search] [Extensions]
 ECHO  %~n0  -h^|-?^|-h2^|-??  
 ECHO:
 ECHO -------------------
 ECHO OPTION DEFINITIONS:
 ECHO -------------------
 ECHO  -?,  /H ..... Display This Help Message  (also --HELP)
 ECHO  -??, /H2 .... Display Extended Help Message
 ECHO:

 IF ERRORLEVEL 8 IF NOT ERRORLEVEL 16 (
	 ECHO ----------------
	 ECHO SYNTAX EXAMPLES:
	 ECHO ----------------
	 ECHO  %~n0 D:\ 20
	 ECHO  %~n0 %SystemRoot% 30 "EXE DLL"
	 ECHO  %~n0 %SystemDrive% 10 "+ EXE DLL EXT1 EXT2"
	 ECHO  %~n0 -?
	 ECHO:
	 ECHO ------------
	 ECHO USAGE NOTES:
	 ECHO ------------
	 ECHO  * Parameters surrounded by ^<^> are mandatory.
	 ECHO  * Parameters surrounded by [] are optional.
	 ECHO:
	 ECHO  * Options are case-insensitive, and can be prefaced by "-" or "/".
	 ECHO:
	 ECHO  * Default extension list = %#DEFAULT_EXT%
	 ECHO:
	 ECHO  * Use "+" to ADD to the list of currently searched extensions.
	 ECHO  * Use "*" to select an extended list of executable extensions to search.
	 ECHO  * Multiple extensions, including "+" is supplied, must be surrounded in doublequotes.
 )
  