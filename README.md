# PSRA-PCE
PSRA-PCE is a library for power system resilience assessment using polynomial chaos expansion (PCE) models. It is intended to be an extension of the PSres library, providing a framework for efficient global power system resilience assessment under uncertainty. It is based on [UQLab](https://www.uqlab.com/) [1] and the [PSres](https://github.com/AGerkis/ps-res/tree/main) resilience model. For a theoretical motivation and detailed overview of the PSRA-PCE resilience assessment framework see [_Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability_](https://arxiv.org/abs/2501.09857) by A. Gerkis and X. Wang [2].

# Licensing & Citing
This software is open source under the GNU GPLv3 license. All usage, re-production, and re-distribution of this software must respect the terms and conditions of this license.

We request that publications deriving from the use of the PSRA-PCE library explicitly acknowledge that fact by citing the following publication:

A. Gerkis and X. Wang, “Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability,” in 2025 IEEE Power & Energy Society General Meeting (PESGM), Austin, TX, July 2025.

# Getting Started
To get PSRA-PCE installed on your computer follow the directions below. MATLAB r2022a or later is recommended to use PSRA-PCE.

## Dependencies
This library has the following dependencies, ensure these libraries are installed and working before using PSRA-PCE!
1. [AC-CFM](https://github.com/mnoebels/AC-CFM)
2. [MATPOWER](https://matpower.org/)
3. [IPOPT](https://coin-or.github.io/Ipopt/)
4. [PSres](https://github.com/AGerkis/ps-res/tree/main)
5. [UQLab](https://www.uqlab.com/)

IPOPT is not strictly necessary, but changes to the PSres model set-up are required if this library is not installed, see PSres documentation.

## Installation
To install PSRA-PCE simply clone this repo into a convenient location on your computer:
1. `git clone https://github.com/AGerkis/PSRA-PCE.git`
2. Add PSRA-PCE to your MATLAB path (Home -> Set Path in the MATLAB tool bar).

# Introduction
This library efficiently assesses uncertainty in power system resilience using PCE models. A power system's resilience can be quantified through some resilience metric, measuring an extreme storm's impact on the system. In this documentation we assume that an extreme storm is modelled through the time at which power system components fail during that event, denoted in a vector $\boldsymbol{\tau}$. For more details see [2]. The resilience metric can then be expressed in the general form

$$
\Omega = \mathcal{M}(\boldsymbol{\tau})
$$

Here the model, $\mathcal{M}$, represents some function (i.e., PSres) computing a resilience metric. While $\mathcal{M}$ is deterministic, the component failure times, $\boldsymbol{\tau}$, will be random in nature [2]. This randomness will propagate to the metric, $\Omega$, meaning that resilience must be assessed probabilistically. 

To accomplish this efficiently, PSRA-PCE computes PCE models of $\Omega$, which approximate $\Omega$ using a polynomial function of the form

$$
\hat{\Omega} = \sum\limits_{i=1}^Nc_i\boldsymbol{\Psi}_i(\boldsymbol{\tau})
$$

where $c_i$ are deterministic coefficients and $\boldsymbol{\Psi}$ are multivariate polynomials. The PCE model can be computed from a small number of samples of the original model's response, and uncertainty in $\Omega$ can be assessed by directly computing $\Omega$'s moments and distribution from $\hat{\Omega}$.

This libraries primary contribution is an enhanced PCE computation method, selecting the model response samples to more reliably and efficiently compute the PCE model. It also provides functions to compute the moments and distribution's of resilience metrics from PCE models. This library seamlessly integrates with the PSres library, supporting resilience assessment through arbitrary power system models and resilience metrics.

For more details on the PSRA-PCE resilience assessment framework see _Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability_ by A. Gerkis and X. Wang [2].

# Usage
The PSRA-PCE library leverages PCE models of an existing power system resilience model, notated $\mathcal{M}$, to assess resilience. In this library we assume $\mathcal{M}$ to be the [PSres](https://github.com/AGerkis/ps-res/tree/main) model, although an arbitrary resilience model can be applied.

To apply the PSRA-PCE model a resilience model must first be defined, computing a resilience metric (i.e., the $\Phi_{LS}$ metric defined by Panteli et al. [3]) as a function of random component failures. This model can be defined using the PSres model's explicit input mode and defining random component failures using UQLab's input module, resulting in a resilience model in the format

$$
\Omega = \mathcal{M}(\boldsymbol{\tau})
$$

Then, a PCE model of $\Omega$ can be computed by generating an experiment (consisting of $N_S$ input-output samples $[\Omega, \boldsymbol{\tau}]$) using the `gen_exp` function in [PSres](https://github.com/AGerkis/ps-res/tree/main) and one of the experiment design methods (e.g., Maximin-LHS) provided in this library. Using this experiment, a PCE model of $\Omega$ can be computed using [UQLab](https://www.uqlab.com/) and applied to assess resilience through the moments (using `psra_moments`) and distribution (using `psra_dist`) of $\Omega$.

# Example
To showcase how PSRA-PCE can be applied to assess resilience an example is included, assessing the IEEE 39-Bus test system's resilience to an extreme storm through the $\Phi_{\textrm{LS}}$ metric. For a complete description of the test case see [2].

### Initialization
First the UQLab library must be initialized

`uqlab;`

### Experiment Generation
Once the appropriate libraries have been intialized we then need to generate the response samples (i.e., experiment) from which the PCE model will be computed. In this example we apply the Maximin-LHS experiment design method proposed in [2].

First, we need to specify the number of response samples to use when computing the PCE model

```
sim_opt.n_s = 120;
```
The resilience model, inputs, and corresponding parameters must then be specified. In this example we make use of a UQLab-formatted input. See the UQLab documentation for more details. First, specify the number of model inputs and outputs
```
sim_opt.n_in = 12;
sim_opt.n_out = 10;
```
Then, load the input model and assign it to the options structure
```
load("example_input_39bus.mat");
sim_opt.input = uq_createInput(input.Options);
```
Finally, specify the resilience model. Here, we make use of the UQLab model format for ease of evaluation.
```
Params = ps_resilience_params("39bus_exp");
Params.output = [1 1]; 
model_opts.mFile = 'uq_psres';
model_opts.Parameters = Params;
sim_opt.model = uq_createModel(model_opts);
```
The final step before the experiment can be generated is to specify the experiment design method. Here we use the Maximin-LHS method, with a Euclidean distance function and $N_C = 50$ candidate LHS designs.
```
exp_opt.Method = 'Maximin';
exp_opt.Distance = 'Euclidean';
exp_opt.N_cand = 50;
```
We then specify the experiment design method as a function handle
```
design_exp = @(N)uq_design_exp(sim_opt.input, N, 1, exp_opt);
```
And finally, we can generate the experiment, evaluating $\Omega$ from $N_S$ input samples
```
exp = gen_exp(sim_opt, design_exp);
```

### PCE Model Computation
Using the generated experiment we can then compute the PCE model using the UQLab library. First we need to specify the PCE model options, including the maximum polynomial degree, $q$-norm truncation, and experiment to use. For a detailed overview of the PCE model computation options see the UQLab documentation.

The PCE model computation options are first specified
```
load("pce_input_39bus.mat");

PCEOpts.Type = 'Metamodel';
PCEOpts.MetaType = 'PCE';
PCEOpts.Method = 'LARS'; 
PCEOpts.ExpDesign.Sampling = 'user';
PCEOpts.Degree = 3:12;
PCEOpts.TruncOptions.qNorm = [1, 0.75, 0.5, 0.25, 0.1];
PCEOpts.DegreeEarlyStop = true;
PCEOpts.LARS.LarsEarlyStop = true;
PCEOpts.LARS.ModifiedLoo = true;
PCEOpts.Input = uq_createInput(input.Options);
[PCEOpts.PolyTypes{1:6}] = deal('arbitrary');
```
And the experiment is then set. Here we compute a PCE model of the $\Phi_{\textrm{LS}}$ metric, so the inputs are the component failure times (the first 6 entries in the experiment inputs) and the outputs are the $\Phi_{\textrm{LS}}$ values (the first row in the experiment outputs).
```
PCEOpts.ExpDesign.X = exp.in(:, 1:6);
PCEOpts.ExpDesign.Y = exp.out(:, 1);
```
Finally, we can compute the PCE model
```
pce_model = uq_createModel(PCEOpts);
```

### Resilience Assessment
The computed resilience model can then be applied to assess the system's resilience. The moments of the metric can be computed
```
[mean, variance] = psra_moments(pce_model);
```
and the metric's distribution can be plotted
```
[distribution, boundaries] = psra_dist(pce_model);
```
For this example the output of `psra_moments` should approximately match
<p align="center" width="100%">
<img src="https://github.com/user-attachments/assets/cec8fa51-e32d-4261-b9ba-59f71f78f25a" alt="`psra_moments` output" width="300">
</p>
and the output plots of `psra_dist` should approximately match
<p align="center" width="100%">
<img src="https://github.com/user-attachments/assets/5819ef3e-df74-4102-af23-ebd96c9ff671" alt="`psra_dist` PDF output" width="400">
<img src="https://github.com/user-attachments/assets/8b7c1db8-135d-42a5-a1ba-532b46166ec0" alt="`psra_dist` CDF output" width="400">
</p>

Note that the outputs will not match exactly due to the inherent randomness when computing PCE models.

# Final Thoughts
Please note that this codebase is not actively maintained. Theoretical background and validation of the PSRA-PCE framework can be found in [2], and a detailed overview of uncertainty quantification through PCE models is available in the UQLab documentation [1]. Good luck, and happy modelling!

# References
[1] S. Marelli and B. Sudret, “Uqlab: A framework for uncertainty quantification in matlab,” in 2nd International Conference on Vulnerability, uncertainty, and risk: quantification, mitigation, and management, Liverpool, United Kingdom, 2014, pp. 2554–2563.

[2] A. Gerkis and X. Wang, “Efficient probabilistic assessment of power system resilience using the polynomial chaos expansion method with enhanced stability,” in 2025 IEEE Power & Energy Society General Meeting (PESGM), Austin, TX, July 2025.

[3] M. Panteli, P. Mancarella, D. N. Trakas, E. Kyriakides, and N. D. Hatziargyriou, “Metrics and quantification of operational and infrastructure resilience in power systems,” IEEE Transactions on Power Systems, vol. 32, no. 6, pp. 4732–4742, Nov. 2017.
