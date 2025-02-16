#!/bin/bash
#SBATCH --time 48:00:00
#SBATCH --ntasks 4    
#SBATCH --constraint icelake
#SBATCH --job-name p1rm
#SBATCH --output slurm_simulation_%j.out

set -e  # Exit immediately if any command fails

# Load required modules
module purge
module load bluebear
module load bear-apps/2022a
module load PICI-LIGGGHTS/3.8.1-foss-2022a-VTK-9.2.2

# Navigate to the directory where the simulation will run
cd $1

# Run LIGGGHTS with 4 MPI processes
mpiexec -n 4 liggghts -in resodyn.sim
