@REM - ASB (20 Jun 2024 // 21 Jun 2024): Create New Files Per Line of Text
@ECHO OFF

 ::: This script will process an input file at the command-line or as a prompted request.
 ::: The output will be stored in the %#OUTPUT_DIR% variable (default = C:\Temp)
 ::: It will read the lines of the input file, and write that line to a file based on
 ::: the current line number (in 3-digit format: 001, 002, etc).  If the first 3 digits
 ::: of the current line (%#PREFIX%) match the count, then those 3 digits plus a space 
 ::: will be excluded from the output.  The destinaton folder will be displayed at 
 ::: the conclusion of the script.  Adjust accordingly.


:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION
 
 SET #FILENAME=%~1
 SET #OUTPUT_DIR=C:\Temp\%~n0\%RANDOM%
 SET #COUNT=0


 rem -- Get the name of the Input File
:GetFilename
 IF NOT DEFINED #FILENAME SET /P "#FILENAME=Enter a filename to process: "
 IF NOT DEFINED #FILENAME GOTO :GetFilename
 SET #FILENAME="%#FILENAME:"=%"
 
 
 rem -- Loop Through File and Save Each Line in a New File
:Main
 IF NOT EXIST "%#OUTPUT_DIR%" MD "%#OUTPUT_DIR%" >NUL 2>NUL
 IF NOT EXIST %#FILENAME% (
	 ECHO:
	 ECHO *** ERROR: INPUT FILE %#FILENAME% NOT FOUND ***
	 ECHO:
	 GOTO :ExitBatch
 ) ELSE (
	 ECHO Processing %#FILENAME% ...
	 ECHO:
	 IF EXIST %#FILENAME% FOR /F "USEBACKQ TOKENS=*" %%F IN (%#FILENAME%) DO (
		 SET /A #COUNT+=1
		 SET #LINENUM=0000!#COUNT!
		 SET #LINENUM=!#LINENUM:~-3!
		 SET #OUTPUT="%#OUTPUT_DIR%\!#LINENUM!.TXT"
		 SET #THISLINE=%%F
		 IF "!#LINENUM! "=="!#THISLINE:~0,4!" SET #THISLINE=!#THISLINE:~4!
		 ECHO  - Generating !#OUTPUT!
		 ECHO !#THISLINE!>!#OUTPUT!
	 )
 )
 

:ExitBatch
 ECHO:
 DIR "%#OUTPUT_DIR%\???.TXT"
 TIMEOUT 60
 ENDLOCAL 
 