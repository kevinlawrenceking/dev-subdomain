@echo off
REM deploy_uat.bat
REM Merges dev → uat and updates the UAT server in one command (Windows version)

REM ===== CONFIGURATION =====
set "GIT_REPO_DIR=C:\Users\xkking\new tao dev\dev-subdomain"
set "UAT_SERVER=youruser@uat.theactorsoffice.com"
set "UAT_PATH=/path/to/wwwroot/uat_theactorsoffice"
REM =========================

echo ---- Pulling latest dev branch ----
cd /d "%GIT_REPO_DIR%"
git checkout dev
git pull origin dev
IF ERRORLEVEL 1 goto error

echo ---- Merging dev into uat ----
git checkout uat
git pull origin uat
IF ERRORLEVEL 1 goto error
git merge dev
IF ERRORLEVEL 1 goto error
git push origin uat
IF ERRORLEVEL 1 goto error

echo ---- Updating UAT server ----
ssh %UAT_SERVER% "cd %UAT_PATH% && git checkout uat && git pull origin uat"
IF ERRORLEVEL 1 goto error

echo.
echo UAT deployment complete!
goto end

:error
echo.
echo ERROR: Deployment failed.
pause
exit /b 1

:end
pause
