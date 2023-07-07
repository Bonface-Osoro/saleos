"""
Simulation model for saleos.

Developed by Bonface Osoro and Ed Oughton.

May 2022

"""
import math
import numpy as np
from itertools import tee
from collections import Counter
from collections import OrderedDict


def calc_geographic_metrics(number_of_satellites, params):
    """
    Calculate geographic metrics, including (i) the distance between the transmitter
    and reciever, and (ii) the coverage area for each satellite.

    Parameters
    ----------
    number_of_satellites : int
        Number of satellites in the contellation being simulated.
    params : dict
        Contains all simulation parameters.

    Returns
    -------
    distance : float
        The distance between the transmitter and reciever in km.
    satellite_coverage_area_km : float
        The area which each satellite covers on Earth's surface in km.

    """
    area_of_earth_covered = params['total_area_earth_km_sq']

    network_density = number_of_satellites / area_of_earth_covered

    satellite_coverage_area_km = (area_of_earth_covered / number_of_satellites) 

    mean_distance_between_assets = math.sqrt((1 / network_density)) / 2

    distance = math.sqrt(((mean_distance_between_assets) ** 2) + ((params['altitude_km']) ** 2))

    return distance, satellite_coverage_area_km


def calc_free_space_path_loss(distance, params, i, random_variations):
    """
    Calculate the free space path loss in decibels.

    FSPL(dB) = 20log(d) + 20log(f) + 32.44

    Where distance (d) is in km and frequency (f) is MHz.

    Parameters
    ----------
    distance : float
        Distance between transmitter and receiver in metres.
    params : dict
        Contains all simulation parameters.
    i : int
        Iteration number.
    random_variation : list
        List of random variation components.

    Returns
    -------
    path_loss : float
        The free space path loss over the given distance.
    random_variation : float
        Stochastic component.
    """
    frequency_MHz = params['dl_frequency'] / 1e6

    path_loss = 20 * math.log10(distance) + 20 * math.log10(frequency_MHz) + 32.44

    random_variation = random_variations[i]

    return path_loss + random_variation, random_variation


def generate_log_normal_dist_value(frequency, mu, sigma, seed_value, draws):
    """
    Generates random values using a lognormal distribution, given a specific mean (mu)
    and standard deviation (sigma).

    Original function in pysim5G/path_loss.py.

    The parameters mu and sigma in np.random.lognormal are not the mean and STD of the
    lognormal distribution. They are the mean and STD of the underlying normal distribution.

    Parameters
    ----------
    frequency : float
        Carrier frequency value in Hertz.
    mu : int
        Mean of the desired distribution.
    sigma : int
        Standard deviation of the desired distribution.
    seed_value : int
        Starting point for pseudo-random number generator.
    draws : int
        Number of required values.

    Returns
    -------
    random_variation : float
        Mean of the random variation over the specified itations.

    """
    if seed_value == None:
        pass
    else:
        frequency_seed_value = seed_value * frequency * 100
        np.random.seed(int(str(frequency_seed_value)[:2]))

    normal_std = np.sqrt(np.log10(1 + (sigma/mu) ** 2))
    normal_mean = np.log10(mu) - normal_std ** 2 / 2

    random_variation  = np.random.lognormal(normal_mean, normal_std, draws)

    return random_variation


def calc_antenna_gain(c, d, f, n):
    """
    Calculates the antenna gain.

    Parameters
    ----------
    c : float
        Speed of light in meters per second (m/s).
    d : float
        Antenna diameter in meters.
    f : int
        Carrier frequency in Hertz.
    n : float
        Antenna efficiency.

    Returns
    -------
    antenna_gain : float
        Antenna gain in dB.

    """
    #Define signal wavelength
    lambda_wavelength = c / f

    #Calculate antenna_gain
    antenna_gain = 10 * (math.log10(n * ((np.pi * d) / lambda_wavelength) ** 2))

    return antenna_gain


def calc_eirp(power, antenna_gain):
    """
    Calculate the Equivalent Isotropically Radiated Power.

    Equivalent Isotropically Radiated Power (EIRP) = (
        Power + Gain
    )

    Parameters
    ----------
    power : float
        Transmitter power in watts.
    antenna_gain : float
        Antenna gain in dB.
    losses : float
        Antenna losses in dB.

    Returns
    -------
    eirp : float
        eirp in dB.

    """
    eirp = power + antenna_gain

    return eirp


def calc_losses(earth_atmospheric_losses, all_other_losses):
    """
    Estimates the transmission signal losses.

    Parameters
    ----------
    earth_atmospheric_losses : int
        Signal losses from rain attenuation.
    all_other_losses : float
        All other signal losses.

    Returns
    -------
    losses : float
        The estimated transmission signal losses.

    """
    losses = earth_atmospheric_losses + all_other_losses

    return losses


def calc_received_power(eirp, path_loss, receiver_gain, losses):
    """
    Calculates the power received at the User Equipment (UE).

    Parameters
    ----------
    eirp : float
        The Equivalent Isotropically Radiated Power in dB.
    path_loss : float
        The free space path loss over the given distance.
    receiver_gain : float
        Antenna gain at the receiver.
    losses : float
        Transmission signal losses.

    Returns
    -------
    received_power : float
        The received power at the receiver in dB.

    """
    received_power = eirp + receiver_gain - path_loss - losses

    return received_power


def calc_noise():
    """
    Estimates the potential noise.

    Terminal noise can be calculated as:

    “K (Boltzmann constant) x T (290K) x bandwidth”.

    The bandwidth depends on bit rate, which defines the number
    of resource blocks. We assume 50 resource blocks, equal 9 MHz,
    transmission for 1 Mbps downlink.

    Required SNR (dB)
    Detection bandwidth (BW) (Hz)
    k = Boltzmann constant
    T = Temperature (Kelvins) (290 Kelvin = ~16 degrees celcius)
    NF = Receiver noise figure (dB)

    NoiseFloor (dBm) = 10log10(k * T * 1000) + NF + 10log10BW

    NoiseFloor (dBm) = (
        10log10(1.38 x 10e-23 * 290 * 1x10e3) + 1.5 + 10log10(10 x 10e6)
    )

    Parameters
    ----------
    bandwidth : int
        The bandwidth of the carrier frequency (MHz).

    Returns
    -------
    noise : float
        Received noise at the UE receiver in dB.

    """
    k = 1.38e-23 #Boltzmann's constant k = 1.38×10−23 joules per kelvin
    t = 290 #Temperature of the receiver system T0 in kelvins
    b = 0.25 #Detection bandwidth (BW) in Hz

    noise = (10 * (math.log10((k * t * 1000)))) + (10 * (math.log10(b * 10 ** 9)))

    return noise


def calc_cnr(received_power, noise):
    """
    Calculate the Carrier-to-Noise Ratio (CNR).

    Returns
    -------
    received_power : float
        The received signal power at the receiver in dB.
    noise : float
        Received noise at the UE receiver in dB.

    Returns
    -------
    cnr : float
        Carrier-to-Noise Ratio (CNR) in dB.

    """
    cnr = received_power - noise

    return cnr


def calc_spectral_efficiency(cnr, lut):
    """
    Given a cnr, find the spectral efficiency.

    Parameters
    ----------
    cnr : float
        Carrier-to-Noise Ratio (CNR) in dB.
    lut : list of tuples
        Lookup table for CNR to spectral efficiency.

    Returns
    -------
    spectral_efficiency : float
        The number of bits per Hertz able to be transmitted.

    """
    for lower, upper in pairwise(lut):

        lower_cnr, lower_se  = lower
        upper_cnr, upper_se  = upper

        if cnr >= lower_cnr and cnr < upper_cnr:
            spectral_efficiency = lower_se
            return spectral_efficiency

        highest_value = lut[-1]

        if cnr >= highest_value[0]:
            spectral_efficiency = highest_value[1]
            return spectral_efficiency

        lowest_value = lut[0]

        if cnr < lowest_value[0]:
            spectral_efficiency = lowest_value[1]
            return spectral_efficiency


def calc_capacity(spectral_efficiency, dl_bandwidth):
    """
    Calculate the channel capacity.

    Parameters
    ----------
    spectral_efficiency : float
        The number of bits per Hertz able to be transmitted.
    dl_bandwidth: float
        The channel bandwidth in Hertz.

    Returns
    -------
    channel_capacity : float
        The channel capacity in Mbps.

    """
    channel_capacity = spectral_efficiency * dl_bandwidth / (10 ** 6)

    return channel_capacity


def single_satellite_capacity(dl_bandwidth, spectral_efficiency,
    number_of_channels, polarization):
    """
    Calculate the capacity of each satellite.

    Parameters
    ----------
    dl_bandwidth :
        Bandwidth in MHz.
    spectral_efficiency :
        Spectral efficiency 64QAM equivalent to 5.1152,
        assuming every constellation uses 64QAM
    number_of_channels :
        ...
    number_of_channels :
        ...

    Returns
    -------
    sat_capacity : ...
        Satellite capacity.

    """
    sat_capacity = (
        (dl_bandwidth / 1000000) *
        spectral_efficiency *
        number_of_channels *
        polarization
    )

    return sat_capacity


def calc_agg_capacity(channel_capacity, number_of_channels, polarization):
    """
    Calculate the aggregate capacity.

    Parameters
    ----------
    channel_capacity : float
        The channel capacity in Mbps.
    number_of_channels : int
        The number of user channels per satellite.

    Returns
    -------
    agg_capacity : float
        The aggregate capacity in Mbps.

    """
    agg_capacity = channel_capacity * number_of_channels * polarization

    return agg_capacity


def pairwise(iterable):
    """
    Return iterable of 2-tuples in a sliding window.

    Parameters
    ----------
    iterable: list
        Sliding window

    Returns
    -------
    list of tuple
        Iterable of 2-tuples

    Example
    -------
    >>> list(pairwise([1,2,3,4]))
        [(1,2),(2,3),(3,4)]

    """
    a, b = tee(iterable)
    next(b, None)

    return zip(a, b)


def calc_per_sat_emission(name):
    """
    calculate the emission amount by 
    category during launch.

    Parameters
    ----------
    name: string
        Name of the constellation.
    fuel_mass: int
        mass of kerosene used by the rockets in kilograms.
    fuel_mass_1: int
        mass of hypergolic fuel used by the rockets in kilograms.
    fuel_mass_2: int
        mass of solid fuel used by the rockets in kilogram.
    fuel_mass_3: int
        mass of cryogenic fuel used by the rockets in kilogram.
    
    Returns
    -------
    emission_dict: dict.
        Emission amounts grouped into global warming 
        (baseline and worst case), ozone depletion 
        (baseline and worst case), resource depletion, 
        freshwater toxicity and human toxicity.
    """

    if name == 'Starlink':
        emission_dict = falcon_9()  # Emission per satellite

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
    Calculate the emissions due to scheduling of rocket launches.

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
    Calculate the emissions due to transportation of rockets.

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

        emission_dict = falcon9_transportation()  # Emission per satellite

    elif name == 'Kuiper':

        emission_dict = ariane_transportation()

    elif name == 'OneWeb':

        emission_dict = soyuzfg_transportation()

    elif name == 'onewebf9':

        emission_dict = falcon9_transportation()  # Emission per satellite

    else:

        print('Invalid Constellation name')

    return emission_dict


def calc_launch_campaign_emission(name):
    """
    Calculate the emissions due to launch campaign.

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

        emission_dict = launcher_campaign()  # Emission per satellite

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
    propellant production.

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

        emission_dict = falcon_propellant_production()  # Emission per satellite

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
    Calculate the emissions due to rocket production.

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
    Calculate the emissions when 
    Soyuz-FG rocket is used.

    Parameters
    ----------
    hypergolic : float
        Hypergolic fuel used by the rocket in kilograms.
    kerosene : float
        Kerosene fuel used by the rocket in kilograms.

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
    Calculate the emissions when 
    Falcon-9 rocket is used.

    Parameters
    ----------
    kerosene: float
        Kerosene fuel used by the rocket in kilograms.

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
    calculate the emissions when 
    Ariane-5 is used.

    Parameters
    ----------
    hypergolic: float
        Hypergolic fuel used by the rocket in kilograms.
    solid: float
        solid fuel used by the rocket in kilograms.
    cryogenic: float
        cryogenic fuel used by the rocket in kilograms.

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
    calculate the emissions from production of ariane rocket.

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
    calculate the emissions from production of falcon9 rocket.

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
    calculate the emissions from production of soyuz-fg.

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
    calculate the emissions from production of ariane propellant.

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
    calculate the emissions from production of falcon propellant.

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
    calculate the emissions from production of falcon propellant.

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
    calculate the emissions from transportation of ariane.

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
    calculate the emissions from transportation of falcon9.

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
    calculate the emissions from transportation of soyuzfg.

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
    calculate the emissions from decontamination of waste treatment.

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
    calculate the emissions from general propellant handling.

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
    calculate the emissions from storage of 1 m^3 propellant.

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
    calculate the emissions due to assembling, integration and testing (AIT).

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
    calculate the emissions due to 1 launch campaign.

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
    calculate the emissions from containment of 900 litres of propellant.

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


def cost_model(satellite_manufacturing, satellite_launch_cost, ground_station_cost, spectrum_cost, regulation_fees, \
    digital_infrastructure_cost, ground_station_energy, subscriber_acquisition, \
    staff_costs, research_development, maintenance, discount_rate, assessment_period):
    """
    Calculate the total cost of ownership(TCO):

    Parameters
    ----------
    params : dict.
        Contains all simulation parameters.

    Returns
    -------
    total_cost_ownership : float
            The total cost of ownership.

    """

    capex = (satellite_manufacturing + satellite_launch_cost 
             + ground_station_cost + spectrum_cost 
             + regulation_fees + digital_infrastructure_cost) #Addition of all capital expenditure

    opex_costs = (ground_station_energy + subscriber_acquisition 
                  + staff_costs + research_development 
                  + maintenance) #Addition of all recurrent expenditures

    year_costs = []

    for time in np.arange(1, assessment_period):  #Discounted for the years
        yearly_opex = opex_costs / (((discount_rate / 100) + 1) ** time)
        year_costs.append(yearly_opex)

    total_cost_ownership = capex + sum(year_costs) + opex_costs

    return total_cost_ownership


def subscriber_scenario(name, subscribers):
    """
    Quantify subscriber scenario for each of the constellations.

    Parameters
    ----------
    name : string
        Name of the constellation.
    subscribers : list
        Number of subscribers
    
    Returns
    -------
    subscriber_dict : dict.
        a dictionary of all estimated subscriber scenario
    """
    subscriber_dict = {}
    
    if name == 'Starlink':

        subscriber_dict['low'], subscriber_dict['baseline'] = subscribers[0], subscribers[1] 
        subscriber_dict['high'] = subscribers[2]

    elif name == 'Kuiper':

        subscriber_dict['low'], subscriber_dict['baseline'] = subscribers[0], subscribers[1] 
        subscriber_dict['high'] = subscribers[2]

    elif name == 'OneWeb':

        subscriber_dict['low'], subscriber_dict['baseline'] = subscribers[0], subscribers[1] 
        subscriber_dict['high'] = subscribers[2]

    else:

        print('Constellation not found. Please ensure the first letter is capitalized')
    
    return subscriber_dict