"""
Uncertainty quantification of costs. 

February 2024

Written by Ed Oughton. 

"""

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
from inputs import parameters
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']


def uq_inputs_cost(parameters):
    """
    Generate all UQ cost inputs in preparation for running through the saleos model. 
    
    """
    iterations = []


    for key, constellation_params in parameters.items():
        
        for i in range(0, constellation_params['iteration_quantity']):

            if key in ['starlink', 'oneweb', 'kuiper', 'geo']:

                data = geo_leo_costs(i, constellation_params)

            iterations = iterations + data

    df = pd.DataFrame.from_dict(iterations)

    filename = 'uq_parameters_cost.csv'

    if not os.path.exists(BASE_PATH):
        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)

    return


def geo_leo_costs(i, constellation_params):
    """
    This function generates random values within the 
    given parameter ranges. 

    """
    output = []

    #these calcs need to be unit input cost * number of units. 
    satellite_manufacturing = random.randint(
        constellation_params['satellite_manufacturing_low'], 
        constellation_params['satellite_manufacturing_high']
    ) * constellation_params['number_of_satellites']

    satellite_launch = random.randint(
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
        constellation_params['maintenance_high']
    )

    capex_costs = (satellite_manufacturing
                    + subscriber_acquisition
                    + regulation_fees
                    + satellite_launch 
                    + ground_station_cost)
    
    opex_costs = (ground_station_energy 
                + staff_costs 
                + fiber_infrastructure_cost 
                + maintenance_costs) 

    output.append({
        'iteration': i,
        'constellation': constellation_params['name'], 
        'number_of_satellites': constellation_params['number_of_satellites'],
        'number_of_ground_stations': constellation_params['number_of_ground_stations'],
        'subscribers_low': constellation_params['subscribers'][0],
        'subscribers_baseline': constellation_params['subscribers'][1],
        'subscribers_high': constellation_params['subscribers'][2],
        'satellite_manufacturing': satellite_manufacturing,
        'satellite_launch': satellite_launch,
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

    print('Running uq_cost_inputs_generator()')
    uq_inputs_cost(parameters)

    print('Completed')