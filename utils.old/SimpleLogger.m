classdef SimpleLogger < handle
    properties (Constant)
        % 定义日志等级常量
        DEBUG = 1
        INFO = 2
        WARN = 3
        ERROR = 4
    end

    properties(Access = private)
        logLevel = SimpleLogger.INFO;
        fileID = -1;
        outputToConsole = false;
    end

    methods
        function obj = SimpleLogger(fileName, logLevel, outputToConsole)
            if nargin < 2
                logLevel = SimpleLogger.INFO; % 默认日志等级为 INFO
            end
            if nargin < 3
                outputToConsole = false; % 默认不输出到控制台
            end

            obj.logLevel = logLevel;
            obj.outputToConsole = outputToConsole;

            obj.fileID = fopen(fileName, 'w');
            if obj.fileID == -1
                error('Failed to open file: %s', fileName);
            end

            fprintf(obj.fileID, '<<<SimpleLogger BEGIN>>>\n');
        end

        function obj = logMessage(obj, message, level)
            if level < obj.logLevel
                return; % 如果日志等级低于设置的等级，不输出
            end

            % 输出到日志文件
            fprintf(obj.fileID, '[%s]%s: %s\n', obj.formatStr(), ...
                SimpleLogger.getLogLevelString(level), message);

            if obj.outputToConsole % 输出到控制台（不显示时间戳）
                fprintf('%s: %s\n', SimpleLogger.getLogLevelString(level), message);
            end
        end

        % 输出 DEBUG 信息
        function obj = debug(obj, message)
            obj = obj.logMessage(message, SimpleLogger.DEBUG);
        end

        % 输出 INFO 信息
        function obj = info(obj, message)
            obj = obj.logMessage(message, SimpleLogger.INFO);
        end

        % 输出 WARN 信息并调用内置的 warning 函数
        function obj = warn(obj, message)
            obj = obj.logMessage(message, SimpleLogger.WARN);
            warning(message)
        end

        % 输出 ERROR 信息并调用内置的 error 函数
        function obj = error(obj, message)
            obj = obj.logMessage(message, SimpleLogger.ERROR);
            error(message)
        end

        % 格式化信息（主要是时间戳）
        function str = formatStr(~)
            str = SimpleLogger.getTimeStamp();
        end

        function delete(obj)
            obj.closeFile();
        end
    end

    methods(Access = private)
        function closeFile(obj)
            if obj.fileID ~= -1
                fprintf(obj.fileID, '<<<SimpleLogger END>>>\n');
                fclose(obj.fileID);
                obj.fileID = -1;
            end
        end
    end

    methods(Static)

        % 创建全局单例
        function obj = instance(fileName, logLevel, outputToConsole)
            persistent gl

            % 如果实例不存在或者无效，重新创建，此时要求提供参数
            if isempty(gl) || ~isvalid(gl)
                if nargin < 2
                    logLevel = SimpleLogger.INFO; % 默认日志等级为 INFO
                end
                if nargin < 3
                    outputToConsole = false; % 默认不输出到控制台
                end

                gl = SimpleLogger(fileName, logLevel, outputToConsole);
                gl.info('Created a new unique instance');
            else
                gl.info('Using the existing unique instance');
            end

            obj = gl;
        end

        % 获取当前时间戳
        function timeStamp = getTimeStamp()
            timeStamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'); %#ok<TNOW1,DATST>
        end

        % 获取日志等级对应的字符串
        function levelString = getLogLevelString(level)
            switch level
                case SimpleLogger.DEBUG
                    levelString = '[DEBUG]';
                case SimpleLogger.INFO
                    levelString = '[INFO]';
                case SimpleLogger.WARN
                    levelString = '[WARN]';
                case SimpleLogger.ERROR
                    levelString = '[ERROR]';
                otherwise
                    levelString = '[    ]';
            end
        end
    end
end
