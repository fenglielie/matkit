function check_duplicate_mfiles()
    % CHECK_DUPLICATE_MFILES Checks for duplicate MATLAB files in the project.
    %
    % This function searches for duplicate MATLAB files in search paths
    % and displays a warning message if any duplicates are found.
    % MATLAB system paths are excluded.

    allPaths = strsplit(path, pathsep);
    projPaths = allPaths(~contains(allPaths, 'MATLAB'));

    fileNames = {};

    for k = 1:numel(projPaths)
        files = dir(fullfile(projPaths{k}, '*.m'));

        for f = 1:numel(files)
            fileNames{end + 1} = files(f).name; %#ok<AGROW>
        end

    end

    uniqueNames = unique(fileNames);
    counts = zeros(size(uniqueNames));

    for i = 1:numel(uniqueNames)
        counts(i) = sum(strcmp(fileNames, uniqueNames{i}));
    end

    duplicateIdx = find(counts > 1);

    if ~isempty(duplicateIdx)
        msg = sprintf('Duplicate .m files found:\n');

        for i = duplicateIdx
            msg = [msg, sprintf('  %s : %d\n', uniqueNames{i}, counts(i))]; %#ok<AGROW>
        end

        warning(msg);
    end

end
