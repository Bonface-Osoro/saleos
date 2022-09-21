"""
Simulation run script for saleos.

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
from __future__ import division
import configparser
import os
import math
import timeit
from numpy import savez_compressed
import pandas as pd

import saleos.sim as sl
from inputs import lut
pd.options.mode.chained_assignment = None #Suppress pandas outdate errors.

#Import the data.
start = timeit.timeit()
data_path = "/Users/osoro/Github/saleos/data/"
df = pd.read_csv(data_path + "uq_parameters.csv")
uq_dict = df.to_dict('records') #Convert the csv to list

path = "/Users/osoro/Github/saleos/results/"
results = []
for item in uq_dict:
    constellation = item["constellation"]

    number_of_satellites = item["number_of_satellites"]

    random_variations = sl.generate_log_normal_dist_value(
        item['dl_frequency_Hz'],
        item['mu'],
        item['sigma'],
        item['seed_value'],
        item['iterations'])

    distance, satellite_coverage_area_km = sl.calc_geographic_metrics(
                                           item["number_of_satellites"], item)

    path_loss = 20*math.log10(distance) + 20*math.log10(item['dl_frequency_Hz']/1e9) + 92.45

    losses = sl.calc_losses(item["earth_atmospheric_losses_dB"], 
                     item["all_other_losses_dB"])

    antenna_gain = sl.calc_antenna_gain(item["speed_of_light"],
                           item["antenna_diameter_m"], item["dl_frequency_Hz"],
                           item["antenna_efficiency"]) 

    eirp = sl.calc_eirp(item["power_dBw"], antenna_gain)

    noise = sl.calc_noise()

    received_power = sl.calc_received_power(eirp, path_loss, 
                             item["receiver_gain_dB"], losses)

    cnr = sl.calc_cnr(received_power, noise)

    spectral_efficiency = sl.calc_spectral_efficiency(cnr, lut)
            
    channel_capacity = sl.calc_capacity(spectral_efficiency, item["dl_bandwidth_Hz"])
    
    agg_capacity = (sl.calc_agg_capacity(channel_capacity, 
                   item["number_of_channels"], item["polarization"])) * item["number_of_satellites"]

    if channel_capacity == 823.6055 or channel_capacity == 411.80275:
        capacity_scenario = "Low"
    elif channel_capacity == 1810.268 or channel_capacity == 526.2125 and item["constellation"] == "OneWeb" or channel_capacity == 1183.8385:
        capacity_scenario = "High"
    else:
        capacity_scenario = "Baseline"

    sat_capacity = sl.single_satellite_capacity(item["dl_bandwidth_Hz"],
                   spectral_efficiency, item["number_of_channels"], 
                   item["polarization"])

    adoption_rate = item["adoption_rate"]

    demand_density_mbps_sqkm = sl.demand_model(item["monthly_traffic_GB"], 
                               item["percent_of_traffic"], item["adoption_rate"], 5, 0.3)
    if item["adoption_rate"] == 0.01:
        demand_scenario = "Low"
    elif item["adoption_rate"] == 1:
        demand_scenario = "High"
    else:
        demand_scenario = "Baseline"

    emission_dict = sl.calc_per_sat_emission(item["constellation"], item["fuel_mass_kg"],
                    item["fuel_mass_1_kg"], item["fuel_mass_2_kg"], item["fuel_mass_3_kg"])

    total_cost_ownership = sl.cost_model(item["satellite_launch_cost"], item["ground_station_cost"], 
                           item["spectrum_cost"], item["regulation_fees"], 
                           item["digital_infrastructure_cost"], item["ground_station_energy"], 
                           item["subscriber_acquisition"], item["staff_costs"], 
                           item["research_development"], item["maintenance_costs"], 
                           item["discount_rate"], item["assessment_period_year"])             
    cost_per_capacity = total_cost_ownership / sat_capacity * number_of_satellites

    if item["capex_scenario"] == "Low":
        cost_scenario = "Low"
    elif item["capex_scenario"] == "High":
        cost_scenario = "High"
    else:
        cost_scenario = "Baseline"

    subscribers_low = item["subscribers_low"]
    subscribers_baseline = item["subscribers_baseline"]
    subscribers_high = item["subscribers_high"]

    aluminium_oxide_emissions = emission_dict['alumina_emission']
    sulphur_oxide_emissions = emission_dict['sulphur_emission']
    carbon_oxide_emissions = emission_dict['carbon_emission']
    cfc_gases_emissions = emission_dict['cfc_gases']
    particulate_matter_emissions = emission_dict['particulate_matter']
    photochemical_oxidation_emissions = emission_dict['photo_oxidation']
    total_emissions = aluminium_oxide_emissions + sulphur_oxide_emissions \
                      + carbon_oxide_emissions + cfc_gases_emissions \
                      + particulate_matter_emissions \
                      + photochemical_oxidation_emissions


    results.append({"constellation": constellation, 
                    "signal_path": distance,
                    "altitude_km": item["altitude_km"],
                    "signal_path_scenario": item["altitude_scenario"],
                    "satellite_coverage_area_km": satellite_coverage_area_km,
                    "dl_frequency_Hz": item["dl_frequency_Hz"],
                    "center_frequency": item["center_frequency"],
                    "path_loss": path_loss,
                    "earth_atmospheric_losses_dB": item["earth_atmospheric_losses_dB"],
                    "atmospheric_loss_scenario": item["atmospheric_loss_scenario"],
                    "losses": losses,
                    "antenna_gain": antenna_gain,
                    "eirp_dB": eirp,
                    "noise": noise,
                    "receiver_gain_db": item["receiver_gain_dB"],
                    "receiver_gain_scenario": item["receiver_gain_scenario"],
                    "received_power_dB": received_power,
                    "received_power_scenario": item["receiver_gain_scenario"],
                    "cnr": cnr,
                    "cnr_scenario": item["cnr_scenario"],
                    "spectral_efficiency": spectral_efficiency,
                    "channel_capacity": channel_capacity,
                    "constellation_capacity": agg_capacity,
                    "capacity_scenario": capacity_scenario,
                    "capacity_per_single_satellite": sat_capacity,
                    "capacity_per_area_mbps/sqkm": agg_capacity/item["coverage_area_per_sat_sqkm"],
                    "adoption_rate_scenario": item["adoption_rate_scenario"],
                    "adoption_rate": adoption_rate,
                    "adoption_scenario": item["adoption_rate_scenario"],
                    "demand_density_mbps_sqkm": demand_density_mbps_sqkm,
                    "demand_scenario": demand_scenario,
                    "subscribers_low": subscribers_low,
                    "subscribers_baseline": subscribers_baseline,
                    "subscribers_high": subscribers_high,                    
                    "satellite_launch_cost": item["satellite_launch_cost"],
                    "satellite_launch_scenario": item["satellite_launch_scenario"],
                    "ground_station_cost_scenario": item["ground_station_scenario"],
                    "ground_station_cost": item["ground_station_cost"],
                    "spectrum_cost": item["spectrum_cost"],
                    "regulation_fees": item["regulation_fees"],
                    "digital_infrastructure_cost": item["digital_infrastructure_cost"],
                    "ground_station_energy": item["ground_station_energy"],
                    "subscriber_acquisition": item["subscriber_acquisition"],
                    "staff_costs": item["staff_costs"],
                    "research_development": item["research_development"],
                    "maintenance_costs": item["maintenance_costs"],
                    "total_cost_ownership": total_cost_ownership,
                    "capex_scenario": item["capex_scenario"],
                    "cost_per_capacity": cost_per_capacity,
                    "cost_scenario": cost_scenario,
                    "aluminium_oxide_emissions": aluminium_oxide_emissions,
                    "sulphur_oxide_emissions": sulphur_oxide_emissions,
                    "carbon_oxide_emissions": carbon_oxide_emissions,
                    "cfc_gases_emissions": cfc_gases_emissions,
                    "particulate_matter_emissions": particulate_matter_emissions,
                    "photochemical_oxidation_emissions": photochemical_oxidation_emissions,
                    "total_emissions_t": total_emissions,
                    "emission_per_capacity": total_emissions / agg_capacity,
                    "emission_per_sqkm": total_emissions / satellite_coverage_area_km,
                    "emission_for_every_cost": total_emissions / total_cost_ownership
                    })

    df = pd.DataFrame.from_dict(results)
    df.to_csv(path + "uq_results.csv") 

end = timeit.timeit()
print("Time taken is ", end - start, "seconds")