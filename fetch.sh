
# We recommend that you run this on a data transfer node and most of what
# happens here is downloading of files.
export ILAMB_ROOT=/lustre/orion/cli137/world-shared/ilamb3-data
export ESGF_ROOT=/lustre/orion/cli137/world-shared/ESGF-data

# Get reference data
ilamb fetch .venv/lib/python3.12/site-packages/ilamb3/configure/ilamb.yaml
ilamb fetch .venv/lib/python3.12/site-packages/ilamb3/configure/iomb.yaml

# Land model data
MODELS=("BCC-ESM1" "CanESM5" "CESM2" "E3SM-1-1" "EC-Earth3-Veg" "GFDL-ESM4" "GISS-E2-1-G" "IPSL-CM6A-LR" "MIROC-ES2L" "MPI-ESM1-2-LR" "UKESM1-0-LL")
mkdir -p _land
for model in "${MODELS[@]}"
do
  echo "Querying ESGF for $model..."
  ilamb esgf .venv/lib/python3.12/site-packages/ilamb3/configure/ilamb.yaml --source-id $model
done
mv *.csv _land/

# Ocean model data
MODELS=("ACCESS-ESM1-5" "CanESM5" "CESM2" "CMCC-ESM2" "CNRM-ESM2-1" "GFDL-ESM4" "GISS-E2-1-G" "IPSL-CM6A-LR" "MIROC-ES2L" "MPI-ESM1-2-LR" "UKESM1-0-LL")
mkdir -p _ocean
for model in "${MODELS[@]}"
do
  echo "Querying ESGF for $model..."
  ilamb esgf .venv/lib/python3.12/site-packages/ilamb3/configure/iomb.yaml --source-id $model
done
mv *.csv _ocean/
