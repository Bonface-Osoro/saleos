# Sustainability Analytics for Low Earth Orbit Satellites (saleos)
Connecting the other 45% of the unconnected world population in areas with no form of coverage will require use of spacebourne technologies. Low Earth Orbit (LEO) satellites are fronted as an alternative due to relatively low cost of production and lower latency. However, placing the thousands of satellites in orbit required to provide global coverage will need several single event launch missions. 
To date, there exists no open-source integrated emission, capacity, cost and coverage models for assessing broadband LEO networks. Several questions remain unanswered.
How does the emissions due to launch of LEO broadband satellites compare to the capacity they provide and costs needed to place and keep them operational? How does the emission for every subscriber compare to terristrial systems?
Therefore, this `saleos` repository provides code to help model emission in tandem with capacity, cost and coverage. 

Citation
---------
Osoro, B., & Oughton, E. (2022). Universal Broadband Assessment of Low Earth Orbit Satellite Constellations: Evaluating Capacity, Coverage, Cost, and Environmental Emissions. Coverage, Cost, and Environmental Emissions (August 2, 2022) [https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4178732].

Example Method
==============

The method is based on a stochastic engineering simulation model which estimates the capacity based on Friss Transmission Equation, costs and emissions. The emissions by the rockets used by the constelllations are modelled by applying the steps defined in previous literature and relating to the number and mass of satellites as well as the number of single launch events.  

The assumptions and uncertainties is taken into account in the integrated model by treating the key inputs that affect the capacity, demand, cost and coverage models as uncertain parameters. The parameters are set into a range of three values (low, baseline, high).Figure 1 illustrates this method.

## Figure 1 Emission, Capacity and Cost method for satellite broadband assessment
<p align="center">
  <img src="/docs/Box_model.png" />
</p>

Example Results
==============

Rather than estimating only aggregated network capacity results, the purpose of the
`saleos` repository (as reported in the affiliated paper) is to provide insight on the potential amount of emission for every subscriber served and how it compares to the terrestrial systems. 
Example scenarios are applied in the modeling process, and results for the estimated emission per subscriber are visualized in Figure 2.

## Figure 2 Estimated per user emission and comparison with terrestrial systems for three LEO constellations
<p align="center">
  <img src="/docs/pub_emission.png" />
</p>