@echo off
git add .
if "%~1"=="" (
    echo No commit message provided. Using default message "Automatic Changes".
    git commit -m "Automatic Changes"
) else (
    git commit -m "%~1"
)
git push origin main

