#!/bin/bash -l
#SBATCH --job-name=ilamb3
#SBATCH --account=cli137
#SBATCH --time=4:00:00
#SBATCH --nodes=3
#SBATCH --output=%x-%j.log

# Run like `sbatch submit_h2o.sh` on log in node
export ILAMB_ROOT=/lustre/orion/cli137/world-shared/ilamb3-data
export ESGF_ROOT=/lustre/orion/cli137/world-shared/ESGF-data

# Setup: This makes sure that we have pointers to where the reference
# data is stored as well as the root of the model data. Finally we
# make sure the environment is activated and ready to go.
cd $SLURM_SUBMIT_DIR
source $SLURM_SUBMIT_DIR/.venv/bin/activate

# Mysterious incantations: Some functions in xarray are not threadsafe
# (like sel) and cause strange problems. h/t Min Xu
export HDF5_USE_FILE_LOCKING=FALSE
export NETCDF4_DISABLE_PTHREADS=1
export OMP_NUM_THREADS=1

# H2O run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
  $SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
  h2o.yaml \
  --model-db _cmp/ACCESS-CM2.csv \
  --model-db _cmp/AWI-CM-1-1-MR.csv \
  --model-db _cmp/AWI-ESM-1-1-LR.csv \
  --model-db _cmp/BCC-CSM2-MR.csv \
  --model-db _cmp/BCC-ESM1.csv \
  --model-db _cmp/CanESM5.csv \
  --model-db _cmp/CMCC-CM2-SR5.csv \
  --model-db _cmp/CNRM-CM6-1.csv \
  --model-db _cmp/CNRM-CM6-1-HR.csv \
  --model-db _cmp/CNRM-ESM2-1.csv \
  --model-db _cmp/EC-Earth3.csv \
  --model-db _cmp/FGOALS-g3.csv \
  --model-db _cmp/GFDL-ESM4.csv \
  --model-db _cmp/GISS-E2-1-G.csv \
  --model-db _cmp/HadGEM3-GC31-LL.csv \
  --model-db _cmp/HadGEM3-GC31-MM.csv \
  --model-db _cmp/INM-CM5-0.csv \
  --model-db _cmp/IPSL-CM6A-LR.csv \
  --model-db _cmp/MIROC6.csv \
  --model-db _cmp/MIROC-ES2L.csv \
  --model-db _cmp/MPI-ESM-1-2-HAM.csv \
  --model-db _cmp/MPI-ESM1-2-HR.csv \
  --model-db _cmp/MPI-ESM1-2-LR.csv \
  --model-db _cmp/MRI-ESM2-0.csv \
  --model-db _cmp/NorCPM1.csv \
  --model-db _cmp/NorESM2-LM.csv \
  --model-db _cmp/NorESM2-MM.csv \
  --model-db _cmp/SAM0-UNICON.csv \
  --model-db _cmp/UKESM1-0-LL.csv \
  --region global \
  --region-source _regions/CONUS.nc \
  --output-path _build/H2O \
  --no-cache \
  --title "Downscaling Pre-Study Over CONUS" \
  --main-region global
