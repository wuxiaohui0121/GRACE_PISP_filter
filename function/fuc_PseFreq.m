function [maxima_counts, lat, extrema_positions] = fuc_PseFreq(grid)
% FUC_PSEFREQ - Calculate pseudo-frequency characteristics and extrema positions
%
% This function analyzes pseudo-frequency characteristics of gridded data by
% identifying local maxima and minima along each latitude band. It's particularly
% useful for analyzing spatial frequency patterns in satellite gravity data.
%
% SYNTAX:
%   [maxima_counts, lat, extrema_positions] = fuc_PseFreq(grid)
%
% INPUTS:
%   grid - Input grid data, dimensions: [rows, cols]
%          Typically represents latitude × longitude gravity field data
%
% OUTPUTS:
%   maxima_counts     - Number of local maxima per row, dimensions: [rows, 1]
%   lat              - Latitude array corresponding to grid rows, dimensions: [1, rows]
%   extrema_positions - Extrema position array, dimensions: [rows, cols]
%                      Values: 1 = local maximum position
%                             -1 = local minimum position
%                              0 = other positions
%
%
% AUTHOR: [Xiaohui Wu]
% EMAIl: [wuxiaohui@cug.edu.cn]
% DATE: [2025-08-04]
% VERSION: 1.0
%

% Input validation
if nargin < 1
    error('fuc_PseFreq:InvalidInput', 'Input grid data is required');
end

if ~isnumeric(grid) || isempty(grid)
    error('fuc_PseFreq:InvalidInput', 'Grid must be a non-empty numeric array');
end

if ndims(grid) ~= 2
    error('fuc_PseFreq:InvalidInput', 'Grid must be a 2D array');
end

% Get grid dimensions
[num_latitudes, num_longitudes] = size(grid);

% Initialize output arrays
maxima_counts = zeros(num_latitudes, 1);
extrema_positions = zeros(num_latitudes, num_longitudes);


% Process each latitude band
for lat_idx = 1:num_latitudes
    try
        % Extract data along current latitude
        y = grid(lat_idx, :);
        
        % Skip processing if all values are NaN or constant
        if all(isnan(y)) || (max(y) - min(y)) < eps
            continue;
        end
        
        % Find local maxima
        mask_max = islocalmax(y, 'MinProminence', 0);
        maxima_counts(lat_idx) = sum(mask_max);
        
        % Find local minima  
        mask_min = islocalmin(y, 'MinProminence', 0);
        
        % Mark extrema positions in the output array
        extrema_positions(lat_idx, mask_max) = 1;   % Mark maxima as +1
        extrema_positions(lat_idx, mask_min) = -1;  % Mark minima as -1
        % Other positions remain 0 (default value)
        
    catch ME
        warning('fuc_PseFreq:ProcessingError', ...
                'Error processing latitude band %d: %s', lat_idx, ME.message);
        continue;
    end
end

% Calculate latitude coordinates
% Assumes uniform global latitude spacing from 90°N to 90°S
lat_resolution = 180 / num_latitudes;
lat_center_offset = lat_resolution / 2;

% Generate latitude array (center of each latitude band)
lat = (90 - lat_center_offset) : (-lat_resolution) : (-90 + lat_center_offset);

% Ensure latitude array has correct dimensions
if length(lat) ~= num_latitudes
    warning('fuc_PseFreq:LatitudeMismatch', ...
            'Latitude array length (%d) does not match grid rows (%d)', ...
            length(lat), num_latitudes);
    % Truncate or pad as needed
    if length(lat) > num_latitudes
        lat = lat(1:num_latitudes);
    else
        lat = [lat, repmat(lat(end), 1, num_latitudes - length(lat))];
    end
end

% Summary statistics
total_maxima = sum(maxima_counts);
avg_maxima_per_lat = mean(maxima_counts);
max_maxima_per_lat = max(maxima_counts);

end