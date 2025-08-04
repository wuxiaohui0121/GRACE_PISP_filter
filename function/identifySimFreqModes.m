function [similar_modes] = identifySimFreqModes(U, S, V, extrema_grid, valid_indices, PAR)
% IDENTIFYSIMFREQMODES - Identify modes with similar frequency characteristics
%
% This function identifies SVD modes that have similar frequency patterns
% to the target extrema grid, which helps detect high-frequency noise.
%
% SYNTAX:
%   [similar_modes] = identifySimFreqModes(U, S, V, extrema_grid, valid_indices, PAR)
%
% INPUTS:
%   U             - SVD U matrix
%   S             - SVD S matrix (diagonal)
%   V             - SVD V matrix (rearranged)
%   extrema_grid  - Target extrema pattern grid
%   valid_indices - Valid row indices
%   PAR           - Parameter structure
%
% OUTPUTS:
%   similar_modes - Array of similar mode indices

    M = PAR.M;
    idx = PAR.idx;
    max_counts = PAR.max_counts;
    
    % Set thresholds
    count_tolerance = PAR.count_tolerance;
    position_tolerance = PAR.position_tolerance;
    
    similar_modes = [];
    
    % Find target index in valid_indices
    target_idx_in_valid = find(valid_indices == idx);
    
    if isempty(target_idx_in_valid)
        warning('Specified idx not found in valid_indices');
        return;
    end
    
    % Iterate through each mode
    for i = 1:size(U, 2)
        try
            % Reconstruct signal for current mode
            reconstructed_matrix = zeros(size(U, 1), M, size(V, 3));
            
            for j = 1:size(V, 3)
                reconstructed_matrix(:, :, j) = U(:, i) * S(i, i) * V(i, :, j);
            end
            
            % Reverse shift to restore original format
            for t = 1:M
                reconstructed_matrix(:, t, :) = circshift(reconstructed_matrix(:, t, :), t-1);
            end
            
            % Calculate average reconstructed signal
            noise_maybe = mean(reconstructed_matrix, 2);
            noise_maybe_2d = reshape(noise_maybe, size(U, 1), size(V, 3))';
            
            % Calculate pseudo-frequency characteristics
            [maxima_counts_recon, ~, extrema_positions_recon] = fuc_PseFreq(noise_maybe_2d);
            
            % Get characteristics for target row
            if target_idx_in_valid <= length(maxima_counts_recon)
                target_max_count_recon = maxima_counts_recon(target_idx_in_valid);
                target_extrema_recon = extrema_positions_recon(target_idx_in_valid, :);
                
                % Compare extrema count similarity
                count_diff = abs(target_max_count_recon - max_counts);
                count_similar = count_diff <= count_tolerance;
                
                % Compare extrema position similarity
                position_similarity = calculatePositionSimilarity(target_extrema_recon, ...
                                                                 extrema_grid, PAR);
                position_similar = position_similarity >= position_tolerance;
                
                % If both conditions are met, consider as similar mode
                if count_similar && position_similar
                    similar_modes = [similar_modes, i];
                end
            end
        catch
            % Handle reconstruction errors
            continue;
        end
    end
end