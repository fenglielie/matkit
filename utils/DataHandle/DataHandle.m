classdef DataHandle < handle
    % DATAHANDLE A simple handle class for storing and modifying structured data.
    %
    % This class defines a handle object that contains a public property `data`,
    % which is initialized as an empty structure. Since it inherits from the
    % `handle` class, any modifications to the `data` property persist across
    % all references to the same object, including when passed as function arguments.
    %
    % DATAHANDLE Properties:
    %   data    - A public structure used to store arbitrary data.
    %
    % EXAMPLE:
    %   obj = DataHandle();
    %   obj.data.value = 42;
    %   modifyData(obj);
    %   disp(obj.data.value); % 100
    %
    %   function modifyData(a)
    %       a.data.value = 100;
    %   end

    properties (Access = public)
        data = struct(); % A structure for storing arbitrary data.
    end

end
