@REM - ReadAFile.BAT (17 Jul 2024 // 17 Jul 2024): Innovative Way to Read a File and Save Each Line as a Variable
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1e5slsj/comment/ldoix5f/
@ECHO OFF

 ::: This script will read an input file with up to 1000 lines (#MAXLINES=999) 
 ::: and save each line as a variable (#LINE000000 to #LINE000999) as necessary.
 ::: How high you can go will depend on system memory, and possibly some other 
 ::: heap or stack resource.  The largest file I tested was one with 823 lines.
 :::
 ::: You would call this from the command-line as:
 :::   ReadAFile.BAT "x:\Some\Folder\InputFile.TXT
 ::: -----------------------------------------------
 :::
 ::: Full script can also be found here .....  https://pastebin.com/4am7S36Y
 :::
 ::: Tested on Windows 10 x64 and Windows 11
 :::


:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #MAXLINES=999
 SET #FILENAME="%~1"& IF "%~1"=="" SET #FILENAME="x:\Some\Folder\SomeFile.TXT"


:Check4File -- Check for the existence of the input file
 IF NOT EXIST %#FILENAME% (
	 ECHO FILE NOT FOUND: %#FILENAME%
	 GOTO :ExitBatch
 ) 


:ReadFile -- Read a file up to maxlines+1 (0 - #MAXLINES)
 < %#FILENAME% (
	 FOR /L %%C IN (0,1,%#MAXLINES%) DO (
		 SET #COUNT=000000%%~C
		 SET #COUNT=!#COUNT:~-6!
		 SET /P #LINE!#COUNT!=
	 )
 ) 


:FinalReport -- Show all the variables with the lines that were read
 SET #LINE

 
:ExitBatch
 TIMEOUT 60
 ENDLOCAL 
