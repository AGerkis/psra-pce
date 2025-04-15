% uq_design_exp.m
%
% Designs N experiments, consisting of a set of input random variable
% realizations on which to evaluate the deterministic model, according to
% some criteria. Options include:
%   Standard: Compute N experiments via the specified sampling method. (Default)
%   Maximin: Compute N_cand candidate experiments via the specified sampling 
%            method and select the N experiments with the largest minimum
%            distance.
% Returns the experiments as an N x M matrix, where N is the number of
% experiments requested and M is the number of random variables in each
% experiment.
%
% Inputs:
%   in_model: The UQ-Lab formatted input model. [uq-input] (MANDATORY)
%   N: The number of points to include in each experiment. [Double] (MANDATORY)
%   N_exp: The number of experiments to generate. [Double] (OPTIONAL)
%   method: A structure containing various options pertaining to the
%            requested sampling method OR the method to use. If just the 
%            method is specified then the default options will be used. [struct OR char] (OPTIONAL)
%               - Method: A string specifying the sampling method to use. [char] (MANDATORY)
%               - Sampling: The sampling method with which to generate
%                           candidate experiments. [char]
%               - N_cand: The number of candidate experiments to consider. [Double] (Maximin)
%               - Distance: The distance function to use when evaluating maximin. [Char] (Maximin)
%               - BurnIn: The number of burnin samples to generate. [Double] (Coherence-Optimal)
%               - DeCor: The number of decorrelation samples to use. [Double] (Coherence-Optimal)
%               - MetaOptions: The option structure for the metamodel which
%                              the experiment will be used to generate. [struct] (Coherence-Optimal)
%
% Outputs:
%   exp: A tensor containing the requested experiments. [N x M x N_exp]
%        Third dimension elements correspond to different experiments.
%
% Author: Aidan Gerkis
% Date: 14-05-2024
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
function exp = uq_design_exp(in_model, N, N_exp, method)
    uq_retrieveSession;
    
    % Parse Inputs
    switch nargin % Assign default values
        case 2
            N_exp = 1;
            Options = get_design_exp_default('Standard');
        case 3
            Options = get_design_exp_default('Standard');
        case 4
            % Check if a structure was passed
            if ~isa(method, "struct") % If a char was passed then use defaults
                Options = get_design_exp_default(method);
            else % Otherwise process the input structure
                Options_user = method;

                if isfield(Options_user, 'Method')
                    Options = get_design_exp_default(Options_user.Method);
                else
                    error("No experiment design method specified!");
                end

                % Determine which fields the user has specified as custom
                cust_opts = fieldnames(Options_user);

                for i=1:length(cust_opts)
                    % Check that the requested field is valid
                    if isfield(Options, cust_opts{i})
                        % Override default options with custom value
                        Options.(cust_opts{i}) = Options_user.(cust_opts{i});
                    else
                        error("Unknown option specified in 'Options'!");
                    end
                end
            end
    end
    
    % Process method and call appropriate function
    switch Options.Method
        case 'Standard'
            exp = uq_design_exp_standard(in_model, N, N_exp, Options);
        case 'Maximin'
            exp = uq_design_exp_maximin(in_model, N, N_exp, Options);
        case 'Minimax'
            exp = uq_design_exp_minimax(in_model, N, N_exp, Options);            
        case 'Coherence-Optimal'
            % Need to assign an additional parameter to the metamodel options
            Options.MetaOptions.Input = in_model;

            exp = uq_design_exp_coh_opt(in_model, N, N_exp, Options);
    end
end