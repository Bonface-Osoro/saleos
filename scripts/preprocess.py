"""
Preprocess all Uncertainty Quantification (UQ) inputs. 

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
from random import*
import decimal
import numpy as np
import pandas as pd
from tqdm import tqdm

import saleos.emissions as sl
from saleos import emissions
from inputs import parameters, lut
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']


def uq_inputs_capacity():
    """
    Generate all UQ capacity inputs to run through the saleos model. 
    
    """
    uq_parameters = []

    for key, item in parameters.items():

        # radio propagation variables#altitude_km
        altitude = (np.concatenate((np.arange(item['altitude_km'], 
                   (item['altitude_km'] + 5) + 1, 1), 
                   np.arange(item['altitude_km'] - 1, 
                   (item['altitude_km'] - 5) - 1, -1))))
        
        elevation_angles = (np.arange(item['elevation_angle'], 
                           (item['elevation_angle'] + 15) 
                           + 5, 5))
        
        atmospheric_loss = (np.concatenate((np.arange(item['earth_atmospheric_losses'], 
                           (item['earth_atmospheric_losses'] + 8) + 2, 2), 
                           np.arange(item['earth_atmospheric_losses'] - 2, 
                           (item['earth_atmospheric_losses'] - 8) - 2, -2))))
        
        receiver_gain = [(item['receiver_gain'] - 5), 
                         (item['receiver_gain']), 
                         (item['receiver_gain'] + 5)]

        for alt in altitude:

            altitude_km = alt

            for rec_gain in receiver_gain:

                receiver_gain_db = rec_gain

                for angle in elevation_angles:

                    elevation_angle = angle

                    for atm_loss in atmospheric_loss:

                        earth_atmospheric_losses_db = atm_loss

                        if atm_loss <= 7.5:

                            cnr_scenario = 'high'

                        elif atm_loss > 13.5:

                            cnr_scenario = 'low' 

                        else:

                            cnr_scenario = 'baseline'
                        
                        number_of_satellites = item['number_of_satellites']
                        name = item['name']
                        total_area_earth_km_sq = item['total_area_earth_km_sq']
                        dl_bandwidth_hz = item['dl_bandwidth_hz']
                        speed_of_light = item['speed_of_light']
                        antenna_diameter_m = item['antenna_diameter_m']
                        antenna_efficiency = item['antenna_efficiency']
                        power_dbw = item['power_dbw']
                        all_other_losses_db = item['all_other_losses_db'] 
                        number_of_channels = item['number_of_channels']
                        polarization = item['polarization']

                        uq_parameters.append({
                            'constellation': name, 
                            'number_of_satellites': number_of_satellites,
                            'total_area_earth_km_sq': total_area_earth_km_sq,
                            'coverage_area_per_sat_sqkm': total_area_earth_km_sq/number_of_satellites,
                            'altitude_km': altitude_km,
                            'elevation_angle': elevation_angle,
                            'dl_frequency_hz': item['dl_frequency_hz'],
                            'dl_bandwidth_hz': dl_bandwidth_hz,
                            'speed_of_light': speed_of_light,
                            'antenna_diameter_m': antenna_diameter_m,
                            'antenna_efficiency': antenna_efficiency,
                            'power_dbw': power_dbw,
                            'receiver_gain_db': receiver_gain_db,
                            'earth_atmospheric_losses_db': earth_atmospheric_losses_db,
                            'cnr_scenario': cnr_scenario,
                            'all_other_losses_db': all_other_losses_db,
                            'number_of_channels': number_of_channels,
                            'polarization': polarization,
                            'subscribers_low': item['subscribers'][0],
                            'subscribers_baseline': item['subscribers'][1],
                            'subscribers_high': item['subscribers'][2]
                        })

    df = pd.DataFrame.from_dict(uq_parameters)

    filename = 'uq_parameters_capacity.csv'

    if not os.path.exists(BASE_PATH):
        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return 


def uq_inputs_emissions():
    """
    Generate all UQ emissions inputs to run through the saleos model. 
    
    """
    results = []

    for key, item in parameters.items():

        # Generate emission results
        emission_dict = sl.calc_per_sat_emission(item['name'])
        scheduling_dict = sl.calc_scheduling_emission(item['name'])
        transport_dict = sl.calc_transportation_emission(item['name'])
        launch_campaign_dict = sl.calc_launch_campaign_emission(item['name'])
        propellant_dict = sl.calc_propellant_emission(item['name'])
        ait_dict = sl.launcher_AIT()
        rocket_dict = sl.calc_rocket_emission(item['name'])

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

        results.append({'constellation': item['name'],
                        'subscribers_low': item['subscribers'][0],
                        'subscribers_baseline': item['subscribers'][1],
                        'subscribers_high': item['subscribers'][2],          
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

    filename = 'uq_parameters_emissions.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return 


def uq_inputs_cost():
    """
    Generate all UQ cost inputs to run through the saleos model. 
    
    """
    uq_parameters = []

    for key, item in parameters.items():

        # Cost variables
        satellite_launch = [item['satellite_launch_cost'] - 63672000, 
                            item['satellite_launch_cost'], 
                            item['satellite_launch_cost'] + 63672000] 

        ground_station = [item['ground_station_cost'] - 
                          (item['ground_station_cost'] * 0.2), 
                         item['ground_station_cost'], 
                         item['ground_station_cost'] + 
                         (item['ground_station_cost'] * 0.2)]

        maintenance_cost = [item['maintenance'] - 3000000, 
                            item['maintenance'], 
                            item['maintenance'] + 3000000]

        staff_cost = [item['staff_costs'] - 10000000, 
                      item['staff_costs'], 
                      item['staff_costs'] + 10000000]


        for sat_launch in satellite_launch:

            satellite_launch_cost = sat_launch

            for gst in ground_station:

                ground_station_cost = gst

                if gst == 39088000 and sat_launch == 186328000 or gst == 16000000 and \
                    sat_launch == 86328000 or gst == 26400000 and sat_launch == 116328000:

                    capex_scenario = 'Low'
                    sat_launch_scenario = 'Low'
                    ground_station_scenario = 'Low'

                elif gst == 48860000 and sat_launch == 250000000 or gst == 20000000 and \
                    sat_launch == 150000000 or gst == 33000000 and sat_launch == 180000000:

                    capex_scenario = 'Baseline'
                    sat_launch_scenario = 'Baseline'
                    ground_station_scenario = 'Baseline'

                else:

                    capex_scenario = 'High'
                    sat_launch_scenario = 'High'
                    ground_station_scenario = 'High'

                for maint_cost in maintenance_cost:

                    maint_costs = maint_cost

                    if maint_cost == maintenance_cost[0]:

                        opex_scenario = 'Low'

                    elif maint_cost == maintenance_cost[1]:

                        opex_scenario = 'Baseline'

                    elif maint_cost == maintenance_cost[2]:

                        opex_scenario = 'High'

                    else: 
                        opex_scenario = 'None'

                    for stf_cost in staff_cost:

                        staff_costs = stf_cost

                        satellite_manufacturing = item['satellite_manufacturing']
                        spectrum_cost = item['spectrum_cost'] 
                        regulation_fees = item['regulation_fees'] 
                        fiber_infrastructure_cost = item['fiber_infrastructure_cost']
                        ground_station_energy = item['ground_station_energy']
                        subscriber_acquisition = item['subscriber_acquisition']
                        research_development = item['research_development'] 
                        maintenance_costs = maint_costs

                        capex_costs = (item['satellite_manufacturing'] 
                                        + item['subscriber_acquisition'] 
                                        + regulation_fees
                                        + satellite_launch_cost 
                                        + ground_station_cost 
                                        + spectrum_cost)
                        
                        opex_costs = (ground_station_energy 
                                        + staff_costs 
                                        + research_development 
                                        + fiber_infrastructure_cost 
                                        + maintenance_costs) 
                        
                        number_of_satellites = item['number_of_satellites']
                        name = item['name']
                        discount_rate = item['discount_rate']
                        assessment_period_year = item['assessment_period']

                        uq_parameters.append({'constellation': name, 
                                                'number_of_satellites': number_of_satellites,
                                                'subscribers_low': item['subscribers'][0],
                                                'subscribers_baseline': item['subscribers'][1],
                                                'subscribers_high': item['subscribers'][2],
                                                'satellite_manufacturing': satellite_manufacturing,
                                                'satellite_launch_cost': satellite_launch_cost,
                                                'satellite_launch_scenario': sat_launch_scenario,
                                                'ground_station_cost': ground_station_cost,
                                                'ground_station_scenario': ground_station_scenario,
                                                'spectrum_cost': spectrum_cost,
                                                'regulation_fees': regulation_fees,
                                                'fiber_infrastructure_cost': fiber_infrastructure_cost,
                                                'ground_station_energy': ground_station_energy,
                                                'subscriber_acquisition': subscriber_acquisition,
                                                'staff_costs': staff_costs,
                                                'research_development': research_development,
                                                'maintenance_costs': maintenance_costs,
                                                'discount_rate': discount_rate,
                                                'assessment_period_year': assessment_period_year,
                                                'opex_costs': opex_costs,
                                                'opex_scenario': opex_scenario,
                                                'capex_costs': capex_costs,
                                                'capex_scenario': capex_scenario})


    df = pd.DataFrame.from_dict(uq_parameters)

    filename = 'uq_parameters_cost.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return

path = os.path.join(BASE_PATH, 'raw', 'scenarios.csv')
df = pd.read_csv(path)
from inputs import falcon_9, soyuz

def calc_emission_type(df, rocket, 
    emission_category):

    """
    This function is for calculating emission type.

    Parameters
    ----------
    df : panda core series
        dataframe.
    rocket : string
        Launching rocket
    emission_category : string
        Emission type e.g 'launch event'.

    Returns
    -------
    emission_dict : dict
        Dictionary containing all 
        the emission categories.
    """
    emission_dict = {}
    df['climate_change_baseline'].loc[i] = (
        rocket['climate_change_baseline'][emission_category])
    emission_dict['climate_change_baseline'] = df['climate_change_baseline'].loc[i]

    df['climate_change_worst_case'].loc[i] = (
        rocket['climate_change_worst_case'][emission_category])
    emission_dict['climate_change_worst_case'] = df['climate_change_worst_case'].loc[i]

    df['ozone_depletion_baseline'].loc[i] = (
        rocket['ozone_depletion_baseline'][emission_category])
    emission_dict['ozone_depletion_baseline'] = df['ozone_depletion_baseline'].loc[i]

    df['ozone_depletion_worst_case'].loc[i] = (
        rocket['ozone_depletion_worst_case'][emission_category])
    emission_dict['ozone_depletion_worst_case'] = df['ozone_depletion_worst_case'].loc[i]

    df['resource_depletion'].loc[i] = (
        rocket['resource_depletion'][emission_category])
    emission_dict['resource_depletion'] = df['resource_depletion'].loc[i]

    df['freshwater_toxicity'].loc[i] = (
        rocket['freshwater_toxicity'][emission_category])
    emission_dict['freshwater_toxicity'] = df['freshwater_toxicity'].loc[i]

    df['human_toxicity'].loc[i] = (
        rocket['human_toxicity'][emission_category])
    emission_dict['human_toxicity'] = df['human_toxicity'].loc[i]

    return emission_dict

df[['launch_event', 'launcher_production', 
    'launcher_ait', 'propellant_production', 
    'propellant_scheduling', 'launcher_transportation', 
    'launch_campaign']] = ''

df = pd.melt(df, id_vars = ['scenario', 'status', 'constellation', 
            'fcc_filling_number', 'rocket', 'representative_of', 
            'rocket_type', 'number_of_satellites', 'number_of_launches',
            ], value_vars = ['launch_event', 'launcher_production', 
            'launcher_ait', 'propellant_production', 'propellant_scheduling', 
            'launcher_transportation', 'launch_campaign'], 
            var_name = 'impact_category', value_name = 'value')

df = df.drop('value', axis = 1) 

df[['climate_change_baseline', 'climate_change_worst_case', 
    'ozone_depletion_baseline', 'ozone_depletion_worst_case',
    'resource_depletion', 'freshwater_toxicity',
    'human_toxicity']] = ''

for i in range(len(df)):

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launch_event':

        for key, item in falcon_9.items():

            calc_emission_type(df, falcon_9, 'launch_event')

            
    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_production': 

        calc_emission_type(df, falcon_9, 'launcher_production')

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_ait':

        calc_emission_type(df, falcon_9, 'launcher_ait') 

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'propellant_production':

        calc_emission_type(df, falcon_9, 'propellant_production') 

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'propellant_scheduling':

        calc_emission_type(df, falcon_9, 'propellant_scheduling') 

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launcher_transportation':

        calc_emission_type(df, falcon_9, 'launcher_transportation') 

    if df['rocket'].loc[i] == 'falcon9' and df['impact_category'].loc[i] == 'launch_campaign':

        calc_emission_type(df, falcon_9, 'launch_campaign')


    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launch_event':

        for key, item in soyuz.items():

            calc_emission_type(df, soyuz, 'launch_event')
            
    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_production': 
            
        for key, item in soyuz.items():

            calc_emission_type(df, soyuz, 'launcher_production')

    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_ait': 

        calc_emission_type(df, soyuz, 'launcher_ait')

    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'propellant_production': 

        calc_emission_type(df, soyuz, 'propellant_production')

    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'propellant_scheduling': 

        calc_emission_type(df, soyuz, 'propellant_scheduling')

    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launcher_transportation': 

        calc_emission_type(df, soyuz, 'launcher_transportation')

    if df['rocket'].loc[i] == 'soyuz' and df['impact_category'].loc[i] == 'launch_campaign': 

        calc_emission_type(df, soyuz, 'launch_campaign')
            

df.to_csv('dfs.csv')
'''if __name__ == '__main__':

    print('Running uq_capacity_inputs_generator()')
    uq_inputs_capacity()

    print('Running uq_inputs_emissions')
    uq_inputs_emissions()

    print('Running uq_cost_inputs_generator()')
    uq_inputs_cost()

    print('Completed')'''