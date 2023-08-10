"""
Inputs for saleos simulation.

Written by Bonface Osoro & Ed Oughton.

May 2022

"""
parameters = {
    'starlink': {
        'number_of_satellites': 4425,
        'name':'Starlink',
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 545, #Altitude of starlink satellites in km
        'dl_frequency_Hz': 13.5 * 10 **9 , #Downlink frequency in Hertz
        'dl_bandwidth_Hz': 0.5 * 10 ** 9, #Downlink bandwidth in Hertz
        'speed_of_light': 3.0 * 10 ** 8, #Speed of light in vacuum
        'antenna_diameter_m': 0.6, #Metres
        'antenna_efficiency': 0.6,
        'power_dBw': 30, #dBw
        'receiver_gain': 30,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses_dB': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'polarization': 2,
        'subscribers': [2500000, 3500000, 4500000],
        'satellite_manufacturing': 250000,
        'satellite_launch_cost': 250000000,
        'ground_station_cost': 48860000,
        'spectrum_cost': 125000000,
        'regulation_fees': 720000,
        'fiber_infrastructure_cost': 3550000,
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
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 1195, #Altitude of starlink satellites in km
        'dl_frequency_Hz': 13.5 * 10 ** 9, #Downlink frequency in Hertz
        'dl_bandwidth_Hz': 0.25 * 10 ** 9,
        'speed_of_light': 3.0 * 10 ** 8, #Speed of light in vacuum
        'antenna_diameter_m': 0.65, #Metres
        'antenna_efficiency': 0.6,
        'power_dBw': 30, #dBw
        'receiver_gain': 30,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses_dB': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'polarization': 2,
        'subscribers': [500000, 800000, 1000000],
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 150000000,
        'ground_station_cost': 20000000,
        'spectrum_cost': 125000000,
        'regulation_fees': 7200000,
        'fiber_infrastructure_cost': 3550000,
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
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 605, #Altitude of starlink satellites in km
        'dl_frequency_Hz': 17.7 * 10 ** 9, #Downlink frequency in Hertz
        'dl_bandwidth_Hz': 0.25 * 10 ** 9,
        'speed_of_light': 3.0 * 10 ** 8, #Speed of light in vacuum
        'antenna_diameter_m': 0.9, #Metres
        'antenna_efficiency': 0.6,
        'power_dBw': 30, #dBw
        'receiver_gain': 31,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses_dB': 0.53, #All other losses
        'number_of_channels': 8, #Number of channels per satellite
        'polarization': 2,
        'subscribers': [1500000, 2500000, 3500000],
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 180000000,
        'ground_station_cost': 33000000,
        'spectrum_cost': 125000000,
        'regulation_fees': 7200000,
        'fiber_infrastructure_cost': 2500000,
        'ground_station_energy': 15000000,
        'subscriber_acquisition': 50000000,
        'staff_costs': 253000000,
        'research_development': 60000000,
        'maintenance': 22000000,
        'discount_rate': 5,
        'assessment_period': 5
    },
}

###
lut = [
    ('QPSK 2/9', 0.434841, -2.85, -2.45),
    ('QPSK 13/45', 0.567805, -2.03, -1.60),
    ('QPSK 9/20', 0.889135, 0.22, 0.69),
    ('QPSK 11/20', 1.088581, 1.45, 1.97),
    ('8APSK 5/9-L', 1.647211, 4.73, 5.95),
    ('8APSK 26/45-L', 1.713601, 5.13, 6.35),
    ('8PSK 23/36', 1.896173, 6.12, 6.96),
    ('8PSK 25/36', 2.062148, 7.02, 7.93),
    ('8PSK 13/18', 2.145136, 7.49, 8.42),
    ('16APSK 1/2-L', 1.972253, 5.97, 8.4),
    ('16APSK 8/15-L', 2.104850, 6.55, 9.0),
    ('16APSK 5/9-L', 2.193247, 6.84, 9.35),
    ('16APSK 26/45', 2.281645, 7.51, 9.17),
    ('16APSK 3/5', 2.370043, 7.80, 9.38),
    ('16APSK 3/5-L', 2.370043, 7.41, 9.94),
    ('16APSK 28/45', 2.458441, 8.10, 9.76),
    ('16APSK 23/36', 2.524739, 8.38, 10.04),
    ('16APSK 2/3-L', 2.635236, 8.43, 11.06),
    ('16APSK 25/36', 2.745734, 9.27, 11.04),
    ('16APSK 13/18', 2.856231, 9.71, 11.52),
    ('16APSK 7/9', 3.077225, 10.65, 12.50),
    ('16APSK 77/90', 3.386618, 11.99, 14.00),
    ('32APSK 2/3-L', 3.291954, 11.10, 13.81),
    ('32APSK 32/45', 3.510192, 11.75, 14.50),
    ('32APSK 11/15', 3.620536, 12.17, 14.91),
    ('32APSK 7/9', 3.841226, 13.05, 15.84),
    ('64APSK 32/45-L', 4.206428, 13.98, 17.7),
    ('64APSK 11/15', 4.338659, 14.81, 17.97),
    ('64APSK 7/9', 4.603122, 15.47, 19.10),
    ('64APSK 4/5', 4.735354, 15.87, 19.54),
    ('64APSK 5/6', 4.936639, 16.55, 20.44),
    ('128APSK 3/4', 5.163248, 17.73, 21.43),
    ('128APSK 7/9', 5.355556, 18.53, 22.21),
    ('256APSK 29/45-L', 5.065690, 16.98, 21.6),
    ('256APSK 2/3-L', 5.241514, 17.24, 21.89),
    ('256APSK 31/45-L', 5.417338, 18.10, 22.9),
    ('256APSK 32/45', 5.593162, 18.59, 22.91),
    ('256APSK 11/15-L', 5.768987, 18.84, 23.80),
    ('256APSK 3/4', 5.900855, 19.57, 24.02),
]