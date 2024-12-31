import configparser
import os
import math
import warnings
import numpy as np
import pandas as pd
from tqdm import tqdm
import saleos.capacity as cy
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
        'per_user_capacity_mbps', 'monthly_gb']] = ''


    df = pd.merge(df, df1, on = 'decile')
    for i in tqdm(range(len(df)), desc = "Processing deciles' capacity results"):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['mean_area_sqkm'].loc[i])
            
        elif df.loc[i, 'constellation'] == 'Starlink':

            constellation_size_factor = 4425 / 3236
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i]) * constellation_size_factor

        else:

            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i])

        df.loc[i, 'technology'] = 'satellite'

        df.loc[i, 'total_capacity_mbps'] = (df[
            'capacity_per_single_satellite_mbps'].loc[i] 
            * df['connected_sats'].loc[i])
        
        df.loc[i, 'per_user_capacity_mbps'] = (df['total_capacity_mbps'].loc[i] 
            / df['mean_poor_connected'].loc[i])
        
        df.loc[i, 'monthly_gb'] = cy.monthly_traffic(df.loc[i, 
                                    'per_user_capacity_mbps'])
    
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
    df1 = df1[['decile', 'mean_area_sqkm', 'mean_poor_connected', 
               'cost_per_1GB_usd', 'monthly_income_usd', 'cost_per_month_usd', 
               'adoption_rate_perc', 'arpu_usd']]

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
        'total_tco_usd', 'per_user_tco_usd', 'annualized_per_user_tco_usd',
        'monthly_per_user_tco_usd']] = ''
    
    df = pd.merge(df, df1, on = 'decile')
    
    for i in tqdm(range(len(df)), desc = "Processing deciles' cost results"):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['mean_area_sqkm'].loc[i])
            
        elif df.loc[i, 'constellation'] == 'Starlink':
            
            constellation_size_factor = 4425 / 3236
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i]) * constellation_size_factor

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
            / (df['mean_poor_connected'].loc[i] 
            * (df['adoption_rate_perc'].loc[i] / 100)))
        
        df.loc[i, 'annualized_per_user_tco_usd'] = (df['per_user_tco_usd'].loc[i] 
            / df['assessment_period_year'].loc[i]) 
        
        df.loc[i, 'monthly_per_user_tco_usd'] = (
            df['annualized_per_user_tco_usd'].loc[i] / 12)

        df.loc[i, 'percent_gni'] = ((df['monthly_per_user_tco_usd'].loc[i] 
        / df['monthly_income_usd'].loc[i]) * 100)

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
            
        elif df.loc[i, 'constellation'] == 'Starlink':
            
            constellation_size_factor = 4425 / 3236
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df['mean_area_sqkm'].loc[i]) * constellation_size_factor

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


def capacity_coverage():
    """
    This function calculate the capacity provided by the satellites for users in
    different areas across Sub-Saharan Africa.
    """
    uncov_population = os.path.join(DECILE_DATA, 'SSA_poor_unconnected.csv')
    ssa = os.path.join(DECILE_DATA, 'SSA_subregional_population_deciles.csv')
    sat_capacity = os.path.join(DATA_PROCESSED, 'interim_results_capacity.csv')

    cov = pd.read_csv(uncov_population)
    cov = cov[cov['technology'] == 'GSM']
    cov = cov[cov['poverty_range'] == 'GSAP2_poor']
    cov = cov[['iso3', 'GID_1', 'poor_unconnected']]
    cov = cov.groupby(['iso3', 'GID_1']).agg({'poor_unconnected': 'mean'}).reset_index()

    df = pd.read_csv(ssa)
    df = df[['GID_2', 'decile', 'area']]
    df = df.rename(columns = {'GID_2': 'GID_1'})
    df = pd.merge(df, cov, on = 'GID_1', how = 'inner')
    
    sat = pd.read_csv(sat_capacity)
    starlink_cap = sat[sat['constellation'] == 'Starlink']
    starlink_cap = starlink_cap['capacity_per_single_satellite_mbps'].mean()

    oneweb_cap = sat[sat['constellation'] == 'OneWeb']
    oneweb_cap = (oneweb_cap['capacity_per_single_satellite_mbps'].mean())

    kuiper_cap = sat[sat['constellation'] == 'Kuiper']
    kuiper_cap = (kuiper_cap['capacity_per_single_satellite_mbps'].mean())

    geo_cap = sat[sat['constellation'] == 'GEO']
    geo_cap = (geo_cap['capacity_per_single_satellite_mbps'].mean())

    constellations = ['Starlink', 'OneWeb', 'Kuiper', 'GEO']

    dfs = []
    for constellation in constellations:

        df_copy = df.copy()
        
        df_copy['constellation'] = constellation
        dfs.append(df_copy)

    df = pd.concat(dfs, ignore_index = True)
    for i in range(len(df)):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'sat_cap'] = geo_cap
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['area'].loc[i])
            
        elif df.loc[i, 'constellation'] == 'Kuiper':
            
            df.loc[i, 'sat_cap'] = kuiper_cap
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area'])

        elif df.loc[i, 'constellation'] == 'Starlink':

            df.loc[i, 'sat_cap'] = starlink_cap
            constellation_size_factor = 4425 / 3236
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area']) * constellation_size_factor

        else:

            df.loc[i, 'sat_cap'] = oneweb_cap
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area'])
            
        df.loc[i, 'per_user_mbps'] = ((df.loc[i, 'connected_sats'] 
                * df.loc[i, 'sat_cap']) / df.loc[i, 'poor_unconnected'])

    fileout = 'satellite_capacity_coverage.csv'
    path_out = os.path.join(DATA_SSA, fileout)
    df.to_csv(path_out)

    return None


def cost_coverage():
    """
    This function calculate the cost provided by the satellites for users in
    different areas across Sub-Saharan Africa.
    """
    uncov_population = os.path.join(DECILE_DATA, 'SSA_poor_unconnected.csv')
    ssa = os.path.join(DECILE_DATA, 'SSA_subregional_population_deciles.csv')
    sat_cost = os.path.join(DATA_RESULTS, 'final_cost_results.csv')

    cov = pd.read_csv(uncov_population)
    cov = cov[cov['technology'] == 'GSM']
    cov = cov[cov['poverty_range'] == 'GSAP2_poor']
    cov = cov[['iso3', 'GID_1', 'poor_unconnected']]
    cov = cov.groupby(['iso3', 'GID_1']).agg({'poor_unconnected': 'mean'}).reset_index()

    df = pd.read_csv(ssa)
    df = df[['GID_2', 'decile', 'area']]
    df = df.rename(columns = {'GID_2': 'GID_1'})
    df = pd.merge(df, cov, on = 'GID_1', how = 'inner')
    
    sat = pd.read_csv(sat_cost)
    starlink_cost = sat[sat['constellation'] == 'Starlink']
    starlink_tco = starlink_cost['total_cost_ownership'].mean()
    starlink_sats = starlink_cost['number_of_satellites'].mean()
    starlink_tco = starlink_tco / starlink_sats

    oneweb_cost = sat[sat['constellation'] == 'OneWeb']
    oneweb_tco = (oneweb_cost['total_cost_ownership'].mean())
    oneweb_sats = oneweb_cost['number_of_satellites'].mean()
    oneweb_tco = oneweb_tco / oneweb_sats

    kuiper_cost = sat[sat['constellation'] == 'Kuiper']
    kuiper_tco = (kuiper_cost['total_cost_ownership'].mean())
    kuiper_sats = kuiper_cost['number_of_satellites'].mean()
    kuiper_tco = kuiper_tco / kuiper_sats

    geo_cost = sat[sat['constellation'] == 'GEO']
    geo_tco = (geo_cost['total_cost_ownership'].mean())
    geo_sats = geo_cost['number_of_satellites'].mean()
    geo_tco = geo_tco / geo_sats

    constellations = ['Starlink', 'OneWeb', 'Kuiper', 'GEO']

    dfs = []
    for constellation in constellations:

        df_copy = df.copy()
        
        df_copy['constellation'] = constellation
        dfs.append(df_copy)

    df = pd.concat(dfs, ignore_index = True)
  
    for i in tqdm(range(len(df)), desc = 'Processing coverage capacity'):

        if df.loc[i, 'constellation'] == 'geo_generic':
            
            df.loc[i, 'sat_cost'] = geo_tco
            df.loc[i, 'connected_sats'] = GEO_decile_satellites(
                df['area'].loc[i])
            period = 15
            
        elif df.loc[i, 'constellation'] == 'Kuiper':
            
            df.loc[i, 'sat_cost'] = kuiper_tco
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area'])
            period = 5

        elif df.loc[i, 'constellation'] == 'Starlink':

            df.loc[i, 'sat_cost'] = starlink_tco
            constellation_size_factor = 4425 / 3236
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area']) * constellation_size_factor
            period = 5

        else:

            df.loc[i, 'sat_cost'] = oneweb_tco
            df.loc[i, 'connected_sats'] = LEO_decile_satellite(
                df.loc[i, 'area'])
            period = 5
  
        df.loc[i, 'per_user_tco'] = ((df.loc[i, 'connected_sats'] 
                * df.loc[i, 'sat_cost']) / df.loc[i, 'poor_unconnected'])
        
        df.loc[i, 'per_user_annualized_tco'] = (df.loc[i, 'per_user_tco'] 
                / period)
        
        df.loc[i, 'per_user_monthly_tco'] = (
            df.loc[i, 'per_user_annualized_tco'] / 12)

    fileout = 'satellite_cost_coverage.csv'
    path_out = os.path.join(DATA_SSA, fileout)
    df.to_csv(path_out)

    return None

if __name__ == '__main__':

    #decile_capacity_per_user()

    decile_cost_per_user()

    #decile_emission_per_user()

    #capacity_coverage()

    #cost_coverage()