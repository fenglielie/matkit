cd(fileparts(mfilename('fullpath')));
addpath('../new')

logger = Logger();

% 直接传入格式化字符串
logger.debug('Processing item %d of %d...', 5, 100);
logger.info('User %s has logged in', 'Alice');
logger.warn('Disk space low: %0.2f%% remaining', 4.75);
% logger.error('Failed to open file: %s', 'data.csv');


clear logger; % 释放资源

Logger(format='none',o=false,file='abc.txt').info('hello')
