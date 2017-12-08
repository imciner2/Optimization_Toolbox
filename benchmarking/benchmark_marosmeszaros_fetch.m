function [ QP ] = benchmark_marosmeszaros_fetch( problemName, varargin )
%BENCHMARK_MAROSMESZAROS_FETCH Fetch a problem from the Maros & Meszaros QP benchmark set
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
% Version: 1.4
% Last Modified: December 8, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Modified to use generic SIF scripts
%	1.2 - Updated the output from cutest_getQP() and added error checking
%   1.3 - Added ability to force the rebuild of the QP problem
%   1.4 - Refactored scripts

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


%% Find the directory where the scripts and active problem are located
mDir = which('benchmark_marosmeszaros_fetch');
mDir = strrep(mDir, 'benchmark_marosmeszaros_fetch.m', '');

scriptDir = [mDir, 'scripts', filesep];         % Location of the scripts
problemDir = [mDir, 'problems/activeCUTEst'];   % Location of the active problem
repoDirec = getenv('OPTIM_BENCH');              % Find the repository location


%% Check to see if the extracted problem exists as a .mat file already
saveFile=[repoDirec, '/marosmeszaros/', upper(problemName), '.mat'];
if ( (exist(saveFile, 'file') ~= 0) && (~force) )
    % The file exists, load it then leave
    disp('Problem already downloaded and converted, loading .mat file');
    load(saveFile);
    return;
end


%% Call the problem download script
stat = system([scriptDir, 'SIFdownload.sh ', problemName, ' marosmeszaros ftp://ftp.numerical.rl.ac.uk/pub/cuter/marosmeszaros ', num2str(force)]);

if (stat)
    error(['Unable to fetch problem ', problemName]);
end


%% Call the parser script
system([scriptDir, 'SIFparse.sh ', problemName, ' marosmeszaros ', num2str(force)]);


%% Extract the problem to the working directory
stat = system( [scriptDir, 'SIFextract.sh ', problemName, ' marosmeszaros ', problemDir]);

if (stat)
    error(['Unable to extract problem ', problemName]);
end


%% Navigate to the active directory for the problem, get it, and save it
originalDir = cd(problemDir);
disp('Getting QP form of the problem');
[ QP ] = cutest_getQP();    % Extract the QP
save(saveFile, 'QP');       % Save the problem 
cd(originalDir);

end
