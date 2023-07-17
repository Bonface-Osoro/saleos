from unittest import result
import emission_model as em
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import ScalarFormatter
from matplotlib import pyplot
from saleos.emissions import single_satellite_capacity

pd.set_option('mode.chained_assignment', None)

#Cpacity per single satellite
starlink_capacity = single_satellite_capacity(
    250 * 10 ** 6, 
    5.1152, 
    8, 
    2
)

kuiper_capacity = single_satellite_capacity(
    250 * 10 ** 6, 
    5.1152, 
    8, 
    2
)

oneweb_capacity = single_satellite_capacity(
    250*10**6, 
    5.1152, 
    8, 
    2
)