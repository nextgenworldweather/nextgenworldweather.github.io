@echo off
:: Enhanced Git push script with advanced conflict resolution
:: Version 2.1.0

setlocal enabledelayedexpansion

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
    exit /b 0
)

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

echo Push completed successfully.
exit /b 0

:: Main script execution
call :advanced_push