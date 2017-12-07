function [ QP ] = cutest_getQP( varargin )
%CUTEST_GETQP Get the QP representation of a CUTEst problem
%
% This function will return the QP representation of the CUTEst problem.
% The optimization problem returned is of the form
%
%   min x'Qx + c'x
%   s.t. 
%       Aeq*x= beq
%       Ale*x <= ble
%
%       lb <= x <= ub
%
% Usage:
%   [Q, c, Aeq, beq, Ale, ble, ub, lb, x0, mu0] = cutest_getQP()
%   [Q, c, Aeq, beq, Ale, ble, ub, lb, x0, mu0] = cutest_getQP( point )
%   [Q, c, Aeq, beq, Ale, ble, ub, lb, x0, mu0] = cutest_getQP( point, problemDir )
%
% Inputs:
%   point - The point around which the QP should be formed (if empty or []
%           then the QP is found around the origin).
%   problemDir - Directory the mcutest.mex file is located in (if not in
%                current directory)
%
% Outputs:
%   QP  - A data structure containing the problem matrices (as follows)
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
%
% Created by: Ian McInerney
% Created on: November 15, 2017
% Version: 1.4
% Last Modified: December 4, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Added initial variable output
%   1.2 - Modified output to be in a data structure, added problem name field
%   1.3 - Changed objective gradient function to use cutest_slagjac instead of cutest_grad
%   1.4 - Add rounding to 0 if value is less than 1e-8
%         Modified gradient evaluation to retry evaluation if any value is greater than 1e8
%         Added ability to specify the point to form the QP around


%% Get the arguments from the function
switch ( length(varargin) )

    case 0
        % Default case (no arguments)
        point = [];
        originalDir = pwd;
    case 1
        % The point to use was specified
        point = varargin{1};
        originalDir = pwd;
    case 2
        % The point to use was specified
        point = varargin{1};
        
        % Navigate to the proper directory
        originalDir = cd( varargin{2} );
    otherwise
        % Default case (no arguments)
        point = [];
        originalDir = pwd;
end


%% Make sure the cutest problem exists on the path
if ( exist('mcutest') ~= 3 )
    error('Cutest problem is not in the current directory');
end

% Get the CUTEst problem structure from the mex file
Problem = cutest_setup();

% The lower bound for coefficients
tol = 1e-8;


%% Create the point where the derivative should be found if it isn't specified
if ( isempty(point) )
    point = zeros(Problem.n, 1);
end


%% Get the objective function quadratic term

% Get the hessian of the objective at the point
QP.Q = cutest_isphess( point, 0);

% Round any near-zero values to zero
QP.Q( abs(QP.Q) < tol ) = 0;


%% Get the objective function linear term

% In an ideal world, this cutest_grad function would be all that is needed,
% however it crashes the .mex file when run on problems that have parameters set
% at SIF decode time
%QP.c = sparse( cutest_grad( point, 0) );   % Get the gradient at x=0

% Get the gradient of the objective at the point
% This is done in a voting fashion, where the gradient is computed multiple
% times, then the number that appears the most in each slot is chosen as
% the actual gradient value
%
% This method is used because it was noticed that for certain problems
% (e.g. the cvxqp1 from CUTEst with N=10) the gradient may return
% extraneous values. In that case it would occasionally return non-zero
% values in positions 5 and 10 (e.g. 1.9e31, 128.001, etc.). The majority
% of the time it returned the correct value of 0, so a voting scheme was
% adopted.
numVotes = 20;
grads = sparse(Problem.n, numVotes);
for (i = 1:1:numVotes)
    [c, ~] = cutest_slagjac( point, 0 );
    c( abs(c) < tol ) = 0;
    grads(:,i) = c;
end

QP.c = mode(grads, 2);



%% Get the constraints

% Get the constraints around the point
[con_rhs, con_lhs ] = cutest_scons(point);

% Check for non-linear constraints and warn the user
if ( sum(Problem.linear) ~= Problem.m )
    warning('Problem contains non-linear constraints. Those constraints will be ignored.');
end

% Create logical indexing for the different constraint types
con_eq = Problem.linear & Problem.equatn;
con_ineq = Problem.linear & ~Problem.equatn;

% Pull out the equality constraints from the constraint arrays
QP.Aeq = con_lhs( con_eq, : );
QP.beq = sparse( con_rhs( con_eq ) );

% Round any near-zero values to zero
QP.Aeq( abs(QP.Aeq) < tol ) = 0;
QP.beq( abs(QP.beq) < tol ) = 0;

% Find the constraints that are LEQ or GEQ
% When the bound doesn't exist, it is put to +/-1e20 in the array
con_leq = con_ineq & (Problem.cl == -1e20);
con_geq = con_ineq & (Problem.cu == 1e20);

% Pull out the <= constraints
Ale = con_lhs( con_leq, : );
ble = sparse(Problem.cu( con_leq ));

% Pull out the >= constraints and convert them to <=, then append them to
% the constraint matrix
QP.Ale = [Ale;
       -1.*con_lhs( con_geq, : ) ];
QP.ble = [ble;
       -1.*Problem.cl( con_geq) ];

% Round any near-zero values to zero
QP.Ale( abs(QP.Ale) < tol ) = 0;
QP.ble( abs(QP.ble) < tol ) = 0;
   

%% Get the upper and lower bounds for the variables
QP.ub = Problem.bu;
QP.lb = Problem.bl;

% Round any near-zero values to zero
QP.ub( abs(QP.ub) < tol ) = 0;
QP.lb( abs(QP.lb) < tol ) = 0;


%% Get the initial guesses for the variables
QP.x0 = Problem.x;
QP.mu0 = Problem.v;

% Round any near-zero values to zero
QP.x0( abs(QP.x0) < tol ) = 0;
QP.mu0( abs(QP.mu0) < tol ) = 0;


%% Terminate the CUTEst problem before exiting
QP.name = Problem.name;
cutest_terminate();

cd(originalDir);

end
