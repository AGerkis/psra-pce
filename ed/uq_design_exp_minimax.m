% uq_design_exp_minimax.m
%
% Designs N experiments through the minimax criteria. Generates N_cand
% candidate experiments and compute the maximum distance in each set.
% Selects the N experiments with the smallest maximum distances as the final
% output.
%
% Intended to be called from uq_design_exp and so does not support flexible
% input arguments. Assumes UQ-Lab was initialized at a higher level.
%
% Inputs:
%   in_model: The UQ-Lab formatted input model. [uq-input] (MANDATORY)
%   N: The number of points to include in each experiment. [Double] (MANDATORY)
%   N_exp: The number of experiments to generate. [Double] (MANDATORY)
%   Options: A structure containing various options pertaining to the
%            requested sampling method OR the method to use. [struct] (MANDATORY)
%
% Outputs:
%   exp: A tensor containing the requested experiments. [N x M x N_exp]
%        Third dimension elements correspond to different experiments.
%
% Author: Aidan Gerkis
% Date: 21-08-2024
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
function exp = uq_design_exp_minimax(in_model, N, N_exp, Options)
    uq_retrieveSession;
    
    % Parse options
    switch Options.Distance % Assign distance function
        case 'Euclidean'
            dfun = @(x)exp_dist(x, 'Euclidean', 'max');
        otherwise
            error("Unknown distance function specified!");
    end

    if N == 1 % Throw error if experiment is too small
        error("Can't compute Maximin-LHS experiments with size 1!");
    end

    % Get size of input vector
    M = length(in_model.Marginals);

    % Select input
    uq_selectInput(in_model.Name);
    
    % Initialize candidate tensor and distance array
    candidates = zeros(N, M, Options.N_cand);
    d = zeros(1, Options.N_cand);
    
    % Generate candidate experiments
    for i=1:Options.N_cand
        % Generate candidate
        candidates(:, :, i) = uq_getSample(N, Options.Sampling);

        % Evaluate distance
        d(i) = dfun(candidates(:, :, i));
    end

    % Find experiments with largest distances
    [~, idxs] = mink(d, N_exp);
    
    % Create experiment
    exp = candidates(:, :, idxs);
end