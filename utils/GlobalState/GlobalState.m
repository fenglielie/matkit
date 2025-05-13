classdef GlobalState < handle
    % GLOBALSTATE A singleton handle class for globally accessible structured data.
    %
    % This class implements the singleton design pattern to provide a globally
    % accessible handle object. It contains a public property `data`, which is
    % initialized as an empty structure and can be used to store arbitrary data.
    %
    % GLOBALSTATE ensures that only one instance of the class exists throughout
    % the program, avoiding the use of global variables while preserving access
    % to shared data across different scopes and functions.
    %
    % GLOBALSTATE Methods (Static):
    %   getInstance     - Returns the single shared instance of the class.
    %
    % GLOBALSTATE Properties:
    %   data            - A public structure used to store arbitrary data.
    %
    % EXAMPLE USAGE:
    %   state = GlobalState.getInstance();
    %   state.data.message = 'hello';
    %   updateMessage();
    %   disp(state.data.message); % 'updated'
    %
    %   function updateMessage()
    %       s = GlobalState.getInstance();
    %       s.data.message = 'updated';
    %   end

    properties (Access = public)
        data = struct(); % A structure for storing arbitrary data.
    end

    methods (Access = private)
        function obj = GlobalState()
            % Private constructor to prevent external instantiation.
        end
    end

    methods (Static)
        function obj = getInstance()
            % GETINSTANCE Returns the unique shared instance of GlobalState.

            persistent uniqueInstance
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                uniqueInstance = GlobalState();
            end

            obj = uniqueInstance;
        end
    end
end
