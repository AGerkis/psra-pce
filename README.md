# psra-pce
PSRA-pce is a library for power system resilience assessment using polynomial chaos expansion (PCE) models. This library provides a framework for efficient global power system resilience assessment under uncertainty. It is based on [UQLab](https://www.uqlab.com/) [1] and the [PSres](https://github.com/AGerkis/ps-res/tree/main) resilience model. For a theoretical motivation and detailed overview of the psra-pce resilience assessment framework see _Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability_ by A. Gerkis and X. Wang [2].

# Licensing & Citing
This software is open source under the GNU GPLv3 license. All usage, re-production, and re-distribution of this software must respect the terms and conditions of this license.

We request that publications deriving from the use of the psra-pce library explicitly acknowledge that fact by citing the following publication:

A. Gerkis and X. Wang, “Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability,” in 2025 IEEE Power & Energy Society General Meeting (PESGM), Austin, TX, July 2025.

# Getting Started
To get psra-pce installed on your computer follow the directions below. MATLAB r2022a or later is recommended to use psra-pce.

## Dependencies
This library has the following dependencies, ensure these libraries are installed and working before using psra-pce!
1. [AC-CFM](https://github.com/mnoebels/AC-CFM)
2. [MATPOWER](https://matpower.org/)
3. [IPOPT](https://coin-or.github.io/Ipopt/)
4. [PSres](https://github.com/AGerkis/ps-res/tree/main)
5. [UQLab](https://www.uqlab.com/)

IPOPT is not strictly necessary, but may require changes to the PSres model set-up, see PSres documentation.

## Installation
To install psra-pce simply clone this repo into a convenient location on your computer:
1. `git clone https://github.com/AGerkis/psra-pce.git`
2. Add psra-pce to your MATLAB path (Home -> Set Path in the MATLAB tool bar).
3. 

# Introduction
This library efficiently assesses uncertainty in power system resilience using PCE models. A power system's resilience can be quantified through some resilience metric, measuring an extreme storm's impact on the system. In this documentation we assume that an extreme storm is modelled through the time at which power system components fail during that event, denoted in a vector $\boldsymbol{\tau}$. For more details see [2]. The resilience metric can then be expressed in the general form

<p align="center" width="100%">
$$\Omega = \mathcal{M}(\boldsymbol{\tau})$$    (1)

Here the model, $\mathcal{M}$, represents some function (i.e., PSres) computing a resilience metric. While (1) is deterministic, the component failure times, $\boldsymbol{\tau}$, will be random in nature [2]. This randomness will propagate to the metric, $\Omega$, meaning that resilience must be assessed probabilistically. 

To accomplish this efficiently, psra-pce applies PCE models of (1), which approximate $\Omega$ using a polynomial function of the form

<p align="center" width="100%">
$$\hat{\Omega} = \sum\limits_{i=1}^Nc_i\boldsymbol{\Psi}_i(\boldsymbol{\tau})$$    (2)

where $c_i$ are deterministic coefficients and $\boldsymbol{\Psi}$ are multivariate polynomials. The PCE model (2) can be computed from a small number of samples of the original model's response (1) and uncertainty in $\Omega$ can be assessed by directly computing $\Omega$'s moments and distribution from (2).

This libraries primary contribution is an enhanced PCE computation method, selecting the model response samples to more reliably and efficiently compute the PCE model (2). It also provides functions to compute the moments and distribution's of resilience metrics from PCE models. This library seamlessly integrates with the PSres library, supporting resilience assessment through arbitrary power system models and resilience metrics.

For more details on the psra-pce resilience assessment framework see _Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability_ by A. Gerkis and X. Wang [2].


# References
[1] S. Marelli and B. Sudret, “Uqlab: A framework for uncertainty quantification in matlab,” in 2nd International Conference on Vulnerability, uncertainty, and risk: quantification, mitigation, and management, Liverpool, United Kingdom, 2014, pp. 2554–2563.

[2] A. Gerkis and X. Wang, “Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability,” in 2025 IEEE Power & Energy Society General Meeting (PESGM), Austin, TX, July 2025.
