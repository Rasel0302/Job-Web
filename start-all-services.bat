@echo off
echo 🚀 Starting ACC Job Portal - All Services...

REM Check if node is available
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js first.
    pause
    exit /b 1
)

REM Check if python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python first.
    pause
    exit /b 1
)

echo 📦 Installing dependencies...

REM Install Node.js dependencies
echo Installing Node.js dependencies...
call npm install

REM Install Python dependencies
echo Installing Python dependencies...
cd recommendation_service
if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing Python packages...
pip install -r requirements-minimal.txt
if %errorlevel% equ 0 (
    pip install -r requirements-ml.txt
)

cd ..

echo 🎯 Starting all services...
echo.
echo Services will be available at:
echo   Frontend: http://localhost:5173
echo   Backend:  http://localhost:5000
echo   AI Service: http://localhost:5001
echo.
echo Press Ctrl+C to stop all services
echo.

REM Start all services using npm
npm run dev:full

pause
