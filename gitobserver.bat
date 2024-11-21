@echo off
:: Git Operations Helper Script with External Logging
:: Version 3.6.0

:: Configuration
setlocal enabledelayedexpansion
set "repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git"
set "branchName=main"
set "logDir=C:\path\to\logs"
set "logFile=%logDir%\git_operations.log"

:: Ensure log directory exists
if not exist "%logDir%" (
    mkdir "%logDir%"
    if %ERRORLEVEL% neq 0 (
        set "logDir=%TEMP%"
        echo Log directory not found. Using %TEMP%: %logDir%.
    )
)

:: Check for Git installation
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Git is not installed or not in the system PATH.
    echo [%date% %time%] ERROR: Git is missing or not in PATH >> "%logFile%"
    exit /b 1
)

:: Main Execution
if "%1"=="" (
    echo Usage:
    echo   git_operations.bat status - Check repository status
    echo   git_operations.bat push   - Push changes to remote
    echo   git_operations.bat pull   - Pull changes from remote
    echo   git_operations.bat sync   - Synchronize with remote
    exit /b 1
)

if "%1"=="status" goto :status
if "%1"=="push" goto :push
if "%1"=="pull" goto :pull
if "%1"=="sync" goto :sync

echo Error: Invalid command. Use status, push, pull, or sync.
exit /b 1

:status
echo Checking repository status...
echo [%date% %time%] Status operation started >> "%logFile%"

git status --short >nul
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
    echo [%date% %time%] ERROR: Failed to retrieve status >> "%logFile%"
    exit /b %ERRORLEVEL%
)

set "changes_found="
for /f "tokens=*" %%a in ('git status --short') do (
    set "changes_found=1"
    goto break_loop
)
:break_loop

if not defined changes_found (
    echo No changes detected in repository.
    echo [%date% %time%] No changes detected >> "%logFile%"
    exit /b 0
)

echo Changes detected in the repository.
set /p status_choice="Would you like to view detailed changes? (y/n): "
if /i "%status_choice%"=="y" (
    call :show_changes
) else (
    echo Status check complete. No detailed view requested.
)
exit /b 0

:push
echo Checking for changes to push...
echo [%date% %time%] Push operation started >> "%logFile%"

set "changes_found="
for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"

if not defined changes_found (
    echo No changes to push.
    echo [%date% %time%] No changes to push >> "%logFile%"
    exit /b 0
)

:get_commit_message
set /p "commit_msg=Enter commit message: "
if "%commit_msg%"=="" (
    echo Commit message cannot be empty. Please try again.
    goto :get_commit_message
)

echo Staging changes...
git add . >nul
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to stage changes.
    echo [%date% %time%] ERROR: Staging failed >> "%logFile%"
    exit /b %ERRORLEVEL%
)

echo Committing changes...
git commit -m "%commit_msg%" >nul
if %ERRORLEVEL% neq 0 (
    echo Error: Commit failed.
    echo [%date% %time%] ERROR: Commit failed >> "%logFile%"
    exit /b %ERRORLEVEL%
)

echo Pushing to remote...
git push origin %branchName% >nul
if %ERRORLEVEL% neq 0 (
    echo Push failed. Attempting to pull and rebase...
    echo [%date% %time%] Push failed. Attempting pull and rebase >> "%logFile%"
    git pull --rebase origin %branchName% >nul
    git push origin %branchName% >nul
)

echo Push completed successfully.
echo [%date% %time%] Push completed successfully >> "%logFile%"
exit /b 0

:pull
echo Checking for remote changes...
echo [%date% %time%] Pull operation started >> "%logFile%"

git fetch origin >nul
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to fetch changes from remote.
    echo [%date% %time%] ERROR: Fetch failed >> "%logFile%"
    exit /b %ERRORLEVEL%
)

git status -uno | findstr /C:"Your branch is up to date" >nul
if %ERRORLEVEL% equ 0 (
    echo Repository is already up to date.
    echo [%date% %time%] Repository is already up to date >> "%logFile%"
    exit /b 0
)

echo Pulling latest changes...
git pull origin %branchName% >nul
if %ERRORLEVEL% neq 0 (
    echo Merge conflict detected. Attempting to resolve...
    echo [%date% %time%] Merge conflict detected >> "%logFile%"
    git mergetool >nul
    git commit -m "Merge conflict resolved manually" >nul
    git push origin %branchName% >nul
)

echo Pull completed successfully.
echo [%date% %time%] Pull completed successfully >> "%logFile%"
exit /b 0

:sync
echo Starting repository synchronization...
echo [%date% %time%] Sync operation started >> "%logFile%"

call :pull
if %ERRORLEVEL% neq 0 (
    echo Sync failed during pull. Check log for details.
    echo [%date% %time%] Sync failed during pull >> "%logFile%"
    exit /b %ERRORLEVEL%
)

call :push
if %ERRORLEVEL% neq 0 (
    echo Sync failed during push. Check log for details.
    echo [%date% %time%] Sync failed during push >> "%logFile%"
    exit /b %ERRORLEVEL%
)

echo Sync operation completed successfully.
echo [%date% %time%] Sync operation completed successfully >> "%logFile%"
exit /b 0

:show_changes
echo Showing detailed changes...
echo [%date% %time%] Showing detailed changes >> "%logFile%"
git diff --name-status
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve changes.
    echo [%date% %time%] ERROR: Failed to retrieve changes >> "%logFile%"
    exit /b %ERRORLEVEL%
)

echo Showing content differences for modified files...
git diff
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve content differences.
    echo [%date% %time%] ERROR: Failed to retrieve content differences >> "%logFile%"
    exit /b %ERRORLEVEL%
)

echo Detailed changes displayed successfully.
echo [%date% %time%] Detailed changes displayed successfully >> "%logFile%"
exit /b 0
