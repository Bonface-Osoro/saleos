"""
Capacity Simulation model for saleos.

Developed by Bonface Osoro and Ed Oughton.

May 2022

"""
import math
import numpy as np
from itertools import tee
from collections import Counter
from collections import OrderedDict

def calc_geographic_metrics(number_of_satellites, total_area_earth_km_sq, altitude_km):
    """
    Calculate (a) the distance between the satellite
    and user terminal and (b) the coverage area for each satellite.

    Parameters
    ----------
    number_of_satellites : int
        Number of satellites in the constellation.
    total_area_earth_km_sq : float
        Total area of the earth in sqkm.
    altitude_km : float
        Satellite orbital altitude in km

    Returns
    -------
    distance : float
        The distance between the satellite and reciever in km.
    satellite_coverage_area_km : float
        The area which each satellite covers on Earth's surface in km.

    """
    area_of_earth_covered = total_area_earth_km_sq

    network_density = number_of_satellites / area_of_earth_covered

    satellite_coverage_area_km = (area_of_earth_covered / number_of_satellites) 

    mean_distance_between_assets = math.sqrt((1 / network_density)) / 2

    distance = math.sqrt(((mean_distance_between_assets) ** 2) + ((altitude_km) ** 2))

    return distance, satellite_coverage_area_km


def calc_path_loss(distance_km, downlink_frequency_Hz):

    """
    This function calculates the free 
    space path loss in dB.

    Free Space Path Loss (dB) = 20log10 x 
        Distance (km) + 20log10 x 
        Downlink Frequency (GHz) + 92.45

    Parameters
    ----------
    distance_km : float
        Slant path based on the satellite 
        density/minimum elevation angle
    downlink_frequency_Hz : float
        Downlink transmission frequency in Hz.

    Returns
    -------
    path_loss :
        Free space path loss in dB
    """
    path_loss = (20 * math.log10(distance_km) + 20 * 
            math.log10(downlink_frequency_Hz / 1e9) 
            + 92.45)
    
    return path_loss


def calc_antenna_gain(c, d, f, n):
    """
    Calculates the antenna gain in dB.

    Antenna gain (dB) = 10log10 
        (Antenna efficiency 
        x pie x Antenna diameter (m))
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
    antenna_gain = 10 * (math.log10(n * ((np.pi * d) / lambda_wavelength) ** 2))

    return antenna_gain


def calc_eirpd(power, antenna_gain):
    """
    Calculate the Effective Isotropic
    Radiated Power Density.

    Equivalent Isotropically Radiated Power Density (EIRPD) = (
        Power + Gain
    )

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
    This function estimates the total 
    transmission losses due to atmospheric 
    and all other losses.

    Losses (dB) = Atmospheric lossses (dB)
                  + Other Losses (dB)

    Parameters
    ----------
    earth_atmospheric_losses : int
        Signal losses from rain attenuation in dB.
    all_other_losses : float
        All other signal losses (cloud, ionospheric 
        and gaseous attenuation) in dB.

    Returns
    -------
    losses : float
        The estimated transmission signal losses in dB.

    """
    losses = earth_atmospheric_losses + all_other_losses

    return losses


def calc_received_power(eirp, path_loss, receiver_gain, losses):
    """
    Calculates the power received at the User Equipment (UE).

    Power Received (dB) = EIRPD (dB) + Receiver gain (dB)
                          + Path Loss (dB) + Total Losses (dB)

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
    Calculates the potential noise.

    Terminal noise can be calculated as:

    “`K (Boltzmann constant)` x `T (290K)` x `bandwidth`”.

    The bandwidth depends on bit rate, which defines the number
    of resource blocks. We assume 50 resource blocks, equal 9 MHz,
    transmission for 1 Mbps downlink.

    Required SNR (dB)
    Detection bandwidth (BW) (Hz)
    k = Boltzmann constant
    T = Temperature (Kelvins) (290 Kelvin = ~16 degrees celcius)
    NF = Receiver noise figure (dB)

    NoiseFloor (dBm) = 10log10(k x T x 1000) + NF + 10log10BW

    NoiseFloor (dBm) = (
        10log10(1.38 x 10e-23 x 290 x 1x10e3) + 1.5 + 10log10(10 x 10e6)
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
    k = 1.38e-23  #Boltzmann's constant k = 1.38×10−23 joules per kelvin
    t = 290  #Temperature of the receiver system T0 in kelvins
    b = 0.25 #Detection bandwidth (BW) in Hz

    noise = (10 * (math.log10((k * t * 1000)))) + (10 * (math.log10(b * 10 ** 9)))

    return noise


def calc_cnr(received_power, noise):
    """
    Calculate the Carrier-to-Noise Ratio (CNR).

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
    Given a carrier-to-noise ratio, 
    the function calculates 
    the spectral efficiency.

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
    Calculate the channel capacity in Mbps.

    Channel Capacity (Mbps) = Spectral efficiency 
                              x Channel bandwidth (MHz)

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
    number_of_channels, polarization):
    """
    Calculate the capacity of each satellite in Mbps.

    Satellite Capacity (Mbps) = Channel bandwidth (Hz)
                                x Spectral efficiency
                                x Number of channels
                                x Polarization

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

    Returns
    -------
    sat_capacity : float
        Satellite capacity in Mbps.

    """
    sat_capacity = (
        (dl_bandwidth / 1000000) *
        spectral_efficiency *
        number_of_channels *
        polarization
    )

    return sat_capacity


def calc_constellation_capacity(channel_capacity, 
                                number_of_channels, 
                                polarization, 
                                number_of_satellites):
    """
    Calculate the total usable constellation capacity assuming 
    that only 50%(0.5) of constellation capacity is usable.

    Constellation Capacity (Mbps) = Channel capacity (Mbps)
                                    x Number of channels
                                    x Polarizations
                                    x Number of satellites
                                    x 0.5 (50% of capacity)

    Parameters
    ----------
    channel_capacity : float
        The channel capacity in Mbps.
    number_of_channels : int
        The number of user channels per satellite.
    polarization : int
        The number of satellite polarizations.
    number_of_satellites : int
        The number of satellites.

    Returns
    -------
    constellation_capacity : float
        The constellation capacity in Mbps.

    """
    constellation_capacity = (channel_capacity * number_of_channels 
                              * polarization * number_of_satellites * 0.5) 

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
    >>> list(pairwise([1,2,3,4]))
        [(1,2),(2,3),(3,4)]

    """
    a, b = tee(iterable)
    next(b, None)

    return zip(a, b)


def capacity_subscriber(const_cap, subscribers):
    """
    This function calculates usable 
    capacity per subscriber in Mbps/subscriber.

    Capacity per subscriber (Mbps/Subscriber) =
             Constellation capacity 
             / Number of subscribers

    Parameters
    ---------
    const_cap : float
        Total usable constellation capacity in Mbps.
    subscribers : int
        Number of subscribers.

    Returns
    -------
    cap_sub : float
        Capacity per subscriber in Mbps/Subscriber

    """
    cap_sub = const_cap / subscribers

    return cap_sub


def monthly_traffic(capacity_mbps):
    """ 
    This function calculates the monthly 
    traffic assuming the lifespan of all 
    constellations is 5 years and 20% 
    accounting for traffic taking place 
    in the busiest hour of the day.

    Conversion of Mbps to monthly traffic in GB. 

    Monthly traffic (GB) = (
        (Capacity_Mbps / 12 * 5) /  # 12 months in 1 year over 5 years
        (8000 * #
        (1 / 30 ) * # 30 days of the month
        (1 / 3600) * # seconds in a 1 hour
        (20 / 100) #  
        )
    )

    Parameters
    ----------
    capacity_mbps : float
        Total usable constellation capacity in Mbps

    Returns
    -------
    Monthly traffic : float
        Returns the monthly traffic in Gigabytes per month per user
            
    """
    amount = (capacity_mbps / 12 * 5) / (8000 * (1 / 30) * (1 / 3600) * (20 / 100))

    return amount