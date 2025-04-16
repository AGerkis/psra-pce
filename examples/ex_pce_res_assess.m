% ex_pce_res_assess.m
%
% An example highlighting how PSRA-PCE can be applied to assess power
% system resilience. Computes a PCE model of the Phi_LS resilience metric
% in the 39-Bus system.
%
% Author: Aidan Gerkis
% Date: 10-04-2025
%
% This file is part of PSRA-PCE.
% Copyright © 2025 Aidan Gerkis
%
% PSRA-PCE is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option) 
% any later version.
% 
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
% for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program.  If not, see <http://www.gnu.org/licenses/>.

clear; close all; clc;
uqlab;

%% Specify Simulation Options
sim_opt = struct(); % Create empty structure

% Simulation Parameters
sim_opt.n_s = 200; % Number of model evaluations to perform in MCS
sim_opt.plotting = 0; % Don't plot results of experiment

% Model Parameters
sim_opt.n_in = 12; % Number of model inputs (2*Size of Active Set)
sim_opt.n_out = 10; % Computing all metrics for 2 indicators

% Specify Inputs for Experiment Generation
load("example_input_39bus.mat");
sim_opt.input = uq_createInput(input.Options);

% Specify Model
Params = ps_resilience_params("39bus_exp"); % Get default parameters
Params.output = [1 1]; % Compute only Phi_LS metric
model_opts.mFile = 'uq_psres';
model_opts.Parameters = Params;

sim_opt.model = uq_createModel(model_opts); % Create Model

%% Specify Experiment Design Function
% Define options
exp_opt = struct();
exp_opt.Method = 'Maximin'; % Specify Maximin design method
exp_opt.Distance = 'Euclidean'; % Use Euclidean distance to compute Maximin distances
exp_opt.N_cand = 50; % Number of candidate designs for MmLHS

% Create function handle
design_exp = @(N)uq_design_exp(sim_opt.input, N, 1, exp_opt);

%% Generate experiments
exp = gen_exp(sim_opt, design_exp);

%% Compute PCE Models
% Here PCE models are computed for the system response in the disturbance
% stage. For this reason the recovery time inputs (in array positions 7:12)
% are ignored.

% Specify PCE Inputs
load("pce_input_39bus.mat");

% Define PCE Model Options
PCEOpts.Type = 'Metamodel';
PCEOpts.MetaType = 'PCE';
PCEOpts.Method = 'LARS'; % Coefficient & Basis Computation Method
PCEOpts.ExpDesign.Sampling = 'user'; % Indicate that an experiment has already been computed
PCEOpts.Degree = 3:12; % Maximum polynomial Degree to Use
PCEOpts.TruncOptions.qNorm = [1, 0.75, 0.5, 0.25, 0.1]; % Trunction Norm order - Use default to start
PCEOpts.DegreeEarlyStop = true;
PCEOpts.LARS.LarsEarlyStop = true;
PCEOpts.LARS.ModifiedLoo = true;
PCEOpts.Input = uq_createInput(input.Options); % Assign Input
[PCEOpts.PolyTypes{1:6}] = deal('arbitrary'); % Set basis type

% Assign experiment to PCE Options structures
PCEOpts.ExpDesign.X = exp.in(:, 1:6); % Assign inputs
PCEOpts.ExpDesign.Y = exp.out(:, 1); % Assign corresponding outputs

% Compute PCE Model
pce_model = uq_createModel(PCEOpts);

%% Assess Resilience
% Load Validation Data
load("validation_data");
val.x = validation.in(:, 1:6);
val.y = validation.out(:, 1);

% Approximate Moments
[mean, variance] = psra_moments(pce_model, val);

% Approximate Distribution;
[distribution, boundaries] = psra_dist(pce_model, val, true);