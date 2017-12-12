%% Setup the MATLAB path to contain the proper folders for the Optimization Toolbox

% Find out where the toolbox is
filename = [mfilename, '.m'];
scriptDir = which(filename);
scriptDir = strrep(scriptDir, filename, '');

% Add all subfolders to the path
addpath( genpath(scriptDir) );

% Remove the benchmark problems directory from the path
rmpath( genpath([scriptDir, filesep, 'benchmarking', filesep, 'problems']) );

% Readd the paths for the MPC benchmarking suite if it exists
mpcBenchmarkingFolder = [scriptDir, filesep, 'benchmarking', filesep, 'problems', filesep, 'mpcBenchmarking'];
if ( exist( [mpcBenchmarkingFolder, filesep, 'installBenchmarks.m'], 'file' ) )
    addpath( genpath([mpcBenchmarkingFolder filesep 'benchmarks']) )
    addpath( genpath([mpcBenchmarkingFolder filesep 'dataStructures']) )
end

% Remove the testbench directory from the path
rmpath( genpath([scriptDir, filesep, 'testbenchs']) );

% Remove the variables used
clear filename scriptDir mpcBenchmarkingFolder;