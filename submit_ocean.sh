#!/bin/bash -l
#SBATCH --job-name=ilamb3
#SBATCH --account=cli137
#SBATCH --time=3:00:00
#SBATCH --nodes=4
#SBATCH --output=%x.log

# Setup: This makes sure that we have pointers to where the reference
# data is stored as well as the root of the model data. Finally we
# make sure the environment is activated and ready to go.
export ILAMB_ROOT=/lustre/orion/cli137/world-shared/ilamb3-data
export ESGF_ROOT=/lustre/orion/cli137/world-shared/ESGF-data
cd $SLURM_SUBMIT_DIR
source $SLURM_SUBMIT_DIR/.venv/bin/activate

# Mysterious incantations: Some functions in xarray are not threadsafe
# (like sel) and cause strange problems. h/t Min Xu
export HDF5_USE_FILE_LOCKING=FALSE
export NETCDF4_DISABLE_PTHREADS=1
export OMP_NUM_THREADS=1

# Ocean run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
$SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
.venv/lib/python3.12/site-packages/ilamb3/configure/iomb.yaml \
--model-db _ocean/ACCESS-ESM1-5.csv \
--model-db _ocean/BCC-ESM1.csv \
--model-db _ocean/CanESM5.csv \
--model-db _ocean/CMCC-ESM2.csv \
--model-db _ocean/GISS-E2-1-G.csv \
--model-db _ocean/MPI-ESM1-2-LR.csv \
--model-db _ocean/UKESM1-0-LL.csv \
--output-path _build/Ocean \
--cache \
--central-longitude -155.0 \
--title "IOMB historical"
