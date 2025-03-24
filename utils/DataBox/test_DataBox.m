function tests = test_DataBox
    tests = functiontests(localfunctions);
end

%% Test DataBox Construction
function testConstructor(testCase)
    db = DataBox('TestBox');
    verifyEqual(testCase, db.name, 'TestBox');
    verifyTrue(testCase, isempty(fieldnames(db.data)));
    verifyTrue(testCase, isempty(fieldnames(db.rules)));
end

%% Test has() method
function testHasMethod(testCase)
    db = DataBox('TestBox');
    db.data.alpha = 42;
    verifyTrue(testCase, db.has('alpha'));
    verifyFalse(testCase, db.has('beta'));
end

%% Test require() method
function testRequireMethod(testCase)
    db = DataBox('TestBox');
    db.require('alpha', 'alpha is required.');

    verifyError(testCase, @() db.check('alpha'), 'DataBox:FieldMissing');

    db.data.alpha = 10;
    verifyWarningFree(testCase, @() db.check('alpha'));
end

%% Test conditionally_require() method
function testConditionallyRequireMethod(testCase)
    db = DataBox('TestBox');
    db.conditionally_require('beta', @(x) x > 5, 'beta must be > 5.');

    verifyWarningFree(testCase, @() db.check('beta'));

    db.data.beta = 3;
    verifyError(testCase, @() db.check('beta'), 'DataBox:ConditionNotMet');

    db.data.beta = 10;
    verifyWarningFree(testCase, @() db.check('beta'));
end

%% Test enforce() method
function testEnforceMethod(testCase)
    db = DataBox('TestBox');
    db.enforce('gamma', @(x) x > 0, 'gamma must be positive.');

    verifyError(testCase, @() db.check('gamma'), 'DataBox:MandatoryFieldMissing');

    db.data.gamma = -5;
    verifyError(testCase, @() db.check('gamma'), 'DataBox:ValidationFailed');

    db.data.gamma = 8;
    verifyWarningFree(testCase, @() db.check('gamma'));
end

%% Test check_all() method
function testCheckAllMethod(testCase)
    db = DataBox('TestBox');
    db.require('alpha', 'alpha is required.');
    db.conditionally_require('beta', @(x) x > 5, 'beta must be > 5.');
    db.enforce('gamma', @(x) x > 0, 'gamma must be positive.');

    verifyError(testCase, @() db.check_all(), 'DataBox:FieldMissing');

    db.data.alpha = 20;
    verifyError(testCase, @() db.check_all(), 'DataBox:MandatoryFieldMissing');

    db.data.gamma = -2;
    verifyError(testCase, @() db.check_all(), 'DataBox:ValidationFailed');

    db.data.gamma = 3;
    db.data.beta = 10;
    verifyWarningFree(testCase, @() db.check_all());
end

%% Test copy() method for deep copy functionality
function testCopyMethod(testCase)
    db1 = DataBox('TestBox1');
    db1.data.alpha = 42;
    db1.data.beta = 10;

    % Create a copy of db1
    db2 = db1.copy();

    % Verify that db2 is a different instance from db1
    verifyFalse(testCase, db1 == db2);

    % Verify that db2 has the same data as db1
    verifyEqual(testCase, db2.data.alpha, 42);
    verifyEqual(testCase, db2.data.beta, 10);

    % Modify db1's data and verify db2 is not affected
    db1.data.alpha = 100;

    verifyNotEqual(testCase, db1.data.alpha, db2.data.alpha);  % db2 should still have the original value
    verifyEqual(testCase, db2.data.alpha, 42);  % db2's alpha should not have changed

    % Verify db2's data remains intact when db1 is modified
    verifyEqual(testCase, db2.data.beta, 10);
end
