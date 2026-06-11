
# We recommend that you run this on a data transfer node and most of what
# happens here is downloading of files.

MODELS=("BCC-ESM1" "CanESM5" "CESM2" "E3SM-1-1" "EC-Earth3-Veg" "GFDL-ESM4" "GISS-E2-1-G" "IPSL-CM6A-LR" "MIROC-ES2L" "MPI-ESM1-2-LR" "NorESM2-LM" "UKESM1-0-LL")

#mkdir -p _land
#for model in "${MODELS[@]}"
#do
#  echo "Querying ESGF for $model..."
#  ilamb esgf .venv/lib/python3.12/site-packages/ilamb3/configure/ilamb.yaml --source-id $model
#done
#mv *.csv _land/

mkdir -p _ocean
for model in "${MODELS[@]}"
do
  echo "Querying ESGF for $model..."
  ilamb esgf .venv/lib/python3.12/site-packages/ilamb3/configure/iomb.yaml --source-id $model
done
mv *.csv _ocean/
