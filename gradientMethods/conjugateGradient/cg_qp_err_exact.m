function [ err ] = cg_qp_err_exact( lam )
%CG_QP_ERR_EXACT Compute sharp error bound for exact CG
%
% This function computes the sharp error bound the the Conjugate Gradient
% method run under exact arithmetic. It utilizes the scaled-and-shifted
% Chebyshev polynomials as the basis for the minimax polynomial which is
% fitted over the eigenvalues provided to the function.
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
% Version: 1.0
% Last Modified: January 30, 2018
%
% Revision History
%   1.0 - Initial release


%% Solver options for the LP solver
solveOpt = {'Algorithm', 'dual-simplex',...
            'MaxIterations', 1000,...
            'Display', 'off'};


%% Make sure eig is a column vector and initialize variables
lam = reshape(lam, [], 1);
numEig = length(lam);

err = zeros(numEig+1, 1);
Z = zeros(numEig, 1);


%% Create the set to perform the interpolation over
eigSet = [ lam, Z ];

      
%% Figure out the error bound for the method
for k=1:1:numEig+1
    % Compute the minimax polynomial using the Scaled-and-Shifted Chebyshev
    % polynomials and the Linear Programming formulation of the minimax
    % polynomial problem.
    [~, err(k)] = lp_minimaxPoly(k-1, eigSet, 'SSChebyshev', 1, solveOpt);
end


end

