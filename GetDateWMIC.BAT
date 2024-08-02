@REM - GetDateWMIC.BAT (01 Aug 2024 // 01 Aug 2024): Get Current Date via WMIC and Calculate Last Month/Year
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1ehrikt/comment/lg23tze/
@ECHO OFF

 :::  This is a slightly modified script to address an issue with octal math intruding 
 :::  itself in month calculations, when you get to August and September (08 and 09)
 :::
 :::  I ran into this some years ago, and it was one of the catalysts for me creating
 :::  the DATEINFO.EXE utility: https://www.majorgeeks.com/files/details/dateinfo.html
 :::
 :::  This version of the script uses WMIC to get the current date and time, and then
 :::  uses SET /A math to do all the calculations.
 :::
 :::  See GetDateBWCC.BAT at my GitHub scripts repository for the version that uses 
 :::  the DATEINFO utility: https://github.com/BrainWaveCC/MiscWinScripts
 :::
 :::  Tested on Windows 10 x64 and Windows 11
 :::

 setlocal EnableDelayedExpansion

 rem Set the source folder name
 set "source_folder=template_folder"

 rem Get the current date and time
 for /f "tokens=2 delims==" %%G in ('wmic OS Get localdatetime /value') do set "dt=%%G"

 rem Extract the year and month from the current date
 set "current_year=!dt:~0,4!"
 set "current_month=!dt:~4,2!"

 rem Calculate the previous month
 set /a "prev_month=1%current_month% - 101"
 if !prev_month! equ 0 (
    set /a "prev_month=12"
    set /a "prev_year=current_year - 1"
 ) else (
    set /a "prev_year=current_year"
 )

 rem Format the previous month in yyyy-mm format
 set "prev_month_padded=0!prev_month!"
 set "prev_month_padded=!prev_month_padded:~-2!"
 set "prev_month_year=!prev_year!-!prev_month_padded!"

 rem Set the destination folder
 set "dest_folder=!prev_month_year!"

 rem Check if the destination folder already exists
 if exist "!dest_folder!\*" (
    echo Destination folder already exists. Skipping duplication.
 ) else (
    rem Duplicate the source folder to the destination folder
    echo xcopy /E /I "!source_folder!" "!dest_folder!"
    echo Folder duplicated and renamed to !prev_month_year!.
 )

 pause
 endlocal
 