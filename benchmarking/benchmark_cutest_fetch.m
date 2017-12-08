function [ problemDir ] = benchmark_cutest_fetch( problemName, varargin )
%BENCHMARK_CUTEST_FETCH Fetch a problem from the CUTEst benchmark set
%
% This function will fetch a problem from the CUTEst benchmark
% set (ftp://ftp.numerical.rl.ac.uk/pub/cutest/sif/mastsif.html), then
% convert it into the MATLAB problem format from CUTEst and place the
% problem in the active directory.
%
%
% Usage:
%   [ problemDir ] = benchmark_fetch_marosmeszaros( problemName )
%   [ problemDir ] = benchmark_fetch_marosmeszaros( problemName, SIFParams )
%   [ problemDir ] = benchmark_fetch_marosmeszaros( problemName, SIFParams, forceRebuild )
%
% Inputs:
%   problemName  - The name of the problem in the CUTEst benchmark set to
%                  download.
%   SIFParams    - Parameters that should be passed to the SIF decoder to
%                  create the problem (a character string) (if not needed,
%                  use [])
%   forceRebuild - Force the problem to be rebuilt (defaults to false, e.g. 0)
%
% Outputs:
%   problemDir - The file directory (full path) where the mcutest.mex file
%                is located. This directory must be the location the
%                problem is accessed from (otherwise it will fail).
%
% Created by: Ian McInerney
% Created on: November 28, 2017
% Version: 1.0
% Last Modified: December 7, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Added error checking
%   1.2 - Added ability to force rebuild of problem

disp(['Fetching problem ', upper(problemName)]);


%% Find the directory where the problems will be located, and navigate to it
scriptDir = which('benchmark_cutest_fetch');
scriptDir = strrep(scriptDir, 'benchmark_cutest_fetch.m', '');
originalDir = cd(scriptDir);


%% Parse the arguments to the function
cd('scripts');

switch ( length(varargin) )

    case 0
        % Default case (no arguments)
        params = [];
        force = 0;
    case 1
        % The SIF decode parameters were specified
        params = varargin{1};
        force = 0;
    case 2
        % SIF decode parameters and force were specified
        params = varargin{1};
        force = varargin{2};
    otherwise
        % Default case (no arguments)
        params = [];
        force = 0;
end

if (force == 1)
    disp('Forcing rebuild of problem');
end

%% Call the scripts to get the problem
if ( ~isempty(params) )
    % Give parameters to the SIF decoder
    stat = system(['./SIFget.sh ', problemName, ' cutest ftp://ftp.numerical.rl.ac.uk/pub/cutest/sif ', num2str(force), ' ', params]);
else
    % No parameters needed
    stat = system(['./SIFget.sh ', problemName, ' cutest ftp://ftp.numerical.rl.ac.uk/pub/cutest/sif ', num2str(force)]);
end
cd('../');


%% Check the error status and see if there was a problem
if (stat)
    error(['Unable to fetch problem ', problemName]);
end


%% Navigate to the active directory for the problem
cd('problems/activeCUTEst');


%% Go back to the original directory and save the problem dir as the output
problemDir = cd(originalDir);

end