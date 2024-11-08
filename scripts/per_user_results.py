import configparser
import os
import math
import warnings
import numpy as np
import pandas as pd
from tqdm import tqdm
from inputs import decile_satellites
warnings.filterwarnings('ignore')
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
DATA_PROCESSED = os.path.join(BASE_PATH, '..', 'data', 'processed')
DATA_RESULTS = os.path.join(BASE_PATH, '..', 'results')
DATA_SSA = os.path.join(BASE_PATH, '..', 'results', 'SSA')
DECILE_DATA = os.path.join(BASE_PATH, '..', '..', 'geosafi-consav', 'results', 
                           'SSA')

deciles = ['Decile 1', 'Decile 2', 'Decile 3', 'Decile 4', 'Decile 5',
           'Decile 6', 'Decile 7', 'Decile 8', 'Decile 9', 'Decile 10']

def decile_satellite(decile):

    """
    This function assigns the number of satellites based on the decile

    Parameters
    ----------
    decile : string
        Population decile category

    Returns
    -------
    number_of_satellites : int
        Number of satellites over a country.
    """
    for key, sat_numbers in decile_satellites.items():

        if key == decile:
            
            number_of_satellites = sat_numbers

    return number_of_satellites


def decile_capacity_per_user():
    """
    This function calculates the per user metrics for each decile.
    """
    print('Generating per user metrics')

    cap_data = os.path.join(DATA_PROCESSED, 'interim_results_capacity.csv')
    pop_path = os.path.join(DECILE_DATA, 'SSA_decile_summary_stats.csv')
    df1 = pd.read_csv(pop_path) 
    df1 = df1[['decile', 'mean_poor_connected']]

    df = pd.read_csv(cap_data)
    df = df[['constellation', 'capacity_per_single_satellite_mbps']]
    df[['decile', 'technology', 'connected_sats', 'total_capacity_mbps', 
        'per_user_capacity_mbps']] = ''

    df['decile'] = np.resize(deciles, len(df))
    df = pd.merge(df, df1, on = 'decile')
    for i in range(len(df)):

        df.loc[i, 'technology'] = 'satellite'

        df.loc[i, 'connected_sats'] = decile_satellite(df['decile'].loc[i])

        df.loc[i, 'total_capacity_mbps'] = (df[
            'capacity_per_single_satellite_mbps'].loc[i] 
            * df['connected_sats'].loc[i])
        
        df.loc[i, 'per_user_capacity_mbps'] = (df['total_capacity_mbps'].loc[i] 
            / df['mean_poor_connected'].loc[i])
    
    ################### Per user capacity #####################

    filename = 'SSA_decile_capacity.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None


def decile_cost_per_user():
    """
    This function calculates the per user metrics for each decile.
    """
    print('Generating satellite per user cost metrics')

    cap_data = os.path.join(DATA_PROCESSED, 'interim_results_cost.csv')
    pop_path = os.path.join(DECILE_DATA, 'SSA_decile_summary_stats.csv')
    df1 = pd.read_csv(pop_path) 
    df1 = df1[['decile', 'mean_poor_connected']]

    df = pd.read_csv(cap_data)
    df = df[['constellation', 'number_of_satellites', 'total_cost_ownership']]
    df[['decile', 'technology', 'connected_sats', 'total_tco_per_satellite', 
        'total_tco_usd', 'per_user_tco_usd']] = ''

    df['decile'] = np.resize(deciles, len(df))
    df = pd.merge(df, df1, on = 'decile')
    for i in range(len(df)):

        df.loc[i, 'technology'] = 'satellite'

        df.loc[i, 'connected_sats'] = decile_satellite(df['decile'].loc[i])

        df.loc[i, 'total_tco_per_satellite'] = (df[
            'total_cost_ownership'].loc[i] 
            / df['number_of_satellites'].loc[i])
        
        df.loc[i, 'total_tco_usd'] = (df['total_tco_per_satellite'].loc[i] 
            * df['connected_sats'].loc[i])
    
    ################### Per user capacity #####################

    filename = 'SSA_decile_cost.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None

decile_cost_per_user()