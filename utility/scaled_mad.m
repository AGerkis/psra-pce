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