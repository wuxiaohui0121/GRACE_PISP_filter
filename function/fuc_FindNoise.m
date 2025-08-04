function [noise] = fuc_FindNoise(grid, extrema_grid, valid_indices, PAR)
% FUC_FINDNOISE - Find and extract noise modes using PISP
%
% This function identifies and extracts noise patterns from gravity field data
% using PISP. It combines two complementary methods: high-frequency noise detection 
% and coupled mode identification to iteratively extract stripe noise.
%
% SYNTAX:
%   [noise] = fuc_FindNoise(grid, extrema_grid, valid_indices, PAR)
%
% INPUTS:
%   grid           - Input gravity field data, dimensions: [rows, cols]
%   extrema_grid   - Extrema pattern grid for frequency analysis
%   valid_indices  - Array of valid row indices for processing
%   PAR            - Parameter structure 
%
% OUTPUTS:
%   noise          - Extracted noise patterns, dimensions: [rows, cols]
%
%
% AUTHOR: [Xiaohui Wu]
% EMAIl: [wuxiaohui@cug.edu.cn]
% DATE: [2025-08-04]
% VERSION: 1.0

% Extract parameters
num_shifts = PAR.max_shift;
corr_threshold = PAR.corr;
M = PAR.M;

% Get data dimensions
[rows, cols] = size(grid);

% Step 1: Apply sliding window transformation
grid_reshaped = reshape(grid', cols, 1, rows);
grid_windowed = zeros(cols, M, rows);

% Apply sliding window
for j = 1:M
    grid_windowed(:, j, :) = circshift(grid_reshaped, 1-j);
end

% Reshape for SVD
Z = reshape(grid_windowed, cols, M*rows);

% Perform SVD decomposition
[U, S, V] = svd(Z, 'econ');

% Keep only first 20 principal components
U1 = U(:, 1:20);
[n, m] = size(U1);

% Rearrange V for subsequent operations
V = reshape(V, M, rows, cols);
V = permute(V, [3, 1, 2]);

% Initialize variables for iterative processing
shift_coupled_modes = zeros(n, num_shifts*2+1);
reconstructed_matrix = zeros(cols, M, rows);
noise_incremental = zeros(cols, 1, rows);
g_windowed = grid_windowed; % Copy for iterative updates


% Main iterative loop for noise extraction
while PAR.FM == 1
    % Method 1: Identify similar frequency modes (high-frequency noise)
    [similar_modes] = identifySimFreqModes(U1, S, V, extrema_grid, valid_indices, PAR);

    % Method 2: Identify coupled modes based on correlation
    coupled_flags = false(m, 1);
    coupled_flags = identifyCoupledModes(U1, m, num_shifts, corr_threshold, ...
        coupled_flags, shift_coupled_modes);
    coupled_modes = find(coupled_flags);

    % Combine and process overlapping modes
    [combined_noise_modes, overlap_info] = identifyOverlapModes(similar_modes, ...
        coupled_modes);

    % Check termination condition
    if isempty(combined_noise_modes) || all(combined_noise_modes == 0)
        PAR.FM = 0;
        break;
    end

    % Reconstruct signal from identified noise modes
    noise_flags = false(m, 1);
    noise_flags(combined_noise_modes) = true;

    % Reconstruct noise-related signal for each latitude
    for lat_idx = 1:rows
        if any(noise_flags)
            reconstructed_matrix(:, :, lat_idx) = ...
                U1(:, noise_flags) * S(noise_flags, noise_flags) * V(noise_flags, :, lat_idx);
        end
    end

    % Reverse shift to restore original data format
    for t = 1:M
        reconstructed_matrix(:, t, :) = circshift(reconstructed_matrix(:, t, :), t-1);
    end

    % Calculate average reconstructed signal (noise increment)
    noise_increment = mean(reconstructed_matrix, 2);
    noise_incremental = noise_incremental + noise_increment;

    % Remove identified noise from data
    grid_reshaped = grid_reshaped - noise_increment;

    % Reapply sliding window for next iteration
    for window_idx = 1:M
        g_windowed(:, window_idx, :) = circshift(grid_reshaped, 1-window_idx);
    end

    % Perform SVD decomposition for next iteration
    Z = reshape(g_windowed, cols, M*rows);
    [U, S, V] = svd(Z, 'econ');
    U1 = U(:, 1:20);
    V = reshape(V, M, rows, cols);
    V = permute(V, [3, 1, 2]);
end

% Step 5: Post-processing - convert accumulated noise back to original coordinate system
noise = reshape(noise_incremental, cols, rows)';


end