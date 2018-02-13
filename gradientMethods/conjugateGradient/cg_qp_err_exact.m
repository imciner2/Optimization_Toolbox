function [ err ] = cg_qp_err_exact( lam )
%CG_QP_ERR_EXACT Compute sharp error bound for exact CG
%
% This function computes the sharp error bound the the Conjugate Gradient
% method run under exact arithmetic. It utilizes the minimax error bound
% proposed by Greenbaum in:
%   A. Greenbaum, “Comparison of splittings used with the conjugate
%   gradient algorithm,” Numer. Math., vol. 33, no. 2, pp. 181–193, 1979.
% It utilizes the barycentric method of computing the polynomial
% interpolation to reduce the chances of numerical instability in the
% interpolation affecting the result.
%
%
% Usage:
%   [ err ] = CG_QP_ERR_EXACT( lam );
%
% Inputs:
%   lam - The eigenvalues of the A matrix
%
% Outputs:
%   err - The bound on the error in the A-norm
%
%
% Created by: Ian McInerney
% Created on: January 30, 2018
% Version: 1.1
% Last Modified: February 13, 2018
%
% Revision History
%   1.0 - Initial release
%   1.1 - Modified polynomial to use Lagrange polynomials and the Remes
%         algorithm


%% Make sure eig is a column vector and remove repeated values
lam = reshape(lam, [], 1);
lam = unique(lam);
numEig = length(lam);


%% Initialize variables
err = NaN(numEig+1, 1);
Z = zeros(numEig, 1);


%% Create the set to perform the interpolation over
eigSet = [ lam, Z ];


%% Figure out the error bound for the method
for k=1:1:numEig
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

