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
    %   state = GlobalState.get_instance();
    %   state.data.message = 'hello';
    %   updateMessage();
    %   disp(state.data.message); % 'updated'
    %
    %   function updateMessage()
    %       s = GlobalState.get_instance();
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

        function obj = get_instance()
            % GETINSTANCE Returns the unique shared instance of GlobalState.

            persistent uniqueInstance

            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                uniqueInstance = GlobalState();
            end

            obj = uniqueInstance;
        end

    end

    methods (Static)

        function set_root(pathInput)
            % SET_ROOT Sets root_dir based on input path or caller's file location.
            %
            % Usage:
            %   GlobalState.set_root();
            %   GlobalState.set_root(pathInput);

            state = GlobalState.get_instance();

            if nargin >= 1 && ischar(pathInput) && ~isempty(pathInput)

                if isfolder(pathInput) || exist(pathInput, 'file') == 2

                    if exist(pathInput, 'file') == 2
                        caller_dir = fileparts(pathInput);
                    else
                        caller_dir = pathInput;
                    end

                else
                    error('set_root:InvalidPath', 'Invalid path: %s', pathInput);
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

        function root_dir = get_root()
            % GET_ROOT Returns the stored root_dir from GlobalState singleton.
            %
            % If root_dir has not been set yet, returns empty.

            state = GlobalState.get_instance();

            if isfield(state.data, 'root_dir')
                root_dir = state.data.root_dir;
            else
                root_dir = [];
            end

        end

    end

    methods (Static)

        function save_path_force()
            % SAVE_PATH_FORCE Forcefully saves the current MATLAB path into GlobalState.
            %
            % This method always overwrites the existing saved path.

            state = GlobalState.get_instance();
            state.data.saved_path = path();
        end

        function save_path_once()
            % SAVE_PATH_ONCE Saves the current MATLAB path into GlobalState only once.
            %
            % If a saved path already exists, this function does nothing.

            state = GlobalState.get_instance();

            if ~isfield(state.data, 'saved_path') || isempty(state.data.saved_path)
                state.data.saved_path = path();
            end

        end

        function saved_path = get_saved_path()
            % GET_SAVED_PATH Returns the saved path string from GlobalState.
            %
            % If no path was saved, returns [].

            state = GlobalState.get_instance();

            if isfield(state.data, 'saved_path')
                saved_path = state.data.saved_path;
            else
                saved_path = [];
            end

        end

        function clean_saved_path()
            % CLEAN_SAVED_PATH Removes the saved path record from GlobalState.

            state = GlobalState.get_instance();

            if isfield(state.data, 'saved_path')
                state.data = rmfield(state.data, 'saved_path');
            end

        end

        function restore_saved_path()
            % RESTORE_SAVED_PATH Restores MATLAB path from the saved path record in GlobalState.

            state = GlobalState.get_instance();

            if isfield(state.data, 'saved_path')
                path(state.data.saved_path);
            else
                warning('No saved path found to restore.');
            end

        end

    end

end
