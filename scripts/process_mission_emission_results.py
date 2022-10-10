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

data_path = '/Users/osoro/Github/saleos/results/'
results_path = '/Users/osoro/Github/saleos/results/'

def process_mission_number(data_path, results_path):
    
    df = pd.read_csv(data_path + "uq_results.csv", index_col=False)
    
    #Select the columns to use.

    df = df[["constellation", "constellation_capacity", "capacity_scenario", "subscribers_low", \
        "subscribers_baseline", "subscribers_high", "total_emissions_t", "emission_per_capacity", \
        "emission_per_sqkm", "emission_for_every_cost", "capex_costs", "total_opex", "opex_scenario",
        "total_cost_ownership", "capex_scenario"]]

    df = pd.melt(df, id_vars=["constellation", "constellation_capacity", "capacity_scenario", \
        "total_emissions_t", "emission_per_capacity", "emission_per_sqkm", "emission_for_every_cost",
        "capex_costs", "total_opex", "opex_scenario", "total_cost_ownership", "capex_scenario"],
         value_vars=["subscribers_low", "subscribers_baseline", "subscribers_high"])

    df.columns = ["constellation", "constellation_capacity", "capacity_scenario", "total_emissions_t", \
                "emission_per_capacity", "emission_per_sqkm", "emission_for_every_cost", "capex_costs","total_opex", \
                "opex_scenario", "total_cost_ownership", "capex_scenario", "subscriber_scenario", "subscribers"]
   
    
    #Create new columns to store the results.

    df[["mission_number", "capacity_per_user", "mission_total_emissions", "mission_emission_per_capacity", 
    "mission_emission_per_sqkm", "mission_emission_for_every_cost", "emission_per_subscriber",
    "capex_per_user","opex_per_user", "tco_per_user"]] = " "
    
    # Generate mission number for each constellation.

    for i in df.index:
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
    # Rename subscriber scenario

    for i in range(len(df)):
        if df["subscriber_scenario"].loc[i] == "subscribers_low":
            df["subscriber_scenario"].loc[i] = "Low"
        elif df["subscriber_scenario"].loc[i] == "subscribers_baseline":
            df["subscriber_scenario"].loc[i] = "Baseline"
        else:
            df["subscriber_scenario"].loc[i] = "High"

    # Calculate the mission emission results for each constellation.

    for i in range(len(df)):
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

    store_results = df.to_csv(results_path + "mission_emission_results.csv")
    results_path2 = '/Users/osoro/Github/saleos/vis/'
    store_results = df.to_csv(results_path2 + "mission_emission_results.csv")

    return store_results

process_mission_number(data_path, results_path)