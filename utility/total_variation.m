% total_variation.m
%
% Computes the total variation between two datasets, A & B, as
%           TV(A, B) = 0.5*sum(|P(A) - P(B)|)
% where the probabilities are computed with a discretization of each given
% distribution into K bins.
%
% Inputs:
%   A: The first distribution. [N x 1 double]
%   B: The second distribution. [M x 1 double]
%   K: The number of bins to use for the discretization. [double] (OPTIONAL)
%
% Outputs:
%   tv: The total variation between the two distributions. [double]
%
% Author: Aidan Gerkis
% Date: 18-06-2024

function tv = total_variation(A, B, K)
    % Parse inputs
    if nargin < 3 % assign defaults
        K = 100;
    end
    
    N_a = length(A); % Number of elements in A
    N_b = length(B); % Number of elements in B

    % Discretize space
    w_min = min([A; B], [], 'all'); % Smallest realization in all data
    w_max = max([A; B], [], 'all'); % Largest realization in all data

    w = linspace(w_min, w_max, K);

    % Compute probabilities
    P_a = histcounts(A, w)./N_a;
    P_b = histcounts(B, w)./N_b;

    % Compute TV
    tv = 0.5*sum(abs(P_a - P_b));
end