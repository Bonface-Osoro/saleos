"""
Simulation run script for saleos.

Written by Bonface Osoro & Ed Oughton.

December 2022

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
from cost import cost_model
from demand import demand_model
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

    agg_capacity = sl.calc_agg_capacity(channel_capacity, 
                   item["number_of_channels"], item["polarization"])

    sat_capacity = sl.single_satellite_capacity(item["dl_bandwidth_Hz"],
                   spectral_efficiency, item["number_of_channels"], 
                   item["polarization"])

    adoption_rate = item["adoption_rate"]

    demand_density_mbps_sqkm = demand_model(item["monthly_traffic_GB"], 
                               item["percent_of_traffic"], item["adoption_rate"], 5, 0.3)

    emission_dict = sl.calc_per_sat_emission(item["constellation"], item["fuel_mass_kg"],
                    item["fuel_mass_1_kg"], item["fuel_mass_2_kg"], item["fuel_mass_3_kg"])

    total_cost_ownership = cost_model(item["satellite_launch_cost"], item["ground_station_cost"], 
                           item["spectrum_cost"], item["regulation_fees"], 
                           item["digital_infrastructure_cost"], item["ground_station_energy"], 
                           item["subscriber_acquisition"], item["staff_costs"], 
                           item["research_development"], item["maintenance_costs"], 
                           item["discount_rate"], item["assessment_period_year"])             
    cost_per_capacity = total_cost_ownership / sat_capacity * number_of_satellites

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
                    "received_power_dB": received_power,
                    "received_power_scenario": item["receiver_gain_scenario"],
                    "cnr": cnr,
                    "spectral_efficiency": spectral_efficiency,
                    "channel_capacity": channel_capacity,
                    "agg_capacity": agg_capacity,
                    "capacity_per_single_satellite": sat_capacity,
                    "capacity_per_area_mbps/sqkm": agg_capacity/item["coverage_area_per_sat_sqkm"],
                    "adoption_rate_scenario": item["adoption_rate_scenario"],
                    "adoption_rate": adoption_rate,
                    "demand_density_mbps_sqkm": demand_density_mbps_sqkm,
                    "total_cost_ownership": total_cost_ownership,
                    "total_cost_ownership_scenario": item["total_cost_ownership_scenario"],
                    "cost_per_capacity": cost_per_capacity,
                    "aluminium_oxide_emissions": aluminium_oxide_emissions,
                    "sulphur_oxide_emissions": sulphur_oxide_emissions,
                    "carbon_oxide_emissions": carbon_oxide_emissions,
                    "cfc_gases_emissions": cfc_gases_emissions,
                    "particulate_matter_emissions": particulate_matter_emissions,
                    "photochemical_oxidation_emissions": photochemical_oxidation_emissions,
                    "total_emissions_t": total_emissions})

    df = pd.DataFrame.from_dict(results)
    df.to_csv(path + "uq_results.csv") 

data_path = '/Users/osoro/Github/saleos/results/'
results_path = '/Users/osoro/Github/saleos/results/'

def process_mission_results(data_path, results_path):
    """
    Prepare full emission results for the three constellations
    
    """
    df = pd.read_csv(data_path + "uq_results.csv", index_col=False)
    
    #Select the columns to use.
    df = df[['constellation', 'aluminium_oxide_emissions',
       'sulphur_oxide_emissions', 'carbon_oxide_emissions',
       'cfc_gases_emissions', 'particulate_matter_emissions',
       'photochemical_oxidation_emissions']]
    
    #Create new columns to store the results.
    df[["starlink_aluminium_emissions", "starlink_sulphur_emissions", 
    "starlink_carbon_emissions", "starlink_cfc_emissions", 
    "starlink_particulate_emissions", "starlink_oxidation_emissions", 
    "starlink_total_emissions", "oneweb_aluminium_emissions", 
    "oneweb_sulphur_emissions", "oneweb_carbon_emissions", 
    "oneweb_cfc_emissions", "oneweb_particulate_emissions", 
    "oneweb_oxidation_emissions", "oneweb_total_emissions", 
    "kuiper_aluminium_emissions", "kuiper_sulphur_emissions", 
    "kuiper_carbon_emissions", "kuiper_cfc_emissions", 
    "kuiper_particulate_emissions", "kuiper_oxidation_emissions", 
    "kuiper_total_emissions"]] = ""
    
    #Iterate through the rows and store the results.
    for i in range(len(df)):
        if df["constellation"].loc[i] == "Starlink":
            df["starlink_aluminium_emissions"].loc[i] = (df["aluminium_oxide_emissions"].loc[i]) * 74
            df["starlink_sulphur_emissions"].loc[i] = (df["sulphur_oxide_emissions"].loc[i]) * 74
            df["starlink_carbon_emissions"].loc[i] = (df["carbon_oxide_emissions"].loc[i]) * 74
            df["starlink_cfc_emissions"].loc[i] = (df["cfc_gases_emissions"].loc[i]) * 74
            df["starlink_particulate_emissions"].loc[i] = (df["particulate_matter_emissions"].loc[i]) * 74
            df["starlink_oxidation_emissions"].loc[i] = (df["photochemical_oxidation_emissions"].loc[i]) * 74
            df["starlink_total_emissions"].loc[i] = df["starlink_aluminium_emissions"].loc[i] \
                + df["starlink_sulphur_emissions"].loc[i] + df["starlink_carbon_emissions"].loc[i] \
                + df["starlink_cfc_emissions"].loc[i] + df["starlink_particulate_emissions"].loc[i] \
                + df["starlink_oxidation_emissions"].loc[i] 
        elif df["constellation"].loc[i]=="OneWeb":
            df["oneweb_aluminium_emissions"].loc[i] = (df["aluminium_oxide_emissions"].loc[i]) * 20
            df["oneweb_sulphur_emissions"].loc[i] = (df["sulphur_oxide_emissions"].loc[i]) * 20
            df["oneweb_carbon_emissions"].loc[i] = (df["carbon_oxide_emissions"].loc[i]) * 20
            df["oneweb_cfc_emissions"].loc[i] = (df["cfc_gases_emissions"].loc[i]) * 20
            df["oneweb_particulate_emissions"].loc[i] = (df["particulate_matter_emissions"].loc[i]) * 20
            df["oneweb_oxidation_emissions"].loc[i] = (df["photochemical_oxidation_emissions"].loc[i]) * 20
            df["oneweb_total_emissions"].loc[i] = df["oneweb_aluminium_emissions"].loc[i] \
                + df["oneweb_sulphur_emissions"].loc[i] + df["oneweb_carbon_emissions"].loc[i] \
                + df["oneweb_cfc_emissions"].loc[i] + df["oneweb_particulate_emissions"].loc[i] \
                + df["oneweb_oxidation_emissions"].loc[i] 
        elif df["constellation"].loc[i]=="Kuiper":
            df["kuiper_aluminium_emissions"].loc[i] = (df["aluminium_oxide_emissions"].loc[i]) * 54
            df["kuiper_sulphur_emissions"].loc[i] = (df["sulphur_oxide_emissions"].loc[i]) * 54
            df["kuiper_carbon_emissions"].loc[i] = (df["carbon_oxide_emissions"].loc[i]) * 54
            df["kuiper_cfc_emissions"].loc[i] = (df["cfc_gases_emissions"].loc[i]) * 54
            df["kuiper_particulate_emissions"].loc[i] = (df["particulate_matter_emissions"].loc[i]) * 54
            df["kuiper_oxidation_emissions"].loc[i] = (df["photochemical_oxidation_emissions"].loc[i]) * 54
            df["kuiper_total_emissions"].loc[i] = df["kuiper_aluminium_emissions"].loc[i] \
                + df["kuiper_sulphur_emissions"].loc[i] + df["kuiper_carbon_emissions"].loc[i] \
                + df["kuiper_cfc_emissions"].loc[i] + df["kuiper_particulate_emissions"].loc[i] \
                + df["kuiper_oxidation_emissions"].loc[i]
        else:
            break
    store_results = df.to_csv(results_path + "mission_emission_results.csv")
    return store_results
process_mission_results(data_path, results_path)

end = timeit.timeit()
print("Time taken is ", end - start, "seconds")