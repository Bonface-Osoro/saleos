import numpy as np
import pandas as pd
import random
import decimal
from random import*
from inputs import parameters, lut

def uq_inputs_generator():
    path = "/Users/osoro/Github/saleos/data/"
    uq_parameters = []

    for key, item in parameters.items():
        altitude = [(item["altitude_km"] - 5), item["altitude_km"], (item["altitude_km"] + 5)]

        dl_frequency = [item["dl_frequency"] - (1.5 * 10 ** 9), item["dl_frequency"], 
                       item["dl_frequency"] + (1.5 * 10 ** 9)] 
        receiver_gain = [(item["receiver_gain"] - 5), (item["receiver_gain"]), (item["receiver_gain"] + 5)]
        atmospheric_loss = [item["earth_atmospheric_losses"]- 3, item["earth_atmospheric_losses"], 
                           item["earth_atmospheric_losses"] + 3]
        adopt_rate = [item["adoption_rate"], 
                     item["adoption_rate"]+0.49, item["adoption_rate"]+0.99]
        satellite_launch = [item["satellite_launch_cost"] - 63672000, 
                            item["satellite_launch_cost"], item["satellite_launch_cost"] + 63672000] 

        for alt in altitude:
            altitude_km = alt
            if alt == 540 or alt == 1190 or alt == 600:
                altitude_scenario = "Low"
            elif alt == 545 or alt == 1195 or alt == 605:
                altitude_scenario = "Baseline"
            else:
                altitude_scenario = "High"
            for freq in dl_frequency:
                dl_frequency_Hz = freq
                if freq == 13.5 * 10 ** 9:
                    center_frequency = "13.5 GHz"
                elif freq == 12 * 10 ** 9:
                    center_frequency = "12 GHz"
                elif freq == 15 * 10 ** 9:
                    center_frequency = "15 GHz"
                elif freq == 16.2 * 10 ** 9:
                    center_frequency = "16.2 GHz"
                elif freq == 17.7 * 10 ** 9:
                    center_frequency = "17.7 GHz"
                else:
                    center_frequency = "19.3 GHz"
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
                        elif atm_loss == 10:
                            atmospheric_loss_scenario = "Baseline"
                        else:
                            atmospheric_loss_scenario = "High"
                        for sat_launch in satellite_launch:
                            satellite_launch_cost = sat_launch
                            if sat_launch == 187624000 or sat_launch == 657624000 or sat_launch == 116328000:
                                total_cost_ownership_scenario = "Low"
                            elif sat_launch == 250000000 or sat_launch == 720000000 or sat_launch == 180000000:
                                total_cost_ownership_scenario = "Baseline"
                            else:
                                total_cost_ownership_scenario = "High"
                            for adop in adopt_rate:
                                adoption_rate = adop
                                if adop == 0.01:
                                    adoption_rate_scenario = "Low"
                                elif adop == 0.5:
                                    adoption_rate_scenario = "Baseline"
                                else:
                                    adoption_rate_scenario = "High"
                                ground_station_cost = item["ground_station_cost"]
                                spectrum_cost = item["spectrum_cost"] 
                                regulation_fees = item["regulation_fees"] 
                                digital_infrastructure_cost = item["digital_infrastructure_cost"]
                                ground_station_energy = item["ground_station_energy"]
                                subscriber_acquisition = item["subscriber_acquisition"] 
                                staff_costs = item["staff_costs"]
                                research_development = item["research_development"] 
                                maintenance_costs = item["maintenance"]
                                number_of_satellites = item["number_of_satellites"]
                                name = item["name"]
                                iterations = item['iterations']
                                seed_value = item['seed_value']
                                mu = item['mu']
                                sigma = item['sigma']
                                total_area_earth_km_sq = item["total_area_earth_km_sq"]
                                dl_bandwidth_Hz = item["dl_bandwidth"]
                                speed_of_light = item["speed_of_light"]
                                antenna_diameter_m = item["antenna_diameter"]
                                antenna_efficiency = item["antenna_efficiency"]
                                power_dBw = item["power"]
                                all_other_losses_dB = item["all_other_losses"] 
                                number_of_channels = item["number_of_channels"]
                                polarization = item["polarization"]
                                traffic_percent = item["percent_of_traffic"]
                                monthly_traffic_GB = item["monthly_traffic_GB"]+5
                                fuel_mass_kg = item["fuel_mass"]
                                fuel_mass_1_kg = item["fuel_mass_1"]
                                fuel_mass_2_kg = item["fuel_mass_2"]
                                fuel_mass_3_kg = item["fuel_mass_3"]
                                discount_rate = item["discount_rate"]
                                assessment_period_year = item["assessment_period"]

                                uq_parameters.append({"constellation": name, 
                                                        "iterations": iterations,
                                                        "seed_value": seed_value,
                                                        "mu": mu,
                                                        "sigma": sigma,
                                                        "number_of_satellites": number_of_satellites,
                                                        "total_area_earth_km_sq": total_area_earth_km_sq,
                                                        "coverage_area_per_sat_sqkm": total_area_earth_km_sq/number_of_satellites,
                                                        "altitude_km": altitude_km,
                                                        "altitude_scenario": altitude_scenario,
                                                        "dl_frequency_Hz": dl_frequency_Hz,
                                                        "center_frequency": center_frequency,
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
                                                        "polarization": polarization,
                                                        "monthly_traffic_GB": monthly_traffic_GB,
                                                        "percent_of_traffic": traffic_percent,
                                                        "adoption_rate": adoption_rate,
                                                        "adoption_rate_scenario": adoption_rate_scenario,
                                                        "fuel_mass_kg": fuel_mass_kg,
                                                        "fuel_mass_1_kg": fuel_mass_1_kg,
                                                        "fuel_mass_2_kg": fuel_mass_2_kg,
                                                        "fuel_mass_3_kg": fuel_mass_3_kg,
                                                        "satellite_launch_cost": satellite_launch_cost,
                                                        "ground_station_cost": ground_station_cost,
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
                                                        "total_cost_ownership_scenario": total_cost_ownership_scenario})

    df = pd.DataFrame.from_dict(uq_parameters)
    df.to_csv(path + "uq_parameters.csv")
            
    return df.shape
uq_inputs_generator()