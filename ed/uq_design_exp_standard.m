% uq_design_exp_standard.m
%
% Designs N experiments through direct sampling of the specified method.
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

function exp = uq_design_exp_standard(in_model, N, N_exp, Options)
    uq_retrieveSession;
    
    % Get size of input vector
    M = length(in_model.Marginals);

    % Select input
    uq_selectInput(in_model);
    
    % Initialize output
    exp = zeros(N, M, N_exp);
    
    % Generate experiments
    for i=1:N_exp
        exp(:, :, i) = uq_getSample(N, Options.Sampling);
    end
end