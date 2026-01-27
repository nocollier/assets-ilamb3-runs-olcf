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

# Join the individual files model data CSV files. You could comment
# out any file if you wanted to exclude it from a run. Add more CSV's
# (generated with get_model_data.py) to run more models.
model_files=("_dbase/ACCESS-ESM1-5.csv" \
"_dbase/CanESM5.csv" \
"_dbase/CESM2.csv" \
"_dbase/CMCC-ESM2.csv" \
"_dbase/EC-Earth3-Veg.csv" \
"_dbase/GFDL-ESM4.csv" \
"_dbase/IPSL-CM6A-LR.csv" \
"_dbase/MIROC-ES2L.csv" \
"_dbase/MPI-ESM1-2-LR.csv" \
"_dbase/MRI-ESM2-0.csv" \
"_dbase/NorESM2-LM.csv" \
"_dbase/SAM0-UNICON.csv" \
"_dbase/TaiESM1.csv" \
"_dbase/UKESM1-0-LL.csv")
IFS=','
models="${model_files[*]}"

# Land run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
$SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
/ccs/home/nate/ilamb3/ilamb3/configure/ilamb.yaml \
--df-comparison "$models" \
--region-sources regions/GlobalLand.nc \
--regions global \
--global-region global \
--output-path _build/Land \
--cache \
--title "ILAMB historical"

# Ocean run
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
$SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
/ccs/home/nate/ilamb3/ilamb3/configure/iomb.yaml \
--df-comparison "$models" \
--output-path _build/Ocean \
--cache \
--central-longitude -155.0 \
--title "IOMB historical"
