clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));

logger = Logger(level=Logger.DEBUG, format='level');

% 支持传入格式化字符串
logger.debug('Processing item %d of %d...', 5, 100);
logger.info('User %s has logged in', 'Alice');
logger.warn('Disk space low: %0.2f G remaining', 4.75);
logger.error('Failed to open file: %s', 'data.csv');

% logger.error_plus('Disk space low: %0.2f G remaining', 4.75);

logger2 = Logger(level=Logger.INFO, format='timestamp_and_level');
logger2.open_file_trunc('tmp.log');
logger2.info('hello');
logger2.debug('hello');
logger2.close_file();
