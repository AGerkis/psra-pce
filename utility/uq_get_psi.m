% uq_get_psi.m
%
% Builds the regressor matrix for a PCE metamodel that has already been
% computed using UQ-Lab. Can compute the regressor matrix for a new sample set
% or for the experiment used to compute the metamodel coefficients.
%
% Inputs:
%   current_model: The PCE metamodel for which to build the regressor
%                  matrix. [uq-model]
%   X: The points on which to compute the regressor matrix. [N x M matrix] (OPTIONAL)
%
% Outputs:
%   Psi: The regressor matrix for the PCE, computed using the experiment. [N x P double]
%           N - Number of samples in experiment.
%           P - Size of basis.
%
% Author: Aidan Gerkis
% Date: 21-05-2024
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
function Psi = uq_get_psi(current_model, X)
    % Parse input
    if isempty(findprop(current_model, 'PCE'))
        error("Error in input: No PCE found in structure passed");
    end
    
    % Retrieve uniformly distributed sample points
    if nargin == 1 % If no points were passed then use the experiment design within the PCE
        U = current_model.ExpDesign.U;
    else % Transform X to a uniformly distributed space
        % Retrieve the probabilistic input models
        Input = current_model.Internal.Input;
        ED_Input = current_model.Internal.ED_Input;

        % Perform isoprobabilistic transform to uniform space
        U = uq_GeneralIsopTransform(X, Input.Marginals, Input.Copula, ED_Input.Marginals, ED_Input.Copula);
    end

    % Get non-zero coefficients
    coeffs = current_model.PCE.Coefficients; % Full coefficient array
    nz_idx = find(coeffs); % Indices of non-zero elements

    % Get indices of bases elements corresponding to non-zero coefficients
    bases_idx = full(current_model.PCE.Basis.Indices(nz_idx, :)); % Convert from sparse to full

    % Evaluate polynomials on design
    cur_unipoly = uq_PCE_eval_unipoly(current_model, U);

    % Build regressor matrix
    Psi = uq_PCE_create_Psi(bases_idx, cur_unipoly);
end