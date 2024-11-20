@echo off
:: Git Operations Helper Script - Refined for Pull Detection
:: Version 2.3.0

:: Configuration
setlocal enabledelayedexpansion
set repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git
set branchName=main

:: Check if Git is installed
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Git is not installed or not accessible in PATH.
    exit /b 1
)

:: Main script execution
if "%1"=="status" (
    call :check_status
) else if "%1"=="push" (
    call :check_and_push
) else if "%1"=="pull" (
    call :check_and_pull
) else (
    echo Error: Invalid option. Use "status", "push", or "pull".
    exit /b 1
)

exit /b 0

:: Function to check status
:check_status
echo Checking repository status...
git status -s >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to retrieve repository status.
    exit /b 1
)

set "changes="
for /f "tokens=* delims=" %%A in ('git status -s') do (
    set "changes=1"
    echo %%A
)

if not defined changes (
    echo No changes detected in the working directory.
    exit /b 0
)

echo Changes detected above.
exit /b 0

:: Function to check for changes and push
:check_and_push
echo Checking repository for changes before pushing...
git status -s >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to retrieve repository status.
    exit /b 1
)

set "changes="
for /f "tokens=* delims=" %%A in ('git status -s') do (
    set "changes=1"
    echo %%A
)

if not defined changes (
    echo No changes detected. Aborting push operation.
    exit /b 0
)

echo Enter commit message:
set /p commitMessage=
if "%commitMessage%"=="" (
    echo Error: Commit message cannot be empty.
    exit /b 1
)

echo Staging and committing changes...
git add . >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to stage files.
    exit /b 1
)

git commit -m "%commitMessage%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Commit failed. Aborting push operation.
    exit /b 1
)

echo Pushing changes to %repoURL%...
git push origin %branchName% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Push operation failed. Checking for upstream changes...
    git pull --rebase origin %branchName% >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Error: Pull and rebase failed. Resolve conflicts manually.
        exit /b 1
    )
    echo Pull and rebase successful. Retrying push...
    git push origin %branchName% >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Error: Push operation still failed. Please resolve manually.
        exit /b 1
    )
)

echo Success: Changes pushed to %repoURL%.
exit /b 0

:: Function to check for changes and pull
:check_and_pull
echo Checking repository for changes before pulling...
git fetch origin %branchName% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to fetch from remote repository.
    exit /b 1
)

:: Compare local and remote branches
set "localHash="
set "remoteHash="
for /f "delims=" %%A in ('git rev-parse %branchName%') do set "localHash=%%A"
for /f "delims=" %%A in ('git rev-parse origin/%branchName%') do set "remoteHash=%%A"

if "%localHash%"=="%remoteHash%" (
    echo Local branch is up-to-date. No pull required.
    exit /b 0
)

echo Remote changes detected. Pulling updates...
git pull origin %branchName% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Pull operation failed. Resolve conflicts manually if present.
    exit /b 1
)

echo Success: Repository updated with changes from remote.
exit /b 0
