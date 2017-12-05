%% Setup the MATLAB path to contain the proper folders for the Optimization Toolbox

% Find out where the toolbox is
filename = [mfilename, '.m'];
scriptDir = which(filename);
scriptDir = strrep(scriptDir, filename, '');

% Add all subfolders to the path
addpath( genpath(scriptDir) );

% Remove the benchmark problems directory from the path
rmpath( genpath([scriptDir, filesep, 'benchmarking', filesep, 'problems']) );

% Remove the testbench directory from the path
rmpath( genpath([scriptDir, filesep, 'testbenchs']) );

% Remove the variables used
clear filename scriptDir