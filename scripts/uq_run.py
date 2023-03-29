"""
Simulation run script for saleos.

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
from __future__ import division
import configparser
import os
import math
import time
from numpy import savez_compressed
import pandas as pd

import saleos.sim as sl
from inputs import lut
from tqdm import tqdm
pd.options.mode.chained_assignment = None #Suppress pandas outdate errors.

#Import the data.
start = time.time() 
data_path = "/Users/osoro/Github/saleos/data/"
df = pd.read_csv(data_path + "uq_parameters.csv")
uq_dict = df.to_dict('records') #Convert the csv to list

path = "/Users/osoro/Github/saleos/results/"
results = []
for item in tqdm(uq_dict, desc = "Processing uncertainity results"):
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

    emission_dict = sl.calc_per_sat_emission(item["constellation"])
    
    scheduling_dict = sl.calc_scheduling_emission(item["constellation"])

    transport_dict = sl.calc_transportation_emission(item["constellation"])

    launch_campaign_dict = sl.calc_launch_campaign_emission(item["constellation"])

    propellant_dict = sl.calc_propellant_emission(item["constellation"])

    ait_dict = sl.launcher_AIT()

    rocket_dict = sl.calc_rocket_emission(item["constellation"])

    total_cost_ownership = sl.cost_model(item["satellite_manufacturing"], item["satellite_launch_cost"], item["ground_station_cost"], 
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

    acidification = emission_dict['acidification']
    global_warming = emission_dict['global_warming']
    ozone_depletion = emission_dict['ozone_depletion']
    particulate_matter_emissions = emission_dict['particulate_matter']
    mineral_depletion = emission_dict['mineral_depletion']
    freshwater_toxicity = emission_dict['freshwater_toxicity']
    human_toxicity = emission_dict['human_toxicity']
    water_depletion = emission_dict['water_depletion']

    acidification_schd = scheduling_dict['acidification']
    global_warming_schd =  scheduling_dict['global_warming']
    ozone_depletion_schd = scheduling_dict['ozone_depletion']
    particulate_matter_emissions_schd = scheduling_dict['particulate_matter']
    mineral_depletion_schd = scheduling_dict['mineral_depletion']
    freshwater_toxicity_schd = scheduling_dict['freshwater_toxicity']
    human_toxicity_schd = scheduling_dict['human_toxicity']
    water_depletion_schd = scheduling_dict['water_depletion']

    acidification_trans = transport_dict['acidification']
    global_warming_trans =  transport_dict['global_warming']
    ozone_depletion_trans = transport_dict['ozone_depletion']
    particulate_matter_emissions_trans = transport_dict['particulate_matter']
    mineral_depletion_trans = transport_dict['mineral_depletion']
    freshwater_toxicity_trans = transport_dict['freshwater_toxicity']
    human_toxicity_trans = transport_dict['human_toxicity']
    water_depletion_trans = transport_dict['water_depletion']

    acidification_campaign = launch_campaign_dict['acidification']
    global_warming_campaign =  launch_campaign_dict['global_warming']
    ozone_depletion_campaign = launch_campaign_dict['ozone_depletion']
    particulate_matter_emissions_campaign = launch_campaign_dict['particulate_matter']
    mineral_depletion_campaign = launch_campaign_dict['mineral_depletion']
    freshwater_toxicity_campaign = launch_campaign_dict['freshwater_toxicity']
    human_toxicity_campaign = launch_campaign_dict['human_toxicity']
    water_depletion_campaign = launch_campaign_dict['water_depletion']

    acidification_propellant = propellant_dict['acidification']
    global_warming_propellant =  propellant_dict['global_warming']
    ozone_depletion_propellant = propellant_dict['ozone_depletion']
    particulate_matter_emissions_propellant = propellant_dict['particulate_matter']
    mineral_depletion_propellant = propellant_dict['mineral_depletion']
    freshwater_toxicity_propellant = propellant_dict['freshwater_toxicity']
    human_toxicity_propellant = propellant_dict['human_toxicity']
    water_depletion_propellant = propellant_dict['water_depletion']

    acidification_ait = ait_dict['acidification']
    global_warming_ait =  ait_dict['global_warming']
    ozone_depletion_ait = ait_dict['ozone_depletion']
    particulate_matter_emissions_ait = ait_dict['particulate_matter']
    mineral_depletion_ait = ait_dict['mineral_depletion']
    freshwater_toxicity_ait = ait_dict['freshwater_toxicity']
    human_toxicity_ait = ait_dict['human_toxicity']
    water_depletion_ait = ait_dict['water_depletion']

    acidification_roct = rocket_dict['acidification']
    global_warming_roct =  rocket_dict['global_warming']
    ozone_depletion_roct = rocket_dict['ozone_depletion']
    particulate_matter_emissions_roct = rocket_dict['particulate_matter']
    mineral_depletion_roct = rocket_dict['mineral_depletion']
    freshwater_toxicity_roct = rocket_dict['freshwater_toxicity']
    human_toxicity_roct = rocket_dict['human_toxicity']
    water_depletion_roct = rocket_dict['water_depletion']

    total_acidification_em = acidification + acidification_schd + acidification_trans + \
                             acidification_campaign + acidification_propellant + \
                             acidification_ait + acidification_roct
    
    total_global_warming_em = global_warming + global_warming_schd + global_warming_trans + \
                              global_warming_campaign + global_warming_propellant + \
                              global_warming_ait + global_warming_roct
    
    total_ozone_depletion_em = ozone_depletion + ozone_depletion_schd + ozone_depletion_trans + \
                               ozone_depletion_campaign + ozone_depletion_propellant + \
                               ozone_depletion_ait + ozone_depletion_roct
    
    total_particulate_em = particulate_matter_emissions + particulate_matter_emissions_schd + \
                           particulate_matter_emissions_trans + particulate_matter_emissions_campaign + \
                           particulate_matter_emissions_propellant + particulate_matter_emissions_ait + \
                           particulate_matter_emissions_roct
    
    total_mineral_depletion = mineral_depletion + mineral_depletion_schd + mineral_depletion_trans + \
                              mineral_depletion_campaign + mineral_depletion_propellant + \
                              mineral_depletion_ait + mineral_depletion_roct
    
    total_freshwater_toxicity = freshwater_toxicity + freshwater_toxicity_schd + \
                                freshwater_toxicity_trans + freshwater_toxicity_campaign + \
                                freshwater_toxicity_propellant +  freshwater_toxicity_ait + \
                                freshwater_toxicity_roct

    total_human_toxicity = human_toxicity + human_toxicity_schd + human_toxicity_trans + \
                           human_toxicity_campaign + human_toxicity_propellant + \
                           human_toxicity_ait + human_toxicity_roct

    total_water_depletion = water_depletion + water_depletion_schd + water_depletion_trans + \
                            water_depletion_campaign + water_depletion_propellant + \
                            water_depletion_ait + water_depletion_roct

    total_emissions = total_global_warming_em  


    results.append({"constellation": constellation, 
                    "signal_path": distance,
                    "altitude_km": item["altitude_km"],
                    "signal_path_scenario": item["altitude_scenario"],
                    "satellite_coverage_area_km": satellite_coverage_area_km,
                    "dl_frequency_Hz": item["dl_frequency_Hz"],
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
                    "capex_costs": item["capex_costs"],
                    "capex_scenario": item["capex_scenario"],
                    "cost_per_capacity": cost_per_capacity,
                    "cost_scenario": cost_scenario,
                    "total_opex": item["opex_costs"],
                    "opex_scenario": item["opex_scenario"],
                    "acidification": acidification,
                    "global_warming": global_warming,
                    "ozone_depletion": ozone_depletion,
                    "particulate_matter_emissions": particulate_matter_emissions,
                    "mineral_depletion": mineral_depletion,
                    "freshwater_toxicity": freshwater_toxicity,
                    "human_toxicity": human_toxicity,
                    "water_depletion": water_depletion,
                    "acidification_schd": acidification_schd,
                    "global_warming_schd": global_warming_schd,
                    "ozone_depletion_schd": ozone_depletion_schd,
                    "particulate_matter_emissions_schd": particulate_matter_emissions_schd,
                    "mineral_depletion_schd": mineral_depletion_schd,
                    "freshwater_toxicity_schd": freshwater_toxicity_schd,
                    "human_toxicity_schd": human_toxicity_schd,
                    "water_depletion_schd": water_depletion_schd,
                    "acidification_trans": acidification_trans,
                    "global_warming_trans": global_warming_trans,
                    "ozone_depletion_trans": ozone_depletion_trans, 
                    "particulate_matter_emissions_trans": particulate_matter_emissions_trans,
                    "mineral_depletion_trans": mineral_depletion_trans, 
                    "freshwater_toxicity_trans": freshwater_toxicity_trans, 
                    "human_toxicity_trans": human_toxicity_trans, 
                    "water_depletion_trans": water_depletion_trans, 
                    "acidification_campaign": acidification_campaign, 
                    "global_warming_campaign": global_warming_campaign,
                    "ozone_depletion_campaign": ozone_depletion_campaign, 
                    "particulate_matter_emissions_campaign": particulate_matter_emissions_campaign, 
                    "mineral_depletion_campaign": mineral_depletion_campaign, 
                    "freshwater_toxicity_campaign": freshwater_toxicity_campaign, 
                    "human_toxicity_campaign": human_toxicity_campaign, 
                    "water_depletion_campaign": water_depletion_campaign, 
                    "acidification_propellant": acidification_propellant, 
                    "global_warming_propellant": global_warming_propellant, 
                    "ozone_depletion_propellant": ozone_depletion_propellant, 
                    "particulate_matter_emissions_propellant":particulate_matter_emissions_propellant,
                    "mineral_depletion_propellant": mineral_depletion_propellant, 
                    "freshwater_toxicity_propellant": freshwater_toxicity_propellant, 
                    "human_toxicity_propellant": human_toxicity_propellant, 
                    "water_depletion_propellant": water_depletion_propellant, 
                    "acidification_ait": acidification_ait, 
                    "global_warming_ait": global_warming_ait, 
                    "ozone_depletion_ait": ozone_depletion_ait, 
                    "particulate_matter_emissions_ait": particulate_matter_emissions_ait, 
                    "mineral_depletion_ait": mineral_depletion_ait,
                    "freshwater_toxicity_ait": freshwater_toxicity_ait,
                    "human_toxicity_ait": human_toxicity_ait, 
                    "water_depletion_ait": water_depletion_ait, 
                    "acidification_roct": acidification_roct, 
                    "global_warming_roct": global_warming_roct, 
                    "ozone_depletion_roct": ozone_depletion_roct, 
                    "particulate_matter_emissions_roct": particulate_matter_emissions_roct, 
                    "mineral_depletion_roct": mineral_depletion_roct, 
                    "freshwater_toxicity_roct": freshwater_toxicity_roct, 
                    "human_toxicity_roct": human_toxicity_roct, 
                    "water_depletion_roct": water_depletion_roct, 
                    "total_acidification_em": total_acidification_em,
                    "total_global_warming_em": total_global_warming_em,
                    "total_ozone_depletion_em": total_ozone_depletion_em,
                    "total_particulate_em": total_particulate_em,
                    "total_mineral_depletion": total_mineral_depletion,
                    "total_freshwater_toxicity": total_freshwater_toxicity,
                    "total_human_toxicity": total_human_toxicity,
                    "total_water_depletion": total_water_depletion,
                    "total_climate_change": total_emissions
                    })

    df = pd.DataFrame.from_dict(results)
    df.to_csv(path + "uq_results.csv") 
    results_path2 = '/Users/osoro/Github/saleos/vis/'
    store_results = df.to_csv(results_path2 + "uq_results.csv")

executionTime = (time.time() - start)
print('Execution time in minutes: ' + str(round(executionTime/60, 2))) 