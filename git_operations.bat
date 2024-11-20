@echo off
:: Git Operations Helper Script - Fixed Version
:: Version 3.2.0

:: Enhanced Configuration
setlocal enabledelayedexpansion
set "repoRoot=%~dp0"
set "repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git"
set "branchName=main"
set "logFile=%~dp0git_operations.log"

:: Command Routing with Parameter Check
if "%1"=="" (
    echo Usage:
    echo   git_operations.bat status - Check repository status
    echo   git_operations.bat push   - Push changes to remote
    echo   git_operations.bat pull   - Pull changes from remote
    echo   git_operations.bat sync   - Synchronize with remote
    exit /b 1
)

:: Check Git Installation
git --version >nul 2>&1 || (
    echo Error: Git is not installed or not in PATH
    echo [%date% %time%] ERROR: Git not found >> "%logFile%"
    exit /b 1
)

:: Status Command
if "%1"=="status" (
    echo Checking repository status...
    echo [%date% %time%] Checking status >> "%logFile%"
    
    git status --short
    
    set "changes_found="
    for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"
    
    if not defined changes_found (
        echo No changes detected in repository.
    )
    exit /b 0
)

:: Push Command
if "%1"=="push" (
    echo Checking for changes to push...
    echo [%date% %time%] Push operation started >> "%logFile%"
    
    git status --short
    set "changes_found="
    for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"
    
    if not defined changes_found (
        echo No changes to push.
        exit /b 0
    )
    
    set /p "commit_msg=Enter commit message: "
    if "!commit_msg!"=="" (
        echo Error: Commit message cannot be empty
        exit /b 1
    )
    
    echo.
    echo Staging changes...
    git add .
    
    echo Committing changes...
    git commit -m "!commit_msg!"
    
    echo Pushing to remote...
    git push origin %branchName%
    if !errorlevel! neq 0 (
        echo Push failed. Attempting to pull and rebase...
        git pull --rebase origin %branchName%
        git push origin %branchName%
    )
    
    echo Push completed successfully.
    exit /b 0
)

:: Pull Command
if "%1"=="pull" (
    echo Checking for remote changes...
    echo [%date% %time%] Pull operation started >> "%logFile%"
    
    git fetch origin
    
    git status -uno | findstr /C:"Your branch is up to date" >nul
    if !errorlevel! equ 0 (
        echo Repository is already up to date.
        exit /b 0
    )
    
    echo Pulling latest changes...
    git pull origin %branchName%
    if !errorlevel! equ 0 (
        echo Pull completed successfully.
    ) else (
        echo Error: Pull failed. Please resolve conflicts manually.
    )
    exit /b !errorlevel!
)

:: Sync Command
if "%1"=="sync" (
    echo Starting repository synchronization...
    echo [%date% %time%] Sync operation started >> "%logFile%"
    
    call :pull_changes
    if !errorlevel! equ 0 call :push_changes
    
    echo Sync operation completed.
    exit /b 0
)

echo Error: Invalid command. Use status, push, pull, or sync.
exit /b 1

:pull_changes
echo Pulling latest changes...
git pull origin %branchName%
exit /b !errorlevel!

:push_changes
echo Checking for local changes...
git status --short
set "changes_found="
for /f "tokens=*" %%a in ('git status --short') do set "changes_found=1"

if defined changes_found (
    set /p "commit_msg=Enter commit message: "
    if "!commit_msg!"=="" exit /b 1
    
    git add .
    git commit -m "!commit_msg!"
    git push origin %branchName%
)
exit /b 0