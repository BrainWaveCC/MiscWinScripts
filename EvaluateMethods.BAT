@REM - EvaluateMethods.BAT (13 Aug 2024 // 16 Aug 2024 / 13 Aug 2024): Compare Performance of String Length Counting Methods
@ECHO OFF

 :::  This script compares the relative performance of different methods for 
 :::  determining the length of a string.  Method #1 is very fast, but as far
 :::  as native methods go, I personally prefer method #2 because it is concise 
 :::  and straightforward to implement. However, if you need to check the size 
 :::  of very large strings (>1000 characters in size) or very many strings in
 :::  total (>1000), then you will not be as happy with method #2 vs method #1. 
 :::  (Frankly, you will not be happy with anything other than #1 in that case.)
 :::
 :::  There's an awesome thread on the SS64 forums about various native methods 
 :::  for getting the length of a string (https://ss64.org/viewtopic.php?t=17),
 :::  but I decided to create one more non-native method by way of a new function 
 :::  in my CHANGECASE utility (which was the most logical tool for me).  Sadly,
 :::  calling an external process hundreds or thousands of times adds overhead 
 :::  that totally undermines the speed advantage of the utility itself, since
 :::  it takes over 100ms to instantiate the utility itself -- each time.
 :::
 :::  The default number of iterations run for the benchmarking is 1000. You can
 :::  provide a custom number at the command line.  If the number of iterations
 :::  is greater then 500, then method #5 will not be executed (for expedience).
 :::
 :::  To run this script, you'll also need a few of my utilities, if you haven't 
 :::  downloaded them already:
 :::
 :::    DATEINFO.EXE   - https://www.softpedia.com/get/Office-tools/Other-Office-Tools/DateInfo.shtml
 :::    CHANGECASE.EXE - https://www.softpedia.com/get/Office-tools/Other-Office-Tools/ChangeCase.shtml
 :::
 :::  To benchmark with a custom  number of iterations, use the following syntax: 
 :::      EvaluateMethods.BAT  [number]               
 :::  -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/EvaluateMethods.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  NOTE: Method #4, as current constructed, does NOT work properly, because it
 :::        the jump to exit the count also exits the parent FOR loop going through
 :::        the total iterations.  In a script, if you only need one iteration, you'll 
 :::        be fine, but if it is part of a bigger FOR loop, it will abort the entire
 :::        mission.  I'll try to get a working edition in here at some point...
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::


:Variables -- v1.1.0
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET "#DATEFMT=-F "mm/dd/yyyy hh:nn:ss.zzz""
 SET "#RANDOMSTR=%RANDOM%"
 SET /A "#BIGNUM=1000"
 SET /A "#MAXLEN1=609"
 SET /A "#MAXLEN2=999"
 SET /A "#ITERATIONS=%~1 + 0"
	 IF "!#ITERATIONS!"=="0"    SET "#ITERATIONS=%#BIGNUM%"
	 IF NOT DEFINED #ITERATIONS SET "#ITERATIONS=%#BIGNUM%"

 rem -- Create Some Strings of Standard and Random Lengths
 FOR /L %%C IN (1,1,100) DO (
	 SET "#DIVIDER=!#DIVIDER!-"
	 SET "#RANDOMSTR=!#RANDOMSTR!-!RANDOM!"
 )
 
 
:Routine1 -- Max iterations of the binary counting method
 CALL :GetTime #STIME1
 SET "#COUNT=0"
 FOR /L %%a IN (1,1,%#ITERATIONS%) DO (
	 SET "#TEMPSTR=%#RANDOMSTR%"
	 SET "#LEN=1"
	 FOR %%C IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
		 IF NOT "!#TEMPSTR:~%%C,1!"=="" (
			 SET /A "#LEN+=%%C"
			 SET "#TEMPSTR=!#TEMPSTR:~%%C!"	 
		 )
	 )
	 SET /A "#COUNT+=1"
 )
 CALL :GetTime #ETIME1
 CALL :ShowSummary Method #1 - FOR 4096,2048,etc


:Routine2 -- Max iterations of the standard counting method using FOR loop (max = 609 characters)
 CALL :GetTime #STIME2
 SET "#COUNT=0"
 FOR /L %%a IN (1,1,%#ITERATIONS%) DO (
	 SET "#LEN="
	 FOR /L %%C IN (0,1,%#MAXLEN1%) DO IF NOT DEFINED #LEN IF "!#RANDOMSTR:~%%C,1!"=="" SET "#LEN=%%C"
	 SET /A "#COUNT+=1"
 )
 CALL :GetTime #ETIME2
 CALL :ShowSummary Method #2 - Standard FOR loop of 0-%#MAXLEN1%


:Routine3 -- Max iterations of a standard FOR loop subroutine, with attempted early exit via GOTO (max = 999 characters)
 CALL :GetTime #STIME3
 SET "#COUNT=0"
 FOR /L %%a IN (1,1,%#ITERATIONS%) DO CALL :GetLength #RANDOMSTR
 CALL :GetTime #ETIME3
 CALL :ShowSummary Method #3 - Standard FOR loop subroutine of 0-%#MAXLEN2% with an early exit condition


:Routine4 -- Max iterations of the standard counting method with FOR loop, with attempted early exit via GOTO (max = 999 characters) -- DOES NOT WORK PROPERLY
 CALL :GetTime #STIME4
 SET "#COUNT=0"
 FOR /L %%a IN (1,1,%#ITERATIONS%) DO (
	 SET "#TEMPSTR=%#RANDOMSTR%"
	 SET "#LEN="
	 FOR /L %%C IN (0,1,%#MAXLEN2%) DO IF NOT DEFINED #LEN IF "!#TEMPSTR:~%%C,1!"=="" (SET "#LEN=%%C" & GOTO :NextSteps)
	:NextSteps -- This doesn't really work. The GOTO above exits BOTH FOR loops, so it only ever does 1 iteration, as evident by #COUNT being 1
	 SET /A "#COUNT+=1"
 )
 CALL :GetTime #ETIME4
 CALL :ShowSummary Method #4 - Standard FOR loop of 0-%#MAXLEN2% with an early exit condition -- NO subroutine


:Routine5 -- Max iterations using my CHANGECASE	utility (max string > 8192 characters)
 IF %#ITERATIONS% LEQ 500 (
	 SET "#COUNT=0"
	 CALL :GetTime #STIME5
	 FOR /L %%a IN (1,1,%#ITERATIONS%) DO (
		 FOR /F %%C IN ('CHANGECASE --SIZE "%#RANDOMSTR%"') DO SET "#LEN=%%C"
		 SET /A "#COUNT+=1"
	 )
	 CALL :GetTime #ETIME5
	 CALL :ShowSummary Method #5 - Using external CHANGECASE --SIZE command
 )


:FinalReport -- Generate Final Report
 ECHO  1st Routine Started On ...................... %#STIME1%
 ECHO  1st Routine Ended On ........................ %#ETIME1%
 ECHO %#DIVIDER%
 ECHO  2nd Routine Started On ...................... %#STIME2%
 ECHO  2nd Routine Ended On ........................ %#ETIME2%
 ECHO %#DIVIDER%
 ECHO  3rd Routine Started On ...................... %#STIME3%
 ECHO  3rd Routine Ended On ........................ %#ETIME3%
 ECHO %#DIVIDER%
 ECHO  4th Routine Started On ...................... %#STIME4%
 ECHO  4th Routine Ended On ........................ %#ETIME4%

 IF %#ITERATIONS% LEQ 500 (
	 ECHO %#DIVIDER%
	 ECHO  5th Routine Started On ...................... %#STIME5%
	 ECHO  5th Routine Ended On ........................ %#ETIME5%
	 ECHO %#DIVIDER%
	 DATEINFO -t !#STIME1#! -n !#ETIME1#! -e "dys hrs mins secs.ms" -o " Job #1 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME2#! -n !#ETIME2#! -e "dys hrs mins secs.ms" -o " Job #2 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME3#! -n !#ETIME3#! -e "dys hrs mins secs.ms" -o " Job #3 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME4#! -n !#ETIME4#! -e "dys hrs mins secs.ms" -o " Job #4 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME5#! -n !#ETIME5#! -e "dys hrs mins secs.ms" -o " Job #5 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME1#! -n !#ETIME5#! -e "dys hrs mins secs.ms" -o " Total Job Duration Was ...................... " 2>NUL
	 ECHO %#DIVIDER%
 ) ELSE (
	 ECHO %#DIVIDER%
	 DATEINFO -t !#STIME1#! -n !#ETIME1#! -e "dys hrs mins secs.ms" -o " Job #1 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME2#! -n !#ETIME2#! -e "dys hrs mins secs.ms" -o " Job #2 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME3#! -n !#ETIME3#! -e "dys hrs mins secs.ms" -o " Job #3 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME4#! -n !#ETIME4#! -e "dys hrs mins secs.ms" -o " Job #4 Duration Was ......................... " 2>NUL
	 DATEINFO -t !#STIME1#! -n !#ETIME4#! -e "dys hrs mins secs.ms" -o " Total Job Duration Was ...................... " 2>NUL
	 ECHO %#DIVIDER%
 )


:ExitBatch -- Wrap things up and exit
 rem SET #
 ENDLOCAL
 EXIT /B


:GetTime -- SUBROUTINE: Store Current Date and Time in Variable
 rem %1 = Variable to Store Date/Time

 SET %~1=!DATE! at !TIME: =0!
 FOR /F "TOKENS=*" %%d IN ('DATEINFO -S %#DATEFMT% -Q 2^>NUL') DO SET "%~1#="%%~d""
 GOTO :EOF


:ShowSummary -- SUBROUTINE: Display Summary Info {%* = Message}
 ECHO  *** %* ***
 ECHO %#DIVIDER:~-80%
 ECHO  String ............... "%#RANDOMSTR%"
 ECHO  Length ............... %#LEN%
 ECHO  Iterations ........... %#ITERATIONS%
 ECHO  Iterations Counted ... %#COUNT%
 ECHO %#DIVIDER:~-80%
 ECHO:
 GOTO :EOF


:GetLength -- SUBROUTINE: Get String Length {%1 = String Variable}
 SET "#TEMPSTR=!%~1!"
 SET "#LEN="
 SET /A "#COUNT+=1"
 FOR /L %%C IN (0,1,%#MAXLEN2%) DO IF "!#RANDOMSTR:~%%C,1!"=="" (SET "#LEN=%%C" & GOTO :EOF)
 GOTO :EOF
