rem - https://www.reddit.com/r/Batch/comments/1dquqcd/comment/latinku/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

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