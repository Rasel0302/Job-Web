#!/bin/bash
# Startup script for Hybrid Job Recommendation Service (Linux/Mac)

echo "🚀 Starting Hybrid Job Recommendation Service..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.8 or higher."
    exit 1
fi

# Set up virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "🔧 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Install requirements
echo "📦 Installing requirements..."
pip install --upgrade pip

# Try to install minimal requirements first
if pip install -r requirements-minimal.txt; then
    echo "✅ Minimal requirements installed successfully"
    
    # Try to install ML requirements
    echo "📊 Installing ML requirements..."
    if pip install -r requirements-ml.txt; then
        echo "✅ ML requirements installed successfully"
        echo "🧠 Full ML capabilities available"
    else
        echo "⚠️ ML requirements failed, continuing with basic functionality"
    fi
else
    echo "❌ Failed to install minimal requirements"
    exit 1
fi

# Set environment variables
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Start the service
echo "🎯 Starting recommendation service..."
python main.py
