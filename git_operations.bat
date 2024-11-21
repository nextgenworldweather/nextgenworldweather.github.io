@echo off
:: Git Operations Helper Script - Streamlined Version
:: Version 3.4.5

:: Configuration
setlocal enabledelayedexpansion
set "repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git"
set "branchName=main"

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
git status --short
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
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
git status --short
set "changes_found="
for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"

if not defined changes_found (
    echo No changes to push.
    exit /b 0
)

set /p "commit_msg=Enter commit message: "
if "%commit_msg%"=="" (
    echo Error: Commit message cannot be empty.
    exit /b 1
)

echo Staging changes...
git add .

echo Committing changes...
git commit -m "%commit_msg%"

echo Pushing to remote...
git push origin %branchName%
if %ERRORLEVEL% neq 0 (
    echo Push failed. Attempting to pull and rebase...
    git pull --rebase origin %branchName%
    git push origin %branchName%
)

echo Push completed successfully.
exit /b 0

:pull
echo Checking for remote changes...
git fetch origin
git status -uno | findstr /C:"Your branch is up to date" >nul
if %ERRORLEVEL% equ 0 (
    echo Repository is already up to date.
    exit /b 0
)

echo Pulling latest changes...
git pull origin %branchName%
if %ERRORLEVEL% neq 0 (
    echo Pull completed successfully.
) else (
    echo Error: Pull failed. Please resolve conflicts manually.
)
exit /b %ERRORLEVEL%

:sync
echo Starting repository synchronization...
call :pull_changes
if %ERRORLEVEL% equ 0 call :push_changes
echo Sync operation completed.
exit /b 0

:show_changes
echo Showing detailed changes...
git diff --name-status
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve changes.
    exit /b %ERRORLEVEL%
)
echo.

echo Showing content differences for modified files...
git diff
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve content differences.
    exit /b %ERRORLEVEL%
)
echo Detailed changes displayed successfully.
exit /b 0

:pull_changes
echo Pulling latest changes...
git pull origin %branchName%
exit /b %ERRORLEVEL%

:push_changes
echo Checking for local changes...
git status --short
set "changes_found="
for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"

if defined changes_found (
    set /p "commit_msg=Enter commit message: "
    if "%commit_msg%"=="" exit /b 1

    git add .
    git commit -m "%commit_msg%"
    git push origin %branchName%
)
exit /b 0
