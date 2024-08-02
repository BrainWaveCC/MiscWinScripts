@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dle2ze/comment/l9zvqus/
@REM - Nice technique shown by another Redditor in this script
rem -- 
@echo off 
 setlocal enableDelayedExpansion
 cd /d "%~dp0"

 for /f "delims=" %%a in ('type "formatted_metadata.txt"') do (
     if /i "%%~xa"==".pdf" (
         set "fName=%%~na"
         >"!fName!.txt" rem/
     ) else (
         >>"!fName!.txt" echo(%%~a
     ) 
 )

 pause
