from __future__ import division
import configparser
import os
import math
import time
from tqdm import tqdm
from numpy import savez_compressed
import pandas as pd

import saleos.sim as sl
from inputs import lut
pd.options.mode.chained_assignment = None #Suppress pandas outdate errors.

start = time.time()
data_path = '/Users/osoro/Github/saleos/results/'
results_path = '/Users/osoro/Github/saleos/results/'

def monthly_traffic(capacity_mbps):
    """ This function calculates the monthly traffic

    Returns
    -------
    traffic : float
            monthly traffic in GB.
    """
    amount = capacity_mbps / (8000 * (1 / 30) * (1 / 3600) * (20 / 100))

    return amount


start = time.time() 

def process_mission_total(data_path, results_path):
    
    df = pd.read_csv(data_path + "uq_results.csv", index_col=False)
    
    #Select the columns to use.
    df = df[["constellation", "constellation_capacity", 
        "capacity_scenario", "capex_costs", "capex_scenario", 
        "subscribers_low", "subscribers_baseline", "subscribers_high",
        "total_opex", "total_cost_ownership", "opex_scenario", 
        "total_global_warming_em", "total_ozone_depletion_em",
        "total_mineral_depletion", 
        "total_freshwater_toxicity", "total_human_toxicity", 
        "total_water_depletion", "total_climate_change"]]

    # Create future columns to use
    df[["mission_number", "total_emissions"]] = ""

    # Process satellite missions       
    for i in tqdm(df.index, desc = "Processing satellite missions"):
        if df["constellation"].loc[i] == "Starlink":
            df["mission_number"].loc[i]=i
            if df["mission_number"].loc[i]<74:
                df["mission_number"].loc[i]=i
            else:
                df["mission_number"].loc[i]=74
        elif df["constellation"].loc[i] == "OneWeb":
            df["mission_number"].loc[i]=i-(2186)
            if df["mission_number"].loc[i]<20:
                df["mission_number"].loc[i]=i-(2186)
            else:
                df["mission_number"].loc[i]=20
        elif df["constellation"].loc[i] == "Kuiper":
            df["mission_number"].loc[i]=i-(4373)
            if df["mission_number"].loc[i]<54:
                df["mission_number"].loc[i]=i-(4373)
            else:
                df["mission_number"].loc[i]=54
        else:
            df["mission_number"].loc[i]= 0
    print("Finished processing satellite missions")

    # Classify subscribers by melting the dataframe into long format
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "capacity_scenario", "total_opex", "capex_costs", "capex_scenario",
        "opex_scenario", "total_cost_ownership", "mission_number", 
        "total_global_warming_em", "total_ozone_depletion_em", 
        "total_mineral_depletion", "total_freshwater_toxicity", 
        "total_human_toxicity", "total_water_depletion", "total_emissions",
        "total_climate_change"], 
        value_vars = ["subscribers_low", "subscribers_baseline", 
        "subscribers_high",], var_name = "subscriber_scenario", 
        value_name = "subscribers")

    # Classify total emissions by impact category
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "capacity_scenario", "total_opex", "capex_costs", "capex_scenario",
        "opex_scenario", "total_cost_ownership", "mission_number", 
        "subscriber_scenario", "subscribers", "total_emissions", 
        "total_climate_change"], 
        value_vars = ["total_global_warming_em", "total_ozone_depletion_em", 
        "total_mineral_depletion", "total_freshwater_toxicity", 
        "total_human_toxicity", "total_water_depletion"], var_name = 
        "impact_category", value_name = "emission_totals")

    # Calculate the total emissions
    for i in tqdm(range(len(df)), desc = "Calculating constellation emission totals".format(i)):
        df["total_emissions"].loc[i] = df["emission_totals"].loc[i] * df["mission_number"].loc[i]
    print("Finished calculating constellation emission totals")

    # Select columns to use
    df = df[['constellation', 'constellation_capacity', 'capacity_scenario',
        'total_opex', 'capex_costs', 'capex_scenario', 'opex_scenario',
        'total_cost_ownership', 'mission_number', 'subscriber_scenario', 
        'subscribers', 'impact_category', 'total_emissions', 
        'total_climate_change']]

    #Create columns to store new data
    df[["capacity_per_user", "emission_per_capacity", "per_cost_emission", 
        "per_subscriber_emission", "capex_per_user", "opex_per_user", 
        "tco_per_user", "capex_per_capacity", "opex_per_capacity", 
        "tco_per_capacity", "monthly_gb", "total_climate_emissions"]] = ""

    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = "Processing constellation aggregate results".format(i)):

        df["capacity_per_user"].loc[i] = df["constellation_capacity"].loc[i] / df["subscribers"].loc[i]

        df["monthly_gb"].loc[i] = monthly_traffic(df["capacity_per_user"].loc[i])

        df["total_climate_emissions"].loc[i] = df["total_climate_change"].loc[i] * df["mission_number"].loc[i]

        df["emission_per_capacity"].loc[i] = df["total_climate_emissions"].loc[i] / df["monthly_gb"].loc[i]
        
        df["per_cost_emission"].loc[i] = df["total_climate_emissions"].loc[i] / df["total_cost_ownership"].loc[i]
                                                    
        df["per_subscriber_emission"].loc[i] = df["total_climate_emissions"].loc[i] / df["subscribers"].loc[i]
        
        df["capex_per_user"].loc[i] = df["capex_costs"].loc[i] / df["subscribers"].loc[i] 
        
        df["opex_per_user"].loc[i] = df["total_opex"].loc[i] / df["subscribers"].loc[i] 
        
        df["tco_per_user"].loc[i] = df["total_cost_ownership"].loc[i] / df["subscribers"].loc[i]
        
        df["capex_per_capacity"].loc[i] = df["capex_costs"].loc[i] / df["monthly_gb"].loc[i]
        
        df["opex_per_capacity"].loc[i] = df["total_opex"].loc[i] / df["monthly_gb"].loc[i]
        
        df["tco_per_capacity"].loc[i] = df["total_cost_ownership"].loc[i] / df["monthly_gb"].loc[i]
         
    store_results = df.to_csv(results_path + "mission_emission_results.csv")
    results_path2 = '/Users/osoro/Github/saleos/vis/'
    store_results = df.to_csv(results_path2 + "mission_emission_results.csv")

    return store_results

process_mission_total(data_path, results_path)
executionTime = (time.time() - start)
print('Execution time in minutes: ' + str(round(executionTime/60, 2)))  