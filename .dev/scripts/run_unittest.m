import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;

cd([fileparts(mfilename('fullpath')),'/../..']);

utilsDir = fullfile('utils');
baseDir = fullfile('base');

suite_utils = TestSuite.fromFolder(utilsDir, 'IncludingSubfolders', true);
suite_base = TestSuite.fromFolder(baseDir, 'IncludingSubfolders', true);
suite = [suite_utils, suite_base];

runner = TestRunner.withTextOutput;

runner.addPlugin(TestReportPlugin.producingHTML('TestReport'));

results = runner.run(suite);
