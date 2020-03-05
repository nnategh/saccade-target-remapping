#!/bin/bash
#
# SBATCH --partition=kingspeak-guest
# SBATCH --account=owner-guest
#
#SBATCH --partition=kingspeak
#
#SBATCH --job-name=saccade-target-remapping
#SBATCH --output=output-%j.txt
#SBATCH --error=error-%j.txt
#
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=10:00:00
#
#SBATCH --mail-user=yasin.zamani@gmail.com
#SBATCH --mail-type=ALL

module load matlab/R2019b
matlab -nosplash -nodesktop -nodisplay  -r "main"
