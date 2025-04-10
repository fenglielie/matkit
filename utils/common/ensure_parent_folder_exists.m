function ensure_parent_folder_exists(target_file)
    % Ensure the parent folder of the target file exists
    %
    % INPUT
    %   target_file - The path of the target file (can be a full path or relative)

    % Get the parent folder of the target file
    [folder, ~, ~] = fileparts(target_file);

    % Create the parent folder if it doesn't exist
    if ~isempty(folder) && ~isfolder(folder)
        mkdir(folder);
        disp(['Parent folder created: ', folder]);
    end

end
