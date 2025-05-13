import configparser
import os
import warnings
import pandas as pd
warnings.filterwarnings('ignore')
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
DATA_PROCESSED = os.path.join(BASE_PATH, '..', 'data', 'processed')
DATA_RESULTS = os.path.join(BASE_PATH, '..', 'results')
DATA_global = os.path.join(BASE_PATH, '..', 'results', 'global')

def satellite_users():
    """
    This function calculates users for each constellation in each GID_1 
    population
    """

    global_data = os.path.join(DATA_global, 'global_1_population.csv')
    df = pd.read_csv(global_data)

    starlink_emission = 2840000000#(2840000000 / 84) * 0.3
    oneweb_emission = 970000000#(970000000 / 84) * 0.3
    kuiper_emission = 3360000000#(3360000000 / 84) * 0.3
    geo_emission = 690000000#(690000000 / 180) * 0.3

    global_area = (5.1 * 1e8) * 0.1
    global_population = 8.1 * 1e9
    global_density = global_population / global_area
    print(global_area, global_population, global_density)
    
    constellations = ['Starlink', 'OneWeb', 'Kuiper', 'GEO']

    dfs = []
    for constellation in constellations:

        df_copy = df.copy()
        
        df_copy['constellation'] = constellation
        dfs.append(df_copy)

    df = pd.concat(dfs, ignore_index = True)
    for i in range(len(df)):

        if df.loc[i, 'constellation'] == 'GEO':

            df.loc[i, 'total_emissions_kg'] = geo_emission
            df.loc[i, 'user_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] / 
                            global_area) * (df.loc[i, 'area']))
            df.loc[i, 'area_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] 
                                            * df.loc[i, 'area']) / global_area)
            df.loc[i, 'emissions_kg'] = (df.loc[i, 'area_emissions_kg'] 
                                         / df.loc[i, 'population'])

        elif df.loc[i, 'constellation'] == 'Starlink':

            df.loc[i, 'total_emissions_kg'] = starlink_emission
            df.loc[i, 'user_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] / 
                            global_area) * (df.loc[i, 'area']))
            df.loc[i, 'area_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] 
                                            * df.loc[i, 'area']) / global_area)
            df.loc[i, 'emissions_kg'] = (df.loc[i, 'area_emissions_kg'] 
                                         / df.loc[i, 'population'])

        elif df.loc[i, 'constellation'] == 'OneWeb':

            df.loc[i, 'total_emissions_kg'] = oneweb_emission
            df.loc[i, 'user_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] / 
                            global_area) * (df.loc[i, 'area']))
            df.loc[i, 'area_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] 
                                            * df.loc[i, 'area']) / global_area)
            df.loc[i, 'emissions_kg'] = (df.loc[i, 'area_emissions_kg'] 
                                         / df.loc[i, 'population'])

        else:

            df.loc[i, 'total_emissions_kg'] = kuiper_emission
            df.loc[i, 'user_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] / 
                            global_area) * (df.loc[i, 'area']))
            df.loc[i, 'area_emissions_kg'] = ((df.loc[i, 'total_emissions_kg'] 
                                            * df.loc[i, 'area']) / global_area)
            df.loc[i, 'emissions_kg'] = (df.loc[i, 'area_emissions_kg'] 
                                         / df.loc[i, 'population'])

    fileout = 'satellite_global_coverage.csv'
    path_out = os.path.join(DATA_global, fileout)
    df.to_csv(path_out)

satellite_users()