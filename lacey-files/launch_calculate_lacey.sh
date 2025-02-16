#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --nodes=4
#SBATCH --constraint=icelake
#SBATCH --ntasks=64

module purge; module load bluebear
module load bear-apps/2022a
module load Python/3.10.4-GCCcore-11.3.0
module load MNE-Python/1.3.1-foss-2022a
module load SciPy-bundle/2022.05-foss-2022a
module load natsort/8.2.0-foss-2022a

export VENV_DIR="${HOME}/virtual-environments"
export VENV_PATH="${VENV_DIR}/my-virtual-env-python2022a${BB_CPU}"

# Create a master venv directory if necessary
mkdir -p ${VENV_DIR}

# Check if virtual environment exists and create it if not
if [[ ! -d ${VENV_PATH}  ]]; then
	python -m venv --system-site-packages ${VENV_PATH}
fi

# Activate the virtual environment
source ${VENV_PATH}/bin/activate

# Execute your Python scripts
python calculate_lacey.py
