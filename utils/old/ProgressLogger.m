classdef ProgressLogger < handle
    % ProgressLogger 一个进度日志类
    % 创建时需要传递日志文件名（覆盖式写入）和总的进度时间（默认值为1）
    % 例如 logger = ProgressLogger('log.txt', 2.0, desc);
    % 调用 obj.logMessage(message) 可以在日志中记录下字符串信息（含时间戳）
    % 调用 obj.logProgress(t) 可以在日志中记录下当前的进度时间以及占总进度的百分比（含时间戳）

    properties(Access = private)
        fileID = -1;
        totalTime = 1;
        desc
    end

    methods
        function obj = ProgressLogger(fileName, totalTime, desc)

            obj.totalTime = totalTime;
            obj.desc = ['Progress of ', desc];

            [filePath, ~, ~] = fileparts(fileName);
            if ~isempty(filePath) && ~exist(filePath,'dir')
                mkdir(filePath);
            end

            obj.fileID = fopen(fileName, 'w');
            if obj.fileID == -1
                error('Failed to open file: %s', fileName);
            end

            fprintf(obj.fileID, '<<<ProgressLogger BEGIN>>>\n');
            obj.logMessage(desc);
        end

        function logMessage(obj, message)
            timeStamp = ProgressLogger.getTimeStamp();
            fprintf(obj.fileID, '[%s] %s\n', timeStamp, message);
        end

        function logProgress(obj, currentTime)
            timeStamp = ProgressLogger.getTimeStamp();
            percentage = (currentTime / obj.totalTime) * 100;
            fprintf(obj.fileID, '[%s] %.2f/%.2f (%.2f%%)\n', timeStamp, currentTime, obj.totalTime, percentage);
        end

        function logProgressWithMessage(obj, currentTime, message)
            timeStamp = ProgressLogger.getTimeStamp();
            percentage = (currentTime / obj.totalTime) * 100;
            fprintf(obj.fileID, '[%s] %.2f/%.2f (%.2f%%) %s\n', timeStamp, currentTime, obj.totalTime, percentage, message);
        end

        function delete(obj)
            obj.closeFile();
        end
    end

    methods(Access = private)
        function closeFile(obj)
            if obj.fileID ~= -1
                fprintf(obj.fileID, '<<<ProgressLogger END>>>\n');
                fclose(obj.fileID);
                obj.fileID = -1;
            end
        end
    end

    methods(Static)
        function timeStamp = getTimeStamp()
            timeStamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'); %#ok<TNOW1,DATST>
        end
    end
end
