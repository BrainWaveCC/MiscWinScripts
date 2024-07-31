@REM - GetInputTest.BAT (16 Jul 2024 // 16 Jul 2024): Test GetInput with Various Password Options
 REM - ur(z}kb0<u>#E&d^{0%S|go*O~[Fy?v[+E`J4)v=P"A;!k
@ECHO OFF
 SETLOCAL ENABLEDELAYEDEXPANSION
 SET #PWD1=B{+F+~{lxdO.74o+^&__bz90L*uyBV]imK
 SET "#PWD2=B{+F+~{lxdO.74o+&__bz90L*uyBV]imK"
 SET #PWD3="B{+F+~{lxdO.74o+&__bz90L*uyBV]imK"


:Test1 - with native SET /P
 SET /P "#NEWPWD1=Please Enter New Password #1: "


:Test2 - with GetInput, but no doublequotes
 FOR /F "TOKENS=*" %%P IN ('GetInput -p "Please Enter New Password #2: " -q') DO SET #NEWPWD2=%%P


:Test3 - with GetInput, but with doublequotes including the var name
 FOR /F "TOKENS=*" %%P IN ('GetInput -p "Please Enter New Password #3: " -q') DO SET "#NEWPWD3=%%P"


:Test4 - with GetInput, but with doublequotes
 FOR /F "TOKENS=*" %%P IN ('GetInput -p "Please Enter New Password #4: " -q') DO SET #NEWPWD4="%%P"


:FinalReport
 FOR %%C IN (1 2 3 4) DO ECHO Password from Process #%%C = "!#NEWPWD%%C!"
 ECHO:
 SET #
 
 
:ExitBatch
 TIMEOUT 60
 ENDLOCAL 
