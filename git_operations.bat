@echo off
:: Enhanced Git operations script with status report and auto-commit
:: Version 2.3.4

setlocal enabledelayedexpansion

:: Function to show git status and handle user prompt
:show_status
echo Generating Git status report...
git status
if %ERRORLEVEL% neq 0 (
    echo Failed to retrieve status. Check for errors.
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
    echo Changes detected in the repository.
    set /p user_choice="Would you like to stage and commit all changes? (y/n): "
    if /i "!user_choice!"=="y" (
        echo Enter commit message:
        set /p commitMessage=

        if "!commitMessage!"=="" (
            echo Commit message cannot be empty.
            exit /b 1
        )

        echo Staging and committing changes...
        git add .
        if %ERRORLEVEL% neq 0 (
            echo Failed to stage changes.
            exit /b %ERRORLEVEL%
        )

        git commit -m "!commitMessage!"
        if %ERRORLEVEL% neq 0 (
            echo Commit failed.
            exit /b %ERRORLEVEL%
        )
        
        echo Changes committed successfully!
    ) else (
        echo Changes not staged and committed.
    )
) else (
    echo No changes to commit.
)

exit /b 0

:: Conflict resolution function
:resolve_conflicts
echo Conflicts detected. Starting interactive resolution...

:: List conflicting files
echo Conflicting files:
git diff --name-only --diff-filter=U
if %ERRORLEVEL% neq 0 (
    echo No conflicts found.
    exit /b 0
)

:: Prompt for conflict resolution method
:conflict_menu
echo Conflict Resolution Options:
echo 1. Open conflicting files in VS Code
echo 2. Use 'git mergetool'
echo 3. Manually resolve conflicts
echo 4. Abort merge
set /p choice="Select option (1-4): "

if "%choice%"=="1" (
    start code .
    goto manual_resolution_prompt
) else if "%choice%"=="2" (
    git mergetool
    goto merge_complete
) else if "%choice%"=="3" (
    goto manual_resolution_prompt
) else if "%choice%"=="4" (
    git merge --abort
    echo Merge aborted.
    exit /b 1
) else (
    echo Invalid option. Try again.
    goto conflict_menu
)

:manual_resolution_prompt
echo IMPORTANT: After resolving conflicts:
echo 1. Remove conflict markers (<<<<<<<, =======, >>>>>>>)
echo 2. Save files
echo 3. Stage resolved files with 'git add'
echo 4. Complete merge with 'git commit'
pause
goto merge_complete

:merge_complete
git status
set /p confirmed="Have you resolved all conflicts? (y/n): "
if /i "%confirmed%"=="y" (
    git add .
    git commit -m "Resolved merge conflicts"
    exit /b 0
) else (
    goto resolve_conflicts
)

:advanced_push
echo Checking for uncommitted changes...
git diff-index --quiet HEAD
if %ERRORLEVEL% equ 0 (
    echo No local changes to commit.
    echo Checking if local branch is ahead of remote...
    git status | findstr "Your branch is ahead of"
    if %ERRORLEVEL% equ 0 (
        echo Local branch is ahead of remote. Pushing changes...
        git push origin main
        if %ERRORLEVEL% neq 0 (
            echo Push failed. Attempting to resolve...
            git pull --rebase origin main
            if %ERRORLEVEL% neq 0 (
                call :resolve_conflicts
            )
            
            git push origin main
        )
        echo Push completed successfully.
        exit /b 0
    ) else (
        echo No new changes to push.
        exit /b 0
    )
) else (
    echo Changes detected. Staging and committing changes...
    echo Enter commit message:
    set /p commitMessage=

    if "%commitMessage%"=="" (
        echo Commit message cannot be empty.
        exit /b 1
    )

    echo Fetching latest changes...
    git fetch origin

    echo Staging and committing changes...
    git add .
    git commit -m "%commitMessage%"

    echo Attempting to push...
    git push origin main
    if %ERRORLEVEL% neq 0 (
        echo Push failed. Attempting to resolve...
        git pull --rebase origin main
        if %ERRORLEVEL% neq 0 (
            call :resolve_conflicts
        )
        
        git push origin main
    )
)

echo Push completed successfully.
exit /b 0

:advanced_pull
echo Pulling changes from GitHub...
git pull origin main
if %ERRORLEVEL% neq 0 (
    echo Pull failed. Resolve any conflicts manually.
    exit /b %ERRORLEVEL%
)
echo Pull successful!
exit /b 0

:: Main script execution
if "%1"=="push" (
    call :advanced_push
) else if "%1"=="pull" (
    call :advanced_pull
) else if "%1"=="status" (
    call :show_status
) else (
    echo Invalid option. Use "push", "pull", or "status".
    exit /b 1
)

exit /b 0
