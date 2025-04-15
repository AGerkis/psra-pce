% dist_euclidean.m
%
% Computes the euclidean distance between two vectors in R^n.
%   d(x, y) = sqrt(sum(x(i) - y(i))^2)
%
% Inputs:
%   x: The first vector for the distance measurement. [N x 1]
%   y: The second vector for the distance measurement. [N x 1]
%
% Outputs:
%   d: The euclidean distance between x & y. [Double]
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
function d = dist_euclidean(x, y)
    % Parse inputs
    Nx = size(x, 1);
    Ny = size(y, 1);
    
    if Nx ~= Ny % Check dimensions
        error("Dimension mismatch between x & y! Vectors must be the same dimension");
    end

    % Compute distance
    d = sqrt(sum((x - y).^2));
end