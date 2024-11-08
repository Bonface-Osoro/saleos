import configparser
import os
import math
import time
import warnings
import pandas as pd

from tqdm import tqdm
warnings.filterwarnings('ignore')
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
DATA_RESULTS = os.path.join(BASE_PATH, '..', 'results')
DATA_SSA = os.path.join(BASE_PATH, '..', 'results', 'SSA')


def model_data():
    """
    This function calculates the summary statistics of the African poverty and 
    connectivity results needed in the capacity, cost and emission model.
    """
    print('Generating decile summary statistics')

    pop_data = os.path.join(DATA_SSA, 'SSA_to_be_served_population.csv')
    df = pd.read_csv(pop_data)

    df = df.groupby(['decile']).agg(total_population = ('population', 'sum'),
        total_poor_unconnected = ('poor_unconnected', 'sum'), total_area_sqkm = 
        ('area', 'sum'), total_max_distance_km = ('max_distance_km', 'sum'), 
        mean_poor_connected = ('poor_unconnected', 'mean'), mean_area_sqkm = 
        ('area', 'mean'), mean_distance_km = ('max_distance_km', 'mean')
        ).reset_index()
    coverage_area_4g_base_station = math.pi * 3 ** 2
    coverage_area_5g_base_station = math.pi * 1.6 ** 2

    df['no_of_4g_base_stations'] = round(df['mean_area_sqkm'] / 
                                         coverage_area_4g_base_station)
    df.loc[df['no_of_4g_base_stations'] == 0, 'no_of_4g_base_stations'] = 1
    df['no_of_5g_base_stations'] = round(df['mean_area_sqkm'] / 
                                         coverage_area_5g_base_station)

    filename = 'SSA_decile_summary_stats.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None


def decile_capacity_per_user():
    """
    This function calculates the per user metrics for each decile.
    """
    print('Generating per user metrics')

    pop_data = os.path.join(DATA_RESULTS, 'final_capacity_results.csv')
    df = pd.read_csv(pop_data)
    print(df.head(3))
    
    ################### Per user costs #####################
    
    df['per_user_capacity_mbps'] = (df['base_station_capacity_mbps'] / 
                                 df['total_poor_unconnected'])
    
    df['per_area_capacity_mbps'] = (df['base_station_capacity_mbps'] / 
                                 df['mean_area_sqkm'])
    
    df = df[['cell_generation', 'decile', 'per_user_capacity_mbps', 
             'per_area_capacity_mbps']]

    filename = 'SSA_decile_capacity.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None

decile_capacity_per_user()