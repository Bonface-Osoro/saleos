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


def uq_inputs_generator():
    """
    Generate all UQ inputs to run through the saleos model. 
    
    """
    uq_parameters = []

    for key, item in parameters.items():

        # radio propagation variables
        altitude = [(item["altitude_km"] - 5), 
                    item["altitude_km"], 
                    (item["altitude_km"] + 5)]
        
        atmospheric_loss = [item["earth_atmospheric_losses"] - 3, 
                            item["earth_atmospheric_losses"], 
                           item["earth_atmospheric_losses"] + 3]
        
        receiver_gain = [(item["receiver_gain"] - 5), 
                         (item["receiver_gain"]), 
                         (item["receiver_gain"] + 5)]

        # cost variables
        satellite_launch = [item["satellite_launch_cost"] - 63672000, 
                            item["satellite_launch_cost"], 
                            item["satellite_launch_cost"] + 63672000] 

        ground_station = [item["ground_station_cost"] - 
                          (item["ground_station_cost"] * 0.2), 
                         item["ground_station_cost"], 
                         item["ground_station_cost"] + 
                         (item["ground_station_cost"] * 0.2)]

        maintenance_cost = [item["maintenance"] - 3000000, 
                            item["maintenance"], 
                            item["maintenance"] + 3000000]

        staff_cost = [item["staff_costs"] - 10000000, 
                      item["staff_costs"], 
                      item["staff_costs"] + 10000000]

        for alt in altitude:

            altitude_km = alt

            if alt == 540 or alt == 1190 or alt == 600:

                altitude_scenario = "Low"

            elif alt == 545 or alt == 1195 or alt == 605:

                altitude_scenario = "Baseline"

            else:

                altitude_scenario = "High"

            for rec_gain in receiver_gain:

                receiver_gain_dB = rec_gain

                if rec_gain == 25 or rec_gain == 26:

                    receiver_gain_scenario = "Low"

                elif rec_gain == 30 or rec_gain == 31:

                    receiver_gain_scenario = "Baseline" 

                else:
                    receiver_gain_scenario = "High"

                for atm_loss in atmospheric_loss:

                    earth_atmospheric_losses_dB = atm_loss

                    if atm_loss == 7:

                        atmospheric_loss_scenario = "Low"
                        cnr_scenario = "High(>13.5 dB)"

                    elif atm_loss == 10:

                        atmospheric_loss_scenario = "Baseline"
                        cnr_scenario = "Baseline(7.6 - 10.5 dB)"

                    else:
                        atmospheric_loss_scenario = "High"
                        cnr_scenario = "Low (<7.5 dB)"

                    for sat_launch in satellite_launch:

                        satellite_launch_cost = sat_launch

                        for gst in ground_station:

                            ground_station_cost = gst

                            if gst == 39088000 and sat_launch == 186328000 or gst == 16000000 and \
                                sat_launch == 86328000 or gst == 26400000 and sat_launch == 116328000:

                                capex_scenario = "Low"
                                sat_launch_scenario = "Low"
                                ground_station_scenario = "Low"

                            elif gst == 48860000 and sat_launch == 250000000 or gst == 20000000 and \
                                sat_launch == 150000000 or gst == 33000000 and sat_launch == 180000000:

                                capex_scenario = "Baseline"
                                sat_launch_scenario = "Baseline"
                                ground_station_scenario = "Baseline"

                            else:
                                capex_scenario = "High"
                                sat_launch_scenario = "High"
                                ground_station_scenario = "High"

                            for maint_cost in maintenance_cost:

                                maint_costs = maint_cost

                                if maint_cost == maintenance_cost[0]:

                                    opex_scenario = "Low"

                                elif maint_cost == maintenance_cost[1]:

                                    opex_scenario = "Baseline"

                                elif maint_cost == maintenance_cost[2]:

                                    opex_scenario = "High"

                                else: 
                                    opex_scenario = "None"

                                for stf_cost in staff_cost:

                                    staff_costs = stf_cost
                                    
                                    satellite_manufacturing = item["satellite_manufacturing"]
                                    spectrum_cost = item["spectrum_cost"] 
                                    regulation_fees = item["regulation_fees"] 
                                    digital_infrastructure_cost = item["digital_infrastructure_cost"]
                                    ground_station_energy = item["ground_station_energy"]
                                    subscriber_acquisition = item["subscriber_acquisition"]
                                    research_development = item["research_development"] 
                                    maintenance_costs = maint_costs

                                    capex_costs = (item["satellite_manufacturing"] 
                                                   + item["subscriber_acquisition"] 
                                                   + regulation_fees
                                                   + satellite_launch_cost 
                                                   + ground_station_cost 
                                                   + spectrum_cost)
                                    opex_costs = (ground_station_energy 
                                                  + staff_costs 
                                                  + research_development 
                                                  + digital_infrastructure_cost 
                                                  + maintenance_costs) 
                                    number_of_satellites = item["number_of_satellites"]
                                    name = item["name"]
                                    total_area_earth_km_sq = item["total_area_earth_km_sq"]
                                    dl_bandwidth_Hz = item["dl_bandwidth_Hz"]
                                    speed_of_light = item["speed_of_light"]
                                    antenna_diameter_m = item["antenna_diameter_m"]
                                    antenna_efficiency = item["antenna_efficiency"]
                                    power_dBw = item["power_dBw"]
                                    all_other_losses_dB = item["all_other_losses_dB"] 
                                    number_of_channels = item["number_of_channels"]
                                    polarization = item["polarization"]
                                    fuel_mass_kg = item["fuel_mass"]
                                    fuel_mass_1_kg = item["fuel_mass_1"]
                                    fuel_mass_2_kg = item["fuel_mass_2"]
                                    fuel_mass_3_kg = item["fuel_mass_3"]
                                    discount_rate = item["discount_rate"]
                                    assessment_period_year = item["assessment_period"]

                                    uq_parameters.append({"constellation": name, 
                                                            "number_of_satellites": number_of_satellites,
                                                            "total_area_earth_km_sq": total_area_earth_km_sq,
                                                            "coverage_area_per_sat_sqkm": total_area_earth_km_sq/number_of_satellites,
                                                            "altitude_km": altitude_km,
                                                            "altitude_scenario": altitude_scenario,
                                                            "dl_frequency_Hz": item["dl_frequency_Hz"],
                                                            "dl_bandwidth_Hz": dl_bandwidth_Hz,
                                                            "speed_of_light": speed_of_light,
                                                            "antenna_diameter_m": antenna_diameter_m,
                                                            "antenna_efficiency": antenna_efficiency,
                                                            "power_dBw": power_dBw,
                                                            "receiver_gain_dB": receiver_gain_dB,
                                                            "receiver_gain_scenario": receiver_gain_scenario,
                                                            "earth_atmospheric_losses_dB": earth_atmospheric_losses_dB,
                                                            "atmospheric_loss_scenario": atmospheric_loss_scenario,
                                                            "all_other_losses_dB": all_other_losses_dB,
                                                            "number_of_channels": number_of_channels,
                                                            "cnr_scenario": cnr_scenario,
                                                            "polarization": polarization,
                                                            "subscribers_low": item["subscribers"][0],
                                                            "subscribers_baseline": item["subscribers"][1],
                                                            "subscribers_high": item["subscribers"][2],
                                                            "fuel_mass_kg": fuel_mass_kg,
                                                            "fuel_mass_1_kg": fuel_mass_1_kg,
                                                            "fuel_mass_2_kg": fuel_mass_2_kg,
                                                            "fuel_mass_3_kg": fuel_mass_3_kg,
                                                            "satellite_manufacturing": satellite_manufacturing,
                                                            "satellite_launch_cost": satellite_launch_cost,
                                                            "satellite_launch_scenario": sat_launch_scenario,
                                                            "ground_station_cost": ground_station_cost,
                                                            "ground_station_scenario": ground_station_scenario,
                                                            "spectrum_cost": spectrum_cost,
                                                            "regulation_fees": regulation_fees,
                                                            "digital_infrastructure_cost": digital_infrastructure_cost,
                                                            "ground_station_energy": ground_station_energy,
                                                            "subscriber_acquisition": subscriber_acquisition,
                                                            "staff_costs": staff_costs,
                                                            "research_development": research_development,
                                                            "maintenance_costs": maintenance_costs,
                                                            "discount_rate": discount_rate,
                                                            "assessment_period_year": assessment_period_year,
                                                            "opex_costs": opex_costs,
                                                            "opex_scenario": opex_scenario,
                                                            "capex_costs": capex_costs,
                                                            "capex_scenario": capex_scenario})

    df = pd.DataFrame.from_dict(uq_parameters)

    filename = 'uq_parameters.csv'

    if not os.path.exists(BASE_PATH):
        
        os.makedirs(BASE_PATH)

    path_out = os.path.join(BASE_PATH, filename)
    df.to_csv(path_out, index=False)
            
    return df.shape


if __name__ == '__main__':

    print('Running uq_inputs_generator()')
    uq_inputs_generator()

    print('Completed')