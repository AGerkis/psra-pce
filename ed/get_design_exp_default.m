% get_design_exp_default.m
%
% Returns the default options for the given experiment design method. Meant
% to be used with uq_design_exp.
%
% Inputs:
%   m: The experiment design method to return options for. [char]
%      May be one of: Standard, Maximin.
%
% Outputs:
%   o: The requested options structure. [struct]
%      
% Author: Aidan Gerkis
% Date: 15-04-2024

function o = get_design_exp_default(m)
    % Parse Input
    if nargin ~= 1
        error("Error in function call, unsupported number of inputs passed!");
    end
    
    % Initialize output
    o  = struct(); 

    % Set common parameters
    o.Method = m;
    o.Sampling = 'LHS';

    % Populate options structure
    switch m
        case 'Standard'
            % Do nothing
        case 'Maximin'
            o.N_cand = 5; %  Number of candidate designs to consider
            o.Distance = 'Euclidean'; % Distance function to use
        case 'Minimax'
            o.N_cand = 5; %  Number of candidate designs to consider
            o.Distance = 'Euclidean'; % Distance function to use
        case 'Coherence-Optimal'
            o.BurnIn = 25; % Number of burn-in samples
            o.DeCor = 5; % Number of samples to skip for decorrelation
            
            % Basic metamodel options
            o.MetaOptions.Type = 'Metamodel';
            o.MetaOptions.MetaType = 'PCE';
            o.MetaOptions.Method = 'LARS'; % Coefficient & Basis Computation Method
            o.MetaOptions.ExpDesign.Sampling = 'user'; % Indicate that user based sampling is used
            o.MetaOptions.Degree = 3:12; % Polynomial Degree to Use
            o.MetaOptions.TruncOptions.qNorm = 1; % Trunction Norm order - Use default to start
            o.MetaOptions.DegreeEarlyStop = true;
            o.MetaOptions.LARS.LarsEarlyStop = true;
            o.MetaOptions.LARS.ModifiedLoo = true;
            [o.MetaOptions.PolyTypes{1:12}] = deal('arbitrary'); % Set basis type
        otherwise
            error("Unknown experiment design method specified!");
    end
end