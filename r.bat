@echo off
REM Repo-local Flutter runner: uses ..\..\flutter\bin\flutter.bat
setlocal
set SCRIPT_DIR=%~dp0
"%SCRIPT_DIR%..\..\flutter\bin\flutter.bat" %*
endlocal
exit /b %ERRORLEVEL%
