function allCs = checkConds(allCs)
% allCs = checkConds(allCs)
%
% Auto-fills missing fields / values
% of condition struct.
%
% Obligatory fields and their values can easily added using
% the fields3have cell array.
%
% Add [] as a values if you don't want to allow
% standard values for that field.
%
% _______________________
%
% Written by as 12/2013

    % specify all fields that shall be checked
    % with std values
    fields2have = {
        'name',          []; ...       
        'dur',           []; ...
        'staticDots',     0; ...
        'semiStaticDots', 0; ...
        'dots2D',         0; ...
        'dots3D',         0; ...
        'radRot',         0; ...
        'dotScramble3D',  0; ...
        'fov',            1; ...
        'movFix',         0  ...
        };

    % check matrix
    checkVec = zeros(1,size(fields2have,1));

    c = allCs(1);
    newCs = struct;
    
    % get fieldnames of c0
    fields2check =  fieldnames(c);

    % check fields
    for currField2have = 1 : size(fields2have, 1)
        fieldIsSet = 0;

        % check every field found in c
        for currField2Check = 1 : length(fieldnames(c))
            if strcmp(fields2have{currField2have}, fields2check{currField2Check})
                fieldIsSet = 1;
            end
        end

        % set field for all conds
        if ~fieldIsSet
                        
            % fill field
            for i = 1 : length(allCs)
                % add field to all conds
                allCs(i).(fields2have{currField2have, 1}) = [];
                allCs(i) = setfield(allCs(i), fields2have{currField2have, 1}, fields2have{currField2have, 2});
            end
        end
    end

    % auto-fill in missing values and throw out error
    % if std value is '[]'
    for i = 1 : length(allCs)

        for f = 1 : size(fields2have,1)

            if isempty(getfield(allCs(i), fields2have{f,1}))

                % is the std value empty as well?
                if isempty(fields2have{f,2})
                    error('Field: %s must not be empty! Check condition #%d', fields2have{f,1}, i)
                else
                    % fill in std value
                    allCs(i) = setfield(allCs(i), fields2have{f, 1}, fields2have{f, 2});
                end

            end
        end
    end


return;

end