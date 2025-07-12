@echo off
echo 🤖 Starting Local AI Backend for DressApp...
echo.
echo 📍 Server will run on: http://localhost:5000
echo 📱 For Android emulator, use: http://10.0.2.2:5000
echo 🍎 For iOS simulator, use: http://localhost:5000
echo.
echo ⚠️  Make sure you have Python and all dependencies installed!
echo.

REM Check if virtual environment exists
if exist "venv\Scripts\activate.bat" (
    echo 🐍 Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo ⚠️  Virtual environment not found. Installing dependencies...
    python -m venv venv
    call venv\Scripts\activate.bat
    pip install -r requirements.txt
)

echo.
echo 🚀 Starting AI Backend Server...
echo.
python start_local_server.py

pause 