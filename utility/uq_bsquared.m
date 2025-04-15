% uq_bsquared.m
%
% Evaluates B^2 for a given PCE basis and sample point according to
% equation (8) in [1].
%
% Inputs:
%   current_model: The PCE model on which to compute B^2. [uq-model]
%   xi: The points on which to compute B^2. [N x M double] 
%
% Outputs:
%   b: The B^2 value. [Double]
%
% Author: Aidan Gerkis
% Date: 22-05-2024
%
% References:
%   [1]: J. Hampton and A. Doostan, "Coherence motivated sampling and 
%          convergence analysis of least squares polynomial chaos regression,”
%          Computer Methods in Applied Mechanics and Engineering, vol. 290, 
%          pp. 73–97, 2015.
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
function b = uq_bsquared(current_model, xi)
    % Parse inputs
    if isempty(findprop(current_model, 'PCE'))
        error("Error in input: No PCE found in structure passed");
    end
    
    % Get number of samples
    N = size(xi, 1);

    % Get regressor matrix, computed with xi
    Psi = uq_get_psi(current_model, xi);
    Psi = Psi.^2;
    
    % Compute B^2 for each sample
    b = zeros(N, 1);

    for i=1:N
        b(i) = sum(Psi(i, :));
    end
end