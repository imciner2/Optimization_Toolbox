function [ QP ] = benchmark_fetch_marosmeszaros( problemName, varargin )
%BENCHMARK_FETCH_MAROSMESZAROS Fetch a problem from the Maros & Meszaros QP benchmark set
%
% This function will fetch a problem from the Maros & Meszaros benchmark
% set (http://www.cuter.rl.ac.uk/Problems/marmes.shtml), then convert it
% into a QP structure in MATLAB. The structure contains fields that map to
% the otpimization problem:
%
%   min x'Qx + c'x
%   s.t. 
%       Aeq*x= beq
%       Ale*x <= ble
%
%       lb <= x <= ub
%
% with intial conditions for the primal variables in x0, and initial
% conditions for the dual variables in mu0.
%
%
% Usage:
%   [ QP ] = benchmark_fetch_marosmeszaros( problemName )
%   [ QP ] = benchmark_fetch_marosmeszaros( problemName, forceRebuild )
%
% Inputs:
%   problemName  - The name of the problem in the Maros & Meszaros QP
%                  benchmark set to download.
%   forceRebuild - Force the problem to be rebuilt (defaults to false, e.g. 0)
%
% Outputs:
%   QP - A structure containing the matrices and vectors that make up the
%        QP problem (as follows).
%         Q    - The quadratic term matrix
%         c    - The linear term vector
%         Aeq  - The coefficient matrix for the linear equality constraints
%         beq  - The constant vector for the linear equality constraints
%         Ale  - The coefficient matrix for the linear inequality constraints
%         ble  - The constant vector for the linear inequality constraints
%         ub   - The upper bounds on the variables
%         lb   - The lower bounds on the variables
%         x0   - Initial guess for x
%         mu0  - Initial geuss for mu
%         name - Problem name
%
% Created by: Ian McInerney
% Created on: November 24, 2017
% Version: 1.2
% Last Modified: December 7, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Modified to use generic SIF scripts
%	1.2 - Updated the output from cutest_getQP() and added error checking
%   1.3 - Added ability to force the rebuild of the QP problem

disp(['Fetching problem ', upper(problemName)]);

%% Get the arguments from the function
if ( ~isempty(varargin) )
    % Figure out if force is needed
    force = varargin{1};
else
    force = 0;
end

if (force == 1)
    disp('Forcing rebuild of problem');
end


%% Find the directory where the problems will be located, and navigate to it
scriptDir = which('benchmark_fetch_marosmeszaros');
scriptDir = strrep(scriptDir, 'benchmark_fetch_marosmeszaros.m', '');
originalDir = cd(scriptDir);


%% Check to see if the problem exists as a .mat file already
saveFile=['problems/marosmeszaros/', upper(problemName), '.mat'];
if ( (exist(saveFile, 'file') ~= 0) && (~force) )
    % The file exists, load it then leave
    disp('Problem already downloaded and converted, loading .mat file');
    load(saveFile);
    cd(originalDir);
    return;
end


%% Call the script to get the problem
disp('Calling conversion scripts');
cd('scripts');
stat = system(['./getSIF.sh ', problemName, ' marosmeszaros ftp://ftp.numerical.rl.ac.uk/pub/cuter/marosmeszaros ', num2str(force)]);
cd('../');


%% Check the error status and see if there was a problem
if (stat)
    error(['Unable to fetch problem ', problemName]);
end

%% Navigate to the active directory for the problem, get it, and save it
cd('problems/activeCUTEst');
disp('Getting QP form of the problem');
[ QP ] = cutest_getQP();
cd(scriptDir);
save(saveFile, 'QP');


%% Go back to the original directory
cd(originalDir);

end
