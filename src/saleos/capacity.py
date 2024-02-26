"""
Capacity Simulation model for saleos.

Developed by Bonface Osoro and Ed Oughton.

May 2022

The Capacity model is based on approach and equations defined by:
[1].  Maral, Gérard, Michel Bousquet, and Zhili Sun. Satellite communications 
      systems: systems, techniques and technology. John Wiley & Sons, 2020.

[2].  Digital Video Broadcasting Project, “Second generation framing structure, 
      channel coding and modulation systems for Broadcasting, Interactive 
      Services, News Gathering and other broadband satellite applications; 
      Part 2: DVB-S2 Extensions (DVB-S2X),” 
      DVB. https://dvb.org/?standard=second-generation-framing-structure-channel
      -coding-and-modulation-systems-for-broadcasting-interactive-services-news
      -gathering-and-other-broadband-satellite-applications-part-2-dvb-s2
      -extensions(accessed Sep. 14, 2022)

[3].  Oughton, Edward J. "Policy options for digital infrastructure strategies: 
      A simulation model for affordable universal broadband in Africa." 
      Telematics and Informatics 76 (2023): 101908.

[4].  R. Steele, “A simple guide to satellite broadband limitations,” Telzed 
      Limited UK, 2020.

"""
import math
import numpy as np
from itertools import tee
from collections import Counter
from collections import OrderedDict


def calc_geographic_metrics(number_of_satellites, total_area_earth_km_sq):
    """
    This function calculates  the coverage 
    area for each satellite based on [1].

    Parameters
    ----------
    number_of_satellites : int
        Number of satellites in the constellation.
    total_area_earth_km_sq : float
        Total area of the earth in sqkm.

    Returns
    -------
    satellite_coverage_area_km : float
        The area which each satellite covers on Earth's surface in km.

    """
    area_of_earth_covered = total_area_earth_km_sq
    satellite_coverage_area_km = (area_of_earth_covered / number_of_satellites)


    return satellite_coverage_area_km


def signal_distance(orbital_altitude_km, elevation_angle):
    """
    This function calculates the slant range between the satellite and the 
    ground user

    Parameters
    ----------
    orbital_altitude_km : float 
        Satellite orbital altitude 

    elevation_angle : float 
        minimum elevation angle of the satellite

    Returns
    -------
    distance_km : float
        Slant path based on the satellite minimum elevation angle

    """
    radius_earth_km = 6378
    angle_radians = np.radians(elevation_angle)
    cos_value = np.cos(angle_radians)

    first_term = (((orbital_altitude_km + radius_earth_km) 
                       / radius_earth_km) ** 2)    
    second_term = (cos_value ** 2)
    third_term = np.sin(angle_radians)
    slant_distance = round((radius_earth_km * ((np.sqrt(first_term 
                     - second_term)) - third_term)), 4)


    return slant_distance


def calc_sat_centric_angle(orbital_altitude_km, elevation_angle):
    """
    This function calculates the nadir angle between a satellite and user.

    Parameters
    -----------
    orbital_altitude_km : float 
        Satellite orbital altitude 
    elevation_angle : float 
        minimum elevation angle of the satellite

    Returns
    -------
    nadir_angle_deg : float
        Nadir angle in degrees

    """
    radius_earth_km = 6378
    angle_radians = np.radians(elevation_angle)
    first_term = (radius_earth_km / (radius_earth_km + orbital_altitude_km)) 
    second_term = np.cos(angle_radians)
    nadir = first_term * second_term
    nadir_angle_rad = math.asin(nadir)
    nadir_angle_deg = math.degrees(nadir_angle_rad)


    return nadir_angle_deg


def calc_earth_central_angle(orbital_altitude_km, elevation_angle):
    """
    This function calculates the earth central angle

    Parameters
    ----------
    orbital_altitude_km : float 
        Satellite orbital altitude 
    elevation_angle : float 
        minimum elevation angle of the satellite

    Returns
    -------
    earth_central_angle : float
        Earth Central angle in degrees

    """
    nadir_angle = calc_sat_centric_angle(orbital_altitude_km, elevation_angle)   
    earth_central_angle = 90 - (elevation_angle + nadir_angle)


    return earth_central_angle


def calc_satellite_coverage(orbital_altitude_km, elevation_angle):
    """
    This function calculate the satellite coverage for different elevation angle 
    and orbital altitude.

    Parameters
    ----------
    orbital_altitude_km : float 
        Satellite orbital altitude 
    elevation_angle : float 
        minimum elevation angle of the satellite

    Returns
    -------
    coverage_area : float
        Individual satellite coverage area in km^2

    """
    earth_central_angle = calc_earth_central_angle(
        orbital_altitude_km, elevation_angle)
    
    earth_central_angle_rad = np.radians(earth_central_angle)
    radius_earth_km = 6378
    cos_angle = np.cos(earth_central_angle_rad)
    outer_term = 2 * np.pi * radius_earth_km ** 2
    inner_term = 1 - cos_angle
    satellite_coverage = outer_term * inner_term


    return satellite_coverage

def calc_free_path_loss(frequency, distance_km):

    """
    This function calculates the free space path loss in dB based on [1].

    Free Space Path Loss (dB) = 20log10 x Distance (km) + 20log10 x Downlink 
    Frequency (GHz) + 92.45

    Parameters
    ----------
    distance_km : float
        Link distance based on the satellite minimum elevation angle

    frequency_hz : float
        Transmission frequency in hertz

    Returns
    -------
    free_path_loss_db : float
        Free space path loss in dB

    """
    frequency = (frequency / (10 ** 9))
    free_path_loss = ((20 * np.log10(frequency)) + (20 * np.log10(distance_km)) 
                    + (92.44))
    

    return free_path_loss


def calc_antenna_gain(c, d, f, n):
    """
    Calculates the antenna gain in dB based on [1].

    Antenna gain (dB) = 10log10(Antenna efficiency x pi x Antenna diameter (m))
        / (wavelength x wavelength)

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
    antenna_gain = (math.log10((n * np.pi * d) / (lambda_wavelength ** 2))) * 10


    return antenna_gain


def calc_eirpd(power, antenna_gain):
    """
    Calculate the Effective Isotropic Radiated Power Density based on [1].

    Equivalent Isotropically Radiated Power Density (EIRPD) = (Power + Gain)

    Parameters
    ----------
    power : float
        satellite power in dbW.
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
    This function estimates the total transmission losses due to atmospheric 
    and all other losses based on [1].

    Losses (dB) = Atmospheric lossses (dB) + Other Losses (dB)

    Parameters
    ----------
    earth_atmospheric_losses : int
        Signal losses from rain attenuation in dB.
    all_other_losses : float
        All other signal losses (cloud, ionospheric and gaseous attenuation) in 
        dB.

    Returns
    -------
    losses : float
        The estimated transmission signal losses in dB.

    """
    losses = earth_atmospheric_losses + all_other_losses


    return losses


def calc_received_power(eirp, path_loss, receiver_gain, losses):
    """
    Calculates the power received at the User Equipment (UE) based on [1].

    Power Received (dB) = EIRPD (dB) + Receiver gain (dB) + Path Loss (dB) + 
    Total Losses (dB)

    Parameters
    ----------
    eirp : float
        The Equivalent Isotropically Radiated Power Density in dB.
    path_loss : float
        The free space path loss over the given distance in dB.
    receiver_gain : float
        Antenna gain at the receiver in dB.
    losses : float
        Transmission signal losses IN dB.

    Returns
    -------
    received_power : float
        The received power at the receiver in dB.

    """
    received_power = eirp + receiver_gain - path_loss - losses


    return received_power


def calc_noise():
    """
    Calculates the potential noise based on [1].

    Terminal noise can be calculated as: “`K (Boltzmann constant)` x `T (290K)` 
    x `bandwidth`”.

    The bandwidth depends on bit rate, which defines the number of resource 
    blocks. We use 50 resource blocks, equal 9 MHz, transmission for 1 Mbps 
    downlink.

    Required SNR (dB)
    Detection bandwidth (BW) (Hz)
    k = Boltzmann constant
    T = Temperature (Kelvins) (290 Kelvin = ~16 degrees celcius)
    NF = Receiver noise figure (dB)

    NoiseFloor (dBm) = 10log10(k x T x 1000) + NF + 10log10BW

    NoiseFloor (dBm) = (10log10(1.38 x 10e-23 x 290 x 1x10e3) + 1.5 + 10log10(10 
    x 10e6))

    Parameters
    ----------
    bandwidth : int
        The bandwidth of the carrier frequency (MHz).

    Returns
    -------
    noise : float
        Received noise at the UE receiver in dB.

    """
    k = 1.38e-23  #Boltzmann's constant k = 1.38×10−23 joules per kelvin
    t = 290  #Temperature of the receiver system T0 in kelvins
    b = 0.25 #Detection bandwidth (BW) in Hz
    noise = (10 * (math.log10((k * t * 1000)))) + (10 * (math.log10(b * 10 ** 9)
                                                         ))

    return noise


def calc_cnr(received_power, noise):
    """
    Calculate the Carrier-to-Noise Ratio (CNR) based on [1].

    Carrier-to-noise ratio (dB) = Power Received (dB) - Noise (dB)

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
    Given a carrier-to-noise ratio, the function calculates the spectral 
    efficiency based on [2].

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
    #get only APSK entries
    lut = [
        (modulation, se, awgn, cnr) for (modulation, se, awgn, cnr) in lut]
    
    for lower, upper in pairwise(lut):

        lower_modulation, lower_se, lower_awgn, lower_cnr  = lower
        upper_modulation, upper_se, upper_awgn, upper_cnr  = upper

        lower_cnr = float(lower_cnr)
        upper_cnr = float(upper_cnr)

        if cnr >= lower_cnr and cnr < upper_cnr:

            spectral_efficiency = lower_se

            return spectral_efficiency

        highest_value = lut[-1]

        if cnr >= float(highest_value[3]):

            spectral_efficiency = highest_value[1]


            return spectral_efficiency

        lowest_value = lut[0]

        if cnr < float(lowest_value[3]):

            spectral_efficiency = lowest_value[1]


            return spectral_efficiency


def calc_capacity(spectral_efficiency, dl_bandwidth):
    """
    Calculate the channel capacity in Mbps based on [1],[2].

    Channel Capacity (Mbps) = Spectral efficiency x Channel bandwidth (MHz)

    Parameters
    ----------
    spectral_efficiency : float
        The number of bits per Hertz that can be transmitted.
    dl_bandwidth: float
        The channel bandwidth in Megahertz.

    Returns
    -------
    channel_capacity : float
        The channel capacity in Mbps.

    """
    channel_capacity = spectral_efficiency * dl_bandwidth / (10 ** 6)


    return channel_capacity


def single_satellite_capacity(dl_bandwidth, spectral_efficiency,
                              number_of_channels, polarization, 
                              number_of_beams):
    """
    Calculate the capacity of each satellite in Mbps based on [1],[2].

    Satellite Capacity (Mbps) = Channel bandwidth (Hz) x Spectral efficiency
                                x Number of channels x Polarization x Number of 
                                beams
    Polarization is 1 if the same bandwidth is used for feeder links.

    Parameters
    ----------
    dl_bandwidth : float
        Bandwidth in Hz.
    spectral_efficiency : float
        Spectral efficiency assuming every 
        constellation uses 64QAM
    number_of_channels : int
        Number of satellite channels
    polarizations : int
        Number of satellite polarizations
    number_of_beams : int
        Number of spot beams

    Returns
    -------
    sat_capacity : float
        Satellite capacity in Mbps.

    """
    sat_capacity = ((dl_bandwidth / 1000000) * spectral_efficiency *
        number_of_channels * polarization * number_of_beams)


    return sat_capacity


def calc_constellation_capacity(channel_capacity, number_of_channels,
                                polarization, number_of_beams,
                                number_of_satellites, percent_coverage):
    """
    Calculate the total usable constellation capacity given that only 67% (0.67) 
    of constellation capacity is usable based on [1]-[4].

    Constellation Capacity (Mbps) = Channel capacity (Mbps) x Number of channels
                                x Polarizations x Number of spot beams
                                x Number of satellites x 0.67 (2/3 of capacity)

    Parameters
    ----------
    channel_capacity : float
        The channel capacity in Mbps.
    number_of_channels : int
        The number of user channels per satellite.
    polarization : int
        The number of satellite polarizations.
    number_of_beams : int
        Number of satellite's spot beams
    number_of_satellites : int
        The number of satellites.
    percent_coverage : int
        percentage of the population on 

    Returns
    -------
    constellation_capacity : float
        The constellation capacity in Mbps.

    """
    constellation_capacity = (channel_capacity * number_of_channels * 
                              polarization * number_of_beams 
                              * number_of_satellites * (percent_coverage / 100)) 


    return constellation_capacity


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
    >>> list(pairwise([1,2,3,4])) [(1,2),(2,3),(3,4)]

    """
    a, b = tee(iterable)
    next(b, None)

    return zip(a, b)


def capacity_subscriber(const_cap, subscribers, traffic_percentage):
    """
    This function calculates usable capacity per subscriber in Mbps/subscriber.

    Capacity per subscriber (Mbps/Subscriber) = Constellation capacity 
             / Number of subscribers

    Parameters
    ----------
    const_cap : float
        Total usable constellation capacity in Mbps.
    subscribers : int
        Number of subscribers.
    traffic_percentage : int
        Number subscribers accessing the network at a busy hour

    Returns
    -------
    cap_sub : float
        Capacity per subscriber in Mbps/Subscriber

    """
    cap_sub = const_cap / (subscribers * (traffic_percentage / 100))


    return cap_sub


def monthly_traffic(capacity_mbps):
    """ 
    This function calculates the monthly traffic for LEO constellations and GEO 
    given 20% of traffic taking place in the busiest hour of the day based on 
    [3].

    Conversion of Mbps to monthly traffic in GB. 

    Monthly traffic (GB) = (Capacity_Mbps)
                           / (8000 x #Conversion of Gigabytes to bits
                           1/30)     #Number of days in a month (30)
                           x 1/3600  #Seconds in hour
                           x 20/100  #Percentage of traffic in the busiest hour 
                           of the day

    Parameters
    ----------
    capacity_mbps : float
        Mean capacity per user in Mbps

    Returns
    -------
    Monthly traffic : float
        Returns the monthly traffic in Gigabytes per month per user
            
    """

    amount = (capacity_mbps) / (8000 * (1 / 30) * (1 / 3600) * (20 / 100))


    return amount


def capacity_area(sat_capacity, total_area_earth_km_sq, number_of_satellites, 
                  traffic_percentage):
    """
    This function calculates the capacity per square kilometer

    Parameters
    ----------
    sat_capacity : float
        Single satellite capacity in Mbps.
    number_of_satellites : int
        Number of satellites in the constellation.
    traffic_percentage : int
        Number subscribers accessing the network at a busy hour
    total_area_earth_km_sq : int
        Total area of the earth in square kilometers.

    Returns
    -------
    cap_area_mbps_sqkm : float
        Capacity per square kilometer

    """
    per_area = (sat_capacity) / (total_area_earth_km_sq / number_of_satellites)
    cap_area_mbps_sqkm = (traffic_percentage / 100) / per_area


    return cap_area_mbps_sqkm