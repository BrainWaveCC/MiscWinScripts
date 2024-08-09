@REM - GetSurvey.BAT (09 Aug 2024 // 09 Aug 2024): Present a survey to a user and accept valid answers
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1entf3a/comment/lhabhmv/
@ECHO OFF

 :::  This script will present a survey of questions and accept YES/NO answers from 
 :::  a user.  This version uses SET /P to obtain the answers, and then validates
 :::  whether or not the answers are legit, and asks for valid answers if necessary.
 :::
 :::  There are a lot of efficiency opportunities for this script, including the 
 :::  consolidation of the actions that occur on YES and NO, and using CHOICE instead
 :::  of SET /P in order to constrain the options right from the beginning.
 :::
 :::  This can be run directly from Windows Explorer, or it can be executed from the
 :::  command-line as follows:
 :::    GetSurvey.BAT [optional_parameter]
 :::
 ::: -----------------------------------------------
 :::
 :::  The full script can be found here:
 :::      https://github.com/BrainWaveCC/MiscWinScripts/blob/main/GetSurvey.BAT
 :::
 :::  NOTE: I usually like prefacing my variables with # or @ (see: README) but 
 :::        I'm sticking to most of the conventions of the original script.
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::

:SetScreen
 mode 60,35
 color a
 title intelijenzia altifiziau


:Variables
 setlocal
 set "e=timeout /t 2 /nobreak >nul"
 set "z=timeout /t 1 /nobreak >nul"
 set "six=timeout/t 15 /nobreak >nul"
 set "cr=%cd%"
 set "cm=%cr%\data"
 set "nm=start "" "%temp%\error.vbs""
 set "options=yes no"
 set "retry=echo Sorry, I didn't understand try again! (use 'yes' or 'no' only)"

 
:StartSurvey - Start Survey Questions (input can be checked in a case insensitive way)
 echo please don't use CAPSLOCK or SYMBOLS with me!
 echo.
 echo.
 %e%
 echo start survey?
 echo.
 %z%
 echo yes or no
 echo.

:Q1-Loop
 set /p "qq=-"
 for %%d in (%options%) do if /i "%qq%"=="%%~d" goto :A1-%qq% 
 %retry%
 goto :Q1-Loop
 

:A1-no
:A2-no - Looks like there was no separate NO entry for Q2, so it will end up in the same place
 cls
 echo press any key to close the program
 pause>nul
 exit
 

:A1-yes
 cls
 echo.
 echo.
 %e%
 echo are you ok?
 echo.
 %z%
 echo yes or no
 echo.

:Q2-Loop
 set /p "q2=-"
 for %%d in (%options%) do if /i "%q2%"=="%%~d" goto :A2-%q2% 
 %retry%
 goto :Q2-Loop
 
 
:A2-yes
 cls
 echo.
 echo.
 %e%
 echo are you scared?
 echo.
 %z%
 echo yes or no
 echo.
 
:Q3-Loop
 set /p "q3=*"
 for %%d in (%options%) do if /i "%q3%"=="%%~d" goto :A3-%q3% 
 %retry%
 goto :Q3-Loop

 
:A3-yes
 cd %cm%
 start  jump.mp4
 %six% 
 taskkill /im "wmplayer.exe" >nul
 pause
 exit
 
:A3-no
 cls
 echo.
 echo.
 %e%
 echo are you REALLY ok?
 echo.
 echo.
 %z%
 echo yes or no
 echo.
 
:Q4-Loop
 set /p "q4=-"
 for %%d in (%options%) do if /i "%q4%"=="%%~d" goto :A4-%q4% 
 %retry%
 goto :Q4-Loop
 
 
:A4-no
:A4-yes
 cls
 echo.
 echo ok
 pause
 exit /b
