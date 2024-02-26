"""
Cost Simulation model for saleos.

Developed by Bonface Osoro and Ed Oughton.

May 2022

"""
import math
import numpy as np
from itertools import tee
from collections import Counter
from collections import OrderedDict

def opex_cost(regulation_fees, ground_station_energy, staff_costs,
              subscriber_acquisition, maintenance, discount_rate, 
              assessment_period):
    """
    This function calculates operating expenditures

    Parameters
    ----------
    regulation_fees : int.
        Orbital fees cost.
    ground_station_energy : int.
        ground station cost.
    staff_costs : int.
        staff costs.
    subscriber_acquisition : int.
        customer marketing and promotion cost.
    maintenance : int.
        maintenance cost.
    discount_rate : float.
        discount rate.
    assessment_period : int.
        assessment period equivalent 
        to the satellite lifespan.

    Returns
    -------
    annual_opex : float
            The operating expenditure costs annually.
    """

    opex_costs = (regulation_fees + ground_station_energy + staff_costs 
                  + subscriber_acquisition + maintenance) 

    year_costs = []
 
    for time in range(0, assessment_period):  
        
        yearly_opex = opex_costs / (((discount_rate / 100) + 1) ** time)
        year_costs.append(yearly_opex)
   
    annual_opex = sum(year_costs)


    return annual_opex


def cost_model(satellite_manufacturing, satellite_launch_cost, 
    ground_station_cost, regulation_fees, fiber_infrastructure_cost, 
    ground_station_energy, subscriber_acquisition, staff_costs,
    maintenance, discount_rate, assessment_period):
    """
    Calculate the total cost of ownership(TCO) in US$:

    Parameters
    ----------
    satellite_manufacturing : int.
        satellite manufacturing cost.
    satellite_launch_cost : int.
        cost of launching satellites.
    ground_station_cost : int.
        cost of constructing a ground station.
    regulation_fees : int.
        Orbital fees cost.
    fiber_infrastructure_cost : int.
        cost of connecting the ground stations to fiber backbone.
    ground_station_energy : int.
        ground station cost.
    subscriber_acquisition : int.
        customer marketing and promotion cost.
    staff_costs : int.
        staff costs.
    maintenance : int.
        maintenance cost.
    discount_rate : float.
        discount rate.
    assessment_period : int.
        assessment period equivalent to the satellite lifespan.

    Returns
    -------
    total_cost_ownership : float
            The total cost of ownership.

    """

    capex = (satellite_manufacturing + satellite_launch_cost 
             + ground_station_cost + fiber_infrastructure_cost) 

    opex_costs = (regulation_fees + ground_station_energy + staff_costs 
                  + subscriber_acquisition + maintenance) 

    year_costs = []

    for time in np.arange(1, assessment_period):  

        yearly_opex = opex_costs / (((discount_rate / 100) + 1) ** time)
        year_costs.append(yearly_opex)

    total_cost_ownership = capex + sum(year_costs) + opex_costs


    return total_cost_ownership


def user_monthly_cost(tco_per_user, lifespan):
    """
    Calculate average monthly cost per user:

    Parameters
    ----------
    tco_per_user : float.
        Total cost per user.
    lifespan : int
        The lifespan of the satellite accounting 
        for period of assessment

    Returns
    -------
    user_monthly_cost : float
            Average monthly amount per user.

    """
    user_monthly_cost = tco_per_user / (lifespan * 12)


    return user_monthly_cost