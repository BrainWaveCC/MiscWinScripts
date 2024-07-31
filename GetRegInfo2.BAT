@REM - GetRegInfo2.BAT (02 Jul 2024 // 02 Jul 2024): Parse Registry Entries for Folder and Version Info
@REM - REG ADD "HKCU\Software\BWCC\TestVersion" /v "ImagePath" /t REG_SZ /D "%SystemDrive%\SomeSoftware\Bin\Data-2.10.55\MyFiles.exe" /F
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET "#KEY=HKLM\system\CurrentControlSet\Services\someservice"
 SET "#KEY=HKCU\Software\BWCC\TestVersion"
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
