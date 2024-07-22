""""
This script is for calculating the total emissions for a single rocket type 
classified by the impact category.
"""

import configparser
import os
import pandas as pd
import numpy as np
pd.options.mode.chained_assignment = None 

CONFIG = configparser.ConfigParser()
CONFIG.read(os.path.join(os.path.dirname(__file__), 'script_config.ini'))
BASE_PATH = CONFIG['file_locations']['base_path']
RESULTS = os.path.join(BASE_PATH, '..', 'results')

emission_data = os.path.join(RESULTS, 'individual_emissions.csv')
df = pd.read_csv(emission_data)
df = df[df['scenario'] == 'scenario1']
df = df[df['subscriber_scenario'] == 'subscribers_baseline']

df = df[['rocket_detailed', 'scenario', 'no_of_launches', 'subscriber_scenario', 
         'impact_category', 'climate_change_baseline_kg', 
         'ozone_depletion_baseline_kg', 'resource_depletion_kg',
         'freshwater_toxicity_m3', 'human_toxicity']]

df[['climate_change_kg', 'ozone_depletion_kg', 'rct_resource_depletion_kg',
    'rct_freshwater_toxicity_m3', 'rct_human_toxicity']] = ""

df['climate_change_kg'] = (df['climate_change_baseline_kg'] / 
                           df['no_of_launches'])

df['ozone_depletion_kg'] = (df['ozone_depletion_baseline_kg'] / 
                           df['no_of_launches'])

df['rct_resource_depletion_kg'] = (df['resource_depletion_kg'] / 
                           df['no_of_launches'])

df['rct_freshwater_toxicity_m3'] = (df['freshwater_toxicity_m3'] / 
                           df['no_of_launches'])

df['rct_human_toxicity'] = (df['human_toxicity'] / df['no_of_launches'])

df = df[['rocket_detailed','impact_category', 'climate_change_kg', 
         'ozone_depletion_kg', 'rct_resource_depletion_kg', 
         'rct_freshwater_toxicity_m3', 'rct_human_toxicity']]

df = df.drop_duplicates(subset=['impact_category', 'rocket_detailed'])

filename = 'rocket_type_emissions.csv'
path_out = os.path.join(RESULTS, filename)
df.to_csv(path_out, index = False)