"""
Inputs for saleos simulation.

Written by Bonface Osoro & Ed Oughton.

May 2022

The GEO and some LEO cost values are estimated from SES financial statements through the following link.
https://www.ses.com/sites/default/files/2023-02/230227_SES_AR2022_Final.pdf

"""
parameters = {                                            
    'starlink': {
        'number_of_satellites': 4425,
        'name':'Starlink',
        'total_area_earth_km_sq': 510000000, #Area of Earth in km^2
        'altitude_km': 545, #Altitude of starlink satellites in km
        'elevation_angle': 25,
        'dl_frequency_hz': [10.7 * 10 **9, 11.7 * 10 **9, 12.7 * 10 **9], #Downlink frequency in Hertz
        'dl_bandwidth_hz': 0.25 * 10 ** 9, #Downlink bandwidth in Hertz
        'speed_of_light': 3.0 * 10 ** 8, #Speed of light in vacuum
        'antenna_diameter_m': 0.6, #Metres
        'antenna_efficiency': 0.6,
        'power_dbw': 30, #dBw
        'receiver_gain': 30,
        'earth_atmospheric_losses': 10, #Rain Attenuation
        'all_other_losses_db': 0.53, #All other losses
        'number_of_beams': 8, #Number of spot beams
        'number_of_channels': 6, #Number of channels per satellite
        'polarization': 1,
        'subscribers': [2500000, 3500000, 4500000],
        'satellite_manufacturing': 250000,
        'satellite_launch_cost': 1210000000,
        'ground_station_cost': 75000000,
        'spectrum_cost': 367000000,
        'regulation_fees': 2320850,
        'maintenance': 7875000, #10% of capex
        'staff_costs': 2072400000, 
        'subscriber_acquisition': 23000000,
        'ground_station_energy': 115500,
        'research_development': 681000000,
        'fiber_infrastructure_cost': 3750000,
        'discount_rate': 5,
        'assessment_period': 5
    },
    'oneweb': {
        'number_of_satellites': 720,
        'name': 'OneWeb',
        'total_area_earth_km_sq': 510000000, 
        'altitude_km': 1195, 
        'elevation_angle': 45,
        'dl_frequency_hz': [10.7 * 10 **9, 11.7 * 10 **9, 12.7 * 10 **9], 
        'dl_bandwidth_hz': 0.25 * 10 ** 9,
        'speed_of_light': 3.0 * 10 ** 8, 
        'antenna_diameter_m': 0.65, 
        'antenna_efficiency': 0.6,
        'power_dbw': 30, 
        'receiver_gain': 35,
        'earth_atmospheric_losses': 10, 
        'all_other_losses_db': 0.53, 
        'number_of_beams': 6,
        'number_of_channels': 3, 
        'polarization': 1,
        'subscribers': [500000, 800000, 1000000],
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 102000000,
        'ground_station_cost': 22000000,
        'spectrum_cost': 312000000,
        'regulation_fees': 1221500,
        'maintenance': 2310000,
        'staff_costs': 99500000,
        'subscriber_acquisition': 3300000,
        'ground_station_energy': 33880,
        'research_development': 99800000,
        'fiber_infrastructure_cost': 1100000,
        'discount_rate': 5,
        'assessment_period': 5
    },
    'kuiper': {
        'number_of_satellites': 3236,
        'name': 'Kuiper',
        'total_area_earth_km_sq': 510000000, 
        'altitude_km': 605, 
        'elevation_angle': 35,
        'dl_frequency_hz': [17.7 * 10 **9, 18.7 * 10 **9, 19.7 * 10 **9], 
        'dl_bandwidth_hz': 0.25 * 10 ** 9,
        'speed_of_light': 3.0 * 10 ** 8, 
        'antenna_diameter_m': 0.9, 
        'antenna_efficiency': 0.6,
        'power_dbw': 30, 
        'receiver_gain': 31,
        'earth_atmospheric_losses': 10, 
        'all_other_losses_db': 0.53,
        'number_of_beams': 8,
        'number_of_channels': 6, 
        'polarization': 1,
        'subscribers': [1500000, 2500000, 3500000],
        'satellite_manufacturing': 400000,
        'satellite_launch_cost': 2038680000,
        'ground_station_cost': 6000000,
        'spectrum_cost': 246000000,
        'regulation_fees': 1197070,
        'maintenance': 630000,
        'staff_costs': 22608000,
        'subscriber_acquisition': 16000000,
        'ground_station_energy': 9240,
        'research_development': 498344000,
        'fiber_infrastructure_cost': 300000,
        'discount_rate': 5,
        'assessment_period': 5
    },
    'geo': {
        'number_of_satellites': 56,
        'name': 'GEO',
        'total_area_earth_km_sq': 510000000, 
        'altitude_km': 35786, 
        'elevation_angle': 5,
        'dl_frequency_hz': [10.5 * 10 **9, 11.5 * 10 **9, 
                            12.5 * 10 **9, 13.5 * 10 **9], 
        'dl_bandwidth_hz': 12 * 10 ** 6,
        'speed_of_light': 3.0 * 10 ** 8, 
        'antenna_diameter_m': 0.5, 
        'antenna_efficiency': 0.55,
        'power_dbw': 64.2, 
        'receiver_gain': 33.4,
        'earth_atmospheric_losses': 10, 
        'all_other_losses_db': 0.53,
        'number_of_beams': 64,
        'number_of_channels': 48, 
        'polarization': 2,
        'subscribers': [1500000, 2500000, 3500000], #[1500000, 3500000, 4500000]
        'satellite_manufacturing': 200000000,
        'satellite_launch_cost': 5880000000,
        'ground_station_cost': 10000000,
        'spectrum_cost': 84000000,
        'regulation_fees': 940640,
        'maintenance': 1050000,
        'staff_costs': 376800000,
        'subscriber_acquisition': 3300000,
        'ground_station_energy': 15400,
        'research_development': 8624000,
        'fiber_infrastructure_cost': 500000,
        'discount_rate': 5,
        'assessment_period': 15
    },
}


### MODCOD, Spectral efficiency, AWGN Linear Channel, Non-Linear Hard LimiterChannel ###
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


falcon_9 = {
    'climate_change_baseline' : {
        'launch_event' : 4113533.907,
        'launcher_production' : 4113533.907,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 4744753.339,
        'propellant_scheduling' : 5594990.917,
        'launcher_transportation' : 17220.72491,
        'launch_campaign' : 5666556.742,
    },
    'climate_change_worst_case' : {
        'launch_event' : 26728958.94,
        'launcher_production' : 4113533.907,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 4744753.339,
        'propellant_scheduling' : 5594990.917,
        'launcher_transportation' : 17220.72491,
        'launch_campaign' : 5666556.742,
    },
    'ozone_depletion_baseline' : {
        'launch_event' : 6837.18,
        'launcher_production' : 0.277478514,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.546874653,
        'propellant_scheduling' : 0.499423015,
        'launcher_transportation' : 0.003568284,
        'launch_campaign' : 0.777870405,
    },
    'ozone_depletion_worst_case' : {
        'launch_event' : 30767.31,
        'launcher_production' : 0.277478514,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.546874653,
        'propellant_scheduling' : 0.499423015,
        'launcher_transportation' : 0.003568284,
        'launch_campaign' : 0.777870405,
    },
    'resource_depletion' : {
        'launch_event' : 0,
        'launcher_production' : 1783.337118,
        'launcher_ait' : 15.65466435,
        'propellant_production' : 32.92663196,
        'propellant_scheduling' : 277.7569651,
        'launcher_transportation' : 0.83687164,
        'launch_campaign' : 33.22600998,
    },
    'freshwater_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 20253601.64,
        'launcher_ait' : 7701094.993,
        'propellant_production' : 15292951.2,
        'propellant_scheduling' : 36949013.69,
        'launcher_transportation' : 47571.20342,
        'launch_campaign' : 18683396.82,
    },
    'human_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 1.51530806,
        'launcher_ait' : 0.486234151,
        'propellant_production' : 1.378727964,
        'propellant_scheduling' : 2.431926984,
        'launcher_transportation' : 0.004766684,
        'launch_campaign' : 1.695861368,
    }
}


soyuz = {
    'climate_change_baseline' : {
        'launch_event' : 288655.1096,
        'launcher_production' : 44680412.98,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 968910.1994,
        'propellant_scheduling' : 3223330.483,
        'launcher_transportation' : 4328.603808,
        'launch_campaign' : 5666556.742 
        },
    'climate_change_worst_case' : {
        'launch_event' : 12031437.19,
        'launcher_production' : 44680412.98,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 968910.1994,
        'propellant_scheduling' : 3223330.483,
        'launcher_transportation' : 4328.603808,
        'launch_campaign' : 5666556.742
        },
    'ozone_depletion_baseline' : {
        'launch_event' : 3157.14,
        'launcher_production' : 3.11181773,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.109998823,
        'propellant_scheduling' : 0.287848601,
        'launcher_transportation' : 0.001339551,
        'launch_campaign' : 0.777870405
        },
    'ozone_depletion_worst_case' : {
        'launch_event' : 13872.25,
        'launcher_production' : 3.11181773,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.109998823,
        'propellant_scheduling' : 0.287848601,
        'launcher_transportation' : 0.001339551,
        'launch_campaign' : 0.777870405
        },
    'resource_depletion' : {
        'launch_event' : 0,
        'launcher_production' : 12473.4086,
        'launcher_ait' : 15.65466435,
        'propellant_production' : 6.71625049,
        'propellant_scheduling' : 159.775698,
        'launcher_transportation' : 0.158493574,
        'launch_campaign' : 33.22600998
        },
    'freshwater_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 280703930.5,
        'launcher_ait' : 7701094.993,
        'propellant_production' : 3114043.098,
        'propellant_scheduling' : 21269740.34,
        'launcher_transportation' : 22931.63867,
        'launch_campaign' : 18683396.82
        },
    'human_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 19.1361269,
        'launcher_ait' : 0.486234151,
        'propellant_production' : 0.28140976,
        'propellant_scheduling' : 1.399552839,
        'launcher_transportation' : 0.002580373,
        'launch_campaign' : 1.695861368}
}


unknown_hyc = {
    'climate_change_baseline' : {
        'launch_event' : 2201094.508,
        'launcher_production' : 24396973.44,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 2856831.769,
        'propellant_scheduling' : 4409160.7,
        'launcher_transportation' : 10774.66436,
        'launch_campaign' : 5666556.742,
    },
    'climate_change_worst_case' : {
        'launch_event' : 19380198.06,
        'launcher_production' : 24396973.44,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 2856831.769,
        'propellant_scheduling' : 4409160.7,
        'launcher_transportation' : 10774.66436,
        'launch_campaign' : 5666556.742
        },
    'ozone_depletion_baseline' : {
        'launch_event' : 4997.16,
        'launcher_production' : 1.694648122,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.385083701,
        'propellant_scheduling' : 0.393635808,
        'launcher_transportation' : 0.002453918,
        'launch_campaign' : 0.777870405
        },
    'ozone_depletion_worst_case' : {
        'launch_event' : 22319.78,
        'launcher_production' : 1.694648122,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.328436738,
        'propellant_scheduling' : 0.393635808,
        'launcher_transportation' : 0.002453918,
        'launch_campaign' : 0.777870405
        },
    'resource_depletion' : {
        'launch_event' : 0,
        'launcher_production' : 7128.37286,
        'launcher_ait' : 15.65466435,
        'propellant_production' : 19.82144123,
        'propellant_scheduling' : 218.7663315,
        'launcher_transportation' : 0.497682607,
        'launch_campaign' : 33.22600998
        },
    'freshwater_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 150478766.1,
        'launcher_ait' : 7701094.993,
        'propellant_production' : 9203497.148,
        'propellant_scheduling' : 29109377.02,
        'launcher_transportation' : 35251.42104,
        'launch_campaign' : 18683396.82
        },
    'human_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 10.32571748,
        'launcher_ait' : 0.486234151,
        'propellant_production' : 0.830068862,
        'propellant_scheduling' : 1.915739911,
        'launcher_transportation' : 0.003673529,
        'launch_campaign' : 1.695861368}
}


unknown_hyg = {
    'climate_change_baseline' : {
        'launch_event' : 467816.8,
        'launcher_production' : 11018755.48,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 4793267.48,
        'propellant_scheduling' : 8984275.336,
        'launcher_transportation' : 11043.18682,
        'launch_campaign' : 5666556.742,
    },
    'climate_change_worst_case' : {
        'launch_event' : 107643343.2,
        'launcher_production' : 11018755.48,
        'launcher_ait' : 1616263.557,
        'propellant_production' : 4793267.48,
        'propellant_scheduling' : 8984275.336,
        'launcher_transportation' : 11043.18682,
        'launch_campaign' : 5666556.742
        },
    'ozone_depletion_baseline' : {
        'launch_event' : 4997.16,
        'launcher_production' : 1.694648122,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.385083701,
        'propellant_scheduling' : 0.393635808,
        'launcher_transportation' : 0.002453918,
        'launch_campaign' : 0.777870405
        },
    'ozone_depletion_worst_case' : {
        'launch_event' : 22319.78,
        'launcher_production' : 1.694648122,
        'launcher_ait' : 0.156575296,
        'propellant_production' : 0.328436738,
        'propellant_scheduling' : 0.393635808,
        'launcher_transportation' : 0.002453918,
        'launch_campaign' : 0.777870405
        },
    'resource_depletion' : {
        'launch_event' : 0,
        'launcher_production' : 7128.37286,
        'launcher_ait' : 15.65466435,
        'propellant_production' : 19.82144123,
        'propellant_scheduling' : 218.7663315,
        'launcher_transportation' : 0.497682607,
        'launch_campaign' : 33.22600998
        },
    'freshwater_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 150478766.1,
        'launcher_ait' : 7701094.993,
        'propellant_production' : 9203497.148,
        'propellant_scheduling' : 29109377.02,
        'launcher_transportation' : 35251.42104,
        'launch_campaign' : 18683396.82
        },
    'human_toxicity' : {
        'launch_event' : 0,
        'launcher_production' : 10.32571748,
        'launcher_ait' : 0.486234151,
        'propellant_production' : 0.830068862,
        'propellant_scheduling' : 1.915739911,
        'launcher_transportation' : 0.003673529,
        'launch_campaign' : 1.695861368}
}