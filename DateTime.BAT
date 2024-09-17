@REM - DateTime.BAT (24 May 1999 // 17 Sep 2024): Multiple methods for capturing date/time variable data
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1fjeqd5/date_and_time_routines_using_native_and_3rd_party/
@ECHO OFF

 :::  The goal of this script is to demonstrate a variety of ways to obtain
 :::  various elements of the date and time for use in Windows shell scripts.
 :::  This can be very useful for naming log or backup files, for instance.
 :::
 :::  Several different methods are used, some with native Windows utilities,
 :::  some with tools from the resource kit, and some with my DateInfo.exe
 :::  utility.
 :::
 :::  NOTE: Some of the parsing methods used in this script would have to be
 :::        modified if a different Regional Setting was used. These scripts
 :::        were only tested with the default English (US) option enabled.
 :::
 :::  You would call this from the command-line as:
 :::    DateTime.BAT   {no parameters required}
 ::: -----------------------------------------------
 :::
 :::  This script relies on two of my 3rd party utilities:
 :::   - Now.exe* .......... compatible with Now.exe from the old Microsoft Resource Kits
 :::   - DateInfo.exe ...... to handle the time calcuations more easily
 :::
 :::  * = If you already have the Microsoft Resource Kit, then you can use that version
 :::    of Now.exe instead.
 :::
 :::  https://www.majorgeeks.com/files/details/now.html
 :::  https://www.majorgeeks.com/files/details/dateinfo.html
 :::  https://en.wikipedia.org/wiki/Resource_Kit
 :::
 :::  You can download these files and put them into the folder with the script,
 :::  or anywhere in your current path.
 :::
 :::  The DOFF.EXE utility used to be available at http://www.jfitz.com/dos/index.html@DOFF
 :::  which provided another method of date/time variables (see section 7 below).
 :::  If DOFF.EXE is not found at time of execution, section #7 will simply be skipped.
 :::
 :::  Full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/DateTime.BAT
 :::
 :::  NOTE: I like prefacing my variables with @ or @ because then it makes it less
 :::        likely that they will clash with anything else, and a simple command like
 :::        "SET @" or "SET #" will enumerate all my variables at one time.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::  (been using variations of this script for testing since NT4, actually)
 :::


 rem ==========================================================================
 rem === Display Various Date/Time Calculations
 rem === Updated On: 17 Sep 2024 / 10 Dec 2019 / 20 Dec 2018
 rem ==========================================================================
:DisplayAll
 SETLOCAL ENABLEDELAYEDEXPANSION & CALL :ShowStatus "STARTED" v9.6.0.900

 rem -- Main Variables
 SET @MSNOW_COMPATIBILITY=TRUE

 rem -- Search for DOFF and use it if possible
 WHERE DOFF.EXE >NUL 2>&1
 IF ERRORLEVEL 1 (SET #DOFF=) ELSE (SET #DOFF=7)

 rem -- Main Routine
 FOR %%i IN (1 2 3 4 5 6 %#DOFF% 8 9) DO CALL :GetDate%%i
 CALL :ShowStatus "FINISHED"
 ENDLOCAL
 EXIT /B


 rem ==========================================================================
 rem === SUBROUTINE: Display the Variables for Each Section
 rem === Updated On: 17 Sep 2024 / 05 Apr 2017 / 21 Apr 2015
 rem ==========================================================================
:Display
 rem %1 = Long Name of Section
 rem %2 = Short Name of Section

 ECHO:
 ECHO Output for: %1
 ECHO ---------------------------------------------------------------------------
 ECHO %%DATE%%    = %DATE%
 ECHO %%TIME%%    = %TIME%
 ECHO:
 FOR /F "TOKENS=*" %%D IN ('DATE /T') DO ECHO DATE /T   = %%D
 FOR /F "TOKENS=*" %%T IN ('TIME /T') DO ECHO TIME /T   = %%T
 ECHO:
 FOR /F "SKIP=1 TOKENS=1,2,5,8,9 DELIMS=, " %%D IN ('WMIC PATH win32_localTime GET * /FORMAT:TABLE ^| FIND " "') DO ECHO WMIC INFO = Day=%%D, Month=%%F, Year=%%H, DayOfWeek=%%E, WeekInMonth=%%G
 ECHO:
 FOR /F "TOKENS=*" %%D IN ('NOW') DO ECHO NOW       = %%D
 ECHO:

 IF DEFINED #DOFF (
	 FOR /F "TOKENS=*" %%D IN ('DOFF "mm/dd/yyyy hh:mi:ss"') DO ECHO DOFF      = %%D
	 ECHO:
 )

 FOR /F "TOKENS=*" %%D IN ('DATEINFO -s -f "mm/dd/yyyy hh:nn:ss.zz" -q') DO ECHO DATEINFO  = %%D
 ECHO:
 ECHO:
 SET @
 ECHO:
 ECHO Sample File #1: "%TEMP%\My File %@TODAY%.TXT"
 ECHO Sample File #2: "%SystemRoot%\System32\LogFiles\%2.%@FILESTAMP%"
 ECHO ---------------------------------------------------------------------------
 ECHO:
 TIMEOUT 20
 ECHO:
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time                      (OPTION #1)
 rem === Updated On: 07 Nov 2010 / 25 May 2005
 rem ==========================================================================
:GetDate1
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem NT4 or Higher -- No Resource Kit Required
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "DELIMS=" %%T IN ('TIME /T') DO SET @TIME=%%T
 FOR /F "TOKENS=1" %%D IN ('DATE /T') DO SET @DAY=%%D
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 SET @DD=%@DATE:~3,2%
 SET @MM=%@DATE:~0,2%
 SET @YYYY=%@DATE:~6,4%
 SET @HOUR=%@TIME:~0,2%
 SET @SUFFIX=%@TIME:~6,1%
 IF /I "%@SUFFIX%"=="A" IF %@HOUR% EQU 12 SET @HOUR=00
 IF /I "%@SUFFIX%"=="P" IF %@HOUR% LSS 12 SET /A @HOUR+=12
 SET @NOW=%@HOUR%%@TIME:~3,2%
 SET @NOW=%@NOW: =0%
 SET @TODAY=%@YYYY%%@MM%%@DD%
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #1 - No ResKit" Option1
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time                      (OPTION #2)
 rem === Updated On: 07 Nov 2010 / 07 Dec 2003
 rem ==========================================================================
:GetDate2
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem NT4 or Higher -- No Resource Kit Required
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "TOKENS=2-5 DELIMS=/ " %%D IN ('DATE /T') DO SET @TODAY=%%F%%D%%E
 FOR /F "TOKENS=1-3 DELIMS=:. " %%T IN ('ECHO %TIME: =0%') DO SET @NOW=%%T%%U%%V
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #2 - No ResKit" Option2
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time                      (OPTION #3)
 rem === Updated On: 07 Nov 2010 / 25 May 2005
 rem ==========================================================================
:GetDate3
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem NT4 or Higher -- No Resource Kit Required
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "DELIMS=" %%T IN ('TIME /T') DO SET @TIME=%%T
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 FOR /F "TOKENS=1-4 DELIMS=-/ " %%D IN ('DATE /T') DO (
	 SET @DAY=%%D
	 SET @DD=%%F
	 SET @MM=%%E
	 SET @YYYY=%%G
 )
 SET @HOUR=%@TIME:~0,2%
 SET @SUFFIX=%@TIME:~6,1%
 IF /I "%@SUFFIX%"=="A" IF %@HOUR% EQU 12 SET @HOUR=00
 IF /I "%@SUFFIX%"=="P" IF %@HOUR% LSS 12 SET /A @HOUR+=12
 SET @NOW=%@HOUR%%@TIME:~3,2%
 SET @NOW=%@NOW: =0%
 SET @TODAY=%@YYYY%%@MM%%@DD%
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #3 - No ResKit" Option3
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time (Long Method)        (OPTION #4)
 rem === Updated On: 07 Nov 2010 / 08 Jan 2007
 rem ==========================================================================
:GetDate4
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires Windows NT4 or higher, plus NOW.EXE (from either source)
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 FOR /F "TOKENS=*" %%T IN ('TIME /T') DO SET @TIME12=%%T
 FOR /F "TOKENS=1-5" %%D IN ('NOW') DO (
	 SET @DAY=%%D
	 SET @DD=%%F
	 SET @MM=%%E
	 SET @MMM=%%E
	 SET @YYYY=%%H
	 SET @TIME=%%G
	 SET @TIME24=%%G
 )

 rem -- Change Long Month (MMM) to Short Month (MM)
 SET @MM=%@MM:Jan=01%
 SET @MM=%@MM:Feb=02%
 SET @MM=%@MM:Mar=03%
 SET @MM=%@MM:Apr=04%
 SET @MM=%@MM:May=05%
 SET @MM=%@MM:Jun=06%
 SET @MM=%@MM:Jul=07%
 SET @MM=%@MM:Aug=08%
 SET @MM=%@MM:Sep=09%
 SET @MM=%@MM:Oct=10%
 SET @MM=%@MM:Nov=11%
 SET @MM=%@MM:Dec=12%

 SET @BEGMONTH=%@MM%01%@YYYY%
 SET @MMDDYYYY=%@MM%%@DD%%@YYYY%
 SET @TODAY=%@YYYY%%@MM%%@DD%
 SET @TODAY_EXP=%@YYYY%-%@MM%-%@DD%
 SET @NOW=%@TIME::=%
 SET @TIMESTAMP=%DATE% at %@TIME12%
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #4 - NT4 ResKit or Higher" Option4
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time (Mini WMIC Method)   (OPTION #5)
 rem === Updated On: 17 Sep 2024
 rem ==========================================================================
:GetDate5
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires Windows 2008 or higher, using WMIC.EXE (Mini)
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 FOR /F "TOKENS=*" %%T IN ('TIME /T') DO SET @TIME12=%%T
 FOR /F "SKIP=1 TOKENS=2-10 DELIMS=," %%D IN ('WMIC PATH win32_localTime GET * /FORMAT:CSV ^| FIND ","') DO (
	 SET @YEAR=%%L
	 SET @MONTH=%%H
	 SET @DAY=%%D
	 SET @HR=%%F
	 SET @MIN=%%G
	 SET @SEC=%%J
	 SET @WEEKINMONTH=%%K
	 SET @DAYOFWEEK=%%E
	 SET @QUARTER=%%I
	 SET @TODAY=%%L%%H%%D
	 SET @NOW=%%F%%G%%J
 )

 FOR %%V IN (MONTH DAY HR MIN SEC DAYOFWEEK WEEKINMONTH QUARTER) DO CALL :DoubleDigits @%%V
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #5 - Windows 2008 or higher, using WMIC.EXE" Option5
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time (Mini Method)        (OPTION #6)
 rem === Updated On: 07 Nov 2010 / 01 Dec 2003
 rem ==========================================================================
:GetDate6
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires NT4 or Higher, Plus Appropriate Server Resource Kit
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL
 FOR /F "TOKENS=2-5 DELIMS=/ " %%D IN ('DATE /T') DO SET @TODAY=%%F%%D%%E
 FOR /F "TOKENS=4-6 DELIMS=: " %%T IN ('NOW') DO SET @NOW=%%T%%U%%V
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT

 CALL :Display "Option #6 - NT4 ResKit or Higher" Option6
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Current Date and Time (Extended Method)    (OPTION #7)
 rem === Updated On: 03 Feb 2020 / 07 Feb 2016
 rem ==========================================================================
:GetDate7 -- Deprecated because the DOFF utility is no longer available
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires Windows 2000 or Higher, plus various 3rd Party Utilities
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL ENABLEDELAYEDEXPANSION

 rem -- Calculate Current Date/Time (Long Procedure -- Using ResKit [Includes Day/Month names])
 rem -- Updated On: 16 Mar 2008 / 07 Jan 2007
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 FOR /F "TOKENS=*" %%T IN ('TIME /T') DO SET @TIME12=%%T
 FOR /F "TOKENS=1-5" %%D IN ('NOW') DO (
	 SET @DAY=%%D
	 SET @MMM=%%E
	 SET @TIME=%%G
	 SET @TIME24=%%G
 )

 rem -- Calculate Current Date/Time (Long Procedure -- Using Doff.exe)
 rem -- Updated On: 27 May 2010 / 16 Mar 2008
 FOR /F "TOKENS=1-7" %%D IN ('DOFF "yyyy yy mm dd hh mi ss"') DO (
	 SET @YYYY=%%D
	 SET @YY=%%E
	 SET @MM=%%F
	 SET @DD=%%G
	 SET @HR=%%H
	 SET @MIN=%%I
	 SET @SEC=%%J
	 SET @NOW=%%H%%I%%J
	 SET @NOW_EXP=%%H.%%I.%%J
 )

 rem -- Determine Current Day of Year (Using DateInfo.exe)
 rem -- Updated On: 07 Feb 2016 / 15 Feb 2015
 SET @PATH=%PATH:(=[%
 SET @PATH=%@PATH:)=]%
 SET @DATEINFO$=& FOR %%V IN (%@PATH: =_%) DO IF EXIST "%%~V\DateInfo.EXE" SET @DATEINFO$="%%~V\DateInfo.EXE"
 IF DEFINED @DATEINFO$ (
	 FOR /F "TOKENS=1-2" %%D IN ('DATEINFO -s -q -f "dddd mmmm"') DO (SET @DDDD=%%D& SET @MMMM=%%E)
	 FOR /F "TOKENS=1"   %%L IN ('DATEINFO -l -q') DO SET @LEAPYEAR=%%L
	 FOR /F "TOKENS=1"   %%N IN ('DATEINFO -w -q') DO SET @DAYOFWEEK=%%N
	 FOR /F "TOKENS=1"   %%D IN ('DATEINFO -y -q') DO SET @DAYOFYEAR=%%D
 ) ELSE (
	 FOR /L %%C IN (0,1,366) DO FOR /F "TOKENS=1" %%D IN ('DOFF "yyyymmdd" -%%Cd') DO IF /I "%%D"=="%@YYYY%0101" SET @DAYOFYEAR=%%C
	 IF /I "%@DAY%"=="Sun" (SET @DAYOFWEEK=1& SET @DDDD=Sunday)
	 IF /I "%@DAY%"=="Mon" (SET @DAYOFWEEK=2& SET @DDDD=Monday)
	 IF /I "%@DAY%"=="Tue" (SET @DAYOFWEEK=3& SET @DDDD=Tuesday)
	 IF /I "%@DAY%"=="Wed" (SET @DAYOFWEEK=4& SET @DDDD=Wednesday)
	 IF /I "%@DAY%"=="Thu" (SET @DAYOFWEEK=5& SET @DDDD=Thursday)
	 IF /I "%@DAY%"=="Fri" (SET @DAYOFWEEK=6& SET @DDDD=Friday)
	 IF /I "%@DAY%"=="Sat" (SET @DAYOFWEEK=7& SET @DDDD=Saturday)
 )

 rem -- Determine EVEN or ODD Day
 rem -- Updated On: 08 Dec 2010 / 11 Nov 2010
 SET /A @DD_DIV_2=%@DD:~-1% %% 2
 IF %@DD_DIV_2% GEQ 1 (
	 SET @DATE_IS_ODD=TRUE
	 SET @DATE_IS_EVEN=FALSE
	 SET @DATE_IS=ODD
 ) ELSE (
	 SET @DATE_IS_ODD=FALSE
	 SET @DATE_IS_EVEN=TRUE
	 SET @DATE_IS=EVEN
 )

 rem -- Calculate Future Dates (Long Procedure -- Using DOff.exe)
 rem -- Updated On: 03 Feb 2020 / 10 Apr 2017
 SET /A @NM=32 - @DD
 FOR /F "TOKENS=1"   %%Y IN ('DOFF "yyyy"') DO SET /A @NEXTYEAR=%%Y + 1
 FOR /F "TOKENS=1-2" %%M IN ('DOFF "yyyy mm" +%@NM%') DO (SET @NEXTMONTH=%%N& SET @NEXTMONTH_EXP=%%M-%%N)
 FOR /F "TOKENS=1-3" %%W IN ('DOFF "yyyy mm dd" +7d') DO (SET @NEXTWEEK=%%W%%X%%Y& SET @NEXTWEEK_EXP=%%W-%%X-%%Y)
 FOR /F "TOKENS=1-3" %%T IN ('DOFF "yyyy mm dd" +1d') DO (SET @TOMORROW=%%T%%U%%V& SET @TOMORROW_EXP=%%T-%%U-%%V)

 rem -- Calculate Previous Dates (Long Procedure -- Using DOff.exe)
 rem -- Updated On: 06 Apr 2015 / 13 Mar 2012
 FOR /F "TOKENS=1"   %%Y IN ('DOFF "yyyy"') DO SET /A @LASTYEAR=%%Y - 1
 FOR /F "TOKENS=1-2" %%L IN ('DOFF "yyyy mm" -%@DD%') DO (SET @LASTMONTH=%%M& SET @LASTMONTH_EXP=%%L-%%M)
 FOR /F "TOKENS=1-3" %%W IN ('DOFF "yyyy mm dd" -7d') DO (SET @LASTWEEK=%%W%%X%%Y& SET @LASTWEEK_EXP=%%W-%%X-%%Y)
 FOR /F "TOKENS=1-3" %%D IN ('DOFF "yyyy mm dd" -1d') DO (SET @YESTERDAY=%%D%%E%%F& SET @YESTERDAY_EXP=%%D-%%E-%%F)

 SET @BEGMONTH=%@MM%01%@YYYY%
 SET @MMDDYYYY=%@MM%%@DD%%@YYYY%
 SET @TODAY=%@YYYY%%@MM%%@DD%
 SET @TODAY_EXP=%@YYYY%-%@MM%-%@DD%
 SET @ZIPSTAMP=%@TODAY%-%@NOW%.ZIP
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT
 SET @TIMESTAMP=%@DATE:/=-% at %@TIME12::=.%
 SET @TIMESTAMP24=%@DATE:/=-% at %TIME: =0%

 CALL :Display "Option #7 - Windows 2000+, plus various 3rd Party Utilities" Option7
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Get Complete Date/Time Info (Using DateInfo)   (OPTION #8)
 rem === Updated On: 15 Feb 2019 / 14 May 2018
 rem ==========================================================================
:GetDate8
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires Windows 2003 or Higher with BrainWave DateInfo.exe Utility
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL ENABLEDELAYEDEXPANSION

 CALL :GetDateInfoValues

 CALL :Display "Option #8 - Windows 2003+ with BrainWave DateInfo Utility" Option8
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Single Pass DateIinfo (v4.0+)                  (OPTION #9)
 rem === Updated On: 15 Feb 2019 / 21 Dec 2018
 rem ==========================================================================
:GetDate9
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 rem Requires Windows 2003 or Higher with BrainWave DateInfo.exe v4.0+
 rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 SETLOCAL ENABLEDELAYEDEXPANSION

 SET @APP_ARCH=
 FOR /F "TOKENS=1-2 DELIMS=;" %%P IN ('DATEINFO --Script-Variables --filter^="date;time;@mm;dd;yy;@hr;@min;@sec" 2^>NUL') DO SET %%P=%%~Q
 IF DEFINED @APP_ARCH (
	 CALL :Display "Option #9 - Windows with BrainWave DateInfo v4.1+ [--Script-Variables]" Option9a
 ) ELSE (
	 CALL :GetDateInfoValues
	 CALL :Display "Option #9 - Windows with BrainWave DateInfo Utility [Old Method]" Option9b
 )
 ENDLOCAL
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Gather DATEINFO calculations, individually
 rem === Updated On: 03 Feb 2020 / 15 Feb 2019
 rem ==========================================================================
:GetDateInfoValues

 rem -- Generate Unique 5-Digit Random Number via DATEINFO.exe (or %RANDOM%)
 rem -- Updated On: 14 May 2018 / 22 Feb 2017
 SET @RANDOM=123%RANDOM%%RANDOM%& FOR /F %%R IN ('DATEINFO -R -Q') DO SET @RANDOM=%%R
 IF DEFINED @RANDOM (SET @RANDOM=%@RANDOM:~-5%) ELSE (SET @RANDOM=%RANDOM%)

 rem -- Obtain Current Date/Time Info via DateInfo.exe (12-Hour Format)
 rem -- Updated On: 14 May 2018
 FOR /F "TOKENS=1*" %%D IN ('DATEINFO -s -f "mm/dd/yyyy hh:nn:ss am/pm" -q') DO (
	 SET @DATE=%%D
	 SET @TIME12=%%E
 )

 rem -- Obtain Current Date/Time Info via DateInfo.exe (24-Hour Format)
 rem -- Updated On: 14 May 2018 / 05 Apr 2017
 FOR /F "TOKENS=1-12" %%D IN ('DATEINFO -s -f "yyyy yy mmmm mmm mm dddd ddd dd hh nn ss zz" -q') DO (
	 SET @YYYY=%%D
	 SET @YY=%%E
	 SET @MMMM=%%F
	 SET @MMM=%%G
	 SET @MM=%%H
	 SET @DDDD=%%I
	 SET @DDD=%%J
	 SET @DAY=%%J
	 SET @DD=%%K
	 SET @HR=%%L
	 SET @MIN=%%M
	 SET @SEC=%%N
	 SET @MSEC=%%O
	 SET @TIME=%%L:%%M:%%N
	 SET @TIME24=%%L:%%M:%%N
	 SET @NOW=%%L%%M%%N
	 SET @NOW_EXP=%%L.%%M.%%N
 )

 rem -- Calculate Special Date/Time Info (Using DateInfo.exe)
 rem -- Updated On: 10 Apr 2017 / 05 Apr 2017/02 Feb 2016
 FOR /F "TOKENS=1" %%L IN ('DATEINFO -l -q') DO SET @LEAPYEAR=%%L
 FOR /F "TOKENS=1" %%N IN ('DATEINFO -w -q') DO SET @DAYOFWEEK=%%N
 FOR /F "TOKENS=1" %%D IN ('DATEINFO -y -q') DO SET @DAYOFYEAR=%%D
 FOR /F "TOKENS=1" %%E IN ('DATEINFO -m -q') DO SET @ENDOFMONTH=%%E

 rem -- Calculate Past/Future Date/Time Info (Using DateInfo.exe)
 rem -- Updated On: 03 Feb 2020 / 10 Apr 2017
 SET /A @NM=32 - @DD
 SET /A @LASTYEAR=@YYYY - 1
 SET /A @NEXTYEAR=@YYYY + 1
 FOR /F "TOKENS=1-2" %%L IN ('DATEINFO -s -p %@DD% -f "yyyy mm" -q') DO (SET @LASTMONTH=%%M&       SET @LASTMONTH_EXP=%%L-%%M)
 FOR /F "TOKENS=1-2" %%M IN ('DATEINFO -s -a %@NM% -f "yyyy mm" -q') DO (SET @NEXTMONTH=%%N&       SET @NEXTMONTH_EXP=%%M-%%N)
 FOR /F "TOKENS=1-3" %%W IN ('DATEINFO -s -p 7 -f "yyyy mm dd" -q') DO  (SET @LASTWEEK=%%W%%X%%Y&  SET @LASTWEEK_EXP=%%W-%%X-%%Y)
 FOR /F "TOKENS=1-3" %%W IN ('DATEINFO -s -a 7 -f "yyyy mm dd" -q') DO  (SET @NEXTWEEK=%%W%%X%%Y&  SET @NEXTWEEK_EXP=%%W-%%X-%%Y)
 FOR /F "TOKENS=1-3" %%T IN ('DATEINFO -s -p 1 -f "yyyy mm dd" -q') DO  (SET @YESTERDAY=%%T%%U%%V& SET @YESTERDAY_EXP=%%T-%%U-%%V)
 FOR /F "TOKENS=1-3" %%T IN ('DATEINFO -s -a 1 -f "yyyy mm dd" -q') DO  (SET @TOMORROW=%%T%%U%%V&  SET @TOMORROW_EXP=%%T-%%U-%%V)

 rem -- Determine EVEN or ODD Day
 rem -- Updated On: 08 Dec 2010 / 11 Nov 2010
 SET /A @DD_DIV_2=%@DD:~-1% %% 2
 IF %@DD_DIV_2% GEQ 1 (
	 SET @DATE_IS_ODD=TRUE
	 SET @DATE_IS_EVEN=FALSE
	 SET @DATE_IS=ODD
 ) ELSE (
	 SET @DATE_IS_ODD=FALSE
	 SET @DATE_IS_EVEN=TRUE
	 SET @DATE_IS=EVEN
 )

 rem -- Generate TimeStamp Variables
 rem -- Updated On: 14 May 2018 / 05 Apr 2017 / 22 Feb 2017
 SET @BEGMONTH=%@MM%01%@YYYY%
 SET @MMDDYYYY=%@MM%%@DD%%@YYYY%
 SET @TODAY=%@YYYY%%@MM%%@DD%
 SET @TODAY_EXP=%@YYYY%-%@MM%-%@DD%
 SET @ZIPSTAMP=%@TODAY%-%@NOW%.ZIP
 SET @FILESTAMP=%@TODAY%-%@NOW%.TXT
 SET @TIMESTAMP=%@DATE:/=-% at %@TIME12::=.%
 SET @TIMESTAMP24=%@DATE:/=-% at %TIME: =0%
 SET @ZIPSTAMP_R=%@TODAY%-%@NOW%#%@RANDOM%.ZIP
 SET @FILESTAMP_R=%@TODAY%-%@NOW%#%@RANDOM%.TXT
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Pad Numbers with Leading 0
 rem === Updated On: 17 Sep 2024
 rem ==========================================================================
:DoubleDigits
 rem %1 = Variable to pad with leading zero

 IF "%~1"=="" GOTO :EOF
 CALL SET #ZZZ=0%%%~1%%
 CALL SET #ZZZ=%#ZZZ:~-2%
 SET %~1=%#ZZZ%
 GOTO :EOF


 rem ==========================================================================
 rem === SUBROUTINE: Set/Display Script Version and Execution Status
 rem === Updated On: 16 Oct 2023 / 24 Dec 2019
 rem ==========================================================================
:ShowStatus
 rem %1 = Run Status of Script
 rem %2 = Current Application Version

 IF NOT DEFINED @DATEFMT SET "@DATEFMT=-F "mm/dd/yyyy hh:nn:ss.zzz""
 SET "@SCRIPTSTATUS=%~1" & IF "%~1"=="" SET "@SCRIPTSTATUS=RUNNING"
 IF NOT "%~2"=="" (SET "@VER=%~nx0 %~2" & SET "@VERSION=%~2")
 IF /I "%~1"=="STARTED" FOR /F "TOKENS=*" %%d IN ('DATEINFO -S %@DATEFMT% -Q 2^>NUL') DO SET "@SCRIPT_BEG#="%%~d""
 IF /I "%~1"=="FINISHED" (
	 IF DEFINED $CODEPAGE FOR /F "TOKENS=1* DELIMS=:" %%B IN ('CHCP %$CODEPAGE%') DO SET "@CHCP_STATUS= {Restoring Code Page:%%C}"
	 IF DEFINED @END_DEBUG_MODE %@END_DEBUG_MODE:"=%
	 TITLE Command Prompt [%USERDOMAIN%\%USERNAME%]   !@DEBUG_MODE!
	 DATEINFO -t %@SCRIPT_BEG#% -e "hr:min:sec.ms" -o "\n*** DURATION: " 2>NUL
 )
 NOW \n*** %@SCRIPTSTATUS%: %@VER% [\v] *** %@CHCP_STATUS%\n!@CRLF-%~1!
 GOTO :EOF
                                                                                       