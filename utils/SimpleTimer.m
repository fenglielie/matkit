classdef SimpleTimer < handle
    % SimpleTimer 一个简单的计时器

    properties(SetAccess = private)
        startTime
        elapsedTime
        isRunning
    end

    methods
        function obj = SimpleTimer()
            obj.startTime = 0;
            obj.elapsedTime = 0;
            obj.isRunning = false;
        end

        function start(obj)
            if ~obj.isRunning
                obj.startTime = tic;
                obj.isRunning = true;
            else
                warning('SimpleTimer is already running');
            end
        end

        function stop(obj)
            if obj.isRunning
                obj.elapsedTime = obj.elapsedTime + toc(obj.startTime);
                obj.isRunning = false;
            else
                warning('SimpleTimer is not running');
            end
        end

        function reset(obj)
            obj.startTime = 0;
            obj.elapsedTime = 0;
            obj.isRunning = false;
        end

        function time = getElapsedTime(obj)
            if obj.isRunning
                time = obj.elapsedTime + toc(obj.startTime);
            else
                time = obj.elapsedTime;
            end
        end
    end

    methods(Static)
        function timeStamp = getTimeStamp()
            timeStamp = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<TNOW1,DATST>
        end

        function writeTimeStampToFile(directory)
            timeStamp = SimpleTimer.getTimeStamp();

            filePath = fullfile(directory, 'time_stamp');
            fileID = fopen(filePath, 'w');

            if fileID == -1
                error('Failed to open file: %s', filePath);
            end

            fprintf(fileID, '%s\n', timeStamp);
            fclose(fileID);
        end
    end
end
