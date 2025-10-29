@echo off
REM Startup script for Hybrid Job Recommendation Service (Windows)

echo 🚀 Starting Hybrid Job Recommendation Service...

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python 3.8 or higher.
    pause
    exit /b 1
)

REM Set up virtual environment if it doesn't exist
if not exist "venv" (
    echo 🔧 Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo 🔌 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install requirements
echo 📦 Installing requirements...
python -m pip install --upgrade pip

REM Try to install minimal requirements first
pip install -r requirements-minimal.txt
if %errorlevel% equ 0 (
    echo ✅ Minimal requirements installed successfully
    
    REM Try to install ML requirements
    echo 📊 Installing ML requirements...
    pip install -r requirements-ml.txt
    if %errorlevel% equ 0 (
        echo ✅ ML requirements installed successfully
        echo 🧠 Full ML capabilities available
    ) else (
        echo ⚠️ ML requirements failed, continuing with basic functionality
    )
) else (
    echo ❌ Failed to install minimal requirements
    pause
    exit /b 1
)

REM Set environment variables
set PYTHONPATH=%PYTHONPATH%;%CD%

REM Start the service
echo 🎯 Starting recommendation service...
python main.py

pause
