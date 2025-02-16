#!/bin/bash

#SBATCH --job-name=check_vtks    # Job name
#SBATCH --output=check_vtks_output.txt     # Standard output file
#SBATCH --error=check_vtks_error.txt       # Standard error file
#SBATCH --time=06:00:00             # Wall time (hh:mm:ss)
#SBATCH --nodes=1                   # Number of nodes (VMs/clusters)
#SBATCH --ntasks=1                  # Number of tasks (processes)
#SBATCH --constraint=icelake    

# Load modules
module purge
module load bluebear 
module load bear-apps/2022a
module load Python/3.10.4-GCCcore-11.3.0

echo "--- Modules loaded ---"

# Python virtual environment
export VENV_DIR="${HOME}/virtual-environments"
export VENV_PATH="${VENV_DIR}/job_venv"

mkdir -p ${VENV_DIR}
if [[ ! -d ${VENV_PATH} ]]; then
    python -m venv --system-site-packages ${VENV_PATH}
fi

echo "--- Python venv created ---"

source ${VENV_PATH}/bin/activate

echo "--- Python venv activated ---"

# Install required Python packages
pip install pyvista

# Run the Python script 
python check_vtks.py && echo " --- check_vtks.py successful ---" || echo " --- check_vtks.py failed ---"