% uq_design_exp_maximin.m
%
% Designs N experiments through the maximin criteria. Generates N_cand
% candidate experiments and compute the minimum distance in each set.
% Selects the N experiments with the largest minimum distances as the final
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
% Date: 14-05-2024

function exp = uq_design_exp_maximin(in_model, N, N_exp, Options)
    uq_retrieveSession;
    
    % Parse options
    switch Options.Distance % Assign distance function
        case 'Euclidean'
            dfun = @(x)exp_dist(x, 'Euclidean');
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
        d(i) = exp_dist(candidates(:, :, i));
    end

    % Find experiments with largest distances
    [~, idxs] = maxk(d, N_exp);
    
    % Create experiment
    exp = candidates(:, :, idxs);
end