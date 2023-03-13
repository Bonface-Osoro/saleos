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

start = time.time() 
def process_mission_total(data_path, results_path):
    
    df = pd.read_csv(data_path + "uq_results.csv", index_col=False)
    
    #Select the columns to use.
    df = df[["constellation", "constellation_capacity", 
        "capacity_scenario", "capex_costs", "capex_scenario", 
        "subscribers_low", "subscribers_baseline", "subscribers_high",
        "total_opex", "total_cost_ownership", "opex_scenario", 
        "emission_for_every_cost", "emission_per_capacity", 
        "emission_per_sqkm", "total_acidification_em", 
        "total_global_warming_em", "total_ozone_depletion_em",
        "total_particulate_em", "total_mineral_depletion", 
        "total_freshwater_toxicity", "total_human_toxicity", 
        "total_water_depletion", "total_emissions_t", 
        "acidification", "particulate_matter_emissions", 
        "mineral_depletion", "freshwater_toxicity", 
        "human_toxicity", "water_depletion", "acidification_schd", 
        "global_warming_schd", "ozone_depletion_schd", 
        "particulate_matter_emissions_schd", "mineral_depletion_schd", 
        "freshwater_toxicity_schd", "human_toxicity_schd", 
        "water_depletion_schd", "acidification_trans", "global_warming_trans", 
        "ozone_depletion_trans", "particulate_matter_emissions_trans", 
        "mineral_depletion_trans", "freshwater_toxicity_trans", 
        "human_toxicity_trans", "water_depletion_trans",
        "acidification_campaign", "global_warming_campaign", 
        "ozone_depletion_campaign", "particulate_matter_emissions_campaign", 
        "mineral_depletion_campaign", "freshwater_toxicity_campaign", 
        "human_toxicity_campaign", "water_depletion_campaign", 
        "acidification_propellant", "global_warming_propellant", 
        "ozone_depletion_propellant", "particulate_matter_emissions_propellant", 
        "mineral_depletion_propellant", "freshwater_toxicity_propellant", 
        "human_toxicity_propellant", "water_depletion_propellant",
        "acidification_ait", "global_warming_ait", "ozone_depletion_ait", 
        "particulate_matter_emissions_ait", "mineral_depletion_ait", 
        "freshwater_toxicity_ait", "human_toxicity_ait", "water_depletion_ait",
        "acidification_roct", "global_warming_roct", "ozone_depletion_roct", 
        "particulate_matter_emissions_roct", "mineral_depletion_roct", 
        "freshwater_toxicity_roct", "human_toxicity_roct", "water_depletion_roct"]]
    
    #Create new columns
    df[["emission_category", "mission_number"]] = ""

    #Process mission number       
    for i in tqdm(df.index, desc = "Processing mission number"):
        if df["constellation"].loc[i] == "Starlink":
            df["mission_number"].loc[i]=i
            if df["mission_number"].loc[i]<74:
                df["mission_number"].loc[i]=i
            else:
                df["mission_number"].loc[i]=74
        elif df["constellation"].loc[i] == "OneWeb":
            df["mission_number"].loc[i]=i-(45929)
            if df["mission_number"].loc[i]<20:
                df["mission_number"].loc[i]=i-(45929)
            else:
                df["mission_number"].loc[i]=20
        elif df["constellation"].loc[i] == "Kuiper":
            df["mission_number"].loc[i]=i-(52490)
            if df["mission_number"].loc[i]<54:
                df["mission_number"].loc[i]=i-(52490)
            else:
                df["mission_number"].loc[i]=54
        else:
            df["mission_number"].loc[i]= 0
    print("Processing mission number completed")
    # Melt the total emissions columns
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "capacity_scenario", "total_emissions_t", "emission_per_capacity", 
        "emission_per_sqkm", "total_opex", "capex_costs", "capex_scenario",
        "opex_scenario", "total_cost_ownership", "emission_for_every_cost",
        "mission_number", "emission_category", "total_acidification_em", 
        "total_global_warming_em", "total_ozone_depletion_em",
        "total_particulate_em", "total_mineral_depletion", 
        "total_freshwater_toxicity", "total_human_toxicity", 
        "total_water_depletion"],
        value_vars = ["subscribers_low", "subscribers_baseline", 
        "subscribers_high",], var_name = "subscriber_scenario", 
        value_name = "subscribers")
    
    # Create new columns
    df[["capacity_per_user", "mission_total_emissions", 
        "mission_emission_per_capacity", "mission_emission_per_sqkm",
        "mission_emission_for_every_cost", "emission_per_subscriber", 
        "capex_per_user","opex_per_user", "tco_per_user", 
        "capex_per_capacity", "opex_per_capacity", "tco_per_capacity"]] = ""

    # Classify total emissions
    for i in tqdm(range(len(df)), desc = 'Processing constellation results'.format(i)):
        df["mission_total_emissions"].loc[i] = df["total_emissions_t"].loc[i] \
                                            * df["mission_number"].loc[i]
        df["mission_emission_per_capacity"].loc[i] = df["emission_per_capacity"].loc[i] \
                                                    * df["mission_number"].loc[i]
        df["mission_emission_per_sqkm"].loc[i] =  df["emission_per_sqkm"].loc[i] \
                                        * df["mission_number"].loc[i]
        df["mission_emission_for_every_cost"].loc[i] = df["emission_for_every_cost"].loc[i] \
                                                    * df["mission_number"].loc[i]
        df["emission_per_subscriber"].loc[i] = df["total_emissions_t"].loc[i] / \
                                            df["subscribers"].loc[i]
        df["capacity_per_user"].loc[i] = df["constellation_capacity"].loc[i] / \
                                        df["subscribers"].loc[i]
        df["capex_per_user"].loc[i] = df["capex_costs"].loc[i] / df["subscribers"].loc[i] 
        df["opex_per_user"].loc[i] = df["total_opex"].loc[i] / df["subscribers"].loc[i]   
        df["tco_per_user"].loc[i] = df["total_cost_ownership"].loc[i] / df["subscribers"].loc[i]
        df["capex_per_capacity"].loc[i] = df["capex_costs"].loc[i] / df["constellation_capacity"].loc[i]
        df["opex_per_capacity"].loc[i] = df["total_opex"].loc[i] / df["constellation_capacity"].loc[i]
        df["tco_per_capacity"].loc[i] = df["total_cost_ownership"].loc[i] / df["constellation_capacity"].loc[i]

    print("Processing constellation results completed")
    # Classify subscribers
    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity", 
        "mission_number",
        "total_cost_ownership", "tco_per_user", "capex_costs",
        "capex_scenario", "capex_per_user", "total_opex",
        "opex_scenario", "opex_per_user", "capex_per_capacity", 
        "opex_per_capacity", "tco_per_capacity", "subscribers", 
        "subscriber_scenario", "mission_total_emissions", 
        "mission_emission_per_capacity", "mission_emission_per_sqkm", 
        "mission_emission_for_every_cost", "emission_per_subscriber",], 
        value_vars = ["total_acidification_em", "total_global_warming_em", 
        "total_ozone_depletion_em", "total_particulate_em", 
        "total_mineral_depletion", "total_freshwater_toxicity", 
        "total_human_toxicity", "total_water_depletion"], var_name = 
        "mission_type_total", value_name = "mission_total")
    
    #Create new columns to store the results.
    for i in tqdm(df.index, desc='Processing total emissions'.format(i)):
        if df["constellation"].loc[i] == "Starlink":
            df["mission_total"].loc[i] = df["mission_total"].loc[i] * 74
        elif df["constellation"].loc[i] == "OneWeb":
            df["mission_total"].loc[i] = df["mission_total"].loc[i] * 20
        else:
            df["mission_total"].loc[i] = df["mission_total"].loc[i] * 54

    print("Processing total emissions completed")

    store_results = df.to_csv(results_path + "mission_emission_results.csv")
    results_path2 = '/Users/osoro/Github/saleos/vis/'
    store_results = df.to_csv(results_path2 + "mission_emission_results.csv")

    return store_results

process_mission_total(data_path, results_path)


def process_individual_emissions(data_path, results_path):

    df = pd.read_csv(data_path + "uq_results.csv", index_col=False)

    df = df[["constellation", "constellation_capacity", 
        "acidification", "particulate_matter_emissions", 
        "mineral_depletion", "freshwater_toxicity", 
        "human_toxicity", "water_depletion", "acidification_schd", 
        "global_warming_schd", "ozone_depletion_schd", 
        "particulate_matter_emissions_schd", "mineral_depletion_schd", 
        "freshwater_toxicity_schd", "human_toxicity_schd", 
        "water_depletion_schd", "acidification_trans", "global_warming_trans", 
        "ozone_depletion_trans", "particulate_matter_emissions_trans", 
        "mineral_depletion_trans", "freshwater_toxicity_trans", 
        "human_toxicity_trans", "water_depletion_trans",
        "acidification_campaign", "global_warming_campaign", 
        "ozone_depletion_campaign", "particulate_matter_emissions_campaign", 
        "mineral_depletion_campaign", "freshwater_toxicity_campaign", 
        "human_toxicity_campaign", "water_depletion_campaign", 
        "acidification_propellant", "global_warming_propellant", 
        "ozone_depletion_propellant", "particulate_matter_emissions_propellant", 
        "mineral_depletion_propellant", "freshwater_toxicity_propellant", 
        "human_toxicity_propellant", "water_depletion_propellant",
        "acidification_ait", "global_warming_ait", "ozone_depletion_ait", 
        "particulate_matter_emissions_ait", "mineral_depletion_ait", 
        "freshwater_toxicity_ait", "human_toxicity_ait", "water_depletion_ait",
        "acidification_roct", "global_warming_roct", "ozone_depletion_roct", 
        "particulate_matter_emissions_roct", "mineral_depletion_roct", 
        "freshwater_toxicity_roct", "human_toxicity_roct", "water_depletion_roct"]]

    df = pd.melt(df, id_vars = ["constellation", "constellation_capacity"], 
        value_vars = ["acidification", "particulate_matter_emissions", 
        "mineral_depletion", "freshwater_toxicity", "human_toxicity", 
        "water_depletion", "acidification_schd", "global_warming_schd", 
        "ozone_depletion_schd", "particulate_matter_emissions_schd", 
        "mineral_depletion_schd", "freshwater_toxicity_schd", 
        "human_toxicity_schd", "water_depletion_schd", "acidification_trans", 
        "global_warming_trans", "ozone_depletion_trans", 
        "particulate_matter_emissions_trans", "mineral_depletion_trans", 
        "freshwater_toxicity_trans", "human_toxicity_trans", 
        "water_depletion_trans", "acidification_campaign", 
        "global_warming_campaign", "ozone_depletion_campaign",
        "particulate_matter_emissions_campaign", "mineral_depletion_campaign", 
        "freshwater_toxicity_campaign", "human_toxicity_campaign", 
        "water_depletion_campaign", "acidification_propellant", 
        "global_warming_propellant", "ozone_depletion_propellant", 
        "particulate_matter_emissions_propellant", "mineral_depletion_propellant",
        "freshwater_toxicity_propellant", "human_toxicity_propellant", 
        "water_depletion_propellant", "acidification_ait", 
        "global_warming_ait", "ozone_depletion_ait", 
        "particulate_matter_emissions_ait", "mineral_depletion_ait", 
        "freshwater_toxicity_ait", "human_toxicity_ait", "water_depletion_ait",
        "acidification_roct", "global_warming_roct", "ozone_depletion_roct", 
        "particulate_matter_emissions_roct", "mineral_depletion_roct", 
        "freshwater_toxicity_roct", "human_toxicity_roct", "water_depletion_roct"],
        var_name = "emissions", value_name = "emissions_amount")

    df[["emission_category", "mission_number"]] = ""   

    for i in tqdm(df.index):
        if "schd" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "scheduling"
        elif "trans" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "transportation"
        elif "campaign" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "campaign"
        elif "propellant" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "propellant_production"
        elif "ait" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "ait"
        elif "roct" in df['emissions'].loc[i]:
            df['emission_category'].loc[i] = "rocket_production"
        else:
            df['emission_category'].loc[i] = "launching"

    print("Processing emissions category completed")   
    for i in tqdm(df.index, desc = 'Processing mission number per individual category'.format(i)):
        if df["constellation"].loc[i] == "Starlink":
            df["mission_number"].loc[i]=i
            if df["mission_number"].loc[i]<74:
                df["mission_number"].loc[i]=i
            else:
                df["mission_number"].loc[i]=74
        elif df["constellation"].loc[i] == "OneWeb":
            df["mission_number"].loc[i]=i-(6560)
            if df["mission_number"].loc[i]<20:
                df["mission_number"].loc[i]=i-(6560)
            else:
                df["mission_number"].loc[i]=20
        elif df["constellation"].loc[i] == "Kuiper":
            df["mission_number"].loc[i]=i-(13121)
            if df["mission_number"].loc[i]<54:
                df["mission_number"].loc[i]=i-(13121)
            else:
                df["mission_number"].loc[i]=54
        else:
            df["mission_number"].loc[i]= 0
    print("Processing mission number for individual emissions completed")
    store_results = df.to_csv(results_path + "individual_emission_results.csv")
    results_path2 = '/Users/osoro/Github/saleos/vis/'
    store_results = df.to_csv(results_path2 + "individual_emission_results.csv")

    return store_results

process_individual_emissions(data_path, results_path)

executionTime = (time.time() - start)
print('Execution time in minutes: ' + str(round(executionTime/60, 2)))