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

import saleos.emissions as sl
import saleos.cost as ct
import saleos.capacity as cy

from inputs import lut
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

        print('Cannot locate uq_parameters_capacity.csv - have you run preprocess.py?')

    df = pd.read_csv(path)
    df = df.to_dict('records')

    results = []

    for item in tqdm(df, desc = "Processing uncertainty results"):

        constellation = item["constellation"]

        number_of_satellites = item["number_of_satellites"]

        distance, satellite_coverage_area_km = cy.calc_geographic_metrics(
            item['number_of_satellites'], 
            item['total_area_earth_km_sq'],
            item['altitude_km']
        )

        path_loss = cy.calc_path_loss(distance, item['dl_frequency_Hz'])

        losses = cy.calc_losses(
            item['earth_atmospheric_losses_dB'], 
            item['all_other_losses_dB']
        )

        antenna_gain = cy.calc_antenna_gain(
            item['speed_of_light'],
            item['antenna_diameter_m'], 
            item['dl_frequency_Hz'],
            item['antenna_efficiency']
        ) 

        eirp = cy.calc_eirpd(
            item['power_dBw'], 
            antenna_gain
        )

        noise = cy.calc_noise()

        received_power = cy.calc_received_power(
            eirp, 
            path_loss, 
            item['receiver_gain_dB'], 
            losses
        )

        cnr = cy.calc_cnr(
            received_power, 
            noise
        )

        spectral_efficiency = cy.calc_spectral_efficiency(
            cnr, 
            lut
        )

        channel_capacity = cy.calc_capacity(
            spectral_efficiency, 
            item['dl_bandwidth_Hz']
        )

        constellation_capacity = (
            cy.calc_constellation_capacity(
                channel_capacity, 
                item['number_of_channels'], 
                item['polarization'],
                item['number_of_satellites']
            )
        )

        sat_capacity = cy.single_satellite_capacity(
            item['dl_bandwidth_Hz'],
            spectral_efficiency, 
            item['number_of_channels'], 
            item['polarization']
        )

        results.append({
            'constellation': item['constellation'], 
            'number_of_satellites': item['number_of_satellites'],
            'total_area_earth_km_sq': item['total_area_earth_km_sq'],
            'coverage_area_per_sat_sqkm': item['total_area_earth_km_sq']/item['number_of_satellites'],
            'altitude_km': item['altitude_km'],
            'dl_frequency_hz': item['dl_frequency_Hz'],
            'dl_bandwidth_hz': item['dl_bandwidth_Hz'],
            'speed_of_light': item['speed_of_light'],
            'antenna_diameter_m': item['antenna_diameter_m'],
            'antenna_efficiency': item['antenna_efficiency'],
            'power_dbw': item['power_dBw'],
            'receiver_gain_db': item['receiver_gain_dB'],
            'earth_atmospheric_losses_db': item['earth_atmospheric_losses_dB'],
            'all_other_losses_db': item['all_other_losses_dB'],
            'number_of_channels': item['number_of_channels'],
            'polarization': item['polarization'],
            'cnr_scenario' : item['cnr_scenario'],
            'subscribers_low': item['subscribers_low'],
            'subscribers_baseline': item['subscribers_baseline'],
            'subscribers_high': item['subscribers_high'],
            'distance_km': distance, 
            'satellite_coverage_area_km': satellite_coverage_area_km,
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
            'capacity_per_area_mbps/sqkm': constellation_capacity / item['coverage_area_per_sat_sqkm'],
        })

        df = pd.DataFrame.from_dict(results)

        filename = 'interim_results_capacity.csv'
        
        if not os.path.exists(DATA):

            os.makedirs(DATA)

        path_out = os.path.join(DATA, filename)
        df.to_csv(path_out, index = False)

    return


def run_uq_processing_cost():
    """
    Run the UQ inputs through the saleos model. 
    
    """
    path = os.path.join(BASE_PATH, 'processed', 'uq_parameters_cost.csv') 

    if not os.path.exists(path):

        print('Cannot locate uq_parameters_cost.csv - have you run preprocess.py?')

    df = pd.read_csv(path)
    df = df.to_dict('records')

    results = []

    for item in tqdm(df, desc = 'Processing uncertainty results'):

        total_cost_ownership = ct.cost_model(item['satellite_manufacturing'],
                                             item['satellite_launch_cost'],
                                             item['ground_station_cost'],
                                             item['spectrum_cost'],
                                             item['regulation_fees'],
                                             item['fiber_infrastructure_cost'],
                                             item['ground_station_energy'],
                                             item['subscriber_acquisition'],
                                             item['staff_costs'],
                                             item['research_development'],
                                             item['maintenance_costs'],
                                             item['discount_rate'],
                                             item['assessment_period_year'])
        
        results.append({
            'constellation': item['constellation'], 
            'subscribers_low': item['subscribers_low'],
            'subscribers_baseline': item['subscribers_baseline'],
            'subscribers_high': item['subscribers_high'],
            'capex_costs': item['capex_costs'],
            'opex_costs': item['opex_costs'],
            'capex_scenario': item['capex_scenario'],
            'opex_scenario': item['opex_scenario'],
            'total_cost_ownership': total_cost_ownership
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
    This function process the 
    constellation mission capacity.
    """
    data_in = os.path.join(DATA, 'interim_results_capacity.csv')
    df = pd.read_csv(data_in, index_col = False)

    df = df[['constellation', 'cnr_scenario',
             'channel_capacity_mbps', 
             'capacity_per_single_satellite_mbps',
             'constellation_capacity_mbps',
             'subscribers_low', 'subscribers_baseline',
             'subscribers_high', 'satellite_coverage_area_km']]
    
    df['mission_number'] = ''
    # Process satellite missions       
    for i in tqdm(df.index, desc = 'Processing satellite missions'):

        if df['constellation'].loc[i] == 'Starlink':
            
            df['mission_number'].loc[i] = 74
        elif df['constellation'].loc[i] == 'OneWeb':
            
            df['mission_number'].loc[i] = 20
        else:
            
            df['mission_number'].loc[i] = 54

    print("Finished processing satellite missions")

    # Classify subscribers by melting the dataframe into long format
    # Switching the subscriber columns from wide format to long format
    df = pd.melt(df, id_vars = ['constellation', 'constellation_capacity_mbps', 
                                'cnr_scenario', 'satellite_coverage_area_km', 
                                'mission_number'], value_vars = ['subscribers_low', 
                                'subscribers_baseline', 'subscribers_high'], 
                                var_name = 'subscriber_scenario', 
                                value_name = 'subscribers')
    
    # Create columns to store new data
    df[['capacity_per_user', 'monthly_gb',
        'user_per_area']] = ''
    
    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation aggregate results'):

         df['capacity_per_user'].loc[i] = cy.capacity_subscriber(df['constellation_capacity_mbps'].loc[i], df['subscribers'].loc[i])

         df['monthly_gb'].loc[i] = (cy.monthly_traffic(df['capacity_per_user'].loc[i]))

         df['user_per_area'].loc[i] = df['subscribers'].loc[i] / df['satellite_coverage_area_km'].loc[i]

    filename = 'final_capacity_results.csv'

    if not os.path.exists(RESULTS):

         os.makedirs(RESULTS)

    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


def process_mission_cost():
    """
    This function process the 
    constellation mission costs.
    """
    data_in = os.path.join(DATA, 'interim_results_cost.csv')
    df = pd.read_csv(data_in, index_col = False)

    df = df[['constellation', 'capex_costs', 'opex_costs',
             'capex_scenario', 'opex_scenario',
             'total_cost_ownership', 'subscribers_low', 
             'subscribers_baseline', 'subscribers_high']]

    # Classify subscribers by melting the dataframe into long format
    # Switching the subscriber columns from wide format to long format
    df = pd.melt(df, id_vars = ['constellation', 'capex_costs', 
                                'opex_costs', 'capex_scenario', 
                                'total_cost_ownership'], 
                                value_vars = ['subscribers_low', 
                                'subscribers_baseline', 'subscribers_high'], 
                                var_name = 'subscriber_scenario', 
                                value_name = 'subscribers')
    
    # Create columns to store new data
    df[[ 'capex_per_user', 'opex_per_user',
         'tco_per_user']] = ''
    
    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation aggregate results'):

         df['capex_per_user'].loc[i] = df['capex_costs'].loc[i] / df['subscribers'].loc[i] 
        
         df['opex_per_user'].loc[i] = df['opex_costs'].loc[i] / df['subscribers'].loc[i] 
        
         df['tco_per_user'].loc[i] = df['total_cost_ownership'].loc[i] / df['subscribers'].loc[i]

    filename = 'final_cost_results.csv'

    if not os.path.exists(RESULTS):

         os.makedirs(RESULTS)

    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


def process_mission_emission():
    """
    This function process the 
    total emissions. 
    
    """
    data_in = os.path.join(DATA, 'uq_parameters_emissions.csv')#[:500]
    df = pd.read_csv(data_in, index_col = False)

    #Select the columns to use.
    df = df[['constellation', 'subscribers_low', 
        'subscribers_baseline', 'subscribers_high',
        'total_global_warming_em', 'total_ozone_depletion_em',
        'total_mineral_depletion', 'total_climate_change_wc',
        'total_freshwater_toxicity', 'total_human_toxicity', 
        'total_climate_change', 'oneweb_f9', 'oneweb_sz']]

    # Create future columns to use
    df[['mission_number', 'total_emissions']] = ''

    # # Process satellite missions       
    for i in tqdm(df.index, desc = 'Processing satellite missions'):
         
         if df['constellation'].loc[i] == 'Starlink':
             
             df['mission_number'].loc[i] = 74
         elif df['constellation'].loc[i] == 'OneWeb':
             
             df['mission_number'].loc[i] = 20
         else:
             
             df['mission_number'].loc[i] = 54

    print("Finished processing satellite missions")

    # # Classify subscribers by melting the dataframe into long format
    # # Switching the subscriber columns from wide format to long format

    df = pd.melt(df, id_vars = ['constellation', 'mission_number',
                                'total_global_warming_em', 'total_ozone_depletion_em', 
                                'total_mineral_depletion', 'total_freshwater_toxicity', 
                                'total_human_toxicity', 'total_emissions', 
                                'total_climate_change', 'total_climate_change_wc', 
                                'oneweb_f9', 'oneweb_sz'], value_vars = ['subscribers_low', 
                                                                         'subscribers_baseline', 
                                                                         'subscribers_high'], 
                                                                         var_name = 'subscriber_scenario', 
                                                                         value_name = 'subscribers')

    # # Classify total emissions by impact category
    df = pd.melt(df, id_vars = ['constellation', 'mission_number', 'subscriber_scenario', 'subscribers', 
                                'total_emissions', 'total_climate_change', 'total_climate_change_wc',
                                'oneweb_f9', 'oneweb_sz'], value_vars = ['total_global_warming_em', 
                                                                         'total_ozone_depletion_em', 
                                                                         'total_mineral_depletion', 
                                                                         'total_freshwater_toxicity',
                                                                         'total_human_toxicity'], 
                                                                         var_name = 'impact_category',
                                                                         value_name = 'emission_totals')  

    # Calculate the total emissions
    for i in tqdm(range(len(df)), desc = 'Calculating constellation emission totals'):

         if df['constellation'].loc[i] == 'Starlink' or df['constellation'].loc[i] == 'Kuiper':
             
             df['total_emissions'].loc[i] = df['emission_totals'].loc[i] * df['mission_number'].loc[i]
         else:
             
             df['total_emissions'].loc[i] = (df['oneweb_sz'].loc[i] * 11) + (df['oneweb_f9'].loc[i] * 7)

    print('Finished calculating constellation emission totals')

    # # Select columns to use
    df = df[['constellation', 'mission_number', 'subscriber_scenario', 'subscribers', 'impact_category', 
             'total_emissions', 'oneweb_f9', 'oneweb_sz', 'total_climate_change', 'total_climate_change_wc']]

    # Create columns to store new data
    df[['per_subscriber_emission', 'total_climate_emissions_kg', 'total_climate_emissions_wc_kg']] = ''

    #  Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation aggregate results'):

         df['total_climate_emissions_kg'].loc[i] = df['total_climate_change'].loc[i] * df['mission_number'].loc[i]

         df['total_climate_emissions_wc_kg'].loc[i] = df['total_climate_change_wc'].loc[i] * df['mission_number'].loc[i]
                                                    
         df['per_subscriber_emission'].loc[i] = df['total_climate_emissions_kg'].loc[i] / df['subscribers'].loc[i]
        

    filename = 'final_emissions_results.csv'

    if not os.path.exists(RESULTS):

         os.makedirs(RESULTS)

    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


if __name__ == '__main__':
    
    start = time.time() 

    print('Running on run_uq_processing_capacity()')
    run_uq_processing_capacity()

    print('Running on run_uq_processing_costs()')
    run_uq_processing_cost()

    print('Working on process_mission_capacity()')
    process_mission_capacity()

    print('Working on process_mission_emissions()')
    process_mission_emission()

    print('Working on process_mission_costs()')
    process_mission_cost()

    executionTime = (time.time() - start)

    print('Execution time in minutes: ' + str(round(executionTime / 60, 2))) 