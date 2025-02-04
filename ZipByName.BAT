@REM - ZipByName.BAT (03 Feb 2025 // 03 Feb 2025): Create zip folders based on the name of the files found
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1ih4v5s/batch_creating_multiple_zip_folders_based_on/
@ECHO OFF

 :::  This script will search the specified source folder for files to zip up by
 :::  name.  It will create the zip archives in a subfolder to the source, using
 :::  the native tar command in Windows 10 and 11.
 :::
 :::  You can run it at the command-line or directly in explorer:
 :::    ZipByName.BAT 
 :::
 ::: -----------------------------------------------
 :::  This script can be found in the followig locations:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/ZipByName.BAT
 :::      https://pastebin.com/SPNKHq5z
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
 SET "#SOURCE=C:\Temp\Other"
 SET "#DEST=%#SOURCE%\Zips"
 SET "#SKIP=--exclude *.ZIP --exclude *.GZ --exclude *.TAR --exclude *.7Z"
 

 rem -- Search specified folder (but not subfolders) for files to zip, but skip all zip-type archives (*.zip, *.gz, *.tar, *.7z, etc)
:Main
 MD "%#DEST%" >NUL 2>&1
 PUSHD "%#SOURCE%
 FOR %%F IN ("%#SOURCE%\*.*") DO IF NOT DEFINED $%%~nF CALL :ZipMyFiles "%%~nF"

 
:ExitBatch
 POPD
 ECHO:
 DIR /OGD "%#DEST%"
 ENDLOCAL
 EXIT /B


:ZipMyFiles -- Zip files by name, except zip/archival type files (%1 = current file group to zip)
 SET "#ZIP=%#DEST%\%~1.zip"

 ECHO: & ECHO Creating "%#ZIP%" ...
 tar -cf "%#ZIP%" -v %#SKIP% "%~1.*" && SET "$%~1=TRUE"
 GOTO :EOF
    