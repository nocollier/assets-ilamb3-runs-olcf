"""
source_id          member_id  grid_label
ACCESS-ESM1-5      r1i1p1f1   gn            30
CanESM5            r1i1p1f1   gn            29
CanESM5-1          r1i1p1f1   gn            29
CESM2              r10i1p1f1  gn            45
CESM2-FV2          r1i1p1f1   gn            45
CESM2-WACCM        r1i1p1f1   gn            44
CESM2-WACCM-FV2    r3i1p1f1   gn            45
CMCC-CM2-SR5       r1i1p1f1   gn            28
CMCC-ESM2          r1i1p1f1   gn            34
CNRM-ESM2-1        r1i1p1f2   gr            24
EC-Earth3-CC       r1i1p1f1   gr            24
EC-Earth3-Veg      r12i1p1f1  gr            26
EC-Earth3-Veg-LR   r1i1p1f1   gr            23
GFDL-ESM4          r1i1p1f1   gr1           23
IPSL-CM6A-LR       r1i1p1f1   gr            23
IPSL-CM6A-LR-INCA  r1i1p1f1   gr            23
MIROC-ES2H         r1i1p4f2   gn            30
MIROC-ES2L         r1i1p1f2   gn            30
MPI-ESM-1-2-HAM    r1i1p1f1   gn            32
MPI-ESM1-2-LR      r1i1p1f1   gn            32
MRI-ESM2-0         r1i2p1f1   gn            30
NorESM2-LM         r1i1p1f1   gn            26
NorESM2-MM         r1i1p1f1   gn            26
SAM0-UNICON        r1i1p1f1   gn            24
TaiESM1            r1i1p1f1   gn            23
UKESM1-0-LL        r1i1p1f2   gn            32
UKESM1-1-LL        r1i1p1f2   gn            25
"""

import itertools
import os
from pathlib import Path

import pandas as pd
import xarray as xr
from ilamb3.cli import _dataframe_cmip
from intake_esgf import ESGFCatalog
from intake_esgf.exceptions import NoSearchResults


def remove_duplicate_tables(cat: ESGFCatalog) -> ESGFCatalog:
    """
    Sometimes a variable is duplicated in several table_id's.
    """
    drops = []
    for _, grp in cat.df.groupby(
        ["source_id", "member_id", "grid_label", "variable_id"]
    ):
        if len(grp) == 1:
            continue

        drops += list(grp.index[1:])
    cat.df = cat.df.drop(drops)
    return cat


def remove_dumb_table_ids(cat: ESGFCatalog) -> ESGFCatalog:
    cat.df = cat.df[~cat.df["table_id"].isin(["ImonAnt", "ImonGre"])]
    return cat


Path("_dbase").mkdir(exist_ok=True)

VARIABLES = [
    "burntFractionAll",  # ILAMB
    "cSoil",
    "cSoilAbove1m",
    "cVeg",
    "evspsbl",
    "fBNF",
    "gpp",
    "hfls",
    "hfss",
    "hurs",
    "lai",
    "mrro",
    "mrsol",
    "pr",
    "ra",
    "rh",
    "rlds",
    "rlus",
    "rsds",
    "rsus",
    "snc",
    "tas",
    "tasmax",
    "tasmin",
    "tsl",
    "chl",  # IOMB
    "no3",
    "o2",
    "omlmax",
    "po4",
    "si",
    "sotalk",
    "thetao",
]
MODELS = [
    # {"source_id": "ACCESS-ESM1-5", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "CanESM5", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "CESM2", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "CMCC-ESM2", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "E3SM-2-1", "member_id": "r1i1p1f1", "grid_label": "gr"},
    # {"source_id": "EC-Earth3-Veg", "member_id": "r12i1p1f1", "grid_label": "gr"},
    # {"source_id": "GFDL-ESM4", "member_id": "r1i1p1f1", "grid_label": "gr1"},
    {"source_id": "IPSL-CM6A-LR", "member_id": "r1i1p1f1", "grid_label": "gr"},
    # {"source_id": "MIROC-ES2L", "member_id": "r1i1p1f2", "grid_label": "gn"},
    # {"source_id": "MPI-ESM1-2-LR", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "MRI-ESM2-0", "member_id": "r1i2p1f1", "grid_label": "gn"},
    # {"source_id": "NorESM2-LM", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "SAM0-UNICON", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "TaiESM1", "member_id": "r1i1p1f1", "grid_label": "gn"},
    # {"source_id": "UKESM1-0-LL", "member_id": "r1i1p1f2", "grid_label": "gn"},
]

# intake_esgf.conf.set(all_indices=True)

for model in MODELS:
    # overwrite the cache
    cache = Path(f"_dbase/{model['source_id']}.csv")
    if cache.is_file():
        cache.unlink()

    # The first set we only get the files beyond 1960
    cat = ESGFCatalog()
    cat.search(
        experiment_id="historical",
        **model,
        variable_id=VARIABLES,
        frequency="mon",
        file_start="1960-01",
        file_end="2015-01",
    )
    cat = remove_dumb_table_ids(cat)
    for _, grp in cat.df.groupby(
        ["source_id", "member_id", "grid_label", "variable_id"]
    ):
        assert len(grp) == 1
    dpd = cat.to_path_dict(ignore_facets="table_id")

    # ...but nbp needs to go back to 1850 for the Hoffman comparison.
    cat = ESGFCatalog()
    try:
        cat.search(
            experiment_id="historical",
            **model,
            variable_id=["nbp", "fgco2"],
            frequency="mon",
        )
        dpd.update(cat.to_path_dict())
    except NoSearchResults:
        pass

    # Now we build a cache file
    df = _dataframe_cmip(
        root=Path(
            os.path.commonpath(itertools.chain(*[val for _, val in dpd.items()]))
        ),
        cache_file=cache,
    )

    # We also need to make sure cell measures are in there.
    add = []
    for v in ["areacella", "sftlf", "areacello", "sftof"]:
        cat = ESGFCatalog()
        try:
            cat.search(
                source_id=model["source_id"],
                grid_label=model["grid_label"],
                variable_id=v,
                frequency="fx",
            )
        except Exception:
            continue
        cat.df = cat.df.iloc[0:1]

        dpd = cat.to_path_dict(ignore_facets="table_id")
        path = next(iter(dpd.items()))[1][0]
        ds = xr.open_dataset(path)

        msr = {c: ds.attrs[c] if c in ds.attrs else pd.NA for c in df.columns}
        msr["path"] = path
        add.append(msr)

    df = pd.concat([df, pd.DataFrame(add)])
    print(df)
    df.to_csv(cache, index=False)
