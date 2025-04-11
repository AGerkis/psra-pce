% psra_dist.m
%
% Approximates a resilience metric's distribution from a PCE model of the
% metric. Computes the 3sigma boundary on the metric values. Optionally
% compares the predicted PDF to a validation dataset, overlaying the
% distributions and computing the total variation between the
% distributions.
%
% Requires UQ-Lab to be initiated.
%
% Inputs:
%   m: The PCE model. [uq-model]
%   v: The validation dataset. [struct]
%       v.x: The model inputs [N_mcs x N_in double]
%       v.y: The model outputs [N_mcs x 1 double]
%    : If the validation dataset is not passed this can be N_D, the number
%      of datapoints to use when computing the distribution. [integer]
%
% Outputs:
%   d: The distribution approximation:
%       d.hist: Model evaluations. [N_mcs (or N_D) x 1 double]
%       d.dist: KDE estimate of distribution. [MATLAB distribution object]
%       d.pdf: PDF Evaluations. [n_s x 1 double]
%       d.cdf: CDF Evaluations. [n_s x 1 double]
%       d.rng: Values on which PDF and CDF were evaluated. [n_s x 1 double]
%   b: The three-sigma limits. [2 x 1 double]
%
% Author: Aidan Gerkis
% Date: 11/04/2025

function [d, b] = psra_dist(m, v)
    %% Parse Inputs & Assign parameters
    N_D = 10000; % Number of points to use when computing distribution
    n_s = 1000; % Number of points to use when plotting PDFs and CDFs
    K = 25; % Number of bins to use when computing total variation
    n_bins = 100; % Number of bins to use when plotting distributions
    validate = true; % Validate by default
    
    % Parse N_D if it was passed
    if nargin == 2
        if isa(v, 'numeric')
            N_D = v;
        end
    else % Create a dummy value of v so the next if statement works
        v = struct();
    end

    if nargin ~= 2 || isa(v, 'numeric') % If validation data was not passed
        validate = false;
        
        % Generate samples ()
        try
            v.x = uq_getSample(m.Options.Input, N_D); % Generate samples on which to evaluate PCE
        catch
            error("UQ-Lab Not Initiated!");
        end
    end

    %% Evaluate PCE model on samples
    try
        y_hat = uq_evalModel(m, v.x);
    catch
        error("UQ-Lab Not Initiated!");
    end

    %% Compute PDF from data
    % Fit distribution to data
    dist_hat = fitdist(y_hat, 'Kernel');

    if validate
        dist_true = fitdist(v.y, 'Kernel');
    end

    % Select dataset to use when specifying PDF range (prefers validation
    % data, if it exists)
    if validate
        y_pdf = v.y;
    else
        y_pdf = y_hat;

    end

    % Create array of points for evaluating PDF
    l_b = min(y_pdf);
    u_b = max(y_pdf);
    range = linspace(l_b, u_b, n_s)';

    % Compute PDF & CDF
    pdf_hat = pdf(dist_hat, range);
    cdf_hat = cdf(dist_hat, range);

    if validate
        pdf_true = pdf(dist_true, range);
        cdf_true = cdf(dist_true, range);
    end
    
    %% Compute 3sigma boundaries
    b = [m.PCE.Moments.Mean - 3*sqrt(m.PCE.Moments.Var), ...
         m.PCE.Moments.Mean + 3*sqrt(m.PCE.Moments.Var)];

    %% Compute Total Variation
    if validate
        tv = total_variation(y_pdf, y_hat, K);

        tv_title = sprintf(" - TV = %2.2f", tv); % String to put in title
    else
        tv_title = "";
    end

    %% Make Plots
    % Plot PDFs
    figure('Name', 'PDF Approximation');
    hold on;
    if validate
        h = histogram(v.y, n_bins);
        yyaxis right
        plot(range, pdf_true, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
        yyaxis left
        histogram(y_hat, h.BinEdges, 'FaceColor', [0.8500 0.3250 0.0980]);
        yyaxis right
        plot(range, pdf_hat, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'LineStyle', '-')
        legend(["True", "Approximate", "", ""]);
    else
        histogram(y_hat, n_bins, 'FaceColor', [0.8500 0.3250 0.0980]);
        yyaxis right
        plot(range, pdf_hat, 'r', 'LineWidth', 2)
    end
    ylabel("Probability");
    yyaxis left
    ylabel("Frequency");
    xlabel("Metric Value")
    title("PDF of Metric" + tv_title);
    grid on;
    hold off;
    xlim([min(range), max(range)]);
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';

    % Plot CDFs
    figure('Name', 'CDF Approximation');
    hold on;
    if validate
        h = histogram(v.y, n_bins, 'Normalization', 'cdf');
        yyaxis right
        plot(range, cdf_true, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
        yyaxis left
        histogram(y_hat, h.BinEdges, 'Normalization', 'cdf', 'FaceColor', [0.8500 0.3250 0.0980]);
        yyaxis right
        plot(range, cdf_hat, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'LineStyle', '-')
        legend(["True", "Approximate", "", ""]);
    else
        histogram(y_hat, n_bins, 'Normalization', 'cdf', 'FaceColor', [0.8500 0.3250 0.0980]);
        yyaxis right
        plot(range, cdf_hat, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2)
    end
    ylabel("Cumulative Probability");
    yyaxis left
    ylabel("Cumulative Frequency");
    xlabel("Metric Value")
    title("CDF of Metric" + tv_title);
    grid on;
    hold off;
    xlim([min(range), max(range)]);
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';

    %% Compile Outputs
    d.hist = y_hat;
    d.dist = dist_hat;
    d.pdf = pdf_hat;
    d.cdf = cdf_hat;
    d.rng = range;
end