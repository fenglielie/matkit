clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));

Logger.set_global_level_debug();

logger1 = Logger(level = Logger.DEBUG, format = 'level');

logger1.debug('Processing item %d of %d...', 5, 100);
logger1.info('User %s has logged in', 'Alice');
logger1.warn('Disk space low: %0.2f G remaining', 4.75);
logger1.error('Failed to open file: %s', 'data.csv');
% logger1.error_plus('Disk space low: %0.2f G remaining', 4.75);

logger2 = Logger(level = Logger.INFO, format = 'timestamp_and_level');
logger2.open_file_trunc('tmp.log');
logger2.info('hello');
logger2.debug('hello');
logger2.close_file();

Logger.set_global_level_info();

logger3 = Logger().set_format('timestamp_and_level').set_level(Logger.DEBUG);
logger3.debug('this will not be logged!');
logger3.info('this will be logged');

logger3.set_global_level_debug(); % call by instance
logger3.debug('this will be logged now');

logger3.set_format('none');
logger3.debug('this will be logged without timestamp and level');
