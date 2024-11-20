@echo off
:: Enhanced Git operations script for Windows with advanced features
:: Usage: Call with parameters for push, pull, or status

:: Check if Git is installed
where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Git is not installed or not in system PATH.
    exit /b 1
)

if "%1"=="push" (
    call :push_changes
) else if "%1"=="pull" (
    call :pull_changes
) else if "%1"=="status" (
    call :check_status
) else (
    echo Usage: %0 [push^|pull^|status]
    echo.
    echo Options:
    echo   push   - Stage, commit, and push changes
    echo   pull   - Fetch and merge changes from remote
    echo   status - Check git repository status
    exit /b 1
)

exit /b 0

:push_changes
setlocal enabledelayedexpansion

:: Check for uncommitted changes
git diff-index --quiet HEAD
if %ERRORLEVEL% equ 0 (
    echo No changes to commit.
    exit /b 0
)

echo Enter your commit message:
set /p commitMessage=

if "%commitMessage%"=="" (
    echo Error: Commit message cannot be empty.
    exit /b 1
)

echo Checking repository status...
git fetch origin

echo Pushing changes to GitHub...
git add .
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

git commit -m "%commitMessage%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

git push origin main
if %ERRORLEVEL% neq 0 (
    echo Push failed. Attempting to pull and merge...
    git pull --rebase origin main
    if %ERRORLEVEL% neq 0 (
        echo Merge failed. Resolve conflicts manually.
        exit /b %ERRORLEVEL%
    )
    git push origin main
)
echo Push successful!
exit /b 0

:pull_changes
echo Fetching latest changes...
git fetch origin

echo Pulling changes from GitHub...
git pull origin main
if %ERRORLEVEL% neq 0 (
    echo Pull failed. Possible merge conflicts.
    echo Try resolving conflicts manually or use 'git mergetool'.
    exit /b %ERRORLEVEL%
)
echo Pull successful!
exit /b 0

:check_status
echo Checking Git repository status...
git status
exit /b 0