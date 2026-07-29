@echo off
setlocal enabledelayedexpansion

REM ---------------------------------------------------------------------------
REM Configuration
REM ---------------------------------------------------------------------------

set "PROJECT_NAME=Flask Babael Demo"
set "PROJECT_VERSION=1.0.0"
set "BUGS_EMAIL=you@example.com"

set "BABEL_CFG=babel.cfg"
set "POT_FILE=messages.pot"
set "TRANSLATIONS_DIR=translations"
set "EXPORT_BASE_DIR=temp\testing"

REM Languages to initialize with /init
set "LANGUAGES=de fr it"

REM ---------------------------------------------------------------------------
REM Argument handling
REM ---------------------------------------------------------------------------

set "ACTION=%~1"

if "%ACTION%"=="" (
    call :show_help
    exit /b 0
)

if /I "%ACTION%"=="/help" (
    call :show_help
    exit /b 0
)

if /I "%ACTION%"=="/init" (
    call :do_init
    exit /b %ERRORLEVEL%
)

if /I "%ACTION%"=="/update" (
    call :do_update
    exit /b %ERRORLEVEL%
)

if /I "%ACTION%"=="/compile" (
    call :do_compile
    exit /b %ERRORLEVEL%
)

if /I "%ACTION%"=="/export" (
    call :do_export
    exit /b %ERRORLEVEL%
)

echo.
echo ERROR: Unknown parameter: %ACTION%
echo.
call :show_help
exit /b 1


REM ===========================================================================
REM Help
REM ===========================================================================

:show_help
echo.
echo ============================================================
echo pyBabel Helper
echo ============================================================
echo.
echo Usage:
echo   %~nx0 /init
echo   %~nx0 /update
echo   %~nx0 /compile
echo   %~nx0 /export
echo   %~nx0 /help
echo.
echo Parameters:
echo   /init      Cleans up all language files, extracts strings,
echo              initializes configured languages and compiles MO files.
echo.
echo   /update    Extracts strings into messages.pot and updates existing
echo              PO files.
echo.
echo   /compile   Compiles PO files into MO files.
echo.
echo   /export    Creates a timestamped export folder and ZIP file in:
echo              %EXPORT_BASE_DIR%
echo.
echo   /help      Shows this help message.
echo.
echo Current configuration:
echo   Project:          %PROJECT_NAME%
echo   Version:          %PROJECT_VERSION%
echo   Bugs email:       %BUGS_EMAIL%
echo   Babel config:     %BABEL_CFG%
echo   POT file:         %POT_FILE%
echo   Translations dir: %TRANSLATIONS_DIR%
echo   Export base dir:  %EXPORT_BASE_DIR%
echo   Languages:        %LANGUAGES%
echo.
exit /b 0


REM ===========================================================================
REM /init
REM Cleans up translations, extracts strings, initializes languages, compiles
REM ===========================================================================

:do_init
echo.
echo ============================================================
echo INIT Babel translations
echo ============================================================
echo.

call :check_babel_config
if errorlevel 1 exit /b 1

echo WARNING: This will delete the existing translations directory:
echo   %TRANSLATIONS_DIR%
echo.

if exist "%TRANSLATIONS_DIR%" (
    echo Removing existing translations directory...
    rmdir /s /q "%TRANSLATIONS_DIR%"

    if exist "%TRANSLATIONS_DIR%" (
        echo ERROR: Failed to remove translations directory.
        exit /b 1
    )
)

call :extract_strings
if errorlevel 1 exit /b 1

echo Initializing language files...

for %%L in (%LANGUAGES%) do (
    echo Initializing language: %%L

    pybabel init -i "%POT_FILE%" -d "%TRANSLATIONS_DIR%" -l %%L

    if errorlevel 1 (
        echo ERROR: pybabel init failed for language %%L.
        exit /b 1
    )
)

call :do_compile
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo INIT done
echo ============================================================
echo.

exit /b 0


REM ===========================================================================
REM /update
REM Extracts strings and updates existing PO files
REM ===========================================================================

:do_update
echo.
echo ============================================================
echo UPDATE Babel translations
echo ============================================================
echo.

call :check_babel_config
if errorlevel 1 exit /b 1

call :check_translations_dir
if errorlevel 1 exit /b 1

call :extract_strings
if errorlevel 1 exit /b 1

echo Updating .po files...

pybabel update -i "%POT_FILE%" -d "%TRANSLATIONS_DIR%"

if errorlevel 1 (
    echo ERROR: pybabel update failed.
    exit /b 1
)

echo.
echo ============================================================
echo UPDATE done
echo ============================================================
echo.

exit /b 0


REM ===========================================================================
REM /compile
REM Compiles PO files into MO files
REM ===========================================================================

:do_compile
echo.
echo ============================================================
echo COMPILE Babel translations
echo ============================================================
echo.

call :check_translations_dir
if errorlevel 1 exit /b 1

echo Compiling .mo files...

pybabel compile -d "%TRANSLATIONS_DIR%"

if errorlevel 1 (
    echo ERROR: pybabel compile failed.
    exit /b 1
)

echo.
echo ============================================================
echo COMPILE done
echo ============================================================
echo.

exit /b 0


REM ===========================================================================
REM /export
REM Creates timestamped export folder and ZIP file
REM ===========================================================================

:do_export
echo.
echo ============================================================
echo EXPORT Babel translations
echo ============================================================
echo.

call :check_pot_file
if errorlevel 1 exit /b 1

call :check_translations_dir
if errorlevel 1 exit /b 1

REM ---------------------------------------------------------------------------
REM Create timestamp
REM Format: yyyy-MM-dd_HHmm
REM ---------------------------------------------------------------------------

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmm'"`) do set "STAMP=%%i"

set "EXPORT_DIR=%EXPORT_BASE_DIR%\%STAMP%"
set "EXPORT_TRANSLATIONS_DIR=%EXPORT_DIR%\translations"
set "ZIP_FILE=%EXPORT_BASE_DIR%\%STAMP%.zip"

echo Timestamp:  %STAMP%
echo Export dir: %EXPORT_DIR%
echo Zip file:   %ZIP_FILE%
echo.

echo Creating export folder...

if not exist "%EXPORT_BASE_DIR%" (
    mkdir "%EXPORT_BASE_DIR%"

    if errorlevel 1 (
        echo ERROR: Failed to create export base directory.
        exit /b 1
    )
)

if exist "%EXPORT_DIR%" (
    echo ERROR: Export folder already exists:
    echo   %EXPORT_DIR%
    exit /b 1
)

mkdir "%EXPORT_DIR%"
if errorlevel 1 (
    echo ERROR: Failed to create export directory.
    exit /b 1
)

mkdir "%EXPORT_TRANSLATIONS_DIR%"
if errorlevel 1 (
    echo ERROR: Failed to create export translations directory.
    exit /b 1
)

echo Copying messages.pot...

copy "%POT_FILE%" "%EXPORT_DIR%\%POT_FILE%" >nul

if errorlevel 1 (
    echo ERROR: Failed to copy %POT_FILE%.
    exit /b 1
)

echo Copying translations...

robocopy "%TRANSLATIONS_DIR%" "%EXPORT_TRANSLATIONS_DIR%" /E >nul

REM Robocopy returns 0-7 for success-like outcomes, 8+ means failure.
if errorlevel 8 (
    echo ERROR: Failed to copy translations.
    exit /b 1
)

echo Creating zip archive...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Path '%EXPORT_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"

if errorlevel 1 (
    echo ERROR: Failed to create zip archive.
    exit /b 1
)

echo.
echo ============================================================
echo EXPORT done
echo ============================================================
echo Created:
echo   %EXPORT_DIR%
echo   %ZIP_FILE%
echo.

exit /b 0


REM ===========================================================================
REM Shared helper: Extract strings into messages.pot
REM ===========================================================================

:extract_strings
echo Extracting strings into %POT_FILE%...

pybabel extract ^
  -F "%BABEL_CFG%" ^
  -o "%POT_FILE%" ^
  --project="%PROJECT_NAME%" ^
  --version="%PROJECT_VERSION%" ^
  --msgid-bugs-address="%BUGS_EMAIL%" ^
  .

if errorlevel 1 (
    echo ERROR: pybabel extract failed.
    exit /b 1
)

exit /b 0


REM ===========================================================================
REM Shared helper: Sanity checks
REM ===========================================================================

:check_babel_config
if not exist "%BABEL_CFG%" (
    echo ERROR: Babel config not found:
    echo   %BABEL_CFG%
    exit /b 1
)

exit /b 0


:check_pot_file
if not exist "%POT_FILE%" (
    echo ERROR: POT file not found:
    echo   %POT_FILE%
    echo.
    echo Run this first:
    echo   %~nx0 /update
    echo.
    exit /b 1
)

exit /b 0


:check_translations_dir
if not exist "%TRANSLATIONS_DIR%" (
    echo ERROR: Translations directory not found:
    echo   %TRANSLATIONS_DIR%
    echo.
    echo Run this first:
    echo   %~nx0 /init
    echo.
    exit /b 1
)

exit /b 0
