classdef Logger < handle
    % LOGGER Custom logging class for MATLAB
    %
    % Example usage:
    %   logger = Logger(level=Logger.DEBUG,format='none');
    %   logger.open_file('app.log', 'append');
    %   logger.info('Program started');
    %   logger.warn('Low memory');
    %   logger.warn_plus('Low memory');
    %   logger.error('Failed to load file');
    %   logger.error_plus('Failed to load file');
    %   logger.close_file();
    %
    % Supported log levels: DEBUG < INFO < WARN < ERROR
    %
    % Properties:
    %   level    - Minimum log level to record (default: INFO)
    %   fileID   - File handle for logging (-1 indicates no file output)
    %   format   - Log message format: 'none', 'level', 'timestamp_and_level'

    properties (Constant)
        DEBUG = 1;
        INFO  = 2;
        WARN  = 3;
        ERROR = 4;
    end

    properties (Access = private)
        level  = Logger.INFO;   % Minimum log level
        fileID = -1;            % File handle (-1 = no file)
        format = 'level';       % Log message format
    end

    methods
        function obj = Logger(varargin)
            % Logger Constructor
            %
            % Name-Value Parameters:
            %   level  - Minimum log level (default: Logger.INFO)
            %   format - Log format: 'none', 'level', 'timestamp_and_level' (default: 'level')

            p = inputParser;
            addParameter(p, 'level', Logger.INFO, @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'format', 'level', @(x) ismember(x, {'none', 'level', 'timestamp_and_level'}));
            parse(p, varargin{:});

            obj.level = p.Results.level;
            obj.format = p.Results.format;
        end

        function open_file_append(obj, fileName)
            obj.close_file();

            [fid, msg] = fopen(fileName, 'a'); % append
            if fid == -1
                error('Logger:FileError', 'Failed to open %s: %s', fileName, msg);
            end

            obj.fileID = fid;
            fprintf(obj.fileID, '[%s] LOG FILE INITIALIZED (level: %s)\n',...
                obj.get_timestamp(), obj.get_level_str(obj.level));
        end

        function open_file_trunc(obj, fileName)
            obj.close_file();

            [fid, msg] = fopen(fileName, 'w'); % overwrite
            if fid == -1
                error('Logger:FileError', 'Failed to open %s: %s', fileName, msg);
            end

            obj.fileID = fid;
            fprintf(obj.fileID, '[%s] LOG FILE INITIALIZED (level: %s)\n',...
                obj.get_timestamp(), obj.get_level_str(obj.level));
        end

        function close_file(obj)
            if obj.fileID == -1, return; end

            fprintf(obj.fileID, '[%s] LOG FILE CLOSED\n', obj.get_timestamp());
            fclose(obj.fileID);
            obj.fileID = -1;
        end

        function debug(obj, fmt, varargin)
            if obj.level > Logger.DEBUG, return; end
            obj.log(Logger.DEBUG, fmt, varargin{:});
        end

        function info(obj, fmt, varargin)
            if obj.level > Logger.INFO, return; end
            obj.log(Logger.INFO, fmt, varargin{:});
        end

        function warn(obj, fmt, varargin)
            if obj.level > Logger.WARN, return; end
            obj.log(Logger.WARN, fmt, varargin{:});
        end

        function warn_plus(obj, fmt, varargin)
            if obj.level > Logger.WARN, return; end
            obj.log(Logger.WARN, fmt, varargin{:});

            warning(fmt, varargin{:});
        end

        function error(obj, fmt, varargin)
            if obj.level > Logger.ERROR, return; end
            obj.log(Logger.ERROR, fmt, varargin{:});
        end

        function error_plus(obj, fmt, varargin)
            if obj.level > Logger.ERROR, return; end
            obj.log(Logger.ERROR, fmt, varargin{:});

            error(fmt, varargin{:});
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
                    fprintf(2, logStr);   % stderr
                else
                    fprintf(1, logStr);   % stdout
                end
            end
        end

        function str = format_log(obj, level, msg)
            levelStr = obj.get_level_str(level);

            switch obj.format
                case 'none'
                    str = sprintf('%s\n', msg);
                case 'level'
                    str = sprintf('[%s] %s\n', levelStr, msg);
                case 'timestamp_and_level'
                    str = sprintf('[%s] [%s] %s\n', obj.get_timestamp(), levelStr, msg);
            end
        end

        function ts = get_timestamp(~)
            ts = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'); %#ok<TNOW1,DATST>
        end

        function str = get_level_str(~, level)
            switch level
                case Logger.DEBUG, str = 'DEBUG';
                case Logger.INFO,  str = 'INFO';
                case Logger.WARN,  str = 'WARN';
                case Logger.ERROR, str = 'ERROR';
                otherwise,         str = 'UNKNOWN';
            end
        end
    end
end
