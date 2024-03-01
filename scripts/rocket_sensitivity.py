"""
Simulation run script for saleos.

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
import math
import time
import pandas as pd

from inputs import falcon_9, soyuz, unknown_hyc, unknown_hyg, lut, parameters
from tqdm import tqdm
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
RESULTS = os.path.join(BASE_PATH, '..', 'results')
DATA = os.path.join(BASE_PATH, 'processed')


def calc_emission_type(df, rocket, datapoint, emission_category, no_launches):

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
        Dictionary containing all the emission categories.
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


def calc_sensitivity_emissions():

    """
    This function calculates the amount of emission by rocket types for all the 
    launches.

    """
    path = os.path.join(BASE_PATH, 'raw', 'scenarios.csv')
    df = pd.read_csv(path)

    df[['launch_event', 'launcher_production', 'launcher_ait', 
        'propellant_production', 'propellant_scheduling', 
        'launcher_transportation', 'launch_campaign']] = ''

    df = pd.melt(df, id_vars = ['scenario', 'status', 'constellation', 
         'rocket', 'rocket_detailed', 'representative_of', 'rocket_type', 
         'no_of_satellites', 'no_of_launches',], value_vars = ['launch_event', 
         'launcher_production', 'launcher_ait', 'propellant_production', 
         'propellant_scheduling', 'launcher_transportation', 'launch_campaign'], 
         var_name = 'impact_category', value_name = 'value')

    df = df.drop('value', axis = 1) 

    df[['climate_change_baseline', 'climate_change_worst_case', 
        'ozone_depletion_baseline', 'ozone_depletion_worst_case',
        'resource_depletion', 'freshwater_toxicity',
        'human_toxicity', 'subscribers_low', 'subscribers_baseline', 
        'subscribers_high']] = ''

    for i in range(len(df)):

        ################################### Falcon-9 Rocket ####################
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

        ################################### Soyuz-FG Rocket #################################
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

        ############################ Unknown Hydrocarbon Rocket ##################################
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

        ################################# Unknown Hydrogen Rocket ################################
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

        ################################################# Emission per Subscriber##############################
        for key, item in parameters.items():

            if key == 'starlink':

                if df['constellation'].loc[i] == 'starlink':
                    
                    df['subscribers_low'].loc[i] = item['subscribers'][0]
                    df['subscribers_baseline'].loc[i] = item['subscribers'][1]
                    df['subscribers_high'].loc[i] = item['subscribers'][2]

            if key == 'oneweb':

                if df['constellation'].loc[i] == 'oneweb':
                    
                    df['subscribers_low'].loc[i] = item['subscribers'][0]
                    df['subscribers_baseline'].loc[i] = item['subscribers'][1]
                    df['subscribers_high'].loc[i] = item['subscribers'][2]

            if key == 'kuiper':

                if df['constellation'].loc[i] == 'kuiper':
                    
                    df['subscribers_low'].loc[i] = item['subscribers'][0]
                    df['subscribers_baseline'].loc[i] = item['subscribers'][1]
                    df['subscribers_high'].loc[i] = item['subscribers'][2]

            if key == 'geo':

                if df['constellation'].loc[i] == 'geo_generic':
                    
                    df['subscribers_low'].loc[i] = item['subscribers'][0]
                    df['subscribers_baseline'].loc[i] = item['subscribers'][1]
                    df['subscribers_high'].loc[i] = item['subscribers'][2]

    df = pd.melt(df, id_vars = ['constellation', 'rocket', 'no_of_satellites', 
         'no_of_launches', 'climate_change_baseline',
         'climate_change_worst_case', 'ozone_depletion_baseline', 
         'ozone_depletion_worst_case', 'resource_depletion', 
         'freshwater_toxicity', 'human_toxicity', 'scenario', 'status', 
         'representative_of', 'rocket_type', 'impact_category', ], 
         value_vars = ['subscribers_low', 'subscribers_baseline', 
         'subscribers_high'], 
         var_name = 'subscriber_scenario', value_name = 'subscribers')
    
    df['per_subscriber_emission'] = ''
    
    for i in range(len(df)):
        
        df['per_subscriber_emission'].loc[i] = (
            df['climate_change_baseline'].loc[i] / df['subscribers'].loc[i])

    filename = 'sensitivity_emissions.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    df = df[['constellation', 'no_of_satellites', 'no_of_launches', 
             'climate_change_baseline', 'climate_change_worst_case', 
             'ozone_depletion_baseline', 'ozone_depletion_worst_case', 
             'resource_depletion', 'freshwater_toxicity', 'human_toxicity', 
             'subscribers', 'subscriber_scenario', 'impact_category', 
             'scenario', 'status', 'representative_of', 'rocket_type']]
    df[['annual_baseline_emission_kg', 'annual_worst_case_emission_kg']] = ''
    renamed_columns = {'climate_change_baseline': 'climate_change_baseline_kg', 
                'climate_change_worst_case': 'climate_change_worst_case_kg',
                'ozone_depletion_baseline': 'ozone_depletion_baseline_kg',
                'ozone_depletion_worst_case': 'ozone_depletion_worst_case_kg',
                'resource_depletion': 'resource_depletion_kg',
                'freshwater_toxicity': 'freshwater_toxicity_m3'}
    
    df.rename(columns = renamed_columns, inplace = True)
    
    for i in range(len(df)):

        if df['constellation'].loc[i] == 'geo_generic':

            df['annual_baseline_emission_kg'].loc[i] = (
                df['climate_change_baseline_kg'].loc[i] / 15) 
            
            df['annual_worst_case_emission_kg'].loc[i] = (
                df['climate_change_worst_case_kg'].loc[i] / 15) 
            
        else:

            df['annual_baseline_emission_kg'].loc[i] = (
                df['climate_change_baseline_kg'].loc[i] / 5) 
            
            df['annual_worst_case_emission_kg'].loc[i] = (
                df['climate_change_worst_case_kg'].loc[i] / 5) 
    
    path_out = os.path.join(BASE_PATH, '..', 'results', filename)
    df.to_csv(path_out, index = False)


    return None


if __name__ == '__main__':
    
    start = time.time() 

    print('Processing Rocket sensitivity Emission results')
    calc_sensitivity_emissions()

    executionTime = (time.time() - start)

    print('Execution time in minutes: ' + str(round(executionTime / 60, 2))) 