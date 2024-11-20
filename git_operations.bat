@echo off
:: Git operations script for Windows with user-defined commit messages
:: Usage: Call with parameters for push or pull

if "%1"=="push" (
    call :push_changes
) else if "%1"=="pull" (
    call :pull_changes
) else (
    echo Invalid option. Use "push" or "pull".
    exit /b 1
)

exit /b 0

:push_changes
echo Enter your commit message:
set /p commitMessage=

if "%commitMessage%"=="" (
    echo Commit message cannot be empty.
    exit /b 1
)

echo Pushing changes to GitHub...
git add .
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

git commit -m "%commitMessage%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

git push origin main
if %ERRORLEVEL% neq 0 (
    echo Push failed. Try resolving remote conflicts by pulling first.
    exit /b %ERRORLEVEL%
)
echo Push successful!
exit /b 0

:pull_changes
echo Pulling changes from GitHub...
git pull origin main
if %ERRORLEVEL% neq 0 (
    echo Pull failed. Resolve any conflicts manually.
    exit /b %ERRORLEVEL%
)
echo Pull successful!
exit /b 0
