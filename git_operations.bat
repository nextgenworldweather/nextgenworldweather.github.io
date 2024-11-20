@echo off
:: Git Operations Helper Script
:: Version 2.2.0

:: Configuration
setlocal enabledelayedexpansion
set repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git
set branchName=main

:: Check if Git is installed and accessible
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

:: Get the output of `git status -s`
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

:: Get the output of `git status -s`
set "changes="
for /f "tokens=* delims=" %%A in ('git status -s') do (
    set "changes=1"
    echo %%A
)

if not defined changes (
    echo No changes detected. Aborting push operation.
    exit /b 0
)

:: Prompt for commit message
echo Enter commit message:
set /p commitMessage=
if "%commitMessage%"=="" (
    echo Error: Commit message cannot be empty.
    exit /b 1
)

:: Stage and commit changes
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

:: Push to remote
echo Pushing changes to %repoURL%...
git push origin %branchName% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Push operation failed. Checking for upstream changes...
    git pull --rebase origin %branchName% >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Error: Pull and rebase failed. Please resolve conflicts manually.
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
git fetch >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to fetch from remote repository.
    exit /b 1
)

:: Check if local branch is behind remote
git rev-list --left-right --count origin/%branchName%...%branchName% >temp_rev_count.txt
for /f "tokens=1,2 delims= " %%A in (temp_rev_count.txt) do (
    set "behind=%%A"
    set "ahead=%%B"
)

del temp_rev_count.txt

if "%behind%"=="0" (
    echo Local branch is up to date. No pull required.
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
