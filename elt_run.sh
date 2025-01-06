#!/bin/bash

echo "========== Start Orcestration Process =========="

# Virtual Environment Path
VENV_PATH="D:\Coding\Training\Data_Warehouse\Week_05\dataset-olist\.venv\Scripts\activate"

# Activate Virtual Environment
source "$VENV_PATH"

# Set Python script
PYTHON_SCRIPT="D:\Coding\Training\Data_Warehouse\Week_05\dataset-olist\elt_main.py"

# Run Python Script 
python3 "$PYTHON_SCRIPT"


echo "========== End of Orcestration Process =========="