@echo off
SETLOCAL EnableDelayedExpansion

TITLE GUI Modelling Launcher

echo ==========================================
echo      Starting GUI Modelling...
echo ==========================================

REM 1. Method A: Check PATH
where Rscript >nul 2>&1
IF %ERRORLEVEL% equ 0 (
    echo [INFO] Found Rscript in PATH.
    SET "RSCRIPT_PATH=Rscript"
    GOTO :LaunchApp
)

REM 2. Method B: Check Windows Registry
echo [WARNING] Rscript not in PATH. Checking Registry...
FOR /F "tokens=2*" %%A IN ('reg query "HKLM\SOFTWARE\R-core\R" /v InstallPath 2^>nul') DO (
    SET "R_REG_PATH=%%B"
)

IF DEFINED R_REG_PATH (
    IF EXIST "!R_REG_PATH!\bin\x64\Rscript.exe" (
        SET "RSCRIPT_PATH="!R_REG_PATH!\bin\x64\Rscript.exe""
    ) ELSE (
        SET "RSCRIPT_PATH="!R_REG_PATH!\bin\Rscript.exe""
    )
    echo [INFO] Found R via Registry at: !RSCRIPT_PATH!
    GOTO :LaunchApp
)

REM 3. Method C: Brute Force Search in Program Files
echo [WARNING] Registry check failed. Searching Program Files...
SET "LATEST_R="
FOR /D %%D IN ("%ProgramFiles%\R\R-*") DO (
    SET "LATEST_R=%%D"
)

IF DEFINED LATEST_R (
    IF EXIST "!LATEST_R!\bin\x64\Rscript.exe" (
        SET "RSCRIPT_PATH="!LATEST_R!\bin\x64\Rscript.exe""
    ) ELSE (
        SET "RSCRIPT_PATH="!LATEST_R!\bin\Rscript.exe""
    )
    echo [INFO] Found R in Program Files at: !RSCRIPT_PATH!
    GOTO :LaunchApp
)

REM 4. Failure
echo.
echo [ERROR] Could not find R installation!
echo.
echo Troubleshooting:
echo 1. Is R installed? (https://cloud.r-project.org/)
echo 2. If installed to a custom location, please edit this file 
echo    and set RSCRIPT_PATH manually.
echo.
pause
EXIT /B 1

:LaunchApp
echo [INFO] Checking dependencies and launching app...
echo.

%RSCRIPT_PATH% run_app_dev.R

IF %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] The application exited with an error.
    pause
)
EXIT /B 0
