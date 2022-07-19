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
        altitude = np.arange((item["altitude_km"] - 5), (item["altitude_km"] + 5), 3.3)
        receiver_gain = np.arange((item["receiver_gain"] - 5), (item["receiver_gain"] + 5), 0.06)
        adopt_rate = [item["adoption_rate"], 0.5, 1]
        satellite_launch = [229500000, item["satellite_launch_cost"], 270500000] 
        
        for alt in altitude:
            for rec_gain in receiver_gain:
                for sat_launch in satellite_launch:
                    for adop in adopt_rate:
                        regulation_fees = item["regulation_fees"] 
                        digital_infrastructure_cost = item["digital_infrastructure_cost"]
                        ground_station_energy = item["ground_station_energy"]
                        subscriber_acquisition = item["subscriber_acquisition"] 
                        staff_costs = item["staff_costs"]
                        research_development = item["research_development"] 
                        maintenance_costs = item["maintenance"] 
                        satellite_launch_cost = sat_launch 
                        ground_station_cost = item["ground_station_cost"]
                        spectrum_cost = item["spectrum_cost"]
                        adoption_rate = adop
                        receiver_gain_dB = rec_gain
                        altitude_km = alt
                        number_of_satellites = item["number_of_satellites"]
                        name = item["name"]
                        iterations = item['iterations']
                        seed_value = item['seed_value']
                        mu = item['mu']
                        sigma = item['sigma']
                        total_area_earth_km_sq = item["total_area_earth_km_sq"]
                        dl_frequency_Hz = item["dl_frequency"] 
                        dl_bandwidth_Hz = item["dl_bandwidth"]
                        speed_of_light = item["speed_of_light"]
                        antenna_diameter_m = item["antenna_diameter"]
                        antenna_efficiency = item["antenna_efficiency"]
                        power_dBw = item["power"]
                        earth_atmospheric_losses_dB = item["earth_atmospheric_losses"]- 3
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
                                                "dl_frequency_Hz": dl_frequency_Hz,
                                                "dl_bandwidth_Hz": dl_bandwidth_Hz,
                                                "speed_of_light": speed_of_light,
                                                "antenna_diameter_m": antenna_diameter_m,
                                                "antenna_efficiency": antenna_efficiency,
                                                "power_dBw": power_dBw,
                                                "receiver_gain_dB": receiver_gain_dB,
                                                "earth_atmospheric_losses_dB": earth_atmospheric_losses_dB,
                                                "all_other_losses_dB": all_other_losses_dB,
                                                "number_of_channels": number_of_channels,
                                                "polarization": polarization,
                                                "monthly_traffic_GB": monthly_traffic_GB,
                                                "percent_of_traffic": traffic_percent,
                                                "adoption_rate": adoption_rate,
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
                                                "assessment_period_year": assessment_period_year})

    df = pd.DataFrame.from_dict(uq_parameters)
    df.to_csv(path + "uq_parameters.csv")
            
    return df.shape
uq_inputs_generator()