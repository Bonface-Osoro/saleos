import pytest
from saleos.capacity import (
    calc_geographic_metrics,
    signal_distance,
    calc_sat_centric_angle,
    calc_earth_central_angle,
    calc_satellite_coverage,
    calc_free_path_loss,
    calc_antenna_gain,
    calc_eirpd,
    calc_losses,
    calc_received_power,
    calc_noise,
    calc_cnr,
    calc_capacity,
    single_satellite_capacity,
    calc_constellation_capacity,
    capacity_subscriber,
    monthly_traffic
)
from saleos.cost import cost_model


def test_calc_geographic_metrics():
    """
    Unit test for calculating satellite coverage area

    """
    number_of_satellites = 10
    total_area_earth_km_sq = 100 

    assert round(calc_geographic_metrics(number_of_satellites, total_area_earth_km_sq)) == 10


def test_signal_distance():
    """
    Unit test for calculating signal distance in km.

    """
    orbital_altitude_km = 545
    elevation_angle = 25

    assert round(signal_distance(orbital_altitude_km, elevation_angle)) == 1114


def test_calc_sat_centric_angle():
    """
    Unit test for calculating satellite 
    centric angle in degrees.

    """
    orbital_altitude_km = 545
    elevation_angle = 25

    assert round(calc_sat_centric_angle(orbital_altitude_km, elevation_angle)) == 57


def test_calc_earth_central_angle():
    """
    Unit test for calculating earth 
    central angle in degrees.

    """
    orbital_altitude_km = 545
    elevation_angle = 25

    assert round(calc_earth_central_angle(orbital_altitude_km, elevation_angle)) == 8


def test_calc_satellite_coverage():
    """
    Unit test for calculating 
    coverage area of a single 
    satellite in km^2.

    """
    orbital_altitude_km = 545
    elevation_angle = 25

    assert round(calc_satellite_coverage(orbital_altitude_km, elevation_angle)) == 2734285


def test_calc_free_path_loss():
    """
    Unit test for calculating 
    free space path loss in dB.

    """
    frequency = 10700000000
    distance_km = 1114.3367

    assert round(calc_free_path_loss(frequency, distance_km)) == 174


def test_calc_antenna_gain():
    """
    Unit test for calculating 
    antenna gain in dB.

    """
    c = 3.0 * 10 ** 8
    d = 0.6
    f = 10700000000
    n = 0.6

    assert round(calc_antenna_gain(c, d, f, n)) == 32


def test_calc_eirpd():
    """
    Unit test for calculating 
    Equivalent Isotropically 
    Radiated Power Density 
    (EIRPD) in dB.

    """
    power = 30
    antenna_gain = 31

    assert round(calc_eirpd(power, antenna_gain)) == 61


def test_calc_losses():
    """
    Unit test for calculating 
    total losses in dB.

    """
    earth_atmospheric_losses = 10
    all_other_losses = 1

    assert round(calc_losses(earth_atmospheric_losses, all_other_losses)) == 11


def test_calc_received_power():
    """
    Unit test for calculating 
    received power at user 
    terminal in dB.

    """
    eirp = 10
    path_loss = 20
    receiver_gain = 15
    losses = 2

    assert round(calc_received_power(eirp, path_loss, receiver_gain, losses)) == 3


def test_calc_noise():
    """
    Unit test for calculating 
    noise power at user terminal 
    in dB.

    """

    assert round(calc_noise()) == -90


def test_calc_cnr():
    """
    Unit test for calculating 
    Carrier-to-Noise Ratio (CNR)
    at user terminal in dB.

    """
    received_power = 10
    noise = 2

    assert round(calc_cnr(received_power, noise)) == 8


def test_calc_capacity():
    """
    Unit test for calculating 
    channel capacity in Mbps.

    """
    spectral_efficiency = 1.647211
    dl_bandwidth = 250000000

    assert round(calc_capacity(spectral_efficiency, dl_bandwidth)) == 412


def test_single_satellite_capacity():
    """
    Unit test for calculating single
    satellite capacity in Mbps.

    """
    spectral_efficiency = 1.647211
    dl_bandwidth = 250000000
    number_of_channels = 6
    polarization = 1
    number_of_beams = 8

    assert round(single_satellite_capacity(dl_bandwidth, spectral_efficiency,
    number_of_channels, polarization, number_of_beams)) == 19767


def test_calc_constellation_capacity():
    """
    Unit test for calculating 
    constellation capacity in 
    Mbps.

    """
    channel_capacity = 411.8028
    number_of_channels = 6
    polarization = 1
    number_of_beams = 8
    number_of_satellites = 4425

    assert round(calc_constellation_capacity(channel_capacity, number_of_channels, 
                polarization, number_of_beams, number_of_satellites)) == 43733457
    

def test_capacity_subscriber():
    """
    Unit test for calculating 
    capacity per subscriber in 
    Mbps/subscriber.

    """
    const_cap = 1000
    subscribers = 100

    assert round(capacity_subscriber(const_cap, subscribers)) == 10


def test_monthly_traffic():
    """
    Unit test for calculating 
    monthly traffic in GB.

    """
    capacity_mbps = 17.49338294

    assert round(monthly_traffic(capacity_mbps)) == 20


def test_cost():
    """
    Unit test for calculating 
    constellation's total cost 
    of ownership.

    """
    satellite_manufacturing = 150000
    satellite_launch_cost = 186328000
    ground_station_cost = 39088000
    spectrum_cost = 120000000
    regulation_fees = 720000
    fiber_infrastructure_cost = 3550000
    ground_station_energy = 2750000
    subscriber_acquisition = 50000000
    staff_costs = 20000000
    research_development = 60000000
    maintenance = 23000000
    discount_rate = 5
    assessment_period = 5

    assert round(cost_model(satellite_manufacturing, satellite_launch_cost, 
    ground_station_cost, spectrum_cost, regulation_fees, 
    fiber_infrastructure_cost, ground_station_energy, 
    subscriber_acquisition, staff_costs, research_development, 
    maintenance, discount_rate, assessment_period)) == 1057867791