classdef DataBox < handle
    % DATABOX class for managing and validating a collection of data
    %
    % The DataBox class allows for the storage of dynamic data in the form of
    % a struct and provides mechanisms for setting validation rules on the
    % fields of this data. The class supports defining required fields,
    % conditionally required fields, and mandatory fields with validation functions.
    % It also provides methods to check whether these validation rules are met.
    %
    % DataBox Properties:
    %   data                    - A structure that holds the data fields.
    %   name                    - The name of the DataBox instance.
    %   rules                   - A structure that holds the rules applied to each field in `data`.
    %
    % DataBox Methods:
    %   has                     - Checks if a field exists in the `data` structure.
    %   require                 - Marks a field as required (must exist).
    %   conditionally_require   - Marks a field as conditionally required (if exist, must satisfy a condition).
    %   enforce                 - Marks a field as mandatory (must exist and must satisfy a condition).
    %   check                   - Checks if a specific field satisfies its corresponding rule.
    %   check_all               - Checks all fields to ensure all rules are met.
    %
    % EXAMPLE:
    %   db = DataBox('MyDataBox');
    %
    %   db.data.alpha = 10;
    %   db.data.beta = 5;
    %
    %   db.require('alpha', 'alpha is a required field.');
    %   db.conditionally_require('beta', @(x) x > 3, 'beta must be greater than 3 if provided.');
    %   db.check('beta');   % pass
    %   db.check_all();     % pass
    %
    %   db.enforce('gamma', @(x) x > 0, 'gamma must exist and be greater than 0.');
    %   db.check_all();     % This will throw an error because 'gamma' is missing

    properties (Access = public)
        data % A structure that holds the data fields.
    end

    properties (SetAccess = private)
        name % The name of the DataBox instance.
        rules % A structure that holds the rules applied to each field in `data`.
    end

    methods

        function obj = DataBox(name)
            assert(ischar(name), 'name must be a string');

            obj.name = name;
            obj.data = struct();
            obj.rules = struct();
        end

        function exists = has(obj, name)
            % HAS Check if a field exists in the data structure.
            %
            % INPUT:
            %   name        - The name of the field to check.
            %
            % OUTPUT:
            %   exists      - True if the field exists, otherwise false.

            exists = isfield(obj.data, name);
        end

        function obj = require(obj, name, message)
            % REQUIRE Mark a field as required, meaning it must exist in the data.
            %
            % INPUT:
            %   name        - The name of the required field.
            %   message     - Custom error message (optional).
            %
            % OUTPUT:
            %   obj         - The updated DataBox object.
            %
            % EXAMPLE:
            %   db.require('alpha', 'alpha is mandatory.')

            if nargin < 3, message = ''; end
            obj.rules.(name) = struct('type', 'required', 'validator', [], 'message', message);
        end

        function obj = conditionally_require(obj, name, validator, message)
            % CONDITIONALLY_REQUIRE Marks a field as conditionally required.
            %
            % INPUT:
            %   name        - The name of the conditionally required field.
            %   validator   - The condition that must be satisfied if the field exists.
            %   message     - Custom error message (optional).
            %
            % OUTPUT:
            %   obj         - The updated DataBox object.
            %
            % EXAMPLE:
            %   db.conditionally_require('beta', @(x) x > 3, 'beta must be greater than 3.')

            if nargin < 4, message = ''; end
            obj.rules.(name) = struct('type', 'conditional', 'validator', validator, 'message', message);
        end

        function obj = enforce(obj, name, validator, message)
            % ENFORCE Marks a field as mandatory (must exist and must satisfy a condition).
            %
            % INPUT:
            %   name        - The name of the mandatory field.
            %   validator   - The condition that must be satisfied.
            %   message     - Custom error message (optional).
            %
            % OUTPUT:
            %   obj         - The updated DataBox object.
            %
            % EXAMPLE:
            %   db.enforce('gamma', @(x) x > 0, 'gamma must be positive.')

            if nargin < 4, message = ''; end
            obj.rules.(name) = struct('type', 'mandatory', 'validator', validator, 'message', message);
        end

        function check(obj, fieldname)
            % CHECK Check if a specific field satisfies its validation rule.
            %
            % INPUT:
            %   fieldname - The name of the field to validate.
            %
            % NOTE:
            %   Throw error if the field doesn't meet its validation rule.
            %   Pass if no rule is set for this field.
            %
            %   Errors:
            %      - DataBox:FieldMissing
            %      - DataBox:ConditionNotMet
            %      - DataBox:MandatoryFieldMissing
            %      - DataBox:ValidationFailed
            %      - DataBox:UnknownRuleType
            %
            % EXAMPLE:
            %   db.check('alpha')

            if ~isfield(obj.rules, fieldname)
                return; % No rule exists for this field, no error
            end

            rule = obj.rules.(fieldname);
            errMsg = rule.message; % Use custom error message if provided

            switch rule.type
                case 'required'

                    if ~isfield(obj.data, fieldname)

                        if isempty(errMsg)
                            error('DataBox:FieldMissing', ...
                                'DataBox(%s): %s is required but missing.', obj.name, fieldname);
                        else
                            error('DataBox:FieldMissing', 'DataBox(%s): %s', obj.name, errMsg);
                        end

                    end

                case 'conditional'

                    if isfield(obj.data, fieldname) && ~rule.validator(obj.data.(fieldname))

                        if isempty(errMsg)
                            error('DataBox:ConditionNotMet', ...
                                'DataBox(%s): %s exists but does not satisfy its condition.', obj.name, fieldname);
                        else
                            error('DataBox:ConditionNotMet', 'DataBox(%s): %s', obj.name, errMsg);
                        end

                    end

                case 'mandatory'

                    if ~isfield(obj.data, fieldname)

                        if isempty(errMsg)
                            error('DataBox:MandatoryFieldMissing', ...
                                'DataBox(%s): %s is required but missing.', obj.name, fieldname);
                        else
                            error('DataBox:MandatoryFieldMissing', 'DataBox(%s): %s', obj.name, errMsg);
                        end

                    elseif ~rule.validator(obj.data.(fieldname))

                        if isempty(errMsg)
                            error('DataBox:ValidationFailed', ...
                                'DataBox(%s): %s does not satisfy its required condition.', obj.name, fieldname);
                        else
                            error('DataBox:ValidationFailed', 'DataBox(%s): %s', obj.name, errMsg);
                        end

                    end

                otherwise
                    error('DataBox:UnknownRuleType', 'DataBox(%s): Unknown rule type for %s.', obj.name, fieldname);
            end

        end

        function check_all(obj)
            % CHECK_ALL Check if all fields in the `data` structure satisfy their validation rules.
            %
            % NOTE:
            %   Throw error if any field doesn't meet its validation rule.
            %
            %   Errors:
            %      - DataBox:FieldMissing
            %      - DataBox:ConditionNotMet
            %      - DataBox:MandatoryFieldMissing
            %      - DataBox:ValidationFailed
            %      - DataBox:UnknownRuleType
            %

            fields = fieldnames(obj.rules);

            for i = 1:numel(fields)
                obj.check(fields{i});
            end

        end

        function newObj = copy(obj)
            newObj = DataBox(obj.name);
            newObj.data = obj.data;
            newObj.rules = obj.rules;
        end

    end

end
