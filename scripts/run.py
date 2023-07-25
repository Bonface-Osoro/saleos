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


def run_uq_processing():
    """
    Run the UQ inputs through the saleos model. 
    
    """
    path = os.path.join(BASE_PATH, 'uq_parameters.csv')

    if not os.path.exists(path):

        print('Cannot locate uq_parameters.csv - have you run preprocess.py?')

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

        total_cost_ownership = ct.cost_model(
            item['satellite_manufacturing'], 
            item['satellite_launch_cost'], 
            item['ground_station_cost'], 
            item['spectrum_cost'], item['regulation_fees'], 
            item['fiber_infrastructure_cost'], 
            item['ground_station_energy'], 
            item['subscriber_acquisition'], 
            item['staff_costs'], 
            item['research_development'], 
            item['maintenance_costs'], 
            item['discount_rate'], 
            item['assessment_period_year']
        )             

        cost_per_capacity = total_cost_ownership / sat_capacity * number_of_satellites

        if item['capex_scenario'] == 'Low':

            cost_scenario = 'Low'

        elif item['capex_scenario'] == 'High':

            cost_scenario = 'High'

        else:

            cost_scenario = 'Baseline'

        emission_dict = sl.calc_per_sat_emission(item['constellation'])
        scheduling_dict = sl.calc_scheduling_emission(item['constellation'])
        transport_dict = sl.calc_transportation_emission(item['constellation'])
        launch_campaign_dict = sl.calc_launch_campaign_emission(item['constellation'])
        propellant_dict = sl.calc_propellant_emission(item['constellation'])
        ait_dict = sl.launcher_AIT()
        rocket_dict = sl.calc_rocket_emission(item['constellation'])

        oneweb_sz = sl.soyuz_fg()
        oneweb_f9 = sl.falcon_9()

        total_global_warming_em = (
            emission_dict['global_warming'] + 
            scheduling_dict['global_warming'] +
            transport_dict['global_warming'] +
            launch_campaign_dict['global_warming'] + 
            propellant_dict['global_warming'] + 
            ait_dict['global_warming'] +
            rocket_dict['global_warming']
            )

        total_global_warming_wc = (
            emission_dict['global_warming_wc'] + 
            scheduling_dict['global_warming'] +
            transport_dict['global_warming'] +
            launch_campaign_dict['global_warming'] + 
            propellant_dict['global_warming'] + 
            ait_dict['global_warming'] +
            rocket_dict['global_warming']
            )

        total_ozone_depletion_em = (
            emission_dict['ozone_depletion'] + 
            scheduling_dict['ozone_depletion'] +
            transport_dict['ozone_depletion'] +
            launch_campaign_dict['ozone_depletion'] + 
            propellant_dict['ozone_depletion'] + 
            ait_dict['ozone_depletion'] +
            rocket_dict['ozone_depletion']
            )
        
        total_mineral_depletion = (
            emission_dict['mineral_depletion'] + 
            scheduling_dict['mineral_depletion'] +
            transport_dict['mineral_depletion'] +
            launch_campaign_dict['mineral_depletion'] + 
            propellant_dict['mineral_depletion'] + 
            ait_dict['mineral_depletion'] +
            rocket_dict['mineral_depletion']
            )
        
        total_freshwater_toxicity = (
            emission_dict['freshwater_toxicity'] + 
            scheduling_dict['freshwater_toxicity'] +
            transport_dict['freshwater_toxicity'] +
            launch_campaign_dict['freshwater_toxicity'] + 
            propellant_dict['freshwater_toxicity'] + 
            ait_dict['freshwater_toxicity'] +
            rocket_dict['freshwater_toxicity']
            )
        
        total_human_toxicity = (
            emission_dict['human_toxicity'] + 
            scheduling_dict['human_toxicity'] +
            transport_dict['human_toxicity'] +
            launch_campaign_dict['human_toxicity'] + 
            propellant_dict['human_toxicity'] + 
            ait_dict['human_toxicity'] +
            rocket_dict['human_toxicity']
            )

        results.append({'constellation': constellation, 
                        'satellite_coverage_area_km': satellite_coverage_area_km,
                        'cnr': cnr,
                        'cnr_scenario': item['cnr_scenario'],
                        'spectral_efficiency': spectral_efficiency,
                        'channel_capacity': channel_capacity,
                        'constellation_capacity': constellation_capacity,
                        'capacity_per_single_satellite': sat_capacity,
                        'capacity_per_area_mbps/sqkm': constellation_capacity / item['coverage_area_per_sat_sqkm'],
                        'subscribers_low': item['subscribers_low'],
                        'subscribers_baseline': item['subscribers_baseline'],
                        'subscribers_high': item['subscribers_high'],              
                        'satellite_launch_cost': item['satellite_launch_cost'],
                        'satellite_launch_scenario': item['satellite_launch_scenario'],
                        'total_cost_ownership': total_cost_ownership,
                        'capex_costs': item['capex_costs'],
                        'capex_scenario': item['capex_scenario'],
                        'cost_per_capacity': cost_per_capacity,
                        'cost_scenario': cost_scenario,
                        'total_opex': item['opex_costs'],
                        'opex_scenario': item['opex_scenario'],
                        'global_warming': emission_dict['global_warming'],
                        'global_warming_wc': emission_dict['global_warming_wc'],
                        'ozone_depletion': emission_dict['ozone_depletion'],
                        'mineral_depletion': emission_dict['mineral_depletion'],
                        'freshwater_toxicity': emission_dict['freshwater_toxicity'],
                        'human_toxicity': emission_dict['human_toxicity'],
                        'global_warming_roct': rocket_dict['global_warming'], 
                        'ozone_depletion_roct': rocket_dict['ozone_depletion'], 
                        'mineral_depletion_roct': rocket_dict['mineral_depletion'], 
                        'freshwater_toxicity_roct': rocket_dict['freshwater_toxicity'], 
                        'human_toxicity_roct': rocket_dict['human_toxicity'], 
                        'global_warming_ait': ait_dict['global_warming'], 
                        'ozone_depletion_ait': ait_dict['ozone_depletion'],  
                        'mineral_depletion_ait': ait_dict['mineral_depletion'],
                        'freshwater_toxicity_ait': ait_dict['freshwater_toxicity'],
                        'human_toxicity_ait': ait_dict['human_toxicity'], 
                        'global_warming_propellant': propellant_dict['global_warming'], 
                        'ozone_depletion_propellant': propellant_dict['ozone_depletion'], 
                        'mineral_depletion_propellant': propellant_dict['mineral_depletion'], 
                        'freshwater_toxicity_propellant': propellant_dict['freshwater_toxicity'], 
                        'human_toxicity_propellant': propellant_dict['human_toxicity'], 
                        'global_warming_schd': scheduling_dict['global_warming'],
                        'ozone_depletion_schd': scheduling_dict['ozone_depletion'],
                        'mineral_depletion_schd': scheduling_dict['mineral_depletion'],
                        'freshwater_toxicity_schd': scheduling_dict['freshwater_toxicity'],
                        'human_toxicity_schd': scheduling_dict['human_toxicity'],
                        'global_warming_trans': transport_dict['global_warming'],
                        'ozone_depletion_trans': transport_dict['ozone_depletion'], 
                        'mineral_depletion_trans': transport_dict['mineral_depletion'], 
                        'freshwater_toxicity_trans': transport_dict['freshwater_toxicity'], 
                        'human_toxicity_trans': transport_dict['human_toxicity'], 
                        'global_warming_campaign': launch_campaign_dict['global_warming'],
                        'ozone_depletion_campaign': launch_campaign_dict['ozone_depletion'],  
                        'mineral_depletion_campaign': launch_campaign_dict['mineral_depletion'], 
                        'freshwater_toxicity_campaign': launch_campaign_dict['freshwater_toxicity'], 
                        'human_toxicity_campaign': launch_campaign_dict['human_toxicity'], 
                        'oneweb_f9': oneweb_f9['global_warming'] + oneweb_f9['ozone_depletion'],
                        'oneweb_sz': oneweb_sz['global_warming'] + oneweb_sz['ozone_depletion'], 
                        'total_global_warming_em': total_global_warming_em,
                        'total_ozone_depletion_em': total_ozone_depletion_em,
                        'total_mineral_depletion': total_mineral_depletion,
                        'total_freshwater_toxicity': total_freshwater_toxicity,
                        'total_human_toxicity': total_human_toxicity,
                        'total_climate_change': total_global_warming_em,
                        'total_climate_change_wc': total_global_warming_wc,
                        })

        df = pd.DataFrame.from_dict(results)

        filename = 'interim_results.csv'
        
        if not os.path.exists(RESULTS):

            os.makedirs(RESULTS)

        path_out = os.path.join(RESULTS, filename)
        df.to_csv(path_out, index = False)

    return


def process_mission_total():
    """
    This function process the 
    total emissions. 
    
    """   
    data_in = os.path.join(RESULTS, 'interim_results.csv')#[:500]
    df = pd.read_csv(data_in, index_col = False)

    #Select the columns to use.
    df = df[['constellation', 'constellation_capacity', 
        'cnr_scenario', 'capex_costs', 'capex_scenario', 
        'satellite_coverage_area_km', 'subscribers_low', 
        'subscribers_baseline', 'subscribers_high',
        'total_opex', 'total_cost_ownership', 'opex_scenario', 
        'total_global_warming_em', 'total_ozone_depletion_em',
        'total_mineral_depletion', 'total_climate_change_wc',
        'total_freshwater_toxicity', 'total_human_toxicity', 
        'total_climate_change', 'oneweb_f9', 'oneweb_sz']]

    # Create future columns to use
    df[['mission_number', 'total_emissions']] = ''

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
    # n=6561 to n=19683
    df = pd.melt(
        df,
        id_vars = [
            'constellation', 
            'constellation_capacity', 
            'cnr_scenario', 
            'total_opex', 
            'capex_costs', 
            'capex_scenario', 
            'satellite_coverage_area_km', 
            'opex_scenario', 
            'total_cost_ownership', 
            'mission_number', 
            'total_global_warming_em', 
            'total_ozone_depletion_em', 
            'total_mineral_depletion', 
            'total_freshwater_toxicity', 
            'total_human_toxicity', 
            'total_emissions',
            'total_climate_change', 
            'total_climate_change_wc', 
            'oneweb_f9', 
            'oneweb_sz'
        ], 
        value_vars = [
            'subscribers_low', 
            'subscribers_baseline',
            'subscribers_high',
            ], 
        var_name = 'subscriber_scenario', 
        value_name = 'subscribers'
    )

    # Classify total emissions by impact category
    df = pd.melt(
        df,
        id_vars = [
            'constellation', 
            'constellation_capacity', 
            'cnr_scenario', 
            'total_opex', 
            'capex_costs', 
            'capex_scenario', 
            'satellite_coverage_area_km',
            'opex_scenario', 
            'total_cost_ownership', 
            'mission_number',
            'subscriber_scenario', 
            'subscribers', 
            'total_emissions',
            'total_climate_change', 
            'total_climate_change_wc', 
            'oneweb_f9', 
            'oneweb_sz'
        ], 
        value_vars = [
            'total_global_warming_em', 
            'total_ozone_depletion_em',
            'total_mineral_depletion', 
            'total_freshwater_toxicity', 
            'total_human_toxicity'
            ], 
        var_name = 'impact_category', 
        value_name = 'emission_totals'
    )  

    # Calculate the total emissions
    for i in tqdm(range(len(df)), desc = 'Calculating constellation emission totals'):

        if df['constellation'].loc[i] == 'Starlink' or df['constellation'].loc[i] == 'Kuiper':
            df['total_emissions'].loc[i] = df['emission_totals'].loc[i] * df['mission_number'].loc[i]
        else:
            df['total_emissions'].loc[i] = (df['oneweb_sz'].loc[i] * 11) + (df['oneweb_f9'].loc[i] * 7)

    print('Finished calculating constellation emission totals')

    # Select columns to use
    df = df[['constellation', 'constellation_capacity', 
             'cnr_scenario','satellite_coverage_area_km',
             'total_opex', 'capex_costs', 'capex_scenario', 
             'opex_scenario', 'total_cost_ownership', 
             'mission_number','subscriber_scenario', 
             'subscribers', 'impact_category', 
             'total_emissions', 'oneweb_f9', 
             'oneweb_sz', 'total_climate_change', 
             'total_climate_change_wc'
        ]]

    #Create columns to store new data
    df[['capacity_per_user', 'per_subscriber_emission', 
        'capex_per_user', 'opex_per_user', 'monthly_gb',
        'tco_per_user', 'total_climate_emissions_kg',
        'total_climate_emissions_wc_kg', 'user_per_area'
        ]] = ''

    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = 'Processing constellation aggregate results'):

        df['capacity_per_user'].loc[i] = cy.capacity_subscriber(df['constellation_capacity'].loc[i], df['subscribers'].loc[i])

        df['monthly_gb'].loc[i] = (cy.monthly_traffic(df['capacity_per_user'].loc[i]))

        df['total_climate_emissions_kg'].loc[i] = df['total_climate_change'].loc[i] * df['mission_number'].loc[i]

        df['total_climate_emissions_wc_kg'].loc[i] = df['total_climate_change_wc'].loc[i] * df['mission_number'].loc[i]
                                                    
        df['per_subscriber_emission'].loc[i] = df['total_climate_emissions_kg'].loc[i] / df['subscribers'].loc[i]
        
        df['capex_per_user'].loc[i] = df['capex_costs'].loc[i] / df['subscribers'].loc[i] 
        
        df['opex_per_user'].loc[i] = df['total_opex'].loc[i] / df['subscribers'].loc[i] 
        
        df['tco_per_user'].loc[i] = df['total_cost_ownership'].loc[i] / df['subscribers'].loc[i]

        df['user_per_area'].loc[i] = df['satellite_coverage_area_km'].loc[i] / df['subscribers'].loc[i]

    filename = 'final_results.csv'

    if not os.path.exists(RESULTS):

        os.makedirs(RESULTS)

    path_out = os.path.join(RESULTS, filename)
    df.to_csv(path_out, index = False)

    return None


if __name__ == '__main__':
    
    start = time.time() 

    print('Working on run_uq_processing()')
    run_uq_processing()

    print('Working on process_mission_total()')
    process_mission_total()

    executionTime = (time.time() - start)

    print('Execution time in minutes: ' + str(round(executionTime / 60, 2))) 