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

    methods (Static)

        function setRootHere(pathInput)
            % SETROOTHERE Sets root_dir based on input path or caller's file location.
            %
            % Usage:
            %   GlobalState.setRootHere();
            %   GlobalState.setRootHere(pathInput);

            state = GlobalState.getInstance();

            if nargin >= 1 && ischar(pathInput) && ~isempty(pathInput)

                if isfolder(pathInput) || exist(pathInput, 'file') == 2

                    if exist(pathInput, 'file') == 2
                        caller_dir = fileparts(pathInput);
                    else
                        caller_dir = pathInput;
                    end

                else
                    error('setRootHere:InvalidPath', 'Invalid path: %s', pathInput);
                end

            else
                stk = dbstack('-completenames');

                if numel(stk) < 2
                    caller_dir = pwd;
                else
                    caller_file = stk(2).file;
                    caller_dir = fileparts(caller_file);
                end

            end

            root_dir = strrep(caller_dir, '\', '/');
            state.data.root_dir = root_dir;
        end

        function root_dir = getRoot()
            % GETROOT Returns the stored root_dir from GlobalState singleton.
            %
            % If root_dir has not been set yet, returns empty.

            state = GlobalState.getInstance();

            if isfield(state.data, 'root_dir')
                root_dir = state.data.root_dir;
            else
                root_dir = [];
            end

        end

    end

end
