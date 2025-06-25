GlobalState.save_path_once();
fprintf('call save_path_once:\nsaved_path=%s\n', GlobalState.get_saved_path());

GlobalState.save_path_once();
fprintf('call save_path_once:\nsaved_path=%s\n', GlobalState.get_saved_path());

% Modify current path by adding a dummy folder
dummy = fullfile(pwd, 'dummy');

if ~exist(dummy, 'dir')
    mkdir(dummy);
end

addpath(dummy);
fprintf('Add dummy path: %s to path\nPATH=%s\n', dummy, path);

GlobalState.save_path_once();
fprintf('call save_path_once:\nsaved_path=%s\n', GlobalState.get_saved_path());

GlobalState.save_path_force();
fprintf('call save_path_force:\nsaved_path=%s\n', GlobalState.get_saved_path());

rmpath(dummy);
fprintf('Remove dummy path\nPATH=%s\n', path);

GlobalState.restore_saved_path();
fprintf('call restore_saved_path:\nPATH=%s\n', path);

rmpath(dummy);
fprintf('Remove dummy path\nPATH=%s\n', path);

GlobalState.clean_saved_path();
fprintf('call clean_saved_path:\nsaved_path=%s\n', GlobalState.get_saved_path());
