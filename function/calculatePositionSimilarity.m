function similarity = calculatePositionSimilarity(extrema1, extrema2, PAR)
% CALCULATEPOSITIONSIMILARITY - Calculate similarity between two extrema position sequences
%
% This function computes the similarity between two extrema sequences by
% comparing the positions and types of extrema points within a tolerance range.
%
% SYNTAX:
%   similarity = calculatePositionSimilarity(extrema1, extrema2, PAR)
%
% INPUTS:
%   extrema1 - Reference extrema sequence (1=maximum, -1=minimum, 0=other)
%   extrema2 - Comparison extrema sequence (1=maximum, -1=minimum, 0=other)
%   PAR      - Parameter structure
%
% OUTPUTS:
%   similarity - Similarity score (0-1 range)

    % Ensure sequences have same length
    min_len = min(length(extrema1), length(extrema2));
    extrema1 = extrema1(1:min_len);
    extrema2 = extrema2(1:min_len);
    
    % Find positions of all extrema in extrema1
    extrema1_positions = find(extrema1 ~= 0);
    
    % Return 0 similarity if no extrema in reference sequence
    if isempty(extrema1_positions)
        similarity = 0;
        return;
    end
    
    % Count matches (same sign and opposite sign)
    same_matched_count = 0;
    opposite_matched_count = 0;
    
    % Check each extrema point in extrema1
    for i = 1:length(extrema1_positions)
        pos = extrema1_positions(i);
        target_value = extrema1(pos);
        opposite_value = -target_value;
        
        % Define search range around current position
        left_pos = max(1, pos - PAR.position_lr);
        right_pos = min(min_len, pos + PAR.position_lr);
        check_range = left_pos:right_pos;
        
        % Check values in extrema2 within the range
        range_values = extrema2(check_range);
        
        % Check for same-sign match (same extrema type)
        if any(range_values == target_value)
            same_matched_count = same_matched_count + 1;
        % Check for opposite-sign match (opposite extrema type)
        elseif any(range_values == opposite_value)
            opposite_matched_count = opposite_matched_count + 1;
        end
    end
    
    % Calculate similarity scores
    total_extrema = length(extrema1_positions);
    same_similarity = same_matched_count / total_extrema;
    opposite_similarity = opposite_matched_count / total_extrema;
    
    % Total similarity: maximum of same-sign and opposite-sign similarities
    % This accounts for both in-phase and anti-phase matching
    similarity = max(same_similarity, opposite_similarity);
    
end