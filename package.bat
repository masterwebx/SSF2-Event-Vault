@echo off
echo Building the project...
dotnet build -c Release
if %errorlevel% neq 0 (
    echo Build failed.
    pause
    exit /b 1
)

echo Publishing the application...
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -p:PublishTrimmed=false
if %errorlevel% neq 0 (
    echo Publish failed.
    pause
    exit /b 1
)

echo Preparing publish directory...
if exist publish_final rmdir /s /q publish_final
mkdir publish_final
xcopy /e /i /y "bin\Release\net8.0-windows\win-x64\publish\*" publish_final\
if %errorlevel% neq 0 (
    echo Copy failed.
    pause
    exit /b 1
)

echo Creating zip archive...
taskkill /f /im "SSF2 Event Compiler.exe" 2>nul
timeout /t 2 /nobreak >nul
powershell -command "Compress-Archive -Path 'publish_final\*' -DestinationPath 'SSF2_Event_Compiler_v1.0.zip' -Force"
if %errorlevel% neq 0 (
    echo Zip creation failed.
    pause
    exit /b 1
)

echo Packaging complete. Zip file: SSF2_Event_Compiler_v1.0.zip
pause