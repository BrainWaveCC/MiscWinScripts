@REM - GetRegInfo2.BAT (02 Jul 2024 // 02 Jul 2024): Parse Registry Entries for Folder and Version Info
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET "#KEY=HKLM\system\CurrentControlSet\Services\someservice"
 SET "#VAL=ImagePath"

 FOR /F "TOKENS=3" %%F IN ('REG QUERY "%#KEY%" /V "%#VAL%"') DO (
	 FOR %%P IN ("%%~dpF\.") DO (
		 SET "#VERSION=%%~nxP"
		 SET "#VERSION=!#VERSION:*-=!"
     )
     SET "#FOLDER=%%~F"
 )

 ECHO INSTALLATION FOLDER .... %#FOLDER%
 ECHO SOFTWARE VERSION ....... %#VERSION%
 TIMEOUT 60
 EXIT /B
