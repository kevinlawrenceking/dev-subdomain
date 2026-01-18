@echo off
REM deploy_uat_local.bat
REM Merges dev → uat and pushes to GitHub (no SSH to server)

REM ===== CONFIGURATION =====
set "GIT_REPO_DIR=C:\Users\xkking\new tao dev\dev-subdomain"
REM =========================

echo ---- Pulling latest dev branch ----
cd /d "%GIT_REPO_DIR%"
git checkout dev
git pull origin dev
IF ERRORLEVEL 1 goto error

echo ---- Merging dev into uat ----
cd /d "%GIT_REPO_DIR%"
git checkout uat
git pull origin uat
IF ERRORLEVEL 1 goto error
git merge dev
IF ERRORLEVEL 1 goto error
git push origin uat
IF ERRORLEVEL 1 goto error

echo.
echo Deployment complete.
echo Now use the Hostek Git panel to pull the latest uat branch to the server.
goto end

:error
echo.
echo ERROR: Deployment failed.
pause
exit /b 1

:end
pause
