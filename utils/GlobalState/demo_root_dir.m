cd(fileparts(mfilename('fullpath')));
run('../../setup.m')

GlobalState.set_root();

disp(GlobalState.get_root())
