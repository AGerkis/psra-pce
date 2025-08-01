% uq_design_exp_maximin.m
%
% Designs N_exp experiments through the Maximin-LHS method [1]. Generates N_cand
% candidate experiments and compute the minimum distance in each set.
% Selects the N_exp experiments with the largest minimum distances as the final
% output.
%
% Intended to be called from uq_design_exp and so does not support flexible
% input arguments. Assumes UQ-Lab was initialized at a higher level.
%
% Inputs:
%   in_model: The UQ-Lab formatted input model. [uq-input] (MANDATORY)
%   N_S: The number of points to include in each experiment. [Double] (MANDATORY)
%   N_exp: The number of experiments to generate. [Double] (MANDATORY)
%   o: A structure containing options for the Maximin-LHS method. [struct] (MANDATORY)
%             - o.Distance: The distance function to use, may be a string
%                           ('Euclidean') or function handle (taking an
%                           N_in x N_S array as input).
%             - o.N_cand: The number of candidate LHS designs to generate. [Integer]
%
% Outputs:
%   exp: A tensor containing the requested experiments. [N x M x N_exp]
%        Third dimension elements correspond to different experiments.
%
% Author: Aidan Gerkis
% Date: 14-05-2024
%
% References:
%   [1] A. Gerkis and X. Wang, “Efficient probabilistic assessment of power 
%       system resilience using the polynomial chaos expansion method with 
%       enhanced stability,” in 2025 IEEE Power & Energy Society General 
%       Meeting (PESGM), Austin, TX, July 2025.
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
function exp = uq_design_exp_maximin(in_model, N_S, N_exp, o)
    uq_retrieveSession;
    
    % Parse options
    if isfield(o, "Distance") % Parse distance function
        if isa(o.Distance, "string") || isa(o.Distance, "char") % Option 1: Distance function is specified as a string, using one of the integrated functions
            switch o.Distance % Assign distance function
                case 'Euclidean'
                    dfun = @(x)exp_dist(x, 'Euclidean');
                otherwise
                    error("Unknown distance function specified!");
            end
        elseif isa(o.Distance, "function_handle") % Option 2: Distance function is specified as a function handle
            dfun = o.Distance;
        else
            error("Distance function specified incorrectly! It must be passed as a string or function handle.");
        end
    else % Use Euclidean distance function by defualt
        dfun =  @(x)exp_dist(x, 'Euclidean');
    end

    if N_S == 1 % Throw error if experiment is too small
        error("Can't compute Maximin-LHS experiments with size 1!");
    end

    % Get size of input vector
    M = length(in_model.Marginals);

    % Select input
    uq_selectInput(in_model.Name);
    
    % Initialize candidate tensor and distance array
    candidates = zeros(N_S, M, o.N_cand);
    d = zeros(1, o.N_cand);
    
    % Generate candidate experiments
    for i=1:o.N_cand
        % Generate candidate
        candidates(:, :, i) = uq_getSample(N_S, o.Sampling);

        % Evaluate distance
        d(i) = dfun(candidates(:, :, i));
    end

    % Find experiments with largest distances
    [~, idxs] = maxk(d, N_exp);
    
    % Create experiment
    exp = candidates(:, :, idxs);
end