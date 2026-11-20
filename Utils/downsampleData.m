%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                      FUNCTION: downsampleData
%            Part of the Space Vehicle Simulator Tool Suite
%                Copyright (C) 2022-2026 Mark Lieberbaum
%                         All rights reserved
%
% File Name: downsampleData.m
%
% Description: This function reduces the data rate of a data structure,
%              with the format of the data being the transpose of the SVS
%              data output.
%
% Inputs:
%   svsData:    Data structure with original sample rate
%   nSample:    Downsample factor (output will contain a point every
%               nSample samples)
%
% Outputs: dataOut: Data structure with reduced sample rate
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function svsData = downsampleData(svsData, nSample)
    
    % If this field is a structure, we need to recursively call this
    % function to perform downsampling on all non-structure fields
    if isstruct(svsData)

        % Get fieldnames of each substructure and create a unique list
        substructFieldnames = fieldnames(svsData);

        % Downsample each element of the structure array
        for idx = 1:numel(substructFieldnames)

            % Name of the current substructure field
            curSubstructField = substructFieldnames{idx};

            % If this field is itself a substructure, ecursively call this 
            % function for each element of the substructure.  Otherwise, 
            % call this function on the array
            if isstruct(svsData.(curSubstructField))
                for idx2 = 1:numel(svsData.(curSubstructField))
                    svsData.(curSubstructField)(idx2) = downsampleData(svsData.(curSubstructField)(idx2), nSample);
                end
            else
                svsData.(curSubstructField) = downsampleData(svsData.(curSubstructField), nSample);
            end

        end

    else

        % 3d array accounts for inertia matrix outputs, etc.
        svsData = svsData(:, 1:nSample:end, :);

    end

end
