function check_duplicate_mfiles()
    % CHECK_DUPLICATE_MFILES Checks for duplicate MATLAB files in the project.
    %
    % This function searches for duplicate MATLAB files in search paths
    % and displays a warning message if any duplicates are found.
    % MATLAB system paths are excluded.

    allPaths = strsplit(path, pathsep);
    projPaths = allPaths(~contains(allPaths, 'MATLAB'));

    stk = dbstack('-completenames');

    if numel(stk) == 1 % invoke from command line, add current directory

        if ~any(strcmp(pwd, projPaths))
            projPaths{end + 1} = pwd;
        end

    end

    fileNames = {};
    filePaths = {};

    for k = 1:numel(projPaths)
        files = dir(fullfile(projPaths{k}, '*.m'));

        for f = 1:numel(files)
            fileNames{end + 1} = files(f).name; %#ok<AGROW>
            filePaths{end + 1} = fullfile(projPaths{k}, files(f).name); %#ok<AGROW>
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

        for i = 1:numel(duplicateIdx)
            name = uniqueNames{duplicateIdx(i)};
            msg = [msg, sprintf('  %s:\n', name)]; %#ok<AGROW>

            for j = 1:numel(fileNames)

                if strcmp(fileNames{j}, name)
                    msg = [msg, sprintf('    %s\n', filePaths{j})]; %#ok<AGROW>
                end

            end

        end

        warning(msg);
    end

end
