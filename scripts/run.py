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
import saleos.cost as ct
import saleos.capacity as cy

from inputs import falcon_9, soyuz, unknown_hyc, unknown_hyg, lut, parameters
from tqdm import tqdm
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
RESULTS = os.path.join(BASE_PATH, '..', 'results')
DATA = os.path.join(BASE_PATH, 'processed')


def run_uq_processing_capacity():
    """
    Run the UQ inputs through the saleos model. 
    
    """
    path = os.path.join(BASE_PATH, 'processed', 'uq_parameters_capacity.csv') 

    if not os.path.exists(path):
        print('Cannot locate uq_parameters_capacity.csv')

    df = pd.read_csv(path)
    df = df.to_dict('records')

    results = []

    for item in tqdm(df, desc = "Processing uncertainty results"):

        satellite_coverage_area_km = cy.calc_geographic_metrics(
            item['number_of_satellites'], item['total_area_earth_km_sq'])
        
        slant_distance = round(cy.signal_distance(item['altitude_km'], 
                         item['elevation_angle']), 4)
        
        satellite_centric_angle = cy.calc_sat_centric_angle(
                                  item['altitude_km'], item['elevation_angle'])
        
        earth_central_angle = cy.calc_earth_central_angle(
                                  item['altitude_km'], item['elevation_angle'])
        
        sat_coverage_area = cy.calc_satellite_coverage(item['altitude_km'], 
                                  item['elevation_angle'])
         
        path_loss = round(cy.calc_free_path_loss(item['dl_frequency_hz'], 
                    slant_distance), 4)
        
        losses = round(cy.calc_losses(item['earth_atmospheric_losses_db'], 
            item['all_other_losses_db']), 4)

        antenna_gain = round(cy.calc_antenna_gain(
            item['speed_of_light'], item['antenna_diameter_m'], 
            item['dl_frequency_hz'], item['antenna_efficiency']), 4) 

        eirp = round(cy.calc_eirpd(item['power_dbw'], antenna_gain), 4)

        noise = round(cy.calc_noise(), 4)

        received_power = round(cy.calc_received_power(
            eirp, path_loss, item['receiver_gain_db'], losses), 4)

        cnr = round(cy.calc_cnr(received_power, noise), 4)

        spectral_efficiency = cy.calc_spectral_efficiency(cnr, lut)

        channel_capacity = round(cy.calc_capacity(spectral_efficiency, 
            item['dl_bandwidth_hz']), 4)

        sat_capacity = round(cy.single_satellite_capacity(
            item['dl_bandwidth_hz'], spectral_efficiency, 
            item['number_of_channels'], item['polarization'],
            item['number_of_beams']), 4)
        
        constellation_capacity = round((cy.calc_constellation_capacity(
                channel_capacity, item['number_of_channels'], 
                item['polarization'], item['number_of_beams'], 
                item['number_of_satellites'], item['percent_coverage'])), 4)
            
        # 0.567805 and 1.647211 are spectral efficiency threshold values o
        # btained from page 53 of DVB-S2 documentation
        # ( https://dvb.org/?standard=second-generation-framing-structure
        #   -channel-coding-and-modulation-systems-for-broadcasting-interactive
        #   -services-news-gathering-and-other-broadband-satellite-applications
        #   -part-2-dvb-s2-extensions)
        if spectral_efficiency <= 0.567805:
            cnr_scenario = 'low'
        elif spectral_efficiency >= 1.647211:
            cnr_scenario = 'high'
        else:
            cnr_scenario = 'baseline'
 
        results.append({
            'constellation': item['constellation'], 
            'number_of_satellites': item['number_of_satellites'],
            'total_area_earth_km_sq': item['total_area_earth_km_sq'],
            'elevation_angle': item['elevation_angle'],
            'altitude_km': item['altitude_km'],
            'satellite_centric_angle': satellite_centric_angle,
            'earth_central_angle' : earth_central_angle,
            'signal_path_km': round(slant_distance, 4), 
            'coverage_area_per_sat_sqkm' : round(sat_coverage_area, 4),
            'dl_frequency_hz': item['dl_frequency_hz'],
            'dl_bandwidth_hz': item['dl_bandwidth_hz'],
            'power_dbw': item['power_dbw'],
            'receiver_gain_db': item['receiver_gain_db'],
            'earth_atmospheric_losses_db': item['earth_atmospheric_losses_db'],
            'all_other_losses_db': item['all_other_losses_db'],
            'subscribers_low': item['subscribers_low'],
            'subscribers_baseline': item['subscribers_baseline'],
            'subscribers_high': item['subscribers_high'],
            'subscriber_traffic_percent' : item['subscriber_traffic_percent'],
            'satellite_coverage_area_km': round(satellite_coverage_area_km, 4),
            'percent_coverage' : item['percent_coverage'],
            'path_loss_db': path_loss, 
            'losses_db': losses, 
            'antenna_gain_db': antenna_gain, 
            'eirp_db': eirp,
            'noise_db': noise, 
            'received_power_db': received_power, 
            'cnr_db': cnr, 
            'spectral_efficiency_bphz': spectral_efficiency, 
            'channel_capacity_mbps': channel_capacity,
            'capacity_per_single_satellite_mbps': sat_capacity,
            'constellation_capacity_mbps': constellation_capacity,
            'cnr_scenario' : cnr_scenario
        })

        df = pd.DataFrame.from_dict(results)

        filename = 'interim_results_capacity.csv'
        
        if not os.path.exists(DATA):

            os.makedirs(DATA)

        path_out = os.path.join(DATA, filename)
        df.to_csv(path_out, index = False)

    return 


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

    df.loc[datapoint, 'climate_change_baseline'] = (
        rocket['climate_change_baseline'][emission_category] 
        * no_launches) 
    
    emission_dict['climate_change_baseline'] = (
        df['climate_change_baseline'].loc[datapoint])

    df.loc[datapoint, 'climate_change_worst_case'] = (
        rocket['climate_change_worst_case'][emission_category] 
        * no_launches)
    
    emission_dict['climate_change_worst_case'] = (
        df['climate_change_worst_case'].loc[datapoint])

    df.loc[datapoint, 'ozone_depletion_baseline'] = (
        rocket['ozone_depletion_baseline'][emission_category] 
        * no_launches)
    
    emission_dict['ozone_depletion_baseline'] = (
        df['ozone_depletion_baseline'].loc[datapoint])

    df.loc[datapoint, 'ozone_depletion_worst_case'] = (
        rocket['ozone_depletion_worst_case'][emission_category]
        * no_launches)
    
    emission_dict['ozone_depletion_worst_case'] = (
        df['ozone_depletion_worst_case'].loc[datapoint])

    df.loc[datapoint, 'resource_depletion'] = (
        rocket['resource_depletion'][emission_category]
        * no_launches)
    
    emission_dict['resource_depletion'] = (
        df['resource_depletion'].loc[datapoint])

    df.loc[datapoint, 'freshwater_toxicity'] = (
        rocket['freshwater_toxicity'][emission_category]
        * no_launches)
    
    emission_dict['freshwater_toxicity'] = (
        df['freshwater_toxicity'].loc[datapoint])

    df.loc[datapoint,'human_toxicity'] = (
        rocket['human_toxicity'][emission_category]
        * no_launches)
    
    emission_dict['human_toxicity'] = (
        df.loc[datapoint, 'human_toxicity'])

    return emission_dict


def calc_total_carbon_emission(df, rocket, datapoint, no_launches):

    """
    This function is for calculating total carbon emission by scenario.

    Parameters
    ----------
    df : panda core series
        dataframe.
    rocket : string
        Launching rocket
    datapoint : int
        individual data values
    no_launches : 1
        Number of satellite launches

    Returns
    -------
    total_dict : dict
        Dictionary containing all carbon emission scenarios.
    """

    total_dict = {}

    df.loc[datapoint, 'total_baseline_carbon_emissions'] = (
        rocket['totals']['total_baseline_carbon_emissions'] * no_launches) 
    
    df.loc[datapoint, 'total_worst_case_carbon_emissions'] = (
        rocket['totals']['total_worst_case_carbon_emissions'] * no_launches) 
    
    df.loc[datapoint, 'total_ozone_depletion_baseline'] = (
        rocket['totals']['total_ozone_depletion_baseline'] * no_launches)
    
    df.loc[datapoint, 'total_ozone_depletion_worst_case'] = (
        rocket['totals']['total_ozone_depletion_worst_case'] * no_launches)

    df.loc[datapoint, 'total_resource_depletion'] = (
        rocket['totals']['total_resource_depletion'] * no_launches)

    df.loc[datapoint, 'total_freshwater_toxicity'] = (
        rocket['totals']['total_freshwater_toxicity'] * no_launches)
    
    df.loc[datapoint, 'total_human_toxicity'] = (
        rocket['totals']['total_human_toxicity'] * no_launches)

    return total_dict
    

def calc_social_carbon_cost(carbon_amount):
    """
    This function calculate the total social cost of carbon by multiplying the 
    total amount of carbon in tonnes by US$ 185 as specified in the paper.

    Parameters
    ----------
    carbon_amount : float
        total amount of carbon in kilograms.

    Returns
    -------
    social_carbon_cost : float
        social cost of carbon.
    """

    social_carbon_cost = (carbon_amount / 1000) * 185

    return social_carbon_cost


def calc_emissions():

    """
    This function calculates the amount of emission by rocket types for all the 
    launches.

    """
    path = os.path.join(BASE_PATH, 'raw', 'scenarios.csv')
    df = pd.read_csv(path)

    df = df[df['scenario'] == 'scenario1']

    df[['launch_event', 'launcher_production', 'launcher_ait', 
        'propellant_production', 'propellant_scheduling', 
        'launcher_transportation', 'launch_campaign']] = ''

    df = pd.melt(df, id_vars = ['scenario', 'status', 'constellation', 
         'rocket', 'representative_of', 'rocket_type', 'no_of_satellites', 
         'no_of_launches', 'satellite_lifespan', 'rocket_detailed'], 
         value_vars = ['launch_event', 'launcher_production', 
         'launcher_ait', 'propellant_production', 'propellant_scheduling', 
         'launcher_transportation', 'launch_campaign'], var_name = 
         'impact_category', value_name = 'value')

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
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'oneweb':

                if df['constellation'].loc[i] == 'oneweb':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'kuiper':

                if df['constellation'].loc[i] == 'kuiper':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'geo':

                if df['constellation'].loc[i] == 'geo_generic':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]
    
    df = pd.melt(df, id_vars = ['constellation', 'rocket', 'no_of_satellites', 
         'no_of_launches', 'climate_change_baseline', 'satellite_lifespan',
         'climate_change_worst_case', 'ozone_depletion_baseline', 
         'ozone_depletion_worst_case', 'resource_depletion', 'rocket_detailed',
         'freshwater_toxicity', 'human_toxicity', 'scenario', 'status', 
         'representative_of', 'rocket_type', 'impact_category', ], 
         value_vars = ['subscribers_low', 'subscribers_baseline', 
         'subscribers_high'], 
         var_name = 'subscriber_scenario', value_name = 'subscribers')
    
    df['per_subscriber_emission'] = ''
    
    for i in range(len(df)):
        
        df.loc[i, 'per_subscriber_emission'] = (df.loc[i, 
                  'climate_change_baseline'] / df.loc[i, 'subscribers'])

    filename = 'individual_emissions.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    df = df[['constellation', 'no_of_satellites', 'no_of_launches', 
             'satellite_lifespan', 'climate_change_baseline', 
             'climate_change_worst_case', 'ozone_depletion_baseline', 
             'ozone_depletion_worst_case', 'resource_depletion', 
             'freshwater_toxicity', 'human_toxicity', 'subscribers', 
             'subscriber_scenario', 'impact_category', 'scenario', 'status', 
             'representative_of', 'rocket_type', 'rocket_detailed']]
    df[['annual_baseline_emission_kg', 'annual_worst_case_emission_kg',
        'baseline_social_carbon_cost_usd', 'worst_case_social_carbon_cost_usd',
        'annual_baseline_scc_per_subscriber_usd', 
        'annual_worst_case_scc_per_subscriber_usd']] = ''
    
    renamed_columns = {'climate_change_baseline': 'climate_change_baseline_kg', 
                'climate_change_worst_case': 'climate_change_worst_case_kg',
                'ozone_depletion_baseline': 'ozone_depletion_baseline_kg',
                'ozone_depletion_worst_case': 'ozone_depletion_worst_case_kg',
                'resource_depletion': 'resource_depletion_kg',
                'freshwater_toxicity': 'freshwater_toxicity_m3'}
    
    df.rename(columns = renamed_columns, inplace = True)
    
    for i in range(len(df)):

        df.loc[i, 'baseline_social_carbon_cost_usd'] = (
            calc_social_carbon_cost(df.loc[i, 'climate_change_baseline_kg']))
 
        df.loc[i, 'worst_case_social_carbon_cost_usd'] = (
            calc_social_carbon_cost(df.loc[i, 'climate_change_worst_case_kg']))

        df.loc[i, 'annual_baseline_emission_kg'] = (df.loc[i, 
            'climate_change_baseline_kg'] / df.loc[i, 'satellite_lifespan'])
        
        df.loc[i, 'annual_worst_case_emission_kg'] = (df.loc[i, 
            'climate_change_worst_case_kg'] / df.loc[i, 'satellite_lifespan'])

        df.loc[i, 'annual_baseline_scc_per_subscriber_usd'] = (df.loc[i, 
            'baseline_social_carbon_cost_usd'] / df.loc[i, 
            'satellite_lifespan'] / df.loc[i, 'subscribers'])

        df.loc[i, 'annual_worst_case_scc_per_subscriber_usd'] = (df.loc[i, 
            'worst_case_social_carbon_cost_usd'] / df.loc[i, 
            'satellite_lifespan'] / df.loc[i, 'subscribers'])

    df = df[['constellation', 'no_of_launches', 'no_of_satellites', 
             'climate_change_baseline_kg', 'climate_change_worst_case_kg', 
             'ozone_depletion_baseline_kg', 'ozone_depletion_worst_case_kg', 
             'resource_depletion_kg', 'freshwater_toxicity_m3', 'human_toxicity', 
             'subscribers', 'annual_baseline_emission_kg', 
             'annual_worst_case_emission_kg', 'baseline_social_carbon_cost_usd', 
             'worst_case_social_carbon_cost_usd', 
             'annual_baseline_scc_per_subscriber_usd',
             'annual_worst_case_scc_per_subscriber_usd', 'subscriber_scenario',
             'impact_category', 'scenario', 'rocket_type', 'rocket_detailed']]
    
    path_out = os.path.join(BASE_PATH, '..', 'results', filename)
    df.to_csv(path_out, index = False)

    return None


def calc_total_emissions():

    """
    This function calculates the total amount of emission by rocket types for 
    all the launches.

    """
    path = os.path.join(BASE_PATH, 'raw', 'scenarios.csv')
    df = pd.read_csv(path)
    df = df[df['scenario'] == 'scenario1']

    df[['total_baseline_carbon_emissions', 'total_worst_case_carbon_emissions',
        'total_ozone_depletion_baseline', 'total_ozone_depletion_worst_case',
        'total_resource_depletion', 'total_freshwater_toxicity',
        'total_human_toxicity', 'subscribers_low', 'subscribers_baseline', 
        'subscribers_high']] = ''

    for i in range(len(df)):

        ################################### Falcon-9 Rocket ####################
        if df['rocket'].loc[i] == 'falcon9':

            calc_total_carbon_emission(df, falcon_9, i,  
                                       df['no_of_launches'].loc[i])

        ################################### Soyuz-FG Rocket ####################
        if df['rocket'].loc[i] == 'soyuz':

            calc_total_carbon_emission(df, soyuz, i,  
                                       df['no_of_launches'].loc[i])

        ############################ Unknown Hydrocarbon Rocket ################
        if df['rocket'].loc[i] == 'unknown_hyc':

            calc_total_carbon_emission(df, unknown_hyc, i,  
                                       df['no_of_launches'].loc[i])

        ################################# Unknown Hydrogen Rocket ##############
        if df['rocket'].loc[i] == 'unknown_hyg':

            calc_total_carbon_emission(df, unknown_hyg, i,  
                                       df['no_of_launches'].loc[i])

        ########################## Emission per Subscriber######################
        for key, item in parameters.items():

            if key == 'starlink':

                if df['constellation'].loc[i] == 'starlink':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'oneweb':

                if df['constellation'].loc[i] == 'oneweb':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'kuiper':

                if df['constellation'].loc[i] == 'kuiper':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]

            if key == 'geo':

                if df['constellation'].loc[i] == 'geo_generic':
                    
                    df.loc[i, 'subscribers_low'] = item['subscribers'][0]
                    df.loc[i, 'subscribers_baseline'] = item['subscribers'][1]
                    df.loc[i, 'subscribers_high'] = item['subscribers'][2]
  
    df = pd.melt(df, id_vars = ['constellation', 'satellite_lifespan', 
         'total_baseline_carbon_emissions', 
         'total_worst_case_carbon_emissions', 'total_ozone_depletion_baseline', 
         'total_ozone_depletion_worst_case', 'total_resource_depletion', 
         'total_freshwater_toxicity', 'total_human_toxicity'], value_vars = 
         ['subscribers_low', 'subscribers_baseline', 'subscribers_high'], 
         var_name = 'subscriber_scenario', value_name = 'subscribers')
    
    ####Save Total Carbon Emmissions####
    df = df[['constellation', 'satellite_lifespan', 'subscribers', 
              'total_baseline_carbon_emissions',
              'total_worst_case_carbon_emissions', 
              'total_ozone_depletion_baseline', 
              'total_ozone_depletion_worst_case', 'total_resource_depletion',
              'total_freshwater_toxicity', 'total_human_toxicity',
              'subscriber_scenario']]
    
    df1 = df.groupby(['constellation', 'satellite_lifespan', 
                 'subscribers', 'subscriber_scenario']).agg(
                 {'total_baseline_carbon_emissions': 'sum', 
                  'total_worst_case_carbon_emissions': 'sum', 
                  'total_ozone_depletion_baseline' : 'sum',
                  'total_ozone_depletion_worst_case' : 'sum',
                  'total_resource_depletion' : 'sum',
                  'total_freshwater_toxicity' : 'sum',
                  'total_human_toxicity' : 'sum'}).reset_index()
   
    df1[['annual_baseline_emissions_per_subscriber_kg', 
         'annual_worst_case_emissions_per_subscriber_kg']] = ''
    df1['number_of_satellites'] = ''
    for i in range(len(df1)):

        df1.loc[i, 'annual_baseline_emissions_per_subscriber_kg'] = ((
            df1.loc[i, 'total_baseline_carbon_emissions'] 
            / df1.loc[i, 'subscribers']) / df1.loc[i, 'satellite_lifespan'])  

        df1.loc[i, 'annual_worst_case_emissions_per_subscriber_kg'] = (
            (df1.loc[i, 'total_worst_case_carbon_emissions']
             / df1.loc[i, 'subscribers']) / df1.loc[i, 'satellite_lifespan'])
        
        if df1.loc[i, 'constellation'] == 'geo_generic':

            df1.loc[i, 'number_of_satellites'] = 19

        elif df1.loc[i, 'constellation'] == 'kuiper':

            df1.loc[i, 'number_of_satellites'] = 3236

        elif df1.loc[i, 'constellation'] == 'starlink':

            df1.loc[i, 'number_of_satellites'] = 4425

        else:

            df1.loc[i, 'number_of_satellites'] = 648
    
    df1 = df1[['constellation', 'satellite_lifespan', 'number_of_satellites',
             'subscribers', 'total_baseline_carbon_emissions',
             'total_worst_case_carbon_emissions', 
             'total_ozone_depletion_baseline', 
             'total_ozone_depletion_worst_case', 'total_resource_depletion',
             'total_freshwater_toxicity', 'total_human_toxicity', 
             'annual_baseline_emissions_per_subscriber_kg',
             'annual_worst_case_emissions_per_subscriber_kg',
             'subscriber_scenario']]
    
    renamed_columns = {'total_baseline_carbon_emissions': 'total_baseline_carbon_emissions_kg', 
            'total_worst_case_carbon_emissions': 'total_worst_case_carbon_emissions_kg',
            'total_ozone_depletion_baseline': 'total_ozone_depletion_baseline_kg',
            'total_ozone_depletion_worst_case': 'total_ozone_depletion_worst_case_kg',
            'total_resource_depletion': 'total_resource_depletion_kg',
            'total_freshwater_toxicity': 'total_freshwater_toxicity_m3',
            'total_human_toxicity' : 'total_human_toxicity_cases'}
    
    df1.rename(columns = renamed_columns, inplace = True)
    
    filename2 = 'total_emissions.csv'
    path_out2 = os.path.join(BASE_PATH, '..', 'results', filename2)
    df1.to_csv(path_out2, index = False)

    return None


def run_uq_processing_cost():
    """  
    Run the UQ inputs through the saleos model. 
    
    """
    path = os.path.join(BASE_PATH, 'processed', 'uq_parameters_cost.csv') 

    if not os.path.exists(path):

        print('Cannot locate uq_parameters_cost.csv')

    df = pd.read_csv(path)
    df = df.to_dict('records')

    results = []

    for item in tqdm(df, desc = 'Processing uncertainty results'):

        total_cost_ownership = ct.cost_model(item['satellite_manufacturing'],
                                             item['satellite_launch_cost'],
                                             item['ground_station_cost'],
                                             item['regulation_fees'],
                                             item['fiber_infrastructure_cost'],
                                             item['ground_station_energy'],
                                             item['subscriber_acquisition'],
                                             item['staff_costs'],
                                             item['maintenance_costs'],
                                             item['discount_rate'],
                                             item['assessment_period_year'])
        
        results.append({
            'constellation': item['constellation'], 
            'number_of_satellites': item['number_of_satellites'],
            'subscribers_low': item['subscribers_low'],
            'subscribers_baseline': item['subscribers_baseline'],
            'subscribers_high': item['subscribers_high'],
            'capex_costs': item['capex_costs'],
            'opex_costs': item['opex_costs'],
            'total_cost_ownership': total_cost_ownership,
            'assessment_period_year': item['assessment_period_year'],
        })

        df = pd.DataFrame.from_dict(results)

        filename = 'interim_results_cost.csv'
        
        if not os.path.exists(DATA):

            os.makedirs(DATA)

        path_out = os.path.join(DATA, filename)
        df.to_csv(path_out, index = False)

    return


def process_mission_capacity():
    """
    This function process the constellation mission capacity.

    """
    data_in = os.path.join(DATA, 'interim_results_capacity.csv')
    df = pd.read_csv(data_in, index_col = False)

    df = df[['constellation', 'number_of_satellites', 'channel_capacity_mbps', 
             'capacity_per_single_satellite_mbps',
             'constellation_capacity_mbps', 'subscribers_low', 
             'subscribers_baseline', 'subscribers_high', 'percent_coverage',
             'subscriber_traffic_percent', 'satellite_coverage_area_km', 
             'cnr_scenario']]

    # Classify subscribers by melting the dataframe into long format
    # Switching the subscriber columns from wide format to long format
    df = pd.melt(df, id_vars = ['constellation', 'number_of_satellites', 
                            'constellation_capacity_mbps', 'cnr_scenario', 
                            'subscriber_traffic_percent', 'percent_coverage', 
                            'satellite_coverage_area_km'], value_vars = 
                            ['subscribers_low', 'subscribers_baseline', 
                            'subscribers_high'], value_name = 'subscribers',
                            var_name = 'subscriber_scenario')
    
    # Create columns to store new data
    df[['capacity_per_user', 'monthly_gb', 'user_per_area']] = ''
    
    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation results'):

         df.loc[i, 'capacity_per_user'] = cy.capacity_subscriber(df.loc[i, 
                    'constellation_capacity_mbps'], df.loc[i, 'subscribers'], 
                    df.loc[i, 'subscriber_traffic_percent'])

         df.loc[i, 'monthly_gb'] = cy.monthly_traffic(df.loc[i, 
                                    'capacity_per_user'])

         df.loc[i, 'user_per_area'] = cy.subscribers_per_area(df.loc[i, 
                'number_of_satellites'], df.loc[i, 'percent_coverage'], 
                df.loc[i, 'subscribers'], df.loc[i, 
                'satellite_coverage_area_km'])

    filename = 'final_capacity_results.csv'

    if not os.path.exists(RESULTS):

         os.makedirs(RESULTS)

    df = df[['constellation', 'number_of_satellites', 'constellation_capacity_mbps', 
             'satellite_coverage_area_km', 'capacity_per_user', 
            'subscribers', 'monthly_gb', 'user_per_area', 
            'cnr_scenario', 'subscriber_scenario']]
    
    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


def process_mission_cost():
    """
    This function process the constellation mission costs.

    """
    data_in = os.path.join(DATA, 'interim_results_cost.csv')
    df = pd.read_csv(data_in, index_col = False)

    df = df[['constellation', 'number_of_satellites', 'capex_costs', 'opex_costs',
             'assessment_period_year', 'total_cost_ownership', 
             'subscribers_low', 'subscribers_baseline', 
             'subscribers_high']]

    # Classify subscribers by melting the dataframe into long format.
    # Switching the subscriber columns from wide format to long format.
    df = pd.melt(df, id_vars = ['constellation', 'number_of_satellites', 
                                'capex_costs', 'opex_costs', 
                                'assessment_period_year','total_cost_ownership'], 
                                value_vars = ['subscribers_low', 
                                'subscribers_baseline', 'subscribers_high'], 
                                var_name = 'subscriber_scenario', 
                                value_name = 'subscribers')
    
    # Create columns to store new data
    df[[ 'capex_per_user', 'opex_per_user',
         'tco_per_user', 'user_monthly_cost',
         'tco_per_user_annualized']] = ''
    
    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation results'):

        df.loc[i, 'capex_per_user'] = (df.loc[i, 'capex_costs'] / 
                                       df.loc[i, 'subscribers'])
        
        df.loc[i, 'opex_per_user'] = (df.loc[i, 'opex_costs'] / 
                                      df.loc[i, 'subscribers'])
        
        df.loc[i, 'tco_per_user'] = (df.loc[i, 'total_cost_ownership'] / 
                                     df.loc[i, 'subscribers'])

        df.loc[i, 'user_monthly_cost'] = ct.user_monthly_cost(df.loc[i, 
                            'tco_per_user'], df.loc[i, 'assessment_period_year'])

        if df['constellation'].loc[i] in ['Kuiper','OneWeb','Starlink']:

            df.loc[i, 'tco_per_user_annualized'] = (df.loc[i, 'tco_per_user'] / 
                                         df.loc[i, 'assessment_period_year'])
     
        elif df['constellation'].loc[i] in ['GEO']:

            df.loc[i, 'tco_per_user_annualized'] = (df.loc[i, 'tco_per_user'] / 
                                        df.loc[i, 'assessment_period_year'])
            
        else:

            print('Constellation name not recognized.')
            
    filename = 'final_cost_results.csv'

    if not os.path.exists(RESULTS):

         os.makedirs(RESULTS)

    df = df[['constellation', 'number_of_satellites', 'capex_costs', 'opex_costs', 
             'total_cost_ownership', 'assessment_period_year', 
             'subscribers', 'capex_per_user', 'opex_per_user', 
             'tco_per_user', 'tco_per_user_annualized', 
             'user_monthly_cost', 'subscriber_scenario']]
    
    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


if __name__ == '__main__':
    
    start = time.time() 

    print('Running on run_uq_processing_capacity()')
    run_uq_processing_capacity()

    print('Running on run_uq_processing_costs()')
    run_uq_processing_cost()

    print('Processing Emission results')
    calc_emissions()

    print('Processing Total Emission results')
    calc_total_emissions()

    print('Working on process_mission_capacity()')
    process_mission_capacity()

    print('Working on process_mission_costs()')
    process_mission_cost()

    executionTime = (time.time() - start)

    print('Execution time in minutes: ' + str(round(executionTime / 60, 2))) 