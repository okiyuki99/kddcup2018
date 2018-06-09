import pandas as pd
import numpy as np

CITYS = ["bei","lon"]
TARGETS = {"bei" : ["PM2.5","PM10","O3"], "lon" : ["PM2.5","PM10"]}
STATIONS = {
    "bei" : list(np.unique(pd.read_csv("/mnt/data/kddcup2018/input_clean/original_bei_aq.tsv", sep = "\t")["station_id"])),
    "lon" : list(np.unique(pd.read_csv("/mnt/data/kddcup2018/input_clean/original_lon_aq1.tsv", sep = "\t")["station_id"])),
}
