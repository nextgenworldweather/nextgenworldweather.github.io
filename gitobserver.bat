@echo off
setlocal enabledelayedexpansion

:: Configuration
set "branchName=main"

:: Help Function
if "%1"=="" goto :help_menu
if "%1"=="help" goto :help_menu

:: Command Router
if /i "%1"=="status" goto :git_status
if /i "%1"=="push" goto :git_push
if /i "%1"=="pull" goto :git_pull
if /i "%1"=="sync" goto :git_sync
if /i "%1"=="rollback" goto :git_rollback

echo Invalid command. Use 'help' to see available commands.
exit /b 1

:help_menu
echo Git Operations Helper Script
echo.
echo Usage:
echo   gitobserver.bat status   - Check repository status
echo   gitobserver.bat push     - Stage, commit, and push changes
echo   gitobserver.bat pull     - Pull latest changes from remote
echo   gitobserver.bat sync     - Synchronize local and remote repositories
echo   gitobserver.bat rollback - Rollback last commit
echo   gitobserver.bat help     - Show this help message
exit /b 0

:git_status
echo Checking repository status...
git status
exit /b 0

:git_push
echo Preparing to push changes...
git status --short
set "changes_detected="
for /f %%a in ('git status --short ^| find /c /v ""') do set "changes_detected=%%a"

if not defined changes_detected (
    echo No changes to commit.
    exit /b 0
)

set /p commit_msg="Enter commit message: "
if not defined commit_msg (
    echo Commit message cannot be empty.
    exit /b 1
)

git add .
git commit -m "%commit_msg%"
git push origin %branchName%
exit /b 0

:git_pull
echo Pulling latest changes...
git fetch
git pull origin %branchName%
exit /b 0

:git_sync
echo Synchronizing repository...
git fetch
git pull origin %branchName%
git push origin %branchName%
exit /b 0

:git_rollback
echo Rolling back last commit...
git rev-parse HEAD >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo No commits to rollback.
    exit /b 1
)

set /p confirm="Are you sure you want to rollback the last commit? (y/n): "
if /i "%confirm%"=="y" (
    git reset --soft HEAD~1
    echo Last commit rolled back.
) else (
    echo Rollback cancelled.
)
exit /b 0