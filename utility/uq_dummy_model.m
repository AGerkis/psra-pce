% uq_dummy_model.m
%
% Makes a 'dummy' PCE model for a given option set, consisting of all of
% the model properties and parameters, with a full coefficient set
% initialized to all ones. Intended for use cases where the model
% parameters (i.e. polynomial types and form) are needed, but the computed
% PCE model is not.
%
% Assumes that a user designed experiment is passed.
%
% Inputs: 
%   opt: The options with which to create the dummy model. [struct]
%
% Outputs:
%   dummy: The dummy model. [uq-model]
%
% Author: Aidan Gerkis
% Date: 23-05-2024
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
function dummy = uq_dummy_model(opt)
    % Parse inputs
    M = length(opt.Input.nonConst); % Get number of random variable inputs
    if isfield(opt.ExpDesign, 'CY') % Set number of samples
        N = size(opt.ExpDesign.CY, 1);
    else
        N = 15; 
    end
    deg_max = opt.Degree(end); % Maximum degree
    
    % Generate dummy experiment design
    opt.ExpDesign.X = rand(N, M);
    opt.ExpDesign.Y = zeros(N, 1);

    % Set degree to a single value (otherwise the lowest degree will be
    % returned)
    opt.Degree = deg_max;
    
    % Turn off outputs
    opt.Display = 'quiet';
    
    % Create dummy model
    dummy = uq_createModel(opt);

    % Set coefficients array to all ones
    dummy.PCE.Coefficients = ones(length(dummy.PCE.Coefficients), 1);
end