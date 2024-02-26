"""
Preprocess all Uncertainty Quantification (UQ) inputs. 

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
import random
import numpy as np
import pandas as pd
import saleos.cost as ct
from inputs import parameters
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']


def uq_inputs_capacity(parameters):
    """
    Generate all UQ capacity inputs in preparation for running through the 
    saleos model. 

    Parameters
    ----------
    parameters : dict
        dictionary of dictionary containing constellation engineering values.

    """
    iterations = []


    for key, constellation_params in parameters.items():

        for i in range(0, constellation_params['iteration_quantity']):

            if key in ['starlink', 'oneweb', 'kuiper', 'geo']:
                
                data = multiorbit_sat_capacity(i, constellation_params)

            iterations = iterations + data

    df = pd.DataFrame.from_dict(iterations)

    filename = 'uq_parameters_capacity.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return


def multiorbit_sat_capacity(i, constellation_params):
    """
    This function generates random values within the given parameter ranges. 

    Parameters
    ----------
    i : int.
        number of iterations
    constellation_params : dict
        Dictionary containing satellite engineering details

    Return
    ------
        output : list
            List containing capacity outputs

    """
    output = []

    #these calcs are unit input cost * number of units. 
    altitude_km = random.randint(constellation_params['altitude_km_low'], 
        constellation_params['altitude_km_high'])

    elevation_angle = random.randint(
        constellation_params['elevation_angle_low'], 
        constellation_params['elevation_angle_high']
    ) 

    dl_frequency_hz = random.randint(
        constellation_params['dl_frequency_hz_low'], 
        constellation_params['dl_frequency_hz_high']
    )

    power_dbw = random.randint(constellation_params['power_dbw_low'], 
        constellation_params['power_dbw_high']
    ) 

    receiver_gain = random.randint(constellation_params['receiver_gain_low'], 
        constellation_params['receiver_gain_high']
    )

    earth_atmospheric_losses = random.randint(
        constellation_params['earth_atmospheric_losses_low'], 
        constellation_params['earth_atmospheric_losses_high']
    ) 

    antenna_diameter_m = random.uniform(
        constellation_params['antenna_diameter_m_low'], 
        constellation_params['antenna_diameter_m_high']
    )

    ideal_coverage_area_per_sat_sqkm = (
        constellation_params['total_area_earth_km_sq'] 
        / constellation_params['number_of_satellites'])

    
    output.append({
        'iteration': i,
        'constellation': constellation_params['name'], 
        'number_of_satellites': constellation_params['number_of_satellites'],
        'number_of_ground_stations': (
            constellation_params['number_of_ground_stations']),
        'subscribers_low': constellation_params['subscribers'][0],
        'subscribers_baseline': constellation_params['subscribers'][1],
        'subscribers_high': constellation_params['subscribers'][2],
        'altitude_km': altitude_km,
        'elevation_angle': elevation_angle,
        'dl_frequency_hz': dl_frequency_hz,
        'power_dbw': power_dbw,
        'receiver_gain_db': receiver_gain,
        'earth_atmospheric_losses_db': earth_atmospheric_losses,
        'antenna_diameter_m': antenna_diameter_m,
        'total_area_earth_km_sq' : (
            constellation_params['total_area_earth_km_sq']),
        'ideal_coverage_area_per_sat_sqkm': ideal_coverage_area_per_sat_sqkm,
        'percent_coverage' : constellation_params['percent_coverage'],
        'speed_of_light': constellation_params['speed_of_light'],
        'antenna_efficiency' : constellation_params['antenna_efficiency'],
        'all_other_losses_db' : constellation_params['all_other_losses_db'],
        'number_of_beams' : constellation_params['number_of_beams'],
        'number_of_channels' : constellation_params['number_of_channels'],
        'polarization' : constellation_params['polarization'],
        'dl_bandwidth_hz' : constellation_params['dl_bandwidth_hz'],
        'subscriber_traffic_percent' : (
            constellation_params['subscriber_traffic_percent'])
    })


    return output


def uq_inputs_cost(parameters):
    """
    Generate all UQ cost inputs in preparation for running through the saleos 
    model. 

    Parameters
    ----------
    parameters : dict
        dictionary of dictionary containing constellation cost values.

    """
    iterations = []


    for key, constellation_params in parameters.items():
        
        
        for i in range(0, constellation_params['iteration_quantity']):

            if key in ['starlink', 'oneweb', 'kuiper', 'geo']:

                data = multiorbit_sat_costs(i, constellation_params)

            iterations = iterations + data

    df = pd.DataFrame.from_dict(iterations)

    filename = 'uq_parameters_cost.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return


def multiorbit_sat_costs(i, constellation_params):
    """
    This function generates random values within the given parameter ranges. 

    Parameters
    ----------
    i : int.
        number of iterations
    constellation_params : dict
        Dictionary containing satellite cost details

    Return
    ------
        output : list
            List containing cost outputs

    """
    output = []

    #these calcs are unit input cost * number of units. 
    satellite_manufacturing = random.randint(
        constellation_params['satellite_manufacturing_low'], 
        constellation_params['satellite_manufacturing_high']
    ) * constellation_params['number_of_satellites']

    satellite_launch_cost = random.randint(
        constellation_params['satellite_launch_cost_low'], 
        constellation_params['satellite_launch_cost_high']
    ) * constellation_params['number_of_satellites']

    ground_station_cost = random.randint(
        constellation_params['ground_station_cost_low'], 
        constellation_params['ground_station_cost_high']
    ) * constellation_params['number_of_ground_stations']

    regulation_fees = random.randint(
        constellation_params['regulation_fees_low'], 
        constellation_params['regulation_fees_high']
    ) * constellation_params['number_of_planes']

    fiber_infrastructure_cost = random.randint(
        constellation_params['fiber_infrastructure_low'], 
        constellation_params['fiber_infrastructure_high']
    ) * constellation_params['number_of_ground_stations']

    ground_station_energy = random.randint(
        constellation_params['ground_station_energy_low'], 
        constellation_params['ground_station_energy_high']
    ) * constellation_params['number_of_ground_stations']

    subscriber_acquisition = random.randint(
        constellation_params['subscriber_acquisition_low'], 
        constellation_params['subscriber_acquisition_high']
    )

    staff_costs = random.randint(
        constellation_params['staff_costs_low'], 
        constellation_params['staff_costs_high']
    ) * constellation_params['number_of_employees']

    maintenance_costs = random.randint(
        constellation_params['maintenance_low'], 
        constellation_params['maintenance_high']) 

    capex_costs = (satellite_manufacturing + satellite_launch_cost 
                   + ground_station_cost + fiber_infrastructure_cost)
    
    opex_costs = ct.opex_cost(regulation_fees, ground_station_energy, 
                              staff_costs, subscriber_acquisition, 
                              maintenance_costs, 
                              constellation_params['discount_rate'], 
                              constellation_params['assessment_period'])
    
    output.append({
        'iteration': i,
        'constellation': constellation_params['name'], 
        'number_of_satellites': constellation_params['number_of_satellites'],
        'number_of_ground_stations': (
            constellation_params['number_of_ground_stations']),
        'subscribers_low': constellation_params['subscribers'][0],
        'subscribers_baseline': constellation_params['subscribers'][1],
        'subscribers_high': constellation_params['subscribers'][2],
        'satellite_manufacturing': satellite_manufacturing,
        'satellite_launch_cost': satellite_launch_cost,
        'ground_station_cost': ground_station_cost,
        'regulation_fees': regulation_fees,
        'fiber_infrastructure_cost': fiber_infrastructure_cost,
        'ground_station_energy': ground_station_energy,
        'subscriber_acquisition': subscriber_acquisition,
        'staff_costs': staff_costs,
        'maintenance_costs': maintenance_costs,
        'capex_costs': capex_costs,
        'opex_costs': opex_costs,
        'discount_rate': constellation_params['discount_rate'],
        'assessment_period_year': constellation_params['assessment_period'],
    })

    return output


if __name__ == '__main__':

    print('Running uq_capacity_inputs_generator()')
    uq_inputs_capacity(parameters)

    print('Running uq_cost_inputs_generator()')
    uq_inputs_cost(parameters)

    print('Completed')