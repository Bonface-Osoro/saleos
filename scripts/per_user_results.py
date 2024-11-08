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


def LEO_decile_satellite(decile_area):

    """
    This function assigns the number of LEO satellites based on the decile area 
    given that coverage area of a single satellite is 379km^2 corresponding to 
    a hexagon inscribed in a 15-mile circle that Starlink uses to plan its 
    solid coverage, with an area of 379 square kilometers

    Parameters
    ----------
    decile_area : float
        Decile area in km^2

    Returns
    -------
    number_of_satellites : int
        Number of satellites over a country.
    """
    number_of_satellites = decile_area / 379

    return number_of_satellites


def GEO_decile_satellites(decile_area):

    """
    This is a helper function to calculate the number of satellites needed to 
    cover a decile given that a communication satellite covers a third of 
    World's land mass that is 148,000 square kilometers.

    Parameters
    ----------
    decile_area : float
        Decile area in km^2

    Returns
    -------
    number_of_satellites : float
        Total number of satellites needed to cover the area.
    """
    world_landmass_area = 148 * 1e6
    
    satellite_coverage_area = (world_landmass_area / 3)

    number_of_satellites = decile_area / satellite_coverage_area

    return number_of_satellites


def calc_social_carbon_cost(carbon_amount):
    """
    This function calculate the total social cost of carbon by multiplying the 
    total amount of carbon in tonnes by US$ 75 as suggested in Sub-Saharan 
    Africa (see dissertation methodology chapter for explanation).

    Parameters
    ----------
    carbon_amount : float
        total amount of carbon in kilograms.

    Returns
    -------
    social_carbon_cost : float
        social cost of carbon.
    """

    social_carbon_cost = (carbon_amount / 1000) * 75

    return social_carbon_cost


def decile_capacity_per_user():
    """
    This function calculates the per user metrics for each decile.
    """
    print('Generating per user metrics')

    cap_data = os.path.join(DATA_PROCESSED, 'interim_results_capacity.csv')
    pop_path = os.path.join(DECILE_DATA, 'SSA_decile_summary_stats.csv')
    df1 = pd.read_csv(pop_path) 
    df1 = df1[['decile', 'mean_area_sqkm', 'mean_poor_connected']]

    df = pd.read_csv(cap_data)
    df = df[['constellation', 'capacity_per_single_satellite_mbps']]
    df = df.to_dict('records')

    results = []
    
    for item in tqdm((df), desc = "Processing deciles' capacity input"):
        
        for decile in deciles:
            
            results.append({
                'constellation' : item['constellation'],
                'decile' : decile,
                'capacity_per_single_satellite_mbps' : (
                    item['capacity_per_single_satellite_mbps'])
            })

            df = pd.DataFrame.from_dict(results)

    df[['technology', 'connected_sats', 'total_capacity_mbps', 
        'per_user_capacity_mbps']] = ''


    df = pd.merge(df, df1, on = 'decile')
    for i in tqdm(range(len(df)), desc = "Processing deciles' capacity results"):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['mean_area_sqkm'].loc[i])

        else:

            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i])

        df.loc[i, 'technology'] = 'satellite'

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
    This function calculates the per user cost metrics for each decile.
    """

    cost_data = os.path.join(DATA_PROCESSED, 'interim_results_cost.csv')
    pop_path = os.path.join(DECILE_DATA, 'SSA_decile_summary_stats.csv')
    df1 = pd.read_csv(pop_path) 
    df1 = df1[['decile', 'mean_area_sqkm', 'mean_poor_connected']]

    df = pd.read_csv(cost_data)
    df = df[['constellation', 'number_of_satellites', 
             'assessment_period_year', 'total_cost_ownership']]
    
    df = df.to_dict('records')

    results = []
    
    for item in tqdm((df), desc = "Processing deciles' cost input"):
        
        for decile in deciles:
            
            results.append({
                'constellation' : item['constellation'],
                'decile' : decile,
                'number_of_satellites' : item['number_of_satellites'],
                'assessment_period_year' : item['assessment_period_year'],
                'total_cost_ownership' : (item['total_cost_ownership'])
            })

            df = pd.DataFrame.from_dict(results)
   
    df[['technology', 'connected_sats', 'total_tco_per_satellite', 
        'total_tco_usd', 'per_user_tco_usd', 'annualized_per_user_tco_usd']] = ''
    
    df = pd.merge(df, df1, on = 'decile')
    
    for i in tqdm(range(len(df)), desc = "Processing deciles' cost results"):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['mean_area_sqkm'].loc[i])

        else:

            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i])
            
        df.loc[i, 'technology'] = 'satellite'

        df.loc[i, 'total_tco_per_satellite'] = (df[
            'total_cost_ownership'].loc[i] 
            / df['number_of_satellites'].loc[i])
        
        df.loc[i, 'total_tco_usd'] = (df['total_tco_per_satellite'].loc[i] 
            * df['connected_sats'].loc[i])
        
        df.loc[i, 'per_user_tco_usd'] = (df['total_tco_usd'].loc[i] 
            / df['mean_poor_connected'].loc[i])
        
        df.loc[i, 'annualized_per_user_tco_usd'] = (df['per_user_tco_usd'].loc[i] 
            / df['assessment_period_year'].loc[i]) 
    
    ################### Per user cost #####################

    filename = 'SSA_decile_cost.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None


def decile_emission_per_user():
    """
    This function calculates the per user emission metrics for each decile.
    """
    print('Generating satellite per user emission metrics')

    emission_data = os.path.join(DATA_RESULTS, 'total_emissions.csv')
    pop_path = os.path.join(DECILE_DATA, 'SSA_decile_summary_stats.csv')
    df1 = pd.read_csv(pop_path) 
    df1 = df1[['decile', 'mean_area_sqkm', 'mean_poor_connected']]

    df = pd.read_csv(emission_data)
    df = df[df['subscriber_scenario'] == 'subscribers_baseline']
    df = df[['constellation', 'number_of_satellites', 'satellite_lifespan', 
             'total_baseline_carbon_emissions_kg']]
    
    df = df.to_dict('records')

    results = []
    
    for item in (df):
        
        for decile in deciles:
            
            results.append({
                'constellation' : item['constellation'],
                'decile' : decile,
                'number_of_satellites' : item['number_of_satellites'],
                'satellite_lifespan' : item['satellite_lifespan'],
                'total_baseline_carbon_emissions_kg' : (
                    item['total_baseline_carbon_emissions_kg'])
            })

            df = pd.DataFrame.from_dict(results)

    df[['technology', 'connected_sats', 'emission_per_satellite_kg', 
        'total_emission_kg', 'total_SCC_usd', 'per_user_emissions_kg', 
        'per_user_SCC_usd', 'annualized_per_user_emissions_kg',
        'annualized_per_user_SCC_usd']] = ''
    
    df = pd.merge(df, df1, on = 'decile')
    for i in range(len(df)):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['mean_area_sqkm'].loc[i])

        else:

            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i])

        df.loc[i, 'technology'] = 'satellite'

        df.loc[i, 'emission_per_satellite_kg'] = (df[
            'total_baseline_carbon_emissions_kg'].loc[i] 
            / df['number_of_satellites'].loc[i])
        
        df.loc[i, 'total_emission_kg'] = (df['emission_per_satellite_kg'].loc[i] 
            * df['connected_sats'].loc[i])
        
        df.loc[i, 'total_SCC_usd'] = calc_social_carbon_cost(
            df['total_emission_kg'].loc[i])
        
        df.loc[i, 'per_user_emissions_kg'] = (df['total_emission_kg'].loc[i] 
            / df['mean_poor_connected'].loc[i]) 
        
        df.loc[i, 'per_user_SCC_usd'] = (df['total_SCC_usd'].loc[i] 
            / df['mean_poor_connected'].loc[i]) 
        
        df.loc[i, 'annualized_per_user_emissions_kg'] = (
            df['per_user_emissions_kg'].loc[i] / df['satellite_lifespan'].loc[i]) 
        
        df.loc[i, 'annualized_per_user_SCC_usd'] = (
            df['per_user_SCC_usd'].loc[i] / df['satellite_lifespan'].loc[i]) 
    
    ################### Per user emissions #####################

    filename = 'SSA_decile_emissions.csv'
    folder_out = os.path.join(DATA_SSA)

    if not os.path.exists(folder_out):

        os.makedirs(folder_out)
    
    path_out = os.path.join(folder_out, filename)
    df.to_csv(path_out, index = False)


    return None


if __name__ == '__main__':

    decile_capacity_per_user()

    decile_cost_per_user()

    decile_emission_per_user()