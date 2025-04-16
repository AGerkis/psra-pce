% psra_moments.m
%
% Approximates a resilience metric's moments from a PCE model of the
% metric. Optionally compares the approximated metrics to a validation 
% dataset, overlaying the distributions and computing the total variation 
% between the distributions.
%
% Requires UQ-Lab to be initiated.
%
% Inputs:
%   m: The PCE model. [uq-model]
%   v: The validation dataset. [struct]
%       v.x: The model inputs [N_mcs x N_in double]
%       v.y: The model outputs [N_mcs x 1 double]
%
% Outputs:
%   mu: The mean estimate. [double]
%   std: The variance estimate. [double]
%
% Author: Aidan Gerkis
% Date: 11/04/2025
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
function [mu, std] = psra_moments(m, v)
    %% Parse Inputs
    validate = (nargin == 2); % Check if validation should be performed

    %% Extract moment approximations from PCE model
    mu = m.PCE.Moments.Mean;
    std = sqrt(m.PCE.Moments.Var);

    %% Compare to validation data
    if validate
        % Compute True Moments
        mu_true = mean(v.y);
        std_true = scaled_mad(v.y, 1.16);

        % Print to Console
        fprintf("%%%%%%%%%%%% Moment Validation %%%%%%%%%%%%\n");
        fprintf("   True Mean: %2.2f\n", mu_true);
        fprintf("   Approximate Mean: %2.2f\n", mu);
        fprintf("   Approximation Error: %2.2f%%\n\n", 100*abs((mu-mu_true)/mu_true));

        fprintf("   True Mean: %2.2f\n", std_true);
        fprintf("   Approximate Mean: %2.2f\n", std);
        fprintf("   Approximation Error: %2.2f%%\n\n", 100*abs((std-std_true)/std_true));
    end
end