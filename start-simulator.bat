@echo off
title WristArcade Web Simulator
cd /d "%~dp0"
echo ===================================================
echo   WristArcade Web Simulator Baslatiliyor...
echo ===================================================
start http://localhost:3000
node server.js
pause
