#!/bin/bash

#SBATCH --job-name=study_setup_py   # Job name
#SBATCH --output=job_output.txt     # Standard output file
#SBATCH --error=job_error.txt       # Standard error file
#SBATCH --time=00:10:00             # Wall time (hh:mm:ss)
#SBATCH --nodes=1                   # Number of nodes (VMs/clusters)    
#SBATCH --ntasks=1                  # Number of tasks (processes)
#SBATCH --constraint=icelake    

# Load modules
module purge
module load bluebear 
module load bear-apps/2022a
module load Python/3.10.4-GCCcore-11.3.0
module load SciPy-bundle/2022.05-foss-2022a
module load natsort/8.2.0-foss-2022a

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

# Install required Python packages

# echo "--- Pip modules installed to venv ---"

# Run the Python script 
python study_setup.py && echo " --- study_setup.py successful ---" || echo " --- study_setup.py failed ---"