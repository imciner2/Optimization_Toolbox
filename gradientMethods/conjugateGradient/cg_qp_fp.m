function [ x_final, res, k, x_it, p_it, r_it ] = cg_qp_fp(A, b, x0, ep, varargin)
%CG_QP_FP Minimize the given quadratic function using the conjugate gradient method
%in finite precision arithmetic.
%
% Minimize the unconstrained quadratic program 
%         min 1/2 x'Ax - b'x
% using the Conjugate Gradient method.
%
% This function is based on the algorithm given by Greenbaum in the book
% Iterative Methods for Solving Linear Systems, SIAM, 1997.
%
%
% Usage:
%   [ x_final, res, k ] = CG_QP_FP( A, b, x0, ep );
%   [ x_final, res, k ] = CG_QP_FP( A, b, x0, ep, ... );
%   [ x_final, res, k, x_it, p_it, r_it ] = CG_QP_FP( A, b, x0, ep, 'SaveIterates', 1, ... );
%
% Inputs:
%   A  - The Hessian of the quadratic program
%   b  - The coefficients for the linear term
%   x0 - The initial point
%   ep - The precision to compute with
%
% Outputs:
%   x_final - The final (optimal) x iterate
%   res     - The L2-norm of the residual at each iteration
%   k       - The number of iterations it took to converge to the solution
%   x_it    - The x value at every iteration. Only valid when 'SaveIterates'
%             is on
%   p_it    - The search direction at every iteration. Only valid when
%             'SaveIterates' is on
%   r_it    - The residual at every iteration. Only valid when 'SaveIterates'
%             is on
%
% Options:
%   'MaxIterations' - Specify the maximum number of iterations to perform.
%                     The default is to not have an iteration limit
%
%   'ToleranceFunction' - Specify a custom function to use to compute if
%                         the solution is within tolerance. It must have
%                         arguments (x, r) and return a boolean (true if
%                         within tolerance, false if not).
%                         The default tolerance function uses the residual:
%                           @(x, r) ( norm( r, 2 ) < TOL )
%
%   'Tolerance' - Specify the tolerance values for the default tolerance
%                 function (if it is used).
%                 The default is to use 1e-4.
%
%   'SaveIterates' - Specify whether to save the intermediate values (useful
%                    for computing the error graph). 1 saves the iterates.
%
% See also CG_QP_EXACT, CG_QP
%
% Created by: Ian McInerney
% Created on: January 28, 2017
% Version: 1.0
% Last Modified: January 28, 2018
%
% Revision History:
%   1.0 - Initial Release


%% Make sure the number of arguments is correct
numArgs = length(varargin);
if ( mod(numArgs, 2) ~= 0 )
    error('cg_qp_fp: Incorrect number of arguments');
end

% Determine the number of decimal places to use
pl = abs( log10(ep) );

% Determine the number of variables in the problem
numVars = length(x0);

% Create the input parser
p = inputParser;
addParameter(p, 'MaxIterations', 0);
addParameter(p, 'Tolerance', 1e-4);
addParameter(p, 'ToleranceFunction', 0);
addParameter(p, 'SaveIterates', 0);
parse(p, varargin{:});

% Extract the inputs from the list
MAX_ITER = p.Results.MaxIterations;
TOL = p.Results.Tolerance;
tolFunc = p.Results.ToleranceFunction;
saveIter = p.Results.SaveIterates;

% Create the tolerance function if it doesn't exist
if ( tolFunc == 0 )
    tolFunc = @(x, r) ( norm( r, 2 ) < TOL );
end

% Pre-allocate the arrays
res = zeros(1, MAX_ITER);
x_it = 0;
p_it = 0;
r_it = 0;
if (saveIter)
    x_it = zeros(numVars, MAX_ITER);
    p_it = zeros(numVars, MAX_ITER);
    r_it = zeros(numVars, MAX_ITER);
end

% Setup the initial variables
x = round(x0, pl);
r = round(b - A*x, pl);
p = r;

res(1) = norm( r, 2);


%% Do the algorithm loop
k = 1;
STOP = 0;
while ~STOP
    % Save the iterates if requested
    if (saveIter)
        x_it(:,k) = x;
        p_it(:,k) = p;
        r_it(:,k) = r;
    end
    
    % Precompute a matrix-vector product
    Ap = round(A*p, pl);
    
    % Compute the step length
    alpha = round( ( r'*r ) / ( p'*Ap ), pl);
 
    % Compute the next point and residual
    x_n = round( x + alpha*p, pl);
    r_n = round( r - alpha*Ap, pl);
    
    % Compute the next direction
    beta = round( ( r_n'*r_n ) / ( r'*r ), pl);
    p_n = round( r_n + beta*p, pl);
   
    % Verify the variables are valid
    if ( any( isnan(x_n) ) )
        error('cg_qp_fp: NaN encountered in the variables, stopping');
    end
    
    % Save the new variables for the next loop
    x = x_n;
    r = r_n;
    p = p_n;

    % Save the residual distance
    res(k+1) = norm( r_n, 2 );
    
    % Check the tolerance, and if met then stop
    if ( tolFunc(x, r ) )
        STOP = 1;
    end
    
    % Update the iteration counter
    k = k + 1;
    
    % Stop after the max number of iterations if it is set
    % k starts at 1, then should go for MAX_ITER, stopping once it is hit
    if ( (MAX_ITER ~= 0) && (k == (MAX_ITER+2) ) )
        warning('cg_qp_fp: Maximum interations reached before tolerance');
        STOP = 1;
    end
    
end


%% Output the final point
res = res(1:k);
x_final = x;

% Save the last iterate
if (saveIter)
    x_it(:,k) = x;
    r_it(:,k) = r;
end

k = k-1;    % The iteration count is 1 less than k at the end

end