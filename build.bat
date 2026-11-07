@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo Space Zap ROM build
echo Input: Space_Zap_Disassembly.asm
echo.
if not exist zout mkdir zout
if not exist roms mkdir roms
if not exist tools\zmac.exe (echo ERROR: missing tools\zmac.exe & exit /b 1)
echo [1/4] Assemble the 16 KB program image
echo ^> tools\zmac.exe --oo cim,lst Space_Zap_Disassembly.asm
tools\zmac.exe --oo cim,lst Space_Zap_Disassembly.asm
if errorlevel 1 exit /b 1
if not exist zout\Space_Zap_Disassembly.cim (echo ERROR: missing assembled image & exit /b 1)
echo Created: zout\Space_Zap_Disassembly.cim
echo Created: zout\Space_Zap_Disassembly.lst
echo.
echo [2/4] Split the image into four 4 KB ROMs
powershell -NoProfile -Command "$b=[IO.File]::ReadAllBytes('zout\Space_Zap_Disassembly.cim'); if($b.Length -lt 16384){throw 'compiled image too small'}; $n=@('0662.01','0663.xx','0664.xx','0665.xx'); for($i=0;$i -lt 4;$i++){$p=New-Object byte[] 4096;[Array]::Copy($b,($i*4096),$p,0,4096);[IO.File]::WriteAllBytes(('roms\'+$n[$i]),$p)}"
if errorlevel 1 exit /b 1
echo Created: roms\0662.01
echo Created: roms\0663.xx
echo Created: roms\0664.xx
echo Created: roms\0665.xx
echo.
echo [3/4] Package the MAME ROM set
powershell -NoProfile -Command "Compress-Archive -Force -Path roms\0662.01,roms\0663.xx,roms\0664.xx,roms\0665.xx -DestinationPath roms\spacezap.zip"
if errorlevel 1 exit /b 1
echo Created: roms\spacezap.zip
echo.
echo [4/4] Verify official ROM SHA-1
powershell -NoProfile -Command "$n=@('0662.01','0663.xx','0664.xx','0665.xx');$e=@('784ac67c75c7c101f97ebfd39b2b3f7bf7fa470a','ad0e8c34a209c827c1336f0250cc61fee667fb03','72151e773562da62acd2c1d9638711711cbc13a3','5aabd720a106158a892368c4920d9cd0f5235e34');$bad=$false;for($i=0;$i -lt 4;$i++){$a=(Get-FileHash -LiteralPath ('roms\'+$n[$i]) -Algorithm SHA1).Hash.ToLower();Write-Output ($a+'  roms\'+$n[$i]);if($a -ne $e[$i]){Write-Output ('WARNING: SHA-1 mismatch for '+$n[$i]+' expected '+$e[$i]);$bad=$true}};if($bad){exit 1}else{Write-Output 'PASS: All generated ROMs match the official Space Zap SHA-1 values.'}"
if errorlevel 1 (echo Build failed ROM verification. & exit /b 1)
echo.
echo Build complete: roms\spacezap.zip
exit /b 0
