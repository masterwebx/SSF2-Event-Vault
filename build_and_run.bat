@echo off
echo Building SSF2 Event Compiler WPF...
dotnet build
if %errorlevel% neq 0 (
    echo.
    echo Build failed! Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo Build successful! Starting application...
echo.
dotnet run
if %errorlevel% neq 0 (
    echo.
    echo Application exited with error code %errorlevel%
    pause
)