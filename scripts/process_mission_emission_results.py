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

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']

DATA_RAW = os.path.join(BASE_PATH, '..', 'results')
DATA_PROCESSED = os.path.join(BASE_PATH, '..', 'results')

start = time.time()

data_in = os.path.join(DATA_RAW, 'uq_results.csv')

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

def process_mission_total():
    
    df = pd.read_csv(data_in, index_col=False)
    
    #Select the columns to use.
    df = df[["constellation", "constellation_capacity", 
        "capacity_scenario", "capex_costs", "capex_scenario", "satellite_coverage_area_km",
        "subscribers_low", "subscribers_baseline", "subscribers_high",
        "total_opex", "total_cost_ownership", "opex_scenario", 
        "total_global_warming_em", "total_ozone_depletion_em",
        "total_mineral_depletion", "total_climate_change_wc",
        "total_freshwater_toxicity", "total_human_toxicity", 
        "total_climate_change", "oneweb_f9", "oneweb_sz"]]

    # Create future columns to use
    df[["mission_number", "mission_number_1", "total_emissions"]] = ""

    # Process satellite missions       
    for i in tqdm(df.index, desc = "Processing satellite missions"):
        if df["constellation"].loc[i] == "Starlink":
            df["mission_number"].loc[i]=i+1
            df["mission_number_1"].loc[i]=i*0
            if df["mission_number"].loc[i]<74:
                df["mission_number"].loc[i]=i+1
                df["mission_number_1"].loc[i]=i*0
            else:
                df["mission_number"].loc[i]=74
                df["mission_number_1"].loc[i]=i*0
        elif df["constellation"].loc[i] == "OneWeb":
            df["mission_number"].loc[i]=i-(2186)
            df["mission_number_1"].loc[i]=i-(2186)
            if df["mission_number"].loc[i]<11:
                df["mission_number"].loc[i]=i-(2186)
                df["mission_number_1"].loc[i]=i-(2186)
            else:
                df["mission_number"].loc[i]=11
                df["mission_number_1"].loc[i]=7
        elif df["constellation"].loc[i] == "Kuiper":
            df["mission_number"].loc[i]=i-(4373)
            df["mission_number_1"].loc[i]=i*0
            if df["mission_number"].loc[i]<54:
                df["mission_number"].loc[i]=i-(4373)
                df["mission_number_1"].loc[i]=i*0
            else:
                df["mission_number"].loc[i]=54
                df["mission_number_1"].loc[i]=i*0
        else:
            df["mission_number"].loc[i]= 0
    print("Finished processing satellite missions")

    # Classify subscribers by melting the dataframe into long format
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "capacity_scenario", "total_opex", "capex_costs", "capex_scenario", "satellite_coverage_area_km",
        "opex_scenario", "total_cost_ownership", "mission_number", "mission_number_1", 
        "total_global_warming_em", "total_ozone_depletion_em", 
        "total_mineral_depletion", "total_freshwater_toxicity", 
        "total_human_toxicity", "total_emissions",
        "total_climate_change", "total_climate_change_wc", "oneweb_f9", "oneweb_sz"], 
        value_vars = ["subscribers_low", "subscribers_baseline", 
        "subscribers_high",], var_name = "subscriber_scenario", 
        value_name = "subscribers")

    # Classify total emissions by impact category
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "capacity_scenario", "total_opex", "capex_costs", "capex_scenario", "satellite_coverage_area_km",
        "opex_scenario", "total_cost_ownership", "mission_number", "mission_number_1",
        "subscriber_scenario", "subscribers", "total_emissions", 
        "total_climate_change", "total_climate_change_wc", "oneweb_f9", "oneweb_sz"], 
        value_vars = ["total_global_warming_em", "total_ozone_depletion_em", 
        "total_mineral_depletion", "total_freshwater_toxicity", 
        "total_human_toxicity"], var_name = 
        "impact_category", value_name = "emission_totals")

    # Calculate the total emissions
    for i in tqdm(range(len(df)), desc = "Calculating constellation emission totals".format(i)):

        if df["constellation"].loc[i] == "Starlink" or df["constellation"].loc[i] == "Kuiper":
            df["total_emissions"].loc[i] = df["emission_totals"].loc[i] * df["mission_number"].loc[i]
        else:
            df["total_emissions"].loc[i] = (df["oneweb_sz"].loc[i] * df["mission_number"].loc[i]) + \
            (df["oneweb_f9"].loc[i] * df["mission_number_1"].loc[i])
    print("Finished calculating constellation emission totals")

    # Select columns to use
    df = df[['constellation', 'constellation_capacity', 'capacity_scenario','satellite_coverage_area_km',
        'total_opex', 'capex_costs', 'capex_scenario', 'opex_scenario',
        'total_cost_ownership', 'mission_number', 'mission_number_1', 'subscriber_scenario', 
        'subscribers', 'impact_category', 'total_emissions', "oneweb_f9", "oneweb_sz",
        'total_climate_change', 'total_climate_change_wc']]

    #Create columns to store new data
    df[["capacity_per_user", "emission_per_capacity", "per_cost_emission", 
        "per_subscriber_emission", "capex_per_user", "opex_per_user", 
        "tco_per_user", "capex_per_capacity", "opex_per_capacity", 
        "tco_per_capacity", "monthly_gb", "total_climate_emissions",
        "total_climate_emissions_wc", "user_per_area"]] = ""

    # Calculate total metrics
    for i in tqdm(range(len(df)), desc = "Processing constellation aggregate results".format(i)):

        df["capacity_per_user"].loc[i] = (df["constellation_capacity"].loc[i] * 0.65 * 0.5) / df["subscribers"].loc[i]

        df["monthly_gb"].loc[i] = (monthly_traffic(df["capacity_per_user"].loc[i]))/(5 * 12)

        df["total_climate_emissions"].loc[i] = df["total_climate_change"].loc[i] * df["mission_number"].loc[i]

        df["total_climate_emissions_wc"].loc[i] = df["total_climate_change_wc"].loc[i] * df["mission_number"].loc[i]

        df["emission_per_capacity"].loc[i] = df["total_climate_emissions"].loc[i] / (df["monthly_gb"].loc[i] * 12)
        
        df["per_cost_emission"].loc[i] = df["total_climate_emissions"].loc[i] / df["total_cost_ownership"].loc[i]
                                                    
        df["per_subscriber_emission"].loc[i] = df["total_climate_emissions"].loc[i] / df["subscribers"].loc[i]
        
        df["capex_per_user"].loc[i] = df["capex_costs"].loc[i] / df["subscribers"].loc[i] 
        
        df["opex_per_user"].loc[i] = df["total_opex"].loc[i] / df["subscribers"].loc[i] 
        
        df["tco_per_user"].loc[i] = df["total_cost_ownership"].loc[i] / df["subscribers"].loc[i]
        
        df["capex_per_capacity"].loc[i] = df["capex_costs"].loc[i] / df["monthly_gb"].loc[i]
        
        df["opex_per_capacity"].loc[i] = df["total_opex"].loc[i] / df["monthly_gb"].loc[i]
        
        df["tco_per_capacity"].loc[i] = df["total_cost_ownership"].loc[i] / df["monthly_gb"].loc[i]

        df["user_per_area"].loc[i] = df["subscribers"].loc[i] / df["satellite_coverage_area_km"].loc[i]

    filename = 'mission_emission_results.csv'

    if not os.path.exists(DATA_PROCESSED):
        os.makedirs(DATA_PROCESSED)

    path_out = os.path.join(DATA_PROCESSED, filename)
    df.to_csv(path_out)

    return None

process_mission_total()
executionTime = (time.time() - start)
print('Execution time in minutes: ' + str(round(executionTime/60, 2)))  
