% scaled_mad.m
%
% Computes the Scaled-MAD of a dataset A as
%   Scaled-MAD = c*median(A - median(A))
% Where the scaling factor is an optional input.
%
% Inputs:
%   A: The dataset on which to compute the Scaled-MAD. [N x 1 Double]
%   c: The scaling factor. [Optional] (Default ~= 1.4826)
%
% Outputs:
%   sm: The Scaled-MAD. [Double]
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
function sm = scaled_mad(A, c)
    % Parse inputs
    if nargin == 1 % Assign default values
        c = -1/(sqrt(2)*erfcinv(3/2));
    end

    % Compute median(A)
    mA = median(A);

    % Compute Scaled-MAD
    sm = c*median(abs(A - mA));
end