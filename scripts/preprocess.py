"""
Preprocess all Uncertainty Quantification (UQ) inputs. 

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
import random
#from random import *
import numpy as np
import pandas as pd
import saleos.cost as ct
from inputs import parameters
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
    
        # Generate a list containing satellite altitude values that are above 
        # and below the provided input value by 6 km at an interval of 2 km.
        altitude = (np.concatenate((np.arange(item['altitude_km'], 
                   (item['altitude_km'] + 6) + 2, 2), 
                   np.arange(item['altitude_km'] - 2, 
                   (item['altitude_km'] - 6) - 2, -2))))
        
        # Generate a list containing satellite elevation angle values that are above 
        # the provided input value by 15 degrees at an interval of 5 degrees.
        elevation_angles = (np.arange(item['elevation_angle'], 
                           (item['elevation_angle'] + 15) 
                           + 5, 5))
        
        # Generate a list containing atmospheric loss values that are above 
        # and below the provided input value by 8 dB at an interval of 3 dB.

        atmospheric_loss = (np.concatenate((np.arange(item['earth_atmospheric_losses'], 
                           (item['earth_atmospheric_losses'] + 8) + 3, 3), 
                           np.arange(item['earth_atmospheric_losses'] - 3, 
                           (item['earth_atmospheric_losses'] - 8) - 3, -3))))
        
        # Generate a list containing receiver gain values that are above 
        # and below the provided input value by 3 dB.
        receiver_gain = [(item['receiver_gain'] - 3), 
                         (item['receiver_gain']), 
                         (item['receiver_gain'] + 3)]

        for alt in altitude:

            altitude_km = alt

            for rec_gain in receiver_gain:

                receiver_gain_db = rec_gain

                for angle in elevation_angles:

                    elevation_angle = angle

                    for freq in item['dl_frequency_hz']:

                        dl_frequency_hz = freq

                        for atm_loss in atmospheric_loss:

                            earth_atmospheric_losses_db = atm_loss
                            
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
                                'ideal_coverage_area_per_sat_sqkm': total_area_earth_km_sq / number_of_satellites,
                                'altitude_km': altitude_km,
                                'elevation_angle': elevation_angle,
                                'dl_frequency_hz': dl_frequency_hz,
                                'dl_bandwidth_hz': dl_bandwidth_hz,
                                'speed_of_light': speed_of_light,
                                'antenna_diameter_m': antenna_diameter_m,
                                'antenna_efficiency': antenna_efficiency,
                                'power_dbw': power_dbw,
                                'receiver_gain_db': receiver_gain_db,
                                'earth_atmospheric_losses_db': earth_atmospheric_losses_db,
                                'all_other_losses_db': all_other_losses_db,
                                'number_of_beams' : item['number_of_beams'],
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


def uq_inputs_cost(parameters):
    """
    Generate all UQ cost inputs in preparation for running 
    through the saleos model. 

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
    This function generates random values within the 
    given parameter ranges. 

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

    capex_costs = (satellite_manufacturing 
                   + satellite_launch_cost 
                   + ground_station_cost
                   + fiber_infrastructure_cost
                   )
    
    opex_costs = ct.opex_cost(regulation_fees, 
                              ground_station_energy, 
                              staff_costs, 
                              subscriber_acquisition, 
                              maintenance_costs, 
                              constellation_params['discount_rate'], 
                              constellation_params['assessment_period'])
    
    output.append({
        'iteration': i,
        'constellation': constellation_params['name'], 
        'number_of_satellites': constellation_params['number_of_satellites'],
        'number_of_ground_stations': constellation_params['number_of_ground_stations'],
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
    uq_inputs_capacity()

    print('Running uq_cost_inputs_generator()')
    uq_inputs_cost(parameters)

    print('Completed')