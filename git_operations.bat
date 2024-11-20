@echo off
:: Git Helper Script for nextgenworldweather.github.io Repository
:: Version 2.4.1

:: Configuration
setlocal enabledelayedexpansion
set repoURL=https://github.com/nextgenworldweather/nextgenworldweather.github.io.git
set branchName=main

:: Function to check Git status
:show_status
echo Generating Git status report for repository: %repoURL%...
git status
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to retrieve status. Ensure Git is properly set up for this repository.
    exit /b %ERRORLEVEL%
)

:: Check for changes not staged for commit
set changes_present=0
for /f "tokens=*" %%i in ('git status -s') do (
    set changes_present=1
    goto break_loop
)
:break_loop

if %changes_present% equ 1 (
    echo.
    echo Changes detected in the repository: %repoURL%.
    set /p user_choice="Would you like to stage and commit all changes? (y/n): "
    if /i "!user_choice!"=="y" (
        echo Enter commit message:
        set /p commitMessage=

        if "!commitMessage!"=="" (
            echo Error: Commit message cannot be empty.
            exit /b 1
        )

        echo Staging and committing changes...
        git add .
        if %ERRORLEVEL% neq 0 (
            echo Error: Failed to stage changes.
            exit /b %ERRORLEVEL%
        )

        git commit -m "!commitMessage!"
        if %ERRORLEVEL% neq 0 (
            echo Error: Commit failed.
            exit /b %ERRORLEVEL%
        )
        
        echo Success: Changes committed successfully to %repoURL%!
    ) else (
        echo Changes not staged and committed.
    )
) else (
    echo No changes to commit for %repoURL%.
)

exit /b 0

:: Function for push operation
:advanced_push
echo Checking for uncommitted changes in %repoURL%...
git diff-index --quiet HEAD
if %ERRORLEVEL% equ 0 (
    echo No local changes to commit for %repoURL%.
    echo Checking if local branch is ahead of remote...
    git status | findstr "Your branch is ahead of"
    if %ERRORLEVEL% equ 0 (
        echo Local branch is ahead of remote. Pushing changes to %repoURL%...
        git push origin %branchName%
        if %ERRORLEVEL% neq 0 (
            echo Error: Push failed. Attempting to resolve...
            git pull --rebase origin %branchName%
            if %ERRORLEVEL% neq 0 (
                echo Error: Pull failed. Resolve conflicts manually.
                exit /b 1
            )
            git push origin %branchName%
        )
        echo Success: Push completed successfully to %repoURL%.
        exit /b 0
    ) else (
        echo No new changes to push for %repoURL%.
        exit /b 0
    )
) else (
    echo Changes detected. Staging and committing changes...
    echo Enter commit message:
    set /p commitMessage=

    if "%commitMessage%"=="" (
        echo Error: Commit message cannot be empty.
        exit /b 1
    )

    echo Fetching latest changes from %repoURL%...
    git fetch origin

    echo Staging and committing changes...
    git add .
    git commit -m "%commitMessage%"

    echo Attempting to push to %repoURL%...
    git push origin %branchName%
    if %ERRORLEVEL% neq 0 (
        echo Error: Push failed. Attempting to resolve...
        git pull --rebase origin %branchName%
        if %ERRORLEVEL% neq 0 (
            echo Error: Pull failed. Resolve conflicts manually.
            exit /b 1
        )
        git push origin %branchName%
    )
)

echo Success: Push completed successfully to %repoURL%.
exit /b 0

:: Function for pull operation
:advanced_pull
echo Pulling changes from %repoURL%...
git pull origin %branchName%
if %ERRORLEVEL% neq 0 (
    echo Error: Pull failed for %repoURL%. Resolve any conflicts manually.
    exit /b %ERRORLEVEL%
)
echo Success: Pull completed from %repoURL%.
exit /b 0

:: Main script execution
if "%1"=="push" (
    call :advanced_push
) else if "%1"=="pull" (
    call :advanced_pull
) else if "%1"=="status" (
    call :show_status
) else (
    echo Error: Invalid option. Use "push", "pull", or "status".
    exit /b 1
)

exit /b 0
