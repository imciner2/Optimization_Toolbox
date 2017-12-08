function benchmark_marosmeszaros_info( problemName )
%BENCHMARK_MAROSMESZAROS_INFO Get information about a Maros & Meszaros problem
%
% This function will get information about a problem from the Maros &
% Meszaros benchmark set (http://www.cuter.rl.ac.uk/Problems/marmes.shtml)
% and display it in the terminal.
%
%
% Usage:
%   benchmark_marosmeszaros_info( problemName )
%
% Inputs:
%   problemName  - The name of the problem in the benchmark set to get
%                  information for.
%
%
% Created by: Ian McInerney
% Created on: December 8, 2017
% Version: 1.0
% Last Modified: December 8, 2017
%
% Revision History:
%   1.0 - Initial Release

%% Find the directory where the scripts and active problem are located
mDir = which('benchmark_marosmeszaros_fetch');
mDir = strrep(mDir, 'benchmark_marosmeszaros_fetch.m', '');

scriptDir = [mDir, 'scripts', filesep];         % Location of the scripts

%% Call the problem information script
stat = system([scriptDir, 'SIFinfo.sh ', problemName, ' marosmeszaros']);
