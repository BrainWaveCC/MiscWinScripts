@REM - GetWMICInfo.BAT (26 Jun 2024 // 30 Jun 2024 / 26 Jun 2024): Obtain and Format WMIC Info
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dp0848/comment/lae5jmk/
@ECHO OFF

 ::: This script will obtain some WMIC info, and format the storage sizes
 ::: to KB, MB, GB or TB as preferred. For convenience, two subroutines are
 ::: provided.  One of the subroutines uses all native code, and the other 
 ::: relies on a 3rd party utility: CCALC.EXE 
 ::: (https://www.majorgeeks.com/files/details/brainwave_ccalc.html)
 ::: 
 ::: I was going to provide only the native option, but file sizes are 
 ::: regularly large enough to generate errors, so I provided both routines.
 ::: 
 ::: If you want the debug code to run, run the batch file with any parameter.
 :::   i.e. GetWMICInfo.BAT #
 ::: 
 ::: The full script can also be found here ..... https://pastebin.com/L0PjaNK4
 ::: 


:Variables
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #DEBUG=%~1
 SET #ITERATIONS=19
 
 
 rem -- Parse WMIC and format returned drive info
:ParseWMIC
 FOR /F "SKIP=2 TOKENS=1-7 DELIMS=," %%a IN ('WMIC PARTITION GET Diskindex^,Name^,Index^,Description^,Size /FORMAT:CSV') DO (
	CALL :ConvertNumber_Old "%%~g" MB #SIZE_OLD
	CALL :ConvertNumber     "%%~g" MB #SIZE_MB
	CALL :ConvertNumber     "%%~g" GB #SIZE_GB
	ECHO DiskIndex      : %%c
	ECHO PartitionIndex : %%d
	ECHO Partition Info : %%e,%%f
	ECHO Partition Type : %%b
	ECHO Raw Size       : %%g
	ECHO Size           : !#SIZE_OLD!
	ECHO Size           : !#SIZE_MB!
	ECHO Size           : !#SIZE_GB!
	ECHO:
 )


 rem -- Test My Calculation Routines (set #DEBUG=TRUE if you want this to run)
:RANDOM_MATH_TEST
 IF DEFINED #DEBUG (
	 ECHO:
	 ECHO *** RANDOM NUMBER TESTING ***
	 ECHO:
	 FOR /L %%z IN (1,1,%#ITERATIONS%) DO (
		 SET /A #VAL=!RANDOM! * !RANDOM! * 5
		 CALL :ConvertNumber_Old "!#VAL!" MB #SIZE_OLD
		 CALL :ConvertNumber     "!#VAL!" MB #SIZE_MB
		 CALL :ConvertNumber     "!#VAL!" GB #SIZE_GB
		 ECHO Displaying !#VAL! in MB ^& GB
		 ECHO  - Using Native Calculation .... !#SIZE_OLD!
		 ECHO  - Using CCALC [MB] ............ !#SIZE_MB!
		 ECHO  - Using CCALC [GB] ............ !#SIZE_GB!
		 ECHO:
	 )
 )


:ExitBatch
 TIMEOUT 60
 ENDLOCAL 
 GOTO :EOF
 

 rem -- SUBROUTINE: Convert Large Number to KB, MB, GB, TB or PB (using CCALC.EXE)
:ConvertNumber
 rem %1 = Current Number to be Converted/Formatted
 rem %2 = Unit of Measurement to be Used
 rem %3 = New Variable To Store Converted/Formatted Number

 IF "%~3"=="" GOTO :EOF
                   SET #OPERAND=+ 0
 IF /I "%~2"=="KB" SET #OPERAND=/ 1024
 IF /I "%~2"=="MB" SET #OPERAND=/ 1024 / 1024
 IF /I "%~2"=="GB" SET #OPERAND=/ 1024 / 1024 / 1024
 IF /I "%~2"=="TB" SET #OPERAND=/ 1024 / 1024 / 1024 / 1024

 SET #NUM=%~1
 SET #NUM=!#NUM:-=!
 FOR /F %%N IN ('CCALC !#NUM! %#OPERAND% -f "#,##0.000" 2^>NUL') DO SET %~3=%%~N %~2
 GOTO :EOF


 rem -- SUBROUTINE: Convert Large Number to KB, MB, GB, TB or PB
:ConvertNumber_Old
 rem %1 = Current Number to be Converted
 rem %2 = Unit of Measurement to be Used
 rem %3 = New Variable To Store Converted Number

 IF "%~3"=="" GOTO :EOF
                   SET #OPERAND=+ 0
 IF /I "%~2"=="KB" SET #OPERAND=/ 1024
 IF /I "%~2"=="MB" SET #OPERAND=/ 1024 / 1024
 IF /I "%~2"=="GB" SET #OPERAND=/ 1024 / 1024 / 1024
 IF /I "%~2"=="TB" SET #OPERAND=/ 1024 / 1024 / 1024 / 1024

 SET #NUM=%~1
 SET #NUM=!#NUM:-=!
 SET %~3=Could Not Calculate
 SET /A %~3=!#NUM! %#OPERAND% 2>NUL
 SET %~3=!%~3! %~2
 GOTO :EOF
                          
