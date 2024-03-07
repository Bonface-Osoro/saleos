# Sustainability Analytics for Low Earth Orbit Satellites (saleos)

Welcome to the Sustainability Analytics for Low Earth Orbit Satellites 
(`saleos`) repository.

There is increasing concern about adverse environmental impacts produced by 
Low Earth Orbit (LEO) megaconstellations. The `saleos` codebase provides an 
open-source integrated assessment model capable of concurrently estimating 
environmental emissions, broadband capacity, and social and financial costs 
for different LEO satellite networks.

We focus on evaluating Amazon's Kuiper, Eutelsat's OneWeb and SpaceX's Starlink,
with these three LEO constellations visualized in `Figure 1`. The `saleos` 
codebase allows you to compare these LEO constellations against a representative
Geostationary Earth Orbit (GEO) operator.  

#### Figure 1 Three key LEO constellations: Kuiper, OneWeb and Starlink (Details as of December 2023).
<p align="center">
  <img src="/docs/a_fig_1.png" />
</p>

Emissions produced during the launching of satellites depend on the 
utilized rocket vehicle. Most operators planning or launching LEO broadband 
satellites have used (or intend to use) SpaceX’s Falcon-9 or Falcon-Heavy, 
the European Space Agency’s Ariane rocket system, or prior to Spring 2022, 
Russia’s Soyuz-FG rocket, as detailed in `Figure 2`. 

#### Figure 2 Details of launch rocket systems.
<p align="center">
  <img src="/docs/b_fig_2.png" />
</p>


## Sustainability metrics

The `saleos` codebase is capable of estimating a range of sustainability 
metrics. `Figure 3` illustrates a selection of these including the estimated 
annual emissions per subscriber (subplot b), potential mean peak capacity per 
subscriber (subplot c), and the financial costs per subscriber (subplot e/f).

#### Figure 3 Aggregate sustainability metrics for Kuiper, OneWeb, Starlink and a hypothetical GEO operator.
<p align = 'center'>
  <img src= '/docs/c_aggregate_metrics.png' />
</p>

## Method

The method is based on (i) a Life Cycle Assessment (LCA) model of environmental 
emissions and other impacts,(ii) a stochastic engineering simulation model 
estimating constellation capacity using the Friss Transmission Equation, (iii) 
potential traffic demand based on different adoption scenarios, and (iv) a 
techno-economic model of the associated social and financial costs. `Figure 4` 
illustrates the integrated assessment approach.

#### Figure 4 Integrated assessment method.
<p align = 'center'>
  <img src= '/docs/method_box_diagram.png' />
</p>

## Required data

To use `saleos` the following model input datasets are required from `data/raw`: 
1. `life_cycle_data.xlsx`: This dataset contains estimated emissions and 
other environmental impacts per launch for major rocket vehicles. 
2. `scenarios.csv` : This file contains the past and future launch information
for different constellations, including hydrocarbon (HYC) versus hydrogen (HYD) 
fuel-based rockets. 

Using conda
-----------
The recommended installation method is to use conda, which handles packages 
and virtual environments, along with the conda-forge channel which has a host 
of pre-built libraries and packages.

Create a conda environment called saleos:

  `conda create --name saleos python=3.7 gdal`

Activate it (run this each time you switch projects):

  `conda activate saleos`

Alternatively, to install a conda environment capable of running the model, 
you can utilize the following code:

  `conda env create -f saleos.yml`

The `saleos.yml` file represents an existing virtual environment with a 
variety of packages, necessary for running the model (e.g., pandas, numpy etc.).

First, to run `saleos` you need to generate uncertain capacity and cost 
parameters since they are not deterministic.

So navigate to the `scripts` folder and run `preprocess.py`. This will produce 
two capacity and cost.csv files named `uq_parameters_capacity.csv` and 
`uq_parameters_cost.csv` stored in the path `data/processed`.

Secondly, run the whole integrated model to produce capacity, emission and 
cost results by running the simulation script (`run.py`). It should first 
produce the following intermediate results stored in the folder 
`data/processed`:

1. `interim_results_capacity.csv`
2. `interim_results_cost.csv`

Next, you can inspect the model outputs stored in the `results` folder:

1. `individual_emissions.csv`
2. `final_capacity_results.csv`
3. `final_capacity_cost.csv`

Lastly, to visualize the results, you will navigate into the `vis` folder 
and run the following `r` scripts in any order.

1. `aggregate_metrics.r`
2. `emissions.r`
3. `capacity.r`
4. `social_cost.r`
5. `cost.r`

Quick start
-----------
To quick start, install the `saleos` package.

  `python setup.py install`

Or if you want to develop the package:

   `python setup.py develop`

Then run the scripts in the order defined in the previous section (`Using conda`).

Citation
---------
Ogutu, O. B., Oughton, E. J., Wilson, A. R, & Rao, A. (2023). Sustainability 
assessment of Low Earth Orbit (LEO) satellite broadband mega-constellations. 
arXiv preprint arXiv:2309.02338.

Background and funding
----------------------

**saleos** has been developed by researchers at George Mason University, 
University of Strathclyde and Middlebury College.

## Team
- Bonface Osoro, George Mason University (Model development).
- Edward Oughton, George Mason University (Project lead and corresponding 
author).
- Andrew Wilson, University of Strathclyde / Glasgow Caledonian University 
(LCIA modeling).
- Akhil Rao, Middlebury College (Policy and economics).

Acknowledgement
---------------
We would like to thank George Mason University's department of Geography and 
Geoinformation Science for funding the project. Secondly, we would like to 
thank Nils Pacher and Dr. Inigo del Portillo of Massachusetts Institute of 
Technology (MIT), Aeronautics and Astronautics Department for providing the 
orbital parameter data of Starlink, OneWeb and Kuiper as well as a reproducible 
python code for modeling the orbit of the three LEO constellations. We would 
also like to thank Dr. Whitney Lohmeyer of Olin College of Engineering for 
informally reviewing the capacity model. Lastly, we would like to thank two 
anonymous reviewers and one satellite industry expert who provided substantial 
scientific feedback on the peer-reviewed manuscript and capacity model 
respectively that helped in enhancing quality and key contribution to the 
literature. 