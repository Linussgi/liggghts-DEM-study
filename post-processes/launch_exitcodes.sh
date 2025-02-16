#!/bin/bash

#SBATCH --job-name=post_check_py    # Job name
#SBATCH --output=setup_output.txt     # Standard output file
#SBATCH --error=setup_errors.txt       # Standard error file
#SBATCH --time=01:00:00             # Wall time (hh:mm:ss)
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

source ${VENV_PATH}/bin/activate

echo "--- Python venv activated ---"

# Run the Python script 
python exitcodes.py && echo " --- exitcodes.py successful ---" || echo " --- exitcodes.py failed ---"
