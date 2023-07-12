"""
Simulation model for saleos.

Developed by Bonface Osoro and Ed Oughton.

The emission model is based on the approach by;

[1]. Wilson, Andrew Ross. "Advanced methods of life cycle assessment for space systems." (2019).

[2]. Ross, Martin N., and Patti M. Sheaffer. "Radiative forcing caused by rocket engine emissions." 
     Earth's Future 2.4 (2014): 177-196.

May 2022

"""
import math
import numpy as np
from itertools import tee
from collections import Counter
from collections import OrderedDict

def calc_per_sat_emission(name):
    """
    Calculate the emission amount by 
    category during launch, all in kg.
    
    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':

        emission_dict = falcon_9()  

    elif name == 'Kuiper':

        emission_dict = ariane()

    elif name == 'OneWeb':

        emission_dict = soyuz_fg()

    elif name == 'onewebf9':

        emission_dict = falcon_9()

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_scheduling_emission(name):
    """
    Calculate the emissions due to 
    scheduling of rocket launches
    , all in kg.

    Parameters
    ----------
    name: string
        Name of the constellation.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    if name == 'onewebf9':

        emission_dict0 = propellant_containment()
        emission_list0 = []

        for i in emission_dict0.keys():

            new_emissions = emission_dict0.get(i) * 530
            emission_list0.append(new_emissions)
        emission_dict0 = dict(zip(list(emission_dict0.keys()), emission_list0))

        emission_dict1 = waste_decontamination()
        emission_list1 = []

        for i in emission_dict1.keys():

            new_emissions = emission_dict1.get(i) * 488370
            emission_list1.append(new_emissions)
        emission_list1 = dict(zip(list(emission_dict1.keys()), emission_list1))

        emission_dict2 = propellant_handling()
        emission_list2 = []

        for i in emission_dict2.keys():

            new_emissions = emission_dict2.get(i) * 504
            emission_list2.append(new_emissions)
        emission_list2 = dict(zip(list(emission_dict2.keys()), emission_list2))

        emission_dict3 = propellant_storage()
        emission_list3 = []

        for i in emission_dict3.keys():

            new_emissions = emission_dict3.get(i) * 494
            emission_list3.append(new_emissions)
        emission_list3 = dict(zip(list(emission_dict3.keys()), emission_list3))
        
        cdict1 = Counter(emission_dict0) + Counter(emission_list1)
        cdict2 = Counter(emission_list2) + Counter(emission_list3)
        emission_dict = Counter(cdict1) + Counter(cdict2)

    elif name == 'Starlink':

        emission_dict0 = propellant_containment()
        emission_list0 = []

        for i in emission_dict0.keys():

            new_emissions = emission_dict0.get(i) * 530
            emission_list0.append(new_emissions)
        emission_dict0 = dict(zip(list(emission_dict0.keys()), emission_list0))

        emission_dict1 = waste_decontamination()
        emission_list1 = []

        for i in emission_dict1.keys():
            new_emissions = emission_dict1.get(i) * 488370
            emission_list1.append(new_emissions)
        emission_list1 = dict(zip(list(emission_dict1.keys()), emission_list1))

        emission_dict2 = propellant_handling()
        emission_list2 = []

        for i in emission_dict2.keys():

            new_emissions = emission_dict2.get(i) * 504
            emission_list2.append(new_emissions)
        emission_list2 = dict(zip(list(emission_dict2.keys()), emission_list2))

        emission_dict3 = propellant_storage()
        emission_list3 = []

        for i in emission_dict3.keys():

            new_emissions = emission_dict3.get(i) * 494
            emission_list3.append(new_emissions)
        emission_list3 = dict(zip(list(emission_dict3.keys()), emission_list3))

        cdict1 = Counter(emission_dict0) + Counter(emission_list1)
        cdict2 = Counter(emission_list2) + Counter(emission_list3)
        emission_dict = Counter(cdict1) + Counter(cdict2)

    elif name == 'Kuiper':

        emission_dict0 = propellant_containment()
        emission_list0 = []

        for i in emission_dict0.keys():

            new_emissions = emission_dict0.get(i) * 1148
            emission_list0.append(new_emissions)
        emission_dict0 = dict(zip(list(emission_dict0.keys()), emission_list0))

        emission_dict1 = waste_decontamination()
        emission_list1 = []

        for i in emission_dict1.keys():

            new_emissions = emission_dict1.get(i) * 674900
            emission_list1.append(new_emissions)
        emission_list1 = dict(zip(list(emission_dict1.keys()), emission_list1))

        emission_dict2 = propellant_handling()
        emission_list2 = []

        for i in emission_dict2.keys():

            new_emissions = emission_dict2.get(i) * 504
            emission_list2.append(new_emissions)
        emission_list2 = dict(zip(list(emission_dict2.keys()), emission_list2))

        emission_dict3 = propellant_storage()
        emission_list3 = []

        for i in emission_dict3.keys():

            new_emissions = emission_dict3.get(i) * 1105
            emission_list3.append(new_emissions)
        emission_list3 = dict(zip(list(emission_dict3.keys()), emission_list3))

        cdict1 = Counter(emission_dict0) + Counter(emission_list1)
        cdict2 = Counter(emission_list2) + Counter(emission_list3)
        emission_dict = Counter(cdict1) + Counter(cdict2)

    elif name == 'OneWeb':

        emission_dict0 = propellant_containment()
        emission_list0 = []

        for i in emission_dict0.keys():

            new_emissions = emission_dict0.get(i) * 304
            emission_list0.append(new_emissions)
        emission_dict0 = dict(zip(list(emission_dict0.keys()), emission_list0))

        emission_dict1 = waste_decontamination()
        emission_list1 = []

        for i in emission_dict1.keys():

            new_emissions = emission_dict1.get(i) * 281710
            emission_list1.append(new_emissions)
        emission_list1 = dict(zip(list(emission_dict1.keys()), emission_list1))

        emission_dict2 = propellant_handling()
        emission_list2 = []

        for i in emission_dict2.keys():

            new_emissions = emission_dict2.get(i) * 504
            emission_list2.append(new_emissions)
        emission_list2 = dict(zip(list(emission_dict2.keys()), emission_list2))

        emission_dict3 = propellant_storage()
        emission_list3 = []

        for i in emission_dict3.keys():

            new_emissions = emission_dict3.get(i) * 284
            emission_list3.append(new_emissions)
        emission_list3 = dict(zip(list(emission_dict3.keys()), emission_list3))
        
        cdict1 = Counter(emission_dict0) + Counter(emission_list1)
        cdict2 = Counter(emission_list2) + Counter(emission_list3)
        emission_dict = Counter(cdict1) + Counter(cdict2)

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_transportation_emission(name):
    """
    Calculate the emissions due to 
    transportation of rockets, all in kg.

    Parameters
    ----------
    name: string
        Name of the constellation.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':

        emission_dict = falcon9_transportation()  

    elif name == 'Kuiper':

        emission_dict = ariane_transportation()

    elif name == 'OneWeb':

        emission_dict = soyuzfg_transportation()

    elif name == 'onewebf9':

        emission_dict = falcon9_transportation()  

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_launch_campaign_emission(name):
    """
    Calculate the emissions due to 
    launch campaign, all in kg.

    Parameters
    ----------
    name: string
        Name of the constellation.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':

        emission_dict = launcher_campaign()  

    elif name == 'Kuiper':

        emission_dict = launcher_campaign()

    elif name == 'OneWeb':

        emission_dict = launcher_campaign()

    elif name == 'onewebf9':

        emission_dict = launcher_campaign()  

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_propellant_emission(name):
    """
    calculate the emissions due to 
    propellant production, all in kg.

    Parameters
    ----------
    name: string
        Name of the constellation.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':

        emission_dict = falcon_propellant_production()  

    elif name == 'Kuiper':

        emission_dict = ariane_propellant_production()

    elif name == 'OneWeb':

        emission_dict = soyuzfg_propellant_production()

    elif name == 'onewebf9':

        emission_dict = falcon_propellant_production()  

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_rocket_emission(name):
    """
    Calculate the emissions due to 
    rocket production, all in kg.

    Parameters
    ----------
    name: string
        Name of the constellation.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':

        emission_dict = falcon9_rocket_production()  

    elif name == 'Kuiper':

        emission_dict = ariane_rocket_production()

    elif name == 'OneWeb':

        emission_dict = soyuzfg_rocket_production()

    elif name == 'onewebf9':

        emission_dict = falcon9_rocket_production()  

    else:

        print('Invalid Constellation name')

    return emission_dict


def soyuz_fg():
    """
    Returns the emissions when 
    Soyuz-FG rocket is used, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emissions_dict = {}

    emissions_dict['global_warming'] = 288655.1096

    emissions_dict['global_warming_wc'] = 12031437.19

    emissions_dict['ozone_depletion'] = 3157.14 

    emissions_dict['ozone_depletion_wc'] = 13872.25
    
    emissions_dict['mineral_depletion'] = 0 

    emissions_dict['freshwater_toxicity'] = 0 

    emissions_dict['human_toxicity'] = 0 

    return emissions_dict



def falcon_9():
    """
    Returns the emissions when 
    Falcon-9 rocket is used, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {}

    emission_dict['global_warming'] = 630466.1352  

    emission_dict['global_warming_wc'] = 27266165.94

    emission_dict['ozone_depletion'] = 6837.18

    emission_dict['ozone_depletion_wc'] = 30767.31

    emission_dict['mineral_depletion'] = 0

    emission_dict['freshwater_toxicity'] = 0 

    emission_dict['human_toxicity'] = 0 

    return emission_dict


def ariane():
    """
    Returns the emissions when 
    Ariane-5 is used, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {}

    emission_dict['global_warming'] = 467816.8

    emission_dict['global_warming_wc'] = 107643343.2

    emission_dict['ozone_depletion'] = 86728.6 

    emission_dict['ozone_depletion_wc'] = 211083.6
    
    emission_dict['mineral_depletion'] = 0

    emission_dict['freshwater_toxicity'] = 0 

    emission_dict['human_toxicity'] = 0 

    return emission_dict

def ariane_rocket_production():
    """
    Returns the emissions from 
    production of ariane rocket, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 11018755.48

    emission_dict['ozone_depletion'] = 0.745735051

    emission_dict['mineral_depletion'] = 2719.725687

    emission_dict['freshwater_toxicity'] = 69735037.48

    emission_dict['human_toxicity'] = 4.585385379
    
    return emission_dict


def falcon9_rocket_production():
    """
    Returns the emissions from 
    production of falcon9 rocket
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 4113533.907

    emission_dict['ozone_depletion'] = 0.277478514

    emission_dict['mineral_depletion'] = 1783.337118

    emission_dict['freshwater_toxicity'] = 20253601.64

    emission_dict['human_toxicity'] = 1.51530806
    
    return emission_dict


def soyuzfg_rocket_production():
    """
    Returns the emissions from 
    production of soyuz-fg, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 44680412.98

    emission_dict['ozone_depletion'] = 3.11181773

    emission_dict['mineral_depletion'] = 12473.4086

    emission_dict['freshwater_toxicity'] = 280703930.5

    emission_dict['human_toxicity'] = 19.1361269
    
    return emission_dict


def ariane_propellant_production():
    """
    Returns the emissions from 
    production of ariane propellant
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 4793267.48

    emission_dict['ozone_depletion'] = 0.223292749

    emission_dict['mineral_depletion'] = 34.59642811

    emission_dict['freshwater_toxicity'] = 17124098.34

    emission_dict['human_toxicity'] = 1.520253794
    
    return emission_dict


def falcon_propellant_production():
    """
    Returns the emissions from 
    production of falcon propellant
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 4744753.339

    emission_dict['ozone_depletion'] = 0.546874653

    emission_dict['mineral_depletion'] = 32.92663196

    emission_dict['freshwater_toxicity'] = 15292951.2

    emission_dict['human_toxicity'] = 1.378727964
    
    return emission_dict


def soyuzfg_propellant_production():
    """
    Returns the emissions from 
    production of falcon propellant
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 968910.1994

    emission_dict['ozone_depletion'] = 0.109998823

    emission_dict['mineral_depletion'] = 6.71625049

    emission_dict['freshwater_toxicity'] = 3114043.098

    emission_dict['human_toxicity'] = 0.28140976
    
    return emission_dict


def ariane_transportation():
    """
    calculate the emissions from 
    transportation of ariane, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 11043.18682

    emission_dict['ozone_depletion'] = 0.001892801

    emission_dict['mineral_depletion'] = 0.194786912

    emission_dict['freshwater_toxicity'] = 17341.87779

    emission_dict['human_toxicity'] = 0.001653926
    
    return emission_dict


def falcon9_transportation():
    """
    Returns the emissions from 
    transportation of falcon9, 
    all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 17220.72491

    emission_dict['ozone_depletion'] = 0.003568284

    emission_dict['mineral_depletion'] = 0.83687164

    emission_dict['freshwater_toxicity'] = 47571.20342

    emission_dict['human_toxicity'] = 0.004766684
    
    return emission_dict


def soyuzfg_transportation():
    """
    Returns the emissions from 
    transportation of soyuzfg
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 
    
    emission_dict['global_warming'] = 4328.603808

    emission_dict['ozone_depletion'] = 0.001339551

    emission_dict['mineral_depletion'] = 0.158493574

    emission_dict['freshwater_toxicity'] = 22931.63867

    emission_dict['human_toxicity'] = 0.002580373
    
    return emission_dict


def waste_decontamination():
    """
    Returns the emissions from 
    decontamination of waste 
    treatment, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 8.178531277

    emission_dict['ozone_depletion'] = 0.000000855992

    emission_dict['mineral_depletion'] = 0.000238204

    emission_dict['freshwater_toxicity'] = 47.24602286

    emission_dict['human_toxicity'] = 0.00000283671
    
    return emission_dict


def propellant_handling():
    """
    Returns the emissions 
    from general propellant 
    handling, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 5.277030386

    emission_dict['ozone_depletion'] = 0.00000026525

    emission_dict['mineral_depletion'] = 0.000372566

    emission_dict['freshwater_toxicity'] = 5.984817084

    emission_dict['human_toxicity'] = 0.000000601283
    
    return emission_dict


def propellant_storage():
    """
    Returns the emissions from 
    storage of 1 m^3 propellant
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 5.789177649

    emission_dict['ozone_depletion'] = 0.000000461473

    emission_dict['mineral_depletion'] = 0.000117724

    emission_dict['freshwater_toxicity'] = 22.90504946

    emission_dict['human_toxicity'] = 0.00000206909
    
    return emission_dict


def launcher_AIT():
    """
    Returns the emissions due to 
    assembling, integration and 
    testing (AIT), all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 1616263.557

    emission_dict['ozone_depletion'] = 0.156575296

    emission_dict['mineral_depletion'] = 15.65466435

    emission_dict['freshwater_toxicity'] = 7701094.993

    emission_dict['human_toxicity'] = 0.486234151
    
    return emission_dict


def launcher_campaign():
    """
    Returns the emissions 
    due to 1 launch campaign
    , all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 5666556.742

    emission_dict['ozone_depletion'] = 0.777870405

    emission_dict['mineral_depletion'] = 33.22600998

    emission_dict['freshwater_toxicity'] = 18683396.82

    emission_dict['human_toxicity'] = 1.695861368
    
    return emission_dict


def propellant_containment():
    """
    Returns the emissions from 
    containment of 900 litres of 
    propellant, all in kg.

    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.

    """
    emission_dict = {} 

    emission_dict['global_warming'] = 3010.041736

    emission_dict['ozone_depletion'] = 0.000153001

    emission_dict['mineral_depletion'] = 0.304111566

    emission_dict['freshwater_toxicity'] = 26153.09824

    emission_dict['human_toxicity'] = 0.001972144
    
    return emission_dict