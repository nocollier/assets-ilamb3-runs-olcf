
# Run as `bash fetch_h2o.sh` on log in node

# If you want to use cache in a certain directory, set env variables:
# ILAMB_ROOT=/path/to/ilamb3-data

# Activate the virtual environment
source .venv/bin/activate

# Get reference data
#ilamb fetch h2o.yaml

# Land model data
MODELS=("ACCESS-CM2" "ACCESS-ESM1-5 " "AWI-CM-1-1-MR" "AWI-ESM-1-1-LR" "BCC-CSM2-MR" "BCC-ESM1" "CanESM5" "CMCC-CM2-SR5" "CNRM-CM6-1" "CNRM-CM6-1-HR" "CNRM-ESM2-1" "EC-Earth3" "FGOALS-f3-L" "FGOALS-g3" "GFDL-CM4" "GFDL-ESM4" "GISS-E2-1-G" "HadGEM3-GC31-LL" "HadGEM3-GC31-MM" "INM-CM5-0" "IPSL-CM6A-LR" "KACE-1-0-G" "MIROC6" "MIROC-ES2L" "MPI-ESM-1-2-HAM" "MPI-ESM1-2-HR" "MPI-ESM1-2-LR" "MRI-ESM2-0" "NESM3" "NorCPM1" "NorESM2-LM" "NorESM2-MM" "SAM0-UNICON" "UKESM1-0-LL")

for model in "${MODELS[@]}"
do
    cat _h2o/${model}.csv > ${model}.csv
    grep -e 'mip_era' -e 'areacella' -e 'sftlf' -v _ext/${model}.csv >> ${model}.csv
done
#mkdir -p _ext
#for model in "${MODELS[@]}"
#do
#  echo "Querying ESGF for $model..."
#  ilamb esgf extremes.yaml --source-id $model
#done
#mv *.csv _ext
