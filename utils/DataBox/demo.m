%% Example 1

db = DataBox('MyDataBox');

db.data.alpha = 10;
db.data.beta = 5;

db.require('alpha', 'alpha is a required field.');
db.conditionally_require('beta', @(x) x > 3, 'beta must be greater than 3 if provided.');
db.check('beta');   % pass
db.check_all();     % pass

db.enforce('gamma', @(x) x > 0, 'gamma must exist and be greater than 0.');
db.data.gamma = 2;
db.check_all();     % This will throw an error because 'gamma' is missing



%% Example 2

input_db = DataBox('RectangleInput');
input_db.data.width = 5;
input_db.data.height = 10;

result_db = process_rectangle(input_db);

disp(result_db.data);
% struct with fields:
%    width: 5
%    height: 10
%    area: 50
%    perimeter: 30

input_db.data.width = -5;

try
    result_db = process_rectangle(input_db);
    disp(result_db.data);
catch ME
    fprintf('Caught an error: [%s] %s\n', ME.identifier, ME.message);
end

function result_db = process_rectangle(input_db)
    assert(isa(input_db, 'DataBox'), 'Input must be a DataBox.');

    input_db.enforce('width', @(x) x > 0, 'width must be positive.');
    input_db.enforce('height', @(x) x > 0, 'height must be positive.');
    input_db.check_all();

    result_db = DataBox('RectangleResults');
    result_db.data.width = input_db.data.width;
    result_db.data.height = input_db.data.height;
    result_db.data.area = input_db.data.width * input_db.data.height;
    result_db.data.perimeter = 2 * (input_db.data.width + input_db.data.height);

    result_db.enforce('area', @(x) x > 0, 'area must be positive.');
    result_db.enforce('perimeter', @(x) x > 0, 'perimeter must be positive.');

    result_db.check_all();
end
