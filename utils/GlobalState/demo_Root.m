cd(fileparts(mfilename('fullpath')));
run('../../setup.m')

GlobalState.setRootHere();

disp(GlobalState.getRoot())
