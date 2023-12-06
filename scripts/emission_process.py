import configparser
import os
import pandas as pd
from inputs import falcon_9, soyuz, unknown_hyc, unknown_hyg
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']

def calc_emission_type(df, rocket, datapoint,
    emission_category, no_launches):

    """
    This function is for calculating emission type.

    Parameters
    ----------
    df : panda core series
        dataframe.
    rocket : string
        Launching rocket
    datapoint : int
        individual data values
    emission_category : string
        Emission type e.g 'launch event'.
    no_launches : 1
        Number of satellite launches

    Returns
    -------
    emission_dict : dict
        Dictionary containing all 
        the emission categories.
    """
    emission_dict = {}

    df['climate_change_baseline'].loc[datapoint] = (
        rocket['climate_change_baseline'][emission_category] 
        * no_launches) 
    emission_dict['climate_change_baseline'] = (
        df['climate_change_baseline'].loc[datapoint])

    df['climate_change_worst_case'].loc[datapoint] = (
        rocket['climate_change_worst_case'][emission_category] 
        * no_launches)
    emission_dict['climate_change_worst_case'] = (
        df['climate_change_worst_case'].loc[datapoint])

    df['ozone_depletion_baseline'].loc[datapoint] = (
        rocket['ozone_depletion_baseline'][emission_category] 
        * no_launches)
    emission_dict['ozone_depletion_baseline'] = (
        df['ozone_depletion_baseline'].loc[datapoint])

    df['ozone_depletion_worst_case'].loc[datapoint] = (
        rocket['ozone_depletion_worst_case'][emission_category]
        * no_launches)
    emission_dict['ozone_depletion_worst_case'] = (
        df['ozone_depletion_worst_case'].loc[datapoint])

    df['resource_depletion'].loc[datapoint] = (
        rocket['resource_depletion'][emission_category]
        * no_launches)
    emission_dict['resource_depletion'] = (
        df['resource_depletion'].loc[datapoint])

    df['freshwater_toxicity'].loc[datapoint] = (
        rocket['freshwater_toxicity'][emission_category]
        * no_launches)
    emission_dict['freshwater_toxicity'] = (
        df['freshwater_toxicity'].loc[datapoint])

    df['human_toxicity'].loc[datapoint] = (
        rocket['human_toxicity'][emission_category]
        * no_launches)
    emission_dict['human_toxicity'] = (
        df['human_toxicity'].loc[datapoint])


    return emission_dict


def calc_emissions():

    """
    This function calculates 
    the amount of emission by 
    types for all the launches.
    """
    path = os.path.join(BASE_PATH, 'raw', 'scenarios.csv')
    df = pd.read_csv(path)

    df[['launch_event', 'launcher_production', 
        'launcher_ait', 'propellant_production', 
        'propellant_scheduling', 'launcher_transportation', 
        'launch_campaign']] = ''

    df = pd.melt(df, id_vars = ['scenario', 'status', 'constellation', 
         'fcc_filling_number', 'rocket', 'representative_of', 
         'rocket_type', 'no_of_satellites', 'no_of_launches',], 
         value_vars = ['launch_event', 'launcher_production', 
         'launcher_ait', 'propellant_production', 'propellant_scheduling', 
         'launcher_transportation', 'launch_campaign'], 
         var_name = 'impact_category', value_name = 'value')

    df = df.drop('value', axis = 1) 

    df[['climate_change_baseline', 'climate_change_worst_case', 
        'ozone_depletion_baseline', 'ozone_depletion_worst_case',
        'resource_depletion', 'freshwater_toxicity',
        'human_toxicity']] = ''

    for i in range(len(df)):

        ################################### Starlink ##########################################
        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launch_event':

            for key, item in falcon_9.items():

                calc_emission_type(df, falcon_9, i, 'launch_event', df['no_of_launches'].loc[i])
                
        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_production': 

            calc_emission_type(df, falcon_9, i, 'launcher_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_ait':

            calc_emission_type(df, falcon_9, i, 'launcher_ait', df['no_of_launches'].loc[i]) 

        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'propellant_production':

            calc_emission_type(df, falcon_9, i, 'propellant_production', df['no_of_launches'].loc[i]) 

        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'propellant_scheduling':

            calc_emission_type(df, falcon_9, i, 'propellant_scheduling', df['no_of_launches'].loc[i]) 

        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_transportation':

            calc_emission_type(df, falcon_9, i, 'launcher_transportation', df['no_of_launches'].loc[i]) 

        if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launch_campaign':

            calc_emission_type(df, falcon_9, i, 'launch_campaign', df['no_of_launches'].loc[i])

        ################################### OneWeb ##########################################
        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launch_event':

            for key, item in soyuz.items():

                calc_emission_type(df, soyuz, i, 'launch_event', df['no_of_launches'].loc[i])
                
        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_production': 

            calc_emission_type(df, soyuz, i, 'launcher_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_ait': 

            calc_emission_type(df, soyuz, i, 'launcher_ait', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'propellant_production': 

            calc_emission_type(df, soyuz, i, 'propellant_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'propellant_scheduling': 

            calc_emission_type(df, soyuz, i, 'propellant_scheduling', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_transportation': 

            calc_emission_type(df, soyuz, i, 'launcher_transportation', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launch_campaign': 

            calc_emission_type(df, soyuz, i, 'launch_campaign', df['no_of_launches'].loc[i])

        ################################### Kuiper Hydrocarbon ####################################
        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'launch_event':

            for key, item in unknown_hyc.items():

                calc_emission_type(df, unknown_hyc, i, 'launch_event', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'launcher_production':

            calc_emission_type(df, unknown_hyc, i, 'launcher_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'launcher_ait':

            calc_emission_type(df, unknown_hyc, i, 'launcher_ait', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'propellant_production':

            calc_emission_type(df, unknown_hyc, i, 'propellant_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'propellant_scheduling':

            calc_emission_type(df, unknown_hyc, i, 'propellant_scheduling', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'launcher_transportation':

            calc_emission_type(df, unknown_hyc, i, 'launcher_transportation', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyc' and df['impact_category'].loc[i] == 'launch_campaign':

            calc_emission_type(df, unknown_hyc, i, 'launch_campaign', df['no_of_launches'].loc[i])

        ##################################### Kuiper Hydrogen #####################################
        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'launch_event':

            for key, item in unknown_hyg.items():

                calc_emission_type(df, unknown_hyg, i, 'launch_event', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'launcher_production':

            calc_emission_type(df, unknown_hyg, i, 'launcher_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'launcher_ait':

            calc_emission_type(df, unknown_hyg, i, 'launcher_ait', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'propellant_production':

            calc_emission_type(df, unknown_hyg, i, 'propellant_production', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'propellant_scheduling':

            calc_emission_type(df, unknown_hyg, i, 'propellant_scheduling', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'launcher_transportation':

            calc_emission_type(df, unknown_hyg, i, 'launcher_transportation', df['no_of_launches'].loc[i])

        if df['rocket'].loc[i] == 'unknown_hyg' and df['impact_category'].loc[i] == 'launch_campaign':

            calc_emission_type(df, unknown_hyg, i, 'launch_campaign', df['no_of_launches'].loc[i])

    filename = 'individual_emissions.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, '..', 'results', filename)
    df.to_csv(path_out, index = False)


    return None


if __name__ == '__main__':

    calc_emissions()