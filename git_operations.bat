@echo off
:: Git Operations Helper Script for nextgenworldweather.github.io Repository
:: Version 3.1.0

:: Configuration
setlocal enabledelayedexpansion
set repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git
set branchName=main

:: Helper function to prompt user action for each modified file
:process_changes
set "changes=%~1"

:: Display detected changes
echo Checking repository: %repoURL%...
git status -s
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
    exit /b %ERRORLEVEL%
)

set /p status_choice="Would you like to view detailed status information? (y/n): "
if /i "%status_choice%"=="y" (
    git status -v
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to retrieve detailed status.
        exit /b %ERRORLEVEL%
    )
    echo Detailed status displayed successfully.
) else (
    echo Status check complete. No detailed view requested.
)

:: Prompt user to select operation for all modified files
echo.
echo Please choose an operation to perform on the modified files:
echo 1. Stage all modified files with 'git add .'
echo 2. Discard all changes in the working directory with 'git restore -- .'
echo 3. Skip changes and do nothing
set /p action_choice="Select an option (1/2/3): "

if "%action_choice%"=="1" (
    echo Staging all modified files...
    git add .
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to stage files.
        exit /b %ERRORLEVEL%
    )
    echo Files staged successfully.
) else if "%action_choice%"=="2" (
    echo Discarding changes in all modified files...
    git restore -- .
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to discard changes.
        exit /b %ERRORLEVEL%
    )
    echo Changes discarded successfully.
) else (
    echo No changes applied. Skipping files.
)

:: Commit the changes if staged
echo Enter commit message:
set /p commitMessage=
if "%commitMessage%"=="" (
    echo Error: Commit message cannot be empty.
    exit /b 1
)
git commit -m "%commitMessage%"
if %ERRORLEVEL% neq 0 (
    echo Error: Commit operation failed.
    exit /b %ERRORLEVEL%
)
echo Changes committed successfully.

:: Push committed changes
set /p push_choice="Would you like to push changes to %repoURL%? (y/n): "
if /i "%push_choice%"=="y" (
    git push origin %branchName%
    if %ERRORLEVEL% neq 0 (
        echo Error: Push operation failed. Attempting to resolve...
        git pull --rebase origin %branchName%
        if %ERRORLEVEL% neq 0 (
            echo Error: Pull and rebase failed. Resolve conflicts manually.
            exit /b 1
        )
        git push origin %branchName%
    )
    echo Success: Changes pushed to %repoURL%.
) else (
    echo Push operation cancelled by user.
)

exit /b 0

:: Function to display concise Git status
:show_status
echo Checking repository: %repoURL%...
git status -s
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
    exit /b %ERRORLEVEL%
)

set /p status_choice="Would you like to view detailed status information? (y/n): "
if /i "%status_choice%"=="y" (
    echo Retrieving detailed status for %repoURL%...
    git status -v
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to retrieve detailed status.
        exit /b %ERRORLEVEL%
    )
    echo Detailed status displayed successfully.
) else (
    echo Status check complete. No detailed view requested.
)

exit /b 0

:: Function to pull changes
:advanced_pull
echo Checking repository: %repoURL%...
git status -s
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
    exit /b %ERRORLEVEL%
)

:: Proceed to pull changes
git pull origin %branchName%
if %ERRORLEVEL% neq 0 (
    echo Error: Pull operation failed. Resolve conflicts manually if present.
    exit /b %ERRORLEVEL%
)
echo Success: Pull operation completed successfully.
exit /b 0

:: Function to push changes
:advanced_push
echo Checking repository: %repoURL%...
git status -s
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve repository status.
    exit /b %ERRORLEVEL%
)

:: Check if local branch is ahead of remote
git status | findstr "Your branch is ahead of"
if %ERRORLEVEL% equ 0 (
    echo Local branch is ahead of remote. Pushing changes...
    git push origin %branchName%
    if %ERRORLEVEL% neq 0 (
        echo Error: Push operation failed. Attempting to resolve...
        git pull --rebase origin %branchName%
        if %ERRORLEVEL% neq 0 (
            echo Error: Pull and rebase failed. Resolve conflicts manually.
            exit /b 1
        )
        git push origin %branchName%
    )
    echo Success: Changes pushed to %repoURL%.
    exit /b 0
)

:: Commit changes if any
git diff-index --quiet HEAD
if %ERRORLEVEL% neq 0 (
    echo Staged changes detected. Commit required.
    echo Enter commit message:
    set /p commitMessage= 
    if "%commitMessage%"=="" (
        echo Error: Commit message cannot be empty.
        exit /b 1
    )
    git commit -m "%commitMessage%"
    if %ERRORLEVEL% neq 0 (
        echo Error: Commit operation failed.
        exit /b %ERRORLEVEL%
    )
    echo Changes committed successfully.
)

:: Push committed changes
set /p push_choice="Would you like to push changes to %repoURL%? (y/n): "
if /i "%push_choice%"=="y" (
    git push origin %branchName%
    if %ERRORLEVEL% neq 0 (
        echo Error: Push operation failed. Attempting to resolve...
        git pull --rebase origin %branchName%
        if %ERRORLEVEL% neq 0 (
            echo Error: Pull and rebase failed. Resolve conflicts manually.
            exit /b 1
        )
        git push origin %branchName%
    )
    echo Success: Changes pushed to %repoURL%.
) else (
    echo Push operation cancelled by user.
)

exit /b 0

:: Main script execution
if "%1"=="status" (
    call :show_status
) else if "%1"=="pull" (
    call :advanced_pull
) else if "%1"=="push" (
    call :advanced_push
) else (
    echo Error: Invalid option. Use "status", "pull", or "push".
    exit /b 1
)

exit /b 0
