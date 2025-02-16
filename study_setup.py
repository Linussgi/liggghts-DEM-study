from jinja2 import Environment, FileSystemLoader
import os
import numpy as np
import shutil
import glob
from natsort import natsorted
import itertools

# Side length of phase space
NSAMPLES = 4

# Base amplitude value
BASE_AMP = 0.002549432237860155
FIXED_FRIC = 0.7

# Unused parameters for `resodyn.sim` 
NUM_PARTICLES = 96685
ONTIME = 0.05
FILLTIME = 0.2
SETTLETIME = 0.3

# Toggle slurm workflow to send job to BEAR
SLURM = True

# Setup Jinja2 environment 
current_dir = os.path.dirname(os.path.abspath(__file__))
templates_dir = os.path.join(current_dir, "sim-templates")

env = Environment(loader=FileSystemLoader(templates_dir))
template_particles = env.get_template("particles_template.sim")
template_resodyn = env.get_template("resodyn_template.sim")

# Parameter sweep values
cor_pp_values = np.linspace(0.05, 1.0, NSAMPLES)  # Restitution values
amp_values = np.linspace(BASE_AMP, 3 * BASE_AMP, NSAMPLES)  # Amplitude values

# Parent directory for all parameter sweep folders
output_dir = os.path.join(current_dir, "sweep_output")
os.makedirs(output_dir, exist_ok=True)

# Study generation
iteration = 1
for cor_pp, amp in itertools.product(cor_pp_values, amp_values):
    folder_name = f"rest_{cor_pp:.3f}_amp_{amp:.6f}"
    folder_path = os.path.join(output_dir, folder_name)

    # Create unique folder for each run
    os.makedirs(folder_path, exist_ok=True)

    # Generate `particles.sim` 
    particles_path = os.path.join(folder_path, "particles.sim")
    with open(particles_path, "w") as sim_file:
        sim_file.write(template_particles.render(
            fric_pp=FIXED_FRIC,  
            cor_pp=cor_pp  
        ))

    # Generate `resodyn.sim` 
    resodyn_path = os.path.join(folder_path, "resodyn.sim")
    with open(resodyn_path, "w") as sim_file:
        sim_file.write(template_resodyn.render(
            amp=amp
        ))

    # Copy `mesh` folder and `run.sh`
    new_mesh_dir = os.path.join(folder_path, "mesh")
    source_mesh_dir = os.path.join(current_dir, "mesh")
    shutil.copytree(source_mesh_dir, new_mesh_dir, dirs_exist_ok=True)

    run_script_path = os.path.join(folder_path, "run.sh")
    shutil.copy(os.path.join(current_dir, "bash", "run.sh"), run_script_path)

    iteration += 1

# Submit jobs
if SLURM:
    run_folders = natsorted(glob.glob(os.path.join(output_dir, "rest_*_amp_*"))) 
    for index, run_folder in enumerate(run_folders):
        launch_file = os.path.join(run_folder, "run.sh")
        cmd = f"sbatch --output={run_folder}/slurm-%j.out {launch_file} {run_folder}"

        # Print job names
        run_folder_name = os.path.basename(run_folder)  
        parent_folder_name = os.path.basename(os.path.dirname(run_folder))  
        print(f"Submitting job for {parent_folder_name}/{run_folder_name}: Job {index + 1}")

        os.system(cmd)  # Submit job