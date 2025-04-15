% exp_dist.m
%
% Analyzes the distance between each point in an experiment design consisting
% of N samples of M random variables. Outputs the minimum distance and 
% related statistics.
%
% Inputs:
%   x: The experiment to analyze. [N x M Double]
%   dfun: The distance function to use. [Char] (Optional)
%          - Euclidean: Uses the basic euclidean distance. (Default)
%   criteria: The distance to evaluate. [Char] (Optional)
%               - min: Evaluates the minimum distance. (Default)
%               - max: Evaluates the maximum distance.
%
% Outputs:
%   md: The minimum distance. [Double]
%   momd: The moments of the distance metric. [1 x 2 Double, Index 1: Mean,
%                                              Index 2: Standard Deviation]
%                                              (Optional)
%
% Author: Aidan Gerkis
% Date: 13-05-2024
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
function [md, momd] = exp_dist(x, dfun, criteria)
    % Parse inputs
    switch nargin % Assign defaults
        case 1
            dfun = 'Euclidean';
            criteria = 'min';
        case 2
            criteria = 'min';
    end
    
    % Assign distance function
    switch dfun
        case 'Euclidean'
            dfun = @(x, y)dist_euclidean(x, y);
        otherwise
            error("Unrecognized distance function requested.");
    end
    
    % Assign criteria function
    switch criteria
        case 'min'
            cfun = @(x)min(x);
        case 'max'
            cfun = @(x)max(x);
        otherwise
            error("Unrecognized criteria function requested.");
    end

    % Extract dimensions
    N = size(x, 1);
    
    % Create array to store distances
    % Second value is the total number of iterations
    d = zeros(1, N*N - sum(linspace(1, N-1, N-1)));
    
    idx = 1; % Track position in d

    % Loop through all samples and compute distance
    for i=1:N
        for j=i:N
            if i == j % Don't compute distance between an entry and itself, set to NaN and remove later
                d(idx) = NaN;
            else
                d(idx) = dfun(x(i, :).', x(j, :).');
            end

            idx = idx + 1;
        end
    end
    
    % Remove zero entries
    d = d(~isnan(d));
    
    % Analyze distance
    md = cfun(d); % Find minimum distance
    
    if nargout == 2 % Compute moments if requested
        momd(1) = mean(d);
        momd(2) = std(d);
    end
end