"""
Inputs for saleos simulation.

Written by Bonface Osoro & Ed Oughton.

May 2022

"""

parameters = {
    'starlink': {
        'number_of_satellites': 4425,
        'name':'Starlink',
        'iterations': 100,
        'seed_value': 42,
        'mu': 2, #Mean of distribution
        'sigma': 10, #Standard deviation of distribution
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 545, #Altitude of starlink satellites in km
        'dl_frequency': 13.5*10**9, #Downlink frequency in Hertz
        'dl_bandwidth': 0.5*10**9, #Downlink bandwidth in Hertz
        'speed_of_light': 3.0*10**8, #Speed of light in vacuum
        'antenna_diameter': 0.6, #Metres
        'antenna_efficiency': 0.6,
        'power': 30, #dBw
        'receiver_gain': 30,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'overbooking_factor': 20, # 1 in 20 users access the network
        'polarization':2,
        'monthly_traffic_GB': 25,
        'percent_of_traffic': 15,
        'adoption_rate': 0.01,
        'subscribers': [2500000, 3500000, 4500000],
        'fuel_mass': 488370,
        'fuel_mass_1': 0,
        'fuel_mass_2': 0,
        'fuel_mass_3': 0,
        'number_of_missions': 74,
        'satellite_manufacturing': 250000,
        'satellite_launch_cost': 250000000,
        'ground_station_cost': 48860000,
        'spectrum_cost': 125000000,
        'regulation_fees': 720000,
        'digital_infrastructure_cost': 3550000,
        'ground_station_energy': 3250000,
        'subscriber_acquisition': 50000000,
        'staff_costs': 300000000, #10% of maintenance costs
        'research_development': 60000000,
        'maintenance': 26000000, #10% of capex
        'discount_rate': 5,
        'assessment_period': 5
    },
    'oneweb': {
        'number_of_satellites': 720,
        'name': 'OneWeb',
        'iterations': 100,
        'seed_value': 42,
        'mu': 2, #Mean of distribution
        'sigma': 10, #Standard deviation of distribution
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 1195, #Altitude of starlink satellites in km
        'dl_frequency': 13.5*10**9, #Downlink frequency in Hertz
        'dl_bandwidth': 0.25*10**9,
        'speed_of_light': 3.0*10**8, #Speed of light in vacuum
        'antenna_diameter': 0.65, #Metres
        'antenna_efficiency': 0.6,
        'power': 30, #dBw
        'receiver_gain': 30,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'overbooking_factor': 20, # 1 in 20 users access the network
        'polarization': 2,
        'monthly_traffic_GB': 25,
        'percent_of_traffic': 15,
        'adoption_rate': 0.01,
        'subscribers': [120000, 200000, 300000],
        'fuel_mass': 218150,
        'fuel_mass_1': 7360,
        'fuel_mass_2': 0,
        'fuel_mass_3': 0,
        'number_of_missions': 20,
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 150000000,
        'ground_station_cost': 20000000,
        'spectrum_cost': 125000000,
        'regulation_fees': 7200000,
        'digital_infrastructure_cost': 3550000,
        'ground_station_energy': 3250000,
        'subscriber_acquisition': 50000000,
        'staff_costs': 207000000,
        'research_development': 60000000,
        'maintenance': 18000000,
        'discount_rate': 5,
        'assessment_period': 5
    },
    'kuiper': {
        'number_of_satellites': 3236,
        'name': 'Kuiper',
        'iterations': 100,
        'seed_value': 42,
        'mu': 2, #Mean of distribution
        'sigma': 10, #Standard deviation of distribution
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 605, #Altitude of starlink satellites in km
        'dl_frequency': 17.7*10**9, #Downlink frequency in Hertz
        'dl_bandwidth': 0.25*10**9,
        'speed_of_light': 3.0*10**8, #Speed of light in vacuum
        'antenna_diameter': 0.9, #Metres
        'antenna_efficiency': 0.6,
        'power': 30, #dBw
        'receiver_gain': 31,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'overbooking_factor': 20, # 1 in 20 users access the network
        'polarization': 2,
        'monthly_traffic_GB': 25,
        'percent_of_traffic': 15,
        'adoption_rate': 0.01,
        'subscribers': [1500000, 2500000, 3500000],
        'fuel_mass': 0,
        'fuel_mass_1':10000,
        'fuel_mass_2': 480000,
        'fuel_mass_3': 184900,
        'number_of_missions': 54,
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 180000000,
        'ground_station_cost': 33000000,
        'spectrum_cost': 125000000,
        'regulation_fees': 7200000,
        'digital_infrastructure_cost': 2500000,
        'ground_station_energy': 15000000,
        'subscriber_acquisition': 50000000,
        'staff_costs': 253000000,
        'research_development': 60000000,
        'maintenance': 22000000,
        'discount_rate': 5,
        'assessment_period': 5
    },
    # 'telesat': {
    #     'number_of_satellites': 300,
    #     'iterations': 5,
    #     'seed_value': 42,
    #     'mu': 1, #Mean of distribution
    #     'sigma': 7.8, #Standard deviation of distribution
    #     'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
    #     'portion_of_earth_covered': 0.8, #We assume the poles aren't covered
    #     'altitude_km': 550, #Altitude of starlink satellites in km
    #     'dl_frequency': 13.5*10**9, #Downlink frequency in Hertz
    #     'dl_bandwidth': 0.25*10**9,
    #     'speed_of_light': 3.0*10**8, #Speed of light in vacuum
    #     'antenna_diameter': 0.7, #Metres
    #     'antenna_efficiency': 0.6,
    #     'power': 30, #dBw
    #     'losses': 4, #dB
    # },
}

lut = [
    (5.12, 1.647211),
    (5.96, 1.972253),
    (6.54, 1.972253),
    (6.83, 2.104850),
    (7.5, 2.193247),
    (7.79, 2.281645),
    (7.40, 2.370043),
    (8.0, 2.370043),
    (8.37, 2.458441),
    (8.42, 2.524739),
    (9.26, 2.635236),
    (9.70, 2.745734),
    (10.64, 2.856231),
    (11.98, 3.077225),
    (11.09, 3.386618),
    (11.74, 3.291954),
    (12.16, 3.510192),
    (13.04, 3.620536),
    (13.97, 3.841226),
    (14.8, 4.206428),
    (15.46, 4.338659),
    (15.86, 4.603122),
    (16.54, 4.735354),
    (17.72, 4.936639),
    (18.52, 5.163248),
    (16.97, 5.355556),
    (17.23, 5.065690),
    (18.0, 5.241514),
    (18.58, 5.417338),
    (18.83, 5.593162),
    (19.56, 5.768987),
]