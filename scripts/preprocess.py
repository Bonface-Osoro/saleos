"""
Preprocess all Uncertainty Quantification (UQ) inputs. 

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
import configparser
import os
import numpy as np
import pandas as pd
import random
import decimal
import saleos as sl
from random import*
from tqdm import tqdm
from inputs import parameters, lut

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']


def uq_inputs_capacity():
    """
    Generate all UQ capacity inputs to run through the saleos model. 
    
    """
    uq_parameters = []

    for key, item in parameters.items():

        # radio propagation variables
        altitude = [(item['altitude_km'] - 5), 
                    item['altitude_km'], 
                    (item['altitude_km'] + 5)]
        
        atmospheric_loss = [item['earth_atmospheric_losses'] - 3, 
                            item['earth_atmospheric_losses'], 
                           item['earth_atmospheric_losses'] + 3]
        
        receiver_gain = [(item['receiver_gain'] - 5), 
                         (item['receiver_gain']), 
                         (item['receiver_gain'] + 5)]

        subscriber_scenarios = [
            'low',
            'baseline',
            'high'
        ]

        for alt in altitude:

            altitude_km = alt

            for rec_gain in receiver_gain:

                receiver_gain_dB = rec_gain

                for atm_loss in atmospheric_loss:

                    earth_atmospheric_losses_dB = atm_loss

                    # if atm_loss == 7:

                    #     cnr_scenario = 'High(>13.5 dB)'

                    # elif atm_loss == 10:

                    #     cnr_scenario = 'Baseline(7.6 - 10.5 dB)'

                    # else:

                    #     cnr_scenario = 'Low (<7.5 dB)'

                    for subscriber_scenario in subscriber_scenarios:
                            
                        if subscriber_scenario == 'low':
                            subscribers = item['subscribers'][0]
                        elif subscriber_scenario == 'baseline':
                            subscribers = item['subscribers'][1]
                        elif subscriber_scenario == 'high':
                            subscribers = item['subscribers'][2]

                        number_of_satellites = item['number_of_satellites']
                        name = item['name']
                        total_area_earth_km_sq = item['total_area_earth_km_sq']
                        dl_bandwidth_Hz = item['dl_bandwidth_Hz']
                        speed_of_light = item['speed_of_light']
                        antenna_diameter_m = item['antenna_diameter_m']
                        antenna_efficiency = item['antenna_efficiency']
                        power_dBw = item['power_dBw']
                        all_other_losses_dB = item['all_other_losses_dB'] 
                        number_of_channels = item['number_of_channels']
                        polarization = item['polarization']
                        # discount_rate = item['discount_rate']
                        # assessment_period_year = item['assessment_period']

                        uq_parameters.append({
                            'constellation': name, 
                            'number_of_satellites': number_of_satellites,
                            'total_area_earth_km_sq': total_area_earth_km_sq,
                            'coverage_area_per_sat_sqkm': total_area_earth_km_sq/number_of_satellites,
                            'altitude_km': altitude_km,
                            'dl_frequency_Hz': item['dl_frequency_Hz'],
                            'dl_bandwidth_Hz': dl_bandwidth_Hz,
                            'speed_of_light': speed_of_light,
                            'antenna_diameter_m': antenna_diameter_m,
                            'antenna_efficiency': antenna_efficiency,
                            'power_dBw': power_dBw,
                            'receiver_gain_dB': receiver_gain_dB,
                            'earth_atmospheric_losses_dB': earth_atmospheric_losses_dB,
                            'all_other_losses_dB': all_other_losses_dB,
                            'number_of_channels': number_of_channels,
                            'polarization': polarization,
                            'subscriber_scenario': subscriber_scenario,
                            'subscribers': subscribers,
                        })

    df = pd.DataFrame.from_dict(uq_parameters)

    filename = 'uq_parameters_capacity.csv'

    if not os.path.exists(BASE_PATH):
        os.makedirs(BASE_PATH)
    
    path_out = os.path.join(BASE_PATH, filename)
    df.to_csv(path_out, index=False)

    return 


if __name__ == '__main__':

    print('Running uq_inputs_generator()')
    uq_inputs_capacity()

    print('Completed')