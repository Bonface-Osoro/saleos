"""
Preprocess all Uncertainty Quantification (UQ) inputs. 

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
from random import *
import numpy as np
import pandas as pd
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


def uq_inputs_cost():
    """
    Generate all UQ cost inputs to run through the saleos model. 
    
    """
    uq_parameters = []

    for key, item in parameters.items():

        # Cost variables
        if key == 'geo':

            # Generate a list containing satellite launch cost values that are above 
            # and below the provided input value by $USD 1,680,000,000 for a GEO operator.
            satellite_launch = [item['satellite_launch_cost'] - 1680000000, 
                                item['satellite_launch_cost'], 
                                item['satellite_launch_cost'] + 1680000000] 
            
        else:

            # Generate a list containing satellite launch cost values that are above 
            # and below the provided input value by $USD 63,672,000 for a LEO operator.
            satellite_launch = [item['satellite_launch_cost'] - 63672000, 
                                item['satellite_launch_cost'], 
                                item['satellite_launch_cost'] + 63672000] 
            
        # Generate a list containing ground station cost values that are above 
        # and below the provided input value by 20% of the given cost.
        ground_station = [item['ground_station_cost'] - 
                          (item['ground_station_cost'] * 0.2), 
                         item['ground_station_cost'], 
                         item['ground_station_cost'] + 
                         (item['ground_station_cost'] * 0.2)]
        
        # Generate a list containing maintenance cost values that are above 
        # and below the provided input value by $USD 3,000,000.
        maintenance_cost = [item['maintenance'] - 3000000, 
                            item['maintenance'], 
                            item['maintenance'] + 3000000]
        
        # Generate a list containing staff cost values that are above 
        # and below the provided input value by $USD 1,000,000.
        staff_cost = [item['staff_costs'] - 10000000, 
                      item['staff_costs'], 
                      item['staff_costs'] + 10000000]
        
        if key == 'geo':

            # Generate a list containing satellite manufacturing cost values that are above 
            # and below the provided input value by $USD 5,600,000,000 for a GEO operator.
            total_satellite_cost = item['satellite_manufacturing'] * item['number_of_satellites']
            total_variation_cost = item['number_of_satellites'] * 10000000

            satellite_manufacturing_costs = [total_satellite_cost - total_variation_cost, 
                        total_satellite_cost, total_satellite_cost + total_variation_cost]
            
        else: 

            # Generate a list containing satellite manufacturing cost values that are above 
            # and below the provided input value by $USD 100,000 for a LEO operator.
            total_satellite_cost = item['satellite_manufacturing'] * item['number_of_satellites']
            total_variation_cost = item['number_of_satellites'] * 100000

            satellite_manufacturing_costs = [total_satellite_cost - total_variation_cost, 
                        total_satellite_cost, total_satellite_cost + total_variation_cost]
            
        # Generate a list containing spectrum cost values that are above 
        # and below the provided input value by $USD 5,000,000.
        spectrum_costs = [item['spectrum_cost'] - 5000000, 
                      item['spectrum_cost'], 
                      item['spectrum_cost'] + 5000000]
        
        # Generate a list containing ground station energy values that are above 
        # and below the provided input value by $USD 500,000.
        ground_station_energy_costs = [item['ground_station_energy'] - 500000, 
                      item['ground_station_energy'], 
                      item['ground_station_energy'] + 500000]

        for sat_launch in satellite_launch:

            satellite_launch_cost = sat_launch

            for gst in ground_station:

                ground_station_cost = gst

                if gst == (ground_station[0]) and sat_launch == (satellite_launch[0]):

                    capex_scenario = 'Low'
                    sat_launch_scenario = 'Low'
                    ground_station_scenario = 'Low'

                elif gst == (ground_station[1]) and sat_launch == (satellite_launch[1]):

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

                        for sat_cost in satellite_manufacturing_costs:

                            satellite_manufacturing = sat_cost

                            for spec_costs in spectrum_costs:

                                spectrum_cost = spec_costs

                                for gst_energy_costs in ground_station_energy_costs:

                                    ground_station_energy = gst_energy_costs

                                    regulation_fees = item['regulation_fees'] 
                                    fiber_infrastructure_cost = item['fiber_infrastructure_cost']
                                    subscriber_acquisition = item['subscriber_acquisition']
                                    research_development = item['research_development'] 
                                    maintenance_costs = maint_costs

                                    capex_costs = (satellite_manufacturing
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
                                                            'capex_costs': capex_costs,
                                                            'opex_scenario': opex_scenario,
                                                            'capex_scenario': capex_scenario})


    df = pd.DataFrame.from_dict(uq_parameters)

    filename = 'uq_parameters_cost.csv'

    if not os.path.exists(BASE_PATH):

        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, 'processed', filename)
    df.to_csv(path_out, index = False)


    return None


if __name__ == '__main__':

    print('Running uq_capacity_inputs_generator()')
    uq_inputs_capacity()

    print('Running uq_cost_inputs_generator()')
    uq_inputs_cost()

    print('Completed')