@echo off
REM MovieApp - Auto Setup & Run Script
REM This script will clean, get dependencies, and run the app on Chrome

echo.
echo ============================================
echo   MovieApp - Flutter Web Setup & Run
echo ============================================
echo.

echo [1/3] Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/3] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/3] Running on Chrome...
flutter run -d chrome

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
pause
