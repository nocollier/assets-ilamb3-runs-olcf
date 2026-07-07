# 1. Ensure openmpi is always loaded when you log in (run this once)
```bash
echo "module load openmpi" >> ~/.bashrc
echo "export ILAMB_ROOT=/lustre/orion/cli137/world-shared/ilamb3-data" >> ~/.bashrc
echo "export ESGF_ROOT=/lustre/orion/cli137/world-shared/ESGF-data" >> ~/.bashrc
```

# 2. Go to the direcotry where we launch runs:
```bash
cd /lustre/orion/cli137/proj-shared/ilamb_production_runs/assets-ilamb3-runs-olcf
```

# 3. (EXAMPLE) Write a new configure file
```yaml
Mean State:
  Precipitation:
    GPCPv2.3:
      sources:
        pr: pr/GPCPv2.3/pr.nc
      analyses:
        - bias
        - rmse
        - cycle
        - spatial_distribution
        - dispersion
      seasons: [DJF, MAM, JJA, SON]
      table_unit: mm d-1
      plot_unit: mm d-1
      variable_cmap: Blues
```

# 4. NOTE: If you are working on an ILAMB branch and want those changes to be reflected here:
In pyproject.toml, change the ilamb3 dependency to point to your branch, for example:
```config
ilamb3 = { git = "https://github.com/rubisco-sfa/ilamb3", branch = "logging" }  # pick which branch
```
Then, run `uv sync --upgrade`.


# 4a. If this is your first ILAMB run on this machine, run `ilamb init`
This downloads cartopy basemap things that can't be done in parallel on HPC without cartopy network getting mad.


# 5. Try running with your config
Create a bash file (e.g., `submit_h2o.sh`) with the following contents:
```bash
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

# H2O run
```bash
srun -n 16 --cpu-bind=cores --distribution=cyclic python -m mpi4py.futures \
  $SLURM_SUBMIT_DIR/.venv/bin/ilamb run \
  /lustre/orion/cli137/proj-shared/ilamb_production_runs/assets-ilamb3-runs-olcf/h2o.yaml \
  --model-db _land/CanESM5.csv \
  --region-source regions/GlobalLand.nc \
  --region global \
  --main-region global \
  --output-path _build/H2O \
  --cache \
  --title "H2O CanESM5"
```

Then, run the script in command line:
```bash
sbatch submit_h2o.sh
```

To track the job's progress, run:
```bash
squeue -u $USER
```

To cancel the job, run:
```bash
scancel <job_id>
```