@REM - EvaluateMethods.BAT (13 Aug 2024 // 13 Aug 2024): Compare Performance of String Length Counting Methods
@ECHO OFF

 :::  This script compares the relative performance of different methods for 
 :::  determining the length of a string.  I like method #2 because it is concise,
 :::  but it's not going to be fast for really long strings, or lots of iterations 
 :::  of any size strings (>1000).  So, this script is here to help me benchmark,
 :::  and uses a couple of my utilities:
 :::
 :::    DATEINFO.EXE   - https://www.softpedia.com/get/Office-tools/Other-Office-Tools/DateInfo.shtml
 :::    MAKESTRING.EXE - https://www.softpedia.com/get/Science-CAD/MakeString.shtml
 :::
 :::  If you want a number of different iterations (default = 10000), use: 
 :::      EvaluateMethods.BAT  [number]               
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/EvaluateMethods.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.0.0
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET "#DATEFMT=-F "mm/dd/yyyy hh:nn:ss.zzz""
 SET "#CHECK_THIS=C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\share\cmake-3.27\Modules\CMake Add Fortran Subdirectory"
 SET /A "#BIGNUM=10000"
 SET /A "#MAXLEN=999"
 SET /A "#ITERATIONS=%~1 + 0"
	 IF "!#ITERATIONS!"=="0"    SET "#ITERATIONS=%#BIGNUM%"
	 IF NOT DEFINED #ITERATIONS SET "#ITERATIONS=%#BIGNUM%"


:Routine1 -- Max iterations of the binary counting method
 CALL :GetTime #STIME1
 FOR /L %%a IN (0,1,%#ITERATIONS%) DO (
	 SET "#TEMPSTR=%#CHECK_THIS%"
	 SET "#LEN=1"
	 FOR %%C IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
		 IF NOT "!#TEMPSTR:~%%C,1!"=="" (
			 SET /A "#LEN+=%%C"
			 SET "#TEMPSTR=!#TEMPSTR:~%%C!"	 
		 )
	 )
 )
 CALL :GetTime #ETIME1
 CALL :ShowSummary Method #1 - FOR 4096,2048,etc


:Routine2 -- Max iterations of the standard counting method with GOTO (max = 999 characters)
 CALL :GetTime #STIME2
 FOR /L %%a IN (0,1,%#ITERATIONS%) DO CALL :GetLength #CHECK_THIS
 CALL :GetTime #ETIME2
 CALL :ShowSummary Method #2 - FOR 0-999 with an Early Quit condition


:Routine3 -- Max iterations of the standard counting method with FOR (max = 999 characters)
 CALL :GetTime #STIME3
 FOR /L %%a IN (0,1,%#ITERATIONS%) DO (
	 SET "#LEN="
	 FOR /L %%C IN (0,1,%#MAXLEN%) DO IF "!#CHECK_THIS:~%%C,1!"=="" IF NOT DEFINED #LEN SET "#LEN=%%C"
 )
 CALL :GetTime #ETIME3
 CALL :ShowSummary Method #3 - FOR 0-999


:FinalReport -- Generate Final Report
 ECHO  Total Iterations for Each Routine ........... %#ITERATIONS%
 ECHO:
 ECHO  1st Routine Started On ...................... %#STIME1%
 ECHO  1st Routine Ended On ........................ %#ETIME1%
 MAKESTRING - 100
 ECHO  2nd Routine Started On ...................... %#STIME2%
 ECHO  2nd Routine Ended On ........................ %#ETIME2%
 MAKESTRING - 100
 ECHO  3rd Routine Started On ...................... %#STIME3%
 ECHO  3rd Routine Ended On ........................ %#ETIME3%
 MAKESTRING - 100
 DATEINFO -t !#STIME1#! -n !#ETIME1#! -e "dys hrs mins secs.ms" -o " Job #1 Duration Was ......................... " 2>NUL
 DATEINFO -t !#STIME2#! -n !#ETIME2#! -e "dys hrs mins secs.ms" -o " Job #2 Duration Was ......................... " 2>NUL
 DATEINFO -t !#STIME3#! -n !#ETIME3#! -e "dys hrs mins secs.ms" -o " Job #3 Duration Was ......................... " 2>NUL
 DATEINFO -t !#STIME1#! -n !#ETIME3#! -e "dys hrs mins secs.ms" -o " Total Job Duration Was ...................... " 2>NUL
 MAKESTRING - 100


:ExitBatch
 ENDLOCAL
 EXIT /B


:GetTime -- SUBROUTINE: Store Current Date and Time in Variable
 rem %1 = Variable to Store Date/Time

 SET %~1=!DATE! at !TIME: =0!
 FOR /F "TOKENS=*" %%d IN ('DATEINFO -S %#DATEFMT% -Q 2^>NUL') DO SET "%~1#="%%~d""
 GOTO :EOF


:ShowSummary -- SUBROUTINE: Display Summary Info {%* = Message}
 ECHO  *** %* ***
 MAKESTRING - 80
 ECHO  String = "%#CHECK_THIS%
 ECHO  Length = %#LEN%
 MAKESTRING - 80
 ECHO:
 GOTO :EOF


:GetLength -- SUBROUTINE: Get String Length {%1 = String Variable}
 SET "#TEMPSTR=!%~1!"
 SET "#LEN="
 FOR /L %%C IN (0,1,%#MAXLEN%) DO IF "!#TEMPSTR:~%%C,1!"=="" (SET "#LEN=%%C" & GOTO :EOF)
 GOTO :EOF
