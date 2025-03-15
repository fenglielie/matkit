classdef Logger < handle
    % LOGGER Custom logging class for MATLAB
    %
    % Example usage:
    %   logger = Logger(fileName='tmp.log', logLevel=Logger.DEBUG, outputToConsole=true);
    %   logger.info('Program started.');
    %   logger.warn('This is a warning message.');
    %   logger.error('An error occurred.');
    %
    % Supported log levels: DEBUG < INFO < WARN < ERROR
    %
    % Properties:
    %   logLevel - The minimum level of log messages to display, default: INFO
    %   fileID - File handle for logging
    %   fileName - Name of the log file
    %   outputToConsole - Whether to print logs to console, default: true
    %   logFormat - Log format: 'none', 'level', 'timestamp_and_level', default: 'level'
    %   useMatlabErrors - Whether to use MATLAB's built-in error/warning, default: true


    properties (Constant)
        DEBUG = 1;
        INFO = 2;
        WARN = 3;
        ERROR = 4;
    end

    properties (Access = private)
        logLevel = Logger.INFO;
        fileID = -1;
        fileName = '';
        outputToConsole = true;
        logFormat = 'level';
        useMatlabErrors = true;  % use buildin error/warning
    end

    methods
        function obj = Logger(varargin)
            % Logger Constructor.
            %
            % Name-Value Pair Arguments:
            %   - fileName="log.txt" : Log file name. If empty, logs only print to console.
            %   - logLevel=Logger.INFO : Minimum log level (1=DEBUG, 2=INFO, 3=WARN, 4=ERROR).
            %   - outputToConsole=true : Whether to print logs to the console.
            %   - writeMode="overwrite" : "overwrite" (replace file) or "append" (add to file).
            %   - logFormat="level" : Log format: "none", "level", "timestamp_and_level".
            %   - useMatlabErrors=true : If true, WARN/ERROR will also call MATLAB's warning/error.
            %
            % Example Usage:
            %   logger = Logger();  % Default logger, prints to console
            %   logger = Logger(fileName="log.txt");  % Logs to file and console
            %   logger = Logger(logLevel=Logger.WARN, outputToConsole=false);  % Logs warnings/errors to file only
            %   logger = Logger(logFormat="timestamp_and_level");  % Includes timestamps in log messages
            %   logger = Logger(useMatlabErrors=false);  % Disable MATLAB warning/error
            %
            % Logging methods: (support format strings via sprintf)
            %   logger.debug('a=%d', 1);
            %   logger.info('Info message');
            %   logger.warn('Warning message');
            %   logger.error('Error message');

            p = inputParser;
            addParameter(p, 'fileName', '', @(x) ischar(x) || isstring(x));
            addParameter(p, 'logLevel', Logger.INFO, @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'outputToConsole', true, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'writeMode', 'overwrite', @(x) ischar(x) && any(strcmp(x, {'append', 'overwrite'})));
            addParameter(p, 'logFormat', 'level', @(x) ischar(x) && any(strcmp(x, {'none', 'level', 'timestamp_and_level'})));
            addParameter(p, 'useMatlabErrors', true, @(x) islogical(x) && isscalar(x));
            parse(p, varargin{:});

            obj.logLevel = p.Results.logLevel;
            obj.outputToConsole = p.Results.outputToConsole;
            obj.logFormat = p.Results.logFormat;
            obj.useMatlabErrors = p.Results.useMatlabErrors;

            if ~isempty(p.Results.fileName)
                mode = 'w'; % overwrite (default)
                if strcmp(p.Results.writeMode, 'append')
                    mode = 'a'; % append
                end
                obj.fileID = fopen(p.Results.fileName, mode);
                if obj.fileID == -1
                    error('Logger:FileOpenFail', 'Failed to open file: %s', p.Results.fileName);
                end

                fprintf(obj.fileID, '<<<Log File Opened>>>\n[Timestamp: %s] [Log Level: %s] [Write Mode: %s] [Console Output: %s]\n', ...
                    obj.getTimeStamp(), obj.getLevelStr(obj.logLevel), p.Results.writeMode, mat2str(obj.outputToConsole));
                fprintf('Logger: Open %s (%c)\n', p.Results.fileName, mode);

                obj.fileName = p.Results.fileName;
            end

            if obj.fileID == -1 && ~obj.outputToConsole
                error('Logger:InvalidConfig', 'Either file output or console output must be enabled.');
            end
        end

        function log(obj, level, formatStr, varargin)
            if level < obj.logLevel
                return;
            end
            timeStamp = obj.getTimeStamp();
            message = sprintf(formatStr, varargin{:});
            logStr = obj.formatLogMsg(timeStamp, level, message);

            if obj.outputToConsole
                fprintf('%s', logStr);
            end

            if obj.fileID > 0
                fprintf(obj.fileID, '%s', logStr);
            end
        end

        function debug(obj, formatStr, varargin)
            obj.log(Logger.DEBUG, formatStr, varargin{:});
        end

        function info(obj, formatStr, varargin)
            obj.log(Logger.INFO, formatStr, varargin{:});
        end

        function warn(obj, formatStr, varargin)
            obj.log(Logger.WARN, formatStr, varargin{:});

            if obj.useMatlabErrors
                logMessage = obj.formatLogMsg(obj.getTimeStamp(), Logger.WARN, sprintf(formatStr, varargin{:}));
                warning(logMessage);
            end
        end

        function error(obj, formatStr, varargin)
            obj.log(Logger.ERROR, formatStr, varargin{:});

            if obj.useMatlabErrors
                logMessage = obj.formatLogMsg(obj.getTimeStamp(), Logger.ERROR, sprintf(formatStr, varargin{:}));
                error(logMessage);
            end
        end

        function delete(obj)
            if obj.fileID > 0
                fprintf(obj.fileID, '[Timestamp: %s]\n<<<Log File Closed>>>\n', obj.getTimeStamp());
                fclose(obj.fileID);
                fprintf('Logger: Close %s\n', obj.fileName);
            end
        end
    end

    methods (Access = private)
        function logStr = formatLogMsg(obj, timeStamp, level, message)
            switch obj.logFormat
                case 'none'
                    logStr = sprintf('%s\n', message);
                case 'level'
                    logStr = sprintf('[%s] %s\n', obj.getLevelStr(level), message);
                case 'timestamp_and_level'
                    logStr = sprintf('[%s] [%s] %s\n', timeStamp, obj.getLevelStr(level), message);
                otherwise
                    logStr = sprintf('[%s] [%s] %s\n', timeStamp, obj.getLevelStr(level), message);
            end
        end

        function timeStamp = getTimeStamp(~)
            timeStamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'); %#ok<TNOW1,DATST>
        end

        function str = getLevelStr(~, level)
            switch level
                case Logger.DEBUG, str = 'DEBUG';
                case Logger.INFO, str = 'INFO';
                case Logger.WARN, str = 'WARN';
                case Logger.ERROR, str = 'ERROR';
                otherwise, str = '   ';
            end
        end
    end
end
