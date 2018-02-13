function [ err ] = cg_qp_err_fp( lam, varargin )
%CG_QP_ERR_FP Compute the error bound for finite-precision CG
%
% This function computes the error bound for the Conjugate Gradient
% method run under finite precision arithmetic with the precision specified.
% It utilizes the minimax error bound proposed by Greenbaum in:
%   A. Greenbaum, “Comparison of splittings used with the conjugate
%   gradient algorithm,” Numer. Math., vol. 33, no. 2, pp. 181–193, 1979.
% But with the addition of "fuzzy-eigenvalues" to the eigenvalues provided.
% This approximates the behavior of the finite-precision algorithm, as
% described in:
%   A. Greenbaum, “Behavior of slightly perturbed Lanczos and conjugate-
%   gradient recurrences,” Linear Algebra Appl., vol. 113, pp. 7–63, 1989.
%
% It utilizes the barycentric method of computing the polynomial
% interpolation to reduce the chances of numerical instability in the
% interpolation affecting the result.
%
%
% Usage:
%   [ err ] = CG_QP_ERR_FP( lam );
%   [ err ] = CG_QP_ERR_FP( lam, iter, n, delta );
%
% Inputs:
%   lam   - The eigenvalues of the A matrix
%   iter  - The number of iterations to create estimates for
%   n     - The number of "fuzzy-eigenvalues" to create in the interval
%   delta - The size on each side of the eigenvalue for the interval
%
% Outputs:
%   err - The bound on the error in the A-norm
%
%
% Created by: Ian McInerney
% Created on: January 31, 2018
% Version: 1.1
% Last Modified: February 13, 2018
%
% Revision History
%   1.0 - Initial release
%   1.1 - Modified polynomial to use Lagrange polynomials and the Remes
%         algorithm


%% Extract the input parameters
p = inputParser;
addOptional(p, 'iter', NaN );
addOptional(p, 'n', 10);
addOptional(p, 'delta', 1e-6');
parse(p, varargin{:});

n = p.Results.n;
iter = p.Results.iter;
delta = p.Results.delta;


%% Make sure eig is a column vector
lam = reshape(lam, [], 1);


%% Create the intervals for the fuzzy-eigenvalues
intStart = lam - delta;
intEnd   = lam + delta;

fuzz = [];
for i=1:1:length(intStart)
    fuzz = [fuzz;
            linspace(intStart(i), intEnd(i), n)';
            lam(i)];
end

% Sort and de-duplicate the array (only save the positive values)
fuzz = sort( fuzz );
fuzz = sort( fuzz( fuzz >= 0 ) );
fuzz = unique(fuzz);

% Count the number of fuzzy-eigenvalues eigenvalues
numEig = length(fuzz);


%% Initialize the vectors
err = NaN(iter+1, 1);
Z = zeros(numEig, 1);


%% Create the set to perform the interpolation over
eigSet = [ fuzz, Z ];


%% Compute the number of iterations to run for
iterCap = min(numEig, iter);


%% Figure out the error bound for the method
for k=1:1:iterCap
    % Compute the minimax Lagrange polynomial over the eigenvalue set
    [p, ~] = remes_exchange_lagrange(k-1, eigSet, 10000, 500, 1e-6);

    % Compute the interpolation for the points where the minimax poly has
    % largest error
    np = length(p);
    f = cos(pi*[0:1:np-1]);
    [w, C] = bary_weights_arb(p, np-1);
    interp_den = bary_computeInterp(0, p, f, w, C);

    % Determine the error of the CG algorithm
    err(k) = max( abs(1/interp_den) );
end


end

