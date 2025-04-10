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