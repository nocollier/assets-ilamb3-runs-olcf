#!/bin/bash -l
#SBATCH --job-name=ilamb3
#SBATCH --account=cli137
#SBATCH --time=4:00:00
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

# Land run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
$SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
.venv/lib/python3.12/site-packages/ilamb3/configure/ilamb.yaml \
--model-db _land/BCC-ESM1.csv \
--model-db _land/CanESM5.csv \
--model-db _land/CESM2.csv \
--model-db _land/E3SM-1-1.csv \
--model-db _land/EC-Earth3-Veg.csv \
--model-db _land/GFDL-ESM4.csv \
--model-db _land/GISS-E2-1-G.csv \
--model-db _land/IPSL-CM6A-LR.csv \
--model-db _land/MIROC-ES2L.csv \
--model-db _land/MPI-ESM1-2-LR.csv \
--model-db _land/UKESM1-0-LL.csv \
--region-source regions/GlobalLand.nc \
--region global \
--main-region global \
--output-path _build/Land \
--cache \
--title "ILAMB historical"

# Ocean run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
$SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
/ccs/home/nate/ilamb3/ilamb3/configure/iomb.yaml \
--model-db _ocean/CanESM5.csv \
--output-path _build/Ocean \
--cache \
--central-longitude -155.0 \
--title "IOMB historical"
