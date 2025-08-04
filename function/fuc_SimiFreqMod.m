function [filtered_grid, valid_indices, extrema_grid, PAR] = fuc_SimiFreqMod(grid, PAR)
% FUC_SIMIFREQMOD - Find similar frequency modes in gridded data
%
% This function identifies rows in a grid that have similar pseudo-frequency
% characteristics to a target row. It's designed for preprocessing satellite
% gravity data to group similar spatial patterns for noise reduction.
%
% SYNTAX:
%   [filtered_grid, valid_indices, extrema_grid, PAR] = fuc_SimiFreqMod(grid, PAR)
%
% INPUTS:
%   grid - Input grid data, dimensions: [rows, cols]
%          Typically represents latitude × longitude gravity field data
%   PAR  - Parameter structure containing:
%          .idx  - Target row index for similarity comparison
%          .freq - Frequency tolerance threshold for similarity matching
%
% OUTPUTS:
%   filtered_grid - Filtered grid containing only similar frequency rows
%   valid_indices - Array of row indices with similar frequencies
%   extrema_grid  - Extrema positions for the target row
%   PAR          - Updated parameter structure with additional fields:
%                  .max_counts - Maximum count of extrema in target row
%
%
% AUTHOR: [Xiaohui Wu]
% DATE: [2025-08-04]
% VERSION: 1.0
%
% SEE ALSO: fuc_PseFreq

% Input validation
if nargin < 2
    error('fuc_SimiFreqMod:InvalidInput', 'Both grid and PAR parameters are required');
end

if ~isnumeric(grid) || isempty(grid) || ndims(grid) ~= 2
    error('fuc_SimiFreqMod:InvalidInput', 'Grid must be a non-empty 2D numeric array');
end

if ~isstruct(PAR) || ~isfield(PAR, 'idx') || ~isfield(PAR, 'freq')
    error('fuc_SimiFreqMod:InvalidInput', 'PAR must contain idx and freq fields');
end

% Extract parameters
target_idx = PAR.idx;
freq_tolerance = PAR.freq;

% Get pseudo-frequency characteristics for all rows
[maxima_counts, lat, extrema_positions] = fuc_PseFreq(grid);

% Get grid dimensions
[num_rows, num_cols] = size(grid);

% Validate target index
if target_idx < 1 || target_idx > num_rows
    error('fuc_SimiFreqMod:InvalidIndex', ...
          'Target row index (%d) is outside valid range [1, %d]', ...
          target_idx, num_rows);
end

% Get frequency characteristics of target row
target_freq = maxima_counts(target_idx);
target_extrema = extrema_positions(target_idx, :);

% Initialize valid indices list with target row
valid_indices = target_idx;

% Search backwards (left) from target row
for i = (target_idx - 1):-1:1
    freq_diff = abs(maxima_counts(i) - target_freq);
    
    if freq_diff <= freq_tolerance
        valid_indices = [i, valid_indices];  % Prepend index
    else
        break;  % Frequency difference exceeds tolerance
    end
end

% Search forwards (right) from target row
for i = (target_idx + 1):num_rows
    freq_diff = abs(maxima_counts(i) - target_freq);
    
    if freq_diff <= freq_tolerance
        valid_indices = [valid_indices, i];  % Append index
    else
        break;  % Frequency difference exceeds tolerance
    end
end

% Validate that we have valid indices
if isempty(valid_indices)
    warning('fuc_SimiFreqMod:NoValidIndices', 'No valid indices found');
    filtered_grid = [];
    extrema_grid = [];
    return;
end

% Extract filtered grid data using valid indices
filtered_grid = grid(valid_indices, :);

% Extract extrema pattern for target row
extrema_grid = target_extrema;

% Update parameter structure
PAR.max_counts = target_freq;
PAR.valid_indices = valid_indices;
PAR.target_freq = target_freq;

% Optional: Validate output consistency
if size(filtered_grid, 1) ~= length(valid_indices)
    error('fuc_SimiFreqMod:InconsistentOutput', ...
          'Filtered grid rows (%d) do not match valid indices count (%d)', ...
          size(filtered_grid, 1), length(valid_indices));
end

end