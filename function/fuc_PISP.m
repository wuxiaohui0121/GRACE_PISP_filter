function [noise] = fuc_PISP(grid, time_step, PAR)
% PISP - Physical-Informed Spatial Pattern filter for
% Stripe noise extraction
%
% This function implements Physical-Informed Spatial Pattern (PISP) filter  
% algorithm to identify and extract stripe noise from GRACE satellite gravity field data 
% 
%
% SYNTAX:
%   [noise] = fuc_PISP(grid, time_step, PAR)
%
% INPUTS:
%   grid      - Input gravity field data, dimensions: [rows, cols, time_steps]
%   time_step - Time step index to process
%   PAR       - Parameters 
%
% OUTPUTS:
%   noise     - Identified stripe noise, dimensions: [rows, cols]
%
%
% AUTHOR: [Xiaohui Wu]
% EMAIl: [wuxiaohui@cug.edu.cn]
% DATE: [2025-08-04]
% VERSION: 1.0

% Extract latitude from parameter structure
lat = PAR.lat;

% Get dimensions of input data
[rows, cols, ~] = size(grid);

% Step 1: Data preprocessing
% Extract data for specified time step and remove row-wise mean
g_slice = grid(:, :, time_step);
g_slice = g_slice - mean(g_slice, 2);

% Apply latitude weighting correction (cosine weighting)
cos_weight = sqrt(cosd(lat))';
cos_weight(cos_weight < 0.01) = 0.01;  % Avoid extremely small weights at polar regions
g_weighted = g_slice ./ cos_weight;

% Initialize noise output
noise = zeros(rows, cols);


for idx = 1:size(g_slice, 1)
    % Find similar modes for sliding window denoising
    PAR.idx = idx;

    % Find similar frequency modes
    [filtered_grid, valid_indices, extrema_grid, PAR] = fuc_SimiFreqMod(g_weighted, PAR);

    % Skip if insufficient valid data points
    if length(valid_indices) < 6
        continue;
    end

    % Extract noise patterns
    [noise_grid] = fuc_FindNoise(filtered_grid, extrema_grid, valid_indices, PAR);

    % Store noise for current row
    current_row_mask = (valid_indices == idx);
    if any(current_row_mask)
        noise(idx, :) = noise_grid(current_row_mask, :);
    end

    % Display progress (optional)
    if mod(idx, 10) == 0 || idx == size(g_slice, 1)
        fprintf('Progress: %.1f%% (%d/%d rows completed)\n', ...
            (idx / size(g_slice, 1)) * 100, idx, size(g_slice, 1));
    end
end

% Step 2: Remove cosine weighting to restore original scale
noise = noise .* cos_weight;

fprintf('LSSA processing completed.\n');

end