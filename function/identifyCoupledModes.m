function [coupled_flags] = identifyCoupledModes(U1, m, num_shifts, corr_threshold, ...
                                              coupled_flags, shift_coupled_modes)
% IDENTIFYCOUPLEDMODES - Identify spatially coupled modes
%
% This function identifies modes that are coupled through spatial shifts,
% which often indicate stripe noise patterns in satellite gravity data.
%
% SYNTAX:
%   [coupled_flags] = identifyCoupledModes(U1, m, num_shifts, corr_threshold, 
%                                         coupled_flags, shift_coupled_modes)
%
% INPUTS:
%   U1               - First 20 columns of U matrix from SVD
%   m                - Number of modes to check
%   num_shifts       - Maximum shift amount
%   corr_threshold   - Correlation threshold for coupling detection
%   coupled_flags    - Pre-allocated boolean flag array
%   shift_coupled_modes - Pre-allocated array for storing shifted modes
%
% OUTPUTS:
%   coupled_flags    - Boolean array identifying coupled modes

    for i = 1:m
        for j = i+1:min(i+2, m)
            % Apply different shifts to mode j
            for shift = -num_shifts:num_shifts
                shift_index = num_shifts + shift + 1;
                shift_coupled_modes(:, shift_index) = circshift(U1(:, j), shift);
            end
            
            % Combine current mode with all shifted modes
            U_expanded = [U1(:, i), shift_coupled_modes];
            
            % Calculate correlation coefficient matrix
            try
                correlation = corrcoef(U_expanded);
                corr_values = correlation(1, 2:end);
                
                % Mark as coupled if high correlation (positive or negative) exists
                % and modes are close in index
                if max(abs(corr_values)) > corr_threshold && abs(i-j) <= 2
                    coupled_flags(i) = true;
                    coupled_flags(j) = true;
                end
            catch
                % Handle correlation calculation errors
                continue;
            end
        end
    end
end