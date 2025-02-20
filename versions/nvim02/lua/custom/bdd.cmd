@ECHO off
GOTO start
:find_dp0
SET dp0=%~dp0
EXIT /b
:start
SETLOCAL
CALL :find_dp0

endLocal & goto #_undefined_# 2>NUL || title %COMSPEC% & C:\Users\GZW\scoop\apps\dotnet-sdk-preview\current\dotnet.exe "C:\CMI-GitHub\Tools\BddLsp\BddLspServer\BddLspServer\bin\Debug\net9.0\BddLspServer.dll" %*
