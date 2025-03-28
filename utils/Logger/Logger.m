classdef Logger < handle
    % LOGGER Custom logging class for MATLAB
    %
    % Logger Properties:
    %   level               - Minimum log level to record (default: INFO)
    %   fileID              - File handle for logging (-1 indicates no file output)
    %   format              - Log message format: 'none', 'level', 'timestamp_and_level'
    %
    % Logger Methods:
    %   Logger              - Constructor
    %   open_file_append    - Open a log file (append)
    %   open_file_trunc     - Open a log file (truncate)
    %   close_file          - Close the log file
    %   debug               - Log a debug message only if global level == obj.level == DEBUG
    %   info                - Log an info message if INFO >= max(global_level, obj.level)
    %   warn                - Log a warning message if WARN >= max(global_level, obj.level)
    %   warn_plus           - Log a warning message and call (builtin) warning if WARN >= max(global_level, obj.level)
    %   error               - Log an error message
    %   error_plus          - Log an error message and call (builtin) error
    %   set_global_level    - Set the global log level (default: INFO).
    %   get_global_level    - Get the global log level (default: INFO).
    %
    % NOTE:
    %   Supported log levels: DEBUG < INFO < WARN < ERROR.
    %   Debug messages are logged only if global level == obj.level == DEBUG.
    %   Error messages are always logged.
    %
    % EXAMPLE:
    %   Logger.set_global_level(Logger.DEBUG);
    %
    %   logger = Logger(level=Logger.DEBUG, format='none');
    %   logger.open_file_trunc('app.log');
    %   logger.debug('Processing item %d of %d...', 5, 100);
    %   logger.info('User %s has logged in', 'Alice');
    %   logger.warn('Disk space low: %0.2f G remaining', 4.75);
    %   logger.error('Failed to open file: %s', 'data.csv');
    %   logger.warn_plus('Low memory');
    %   logger.error_plus('Failed to load file');
    %   logger.close_file();

    properties (Constant)
        DEBUG = 1;
        INFO = 2;
        WARN = 3;
        ERROR = 4;
    end

    properties (SetAccess = private)
        level = Logger.INFO; % Minimum log level
        fileID = -1; % File handle (-1 = no file)
        format = 'level'; % Log message format
    end

    methods

        function obj = Logger(varargin)
            % Logger Constructor
            %
            % Key-Value Parameters:
            %   level  - Minimum log level: DEBUG < INFO < WARN < ERROR. (default: Logger.INFO)
            %   format - Log format: 'none', 'level', 'timestamp_and_level'. (default: 'level')

            p = inputParser;
            addParameter(p, 'level', Logger.INFO, @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'format', 'level', @(x) ismember(x, {'none', 'level', 'timestamp_and_level'}));
            parse(p, varargin{:});

            obj.level = p.Results.level;
            obj.format = p.Results.format;
        end

        function open_file_append(obj, fileName)
            % Open a log file (append)

            obj.close_file();

            [fid, msg] = fopen(fileName, 'a'); % append

            if fid == -1
                error('Logger:FileError', 'Failed to open %s: %s', fileName, msg);
            end

            obj.fileID = fid;
            fprintf(obj.fileID, '[%s] LOG FILE INITIALIZED (obj.level: %s) (global_level: %s)\n', ...
                Logger.get_timestamp(), Logger.get_level_str(obj.level), ...
                Logger.get_level_str(Logger.get_global_level()));
        end

        function open_file_trunc(obj, fileName)
            % Open a log file (truncate)

            obj.close_file();

            [fid, msg] = fopen(fileName, 'w'); % overwrite

            if fid == -1
                error('Logger:FileError', 'Failed to open %s: %s', fileName, msg);
            end

            obj.fileID = fid;
            fprintf(obj.fileID, '[%s] LOG FILE INITIALIZED (obj.level: %s) (global_level: %s)\n', ...
                Logger.get_timestamp(), Logger.get_level_str(obj.level), ...
                Logger.get_level_str(Logger.get_global_level()));
        end

        function close_file(obj)
            % Close the log file

            if obj.fileID == -1, return; end

            fprintf(obj.fileID, '[%s] LOG FILE CLOSED\n', Logger.get_timestamp());
            fclose(obj.fileID);
            obj.fileID = -1;
        end

        function debug(obj, fmt, varargin)
            % Log a debug message only if global level == obj.level == DEBUG

            if Logger.DEBUG == max(Logger.get_global_level(), obj.level)
                obj.log(Logger.DEBUG, fmt, varargin{:});
            end

        end

        function info(obj, fmt, varargin)
            % Log an info message if INFO >= max(global_level, obj.level)

            if Logger.INFO >= max(Logger.get_global_level(), obj.level)
                obj.log(Logger.INFO, fmt, varargin{:});
            end

        end

        function warn(obj, fmt, varargin)
            % Log a warning message if WARN >= max(global_level, obj.level)

            if Logger.WARN >= max(Logger.get_global_level(), obj.level)
                obj.log(Logger.WARN, fmt, varargin{:});
            end

        end

        function warn_plus(obj, fmt, varargin)
            % Log a warning message and call (builtin) warning if WARN >= max(global_level, obj.level)

            if Logger.WARN >= max(Logger.get_global_level(), obj.level)
                obj.log(Logger.WARN, fmt, varargin{:});
                builtin('warning', fmt, varargin{:});
            end

        end

        function error(obj, fmt, varargin)
            % Log an error message

            obj.log(Logger.ERROR, fmt, varargin{:});
        end

        function error_plus(obj, fmt, varargin)
            % Log an error message and call (builtin) error

            obj.log(Logger.ERROR, fmt, varargin{:});

            builtin('error', fmt, varargin{:});
        end

        function delete(obj)
            obj.close_file();
        end

    end

    methods (Access = private)

        function log(obj, level, fmt, varargin)
            msg = sprintf(fmt, varargin{:});
            logStr = obj.format_log(level, msg);

            if obj.fileID ~= -1
                fprintf(obj.fileID, logStr);
            else

                if level >= Logger.WARN
                    fprintf(2, logStr); % stderr
                else
                    fprintf(1, logStr); % stdout
                end

            end

        end

        function str = format_log(obj, level, msg)
            levelStr = Logger.get_level_str(level);

            switch obj.format
                case 'none'
                    str = sprintf('%s\n', msg);
                case 'level'
                    str = sprintf('[%s] %s\n', levelStr, msg);
                case 'timestamp_and_level'
                    str = sprintf('[%s] [%s] %s\n', Logger.get_timestamp(), levelStr, msg);
            end

        end

    end

    methods (Static)

        function ts = get_timestamp()
            ts = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
        end

        function str = get_level_str(level)

            switch level
                case Logger.DEBUG, str = 'DEBUG';
                case Logger.INFO, str = 'INFO';
                case Logger.WARN, str = 'WARN';
                case Logger.ERROR, str = 'ERROR';
                otherwise , str = 'UNKNOWN';
            end

        end

        function set_global_level(level)
            % Set the global log level (default: INFO).

            Logger.global_level_accessor(level);
        end

        function level = get_global_level()
            % Get the global log level (default: INFO).

            level = Logger.global_level_accessor();
        end

    end

    methods (Static, Access = private)

        function level = global_level_accessor(newLevel)
            persistent global_level

            if isempty(global_level)
                global_level = Logger.INFO;
            end

            if nargin > 0
                global_level = newLevel;
            end

            level = global_level;
        end

    end

end
