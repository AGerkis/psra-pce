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