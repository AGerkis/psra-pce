% uq_design_exp_coh_opt.m
%
% Designs an experiment according to the coherence-optimal sampling method
% proposed in [1]. Uses Markov-Chain Monte-Carlo (MCMC) Sampling
% implemented using the Metropolis-Hastings Algorithm to generate samples
% from the target distribution, equation (34).
%
% Intended to be called from uq_design_exp and so does not support flexible
% input arguments. Assumes UQ-Lab was initialized at a higher level.
%
% Inputs:
%   in_model: The UQ-Lab formatted input model. [uq-input] (MANDATORY)
%   N: The number of points to include in each experiment. [Double] (MANDATORY)
%   N_exp: The number of experiments to generate. [Double] (MANDATORY)
%   Options: A structure containing options for the coherence-optimal algorithm. [struct] (MANDATORY)
%
% Outputs:
%   exp: A tensor containing the requested experiments. [N x M x N_exp]
%        Third dimension elements correspond to different experiments.
%
% Author: Aidan Gerkis
% Date: 23-05-2024
%
% References:
%   [1]: J. Hampton and A. Doostan, "Coherence motivated sampling and 
%          convergence analysis of least squares polynomial chaos regression,”
%          Computer Methods in Applied Mechanics and Engineering, vol. 290, 
%          pp. 73–97, 2015.
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
function exp = uq_design_exp_coh_opt(in_model, N, N_exp, Options)
    % Parse inputs
    k_burnin = Options.BurnIn; % Number of burnin samples
    k_decor = Options.DeCor; % Number of samples by which to space sampling for decorrelation
    meta_opts = Options.MetaOptions; % Options for PCE metamodel
    M = length(in_model.nonConst); % Size of random vector

    % Compute dummy model containing PCE parameters
    dummy = uq_dummy_model(meta_opts);
    
    % Set in_model as the active input model (for sampling)
    uq_selectInput(in_model);

    % Define target and proposed PDFs
    target_pdf = @(xi)uq_bsquared(dummy, xi);
    prop_pdf = @(xi, null)uq_evalPDF(xi, in_model);

    % Define sampling function
    sample_prop = @(null)uq_getSample(in_model, 1);
    
    % Define starting point
    start = zeros(1, M);
    
    % Number of samples to draw from the MCMC sampler
    N_mcmc = N*k_decor;

    % Generate experiments
    exp = zeros(N, M, N_exp);

    for i=1:N_exp
        % Compute samples by MCMC
        exp_mcmc = mhsample(start, N_mcmc, 'pdf', target_pdf, 'proppdf', prop_pdf, 'proprnd', sample_prop, 'burnin', k_burnin, 'symmetric', true);
        
        % Samples to use, only keep every k_decor-th sample for
        % decorrelation purposes
        indices = [1, linspace(1, N - 1, N - 1)*(k_decor)];
        
        % Save samples
        exp(:, :, i) = exp_mcmc(indices, :);
    end
end