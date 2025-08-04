function [combined_modes, overlap_info] = identifyOverlapModes(similar_modes, coupled_modes)
% IDENTIFYOVERLAPMODES - Identify and process overlapping modes from two methods
%
% SYNTAX:
%   [combined_modes, overlap_info] = identifyOverlapModes(similar_modes, coupled_modes, PAR)
%
% INPUTS:
%   similar_modes - Similar frequency modes found by method 1
%   coupled_modes - Coupled modes found by method 2
%
% OUTPUTS:
%   combined_modes - Combined mode indices (union of both methods)
%   overlap_info   - Structure containing overlap information

    overlap_info = struct();
    
    % Find overlapping modes
    overlap_modes = intersect(similar_modes, coupled_modes);
    
    % Simple combination: take union of both methods
    combined_modes = union(similar_modes, coupled_modes);
    
    % Record overlap information
    overlap_info.overlap_modes = overlap_modes;
    overlap_info.total_overlap = length(overlap_modes);
    overlap_info.method1_modes = similar_modes;
    overlap_info.method2_modes = coupled_modes;
    overlap_info.combined_count = length(combined_modes);
    
end