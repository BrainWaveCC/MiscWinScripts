@REM - GetRegInfo.BAT (02 Jul 2024 // 02 Jul 2024): Parse Registry Entries for Folder and Version Info
@REM - REG ADD "HKCU\Software\BWCC\TestVersion" /v "ImagePath" /t REG_SZ /D "%SystemDrive%\SomeSoftware\Bin\Data-2.10.55\MyFiles.exe" /F
@REM - Original Message: https://www.reddit.com/r/Batch/comments/1dtr7dp/comment/lbbrdkb/
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #KEY=HKLM\system\CurrentControlSet\Services\someservice
 SET #KEY=HKCU\Software\BWCC\TestVersion
 SET #VAL=ImagePath

:Main_Complex
 FOR /F "TOKENS=*" %%V IN ('REG QUERY "%#KEY%" /V "%#VAL%"') DO (
	 SET #LINE=%%~V
	 SET #LINE=!#LINE:%#VAL%=!
	 FOR /F "TOKENS=2" %%a IN ('ECHO !#LINE!') DO (
		 SET #VERSION=TEST
	 )
 )

:Main
 FOR /F "TOKENS=3" %%F IN ('REG QUERY "%#KEY%" /V "%#VAL%"') DO (
	 SET #FOLDER=%%~F
	 SET #VERSION=!#FOLDER:*-=!
	 FOR /F "TOKENS=1 DELIMS=\" %%V IN ('ECHO !#VERSION!') DO SET #VERSION=%%~V
 )

:ExitBatch
 ECHO INSTALLATION FOLDER .... %#FOLDER%
 ECHO SOFTWARE VERSION ....... %#VERSION%
 TIMEOUT 60
 ENDLOCAL
 EXIT /B
