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