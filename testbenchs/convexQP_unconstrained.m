%% Test an unconstrained convex QP solver using hyperplanes
clear;
close all;
clc;

n = 24; % Number of variables
rho = 0.8;
lam1 = 0.001;
lamn = 1;

% Create the test matrix
U = qr(rand(n));
for i=1:1:n
    lam(i) = lam1 + (i-1)/(n-1)*(lamn - lam1)*rho^(n-i);
end
A = U*diag(lam)*U';

% Create a random right-hand side
b = 4*rand(n,1);

% Just start at 0
x0 = zeros(n,1);


%% Run the solvers
[x_opt, res, k, x_it, p_it, r_it] = cg_qp(A, b, x0, 'MaxIterations', 0, 'SaveIterates', 1, 'Tolerance', 1e-6);
[x_opt_e, res_e, k_e, x_it_e, p_it_e, r_it_e] = cg_qp_exact(A, b, x0, 'MaxIterations', n+1, 'SaveIterates', 1, 'Tolerance', 1e-6);
x_opt;

x = quadprog(A, -b);


%% Normalize the p iterates
for (i=1:1:k_e)
    r_it_e(:,i) = r_it_e(:,i)./norm(r_it_e(:,i));
end
for (i=1:1:k)
    r_it(:,i) = r_it(:,i)./norm(r_it(:,i));
end


%% Compute the A-norm of the errors and the orthogonality/rank of the Krylov subspace
rtol = 1e-6;    % The tolerance of the rank
% Do it for the exact arithmetic
for (i=1:1:k_e+1)
    e = x - x_it_e(:,i);
    e_it_e(i) = e'*A*e;
end
for (i=1:1:k_e)
    R = r_it_e(:,1:i);
    O = eye(i) - R'*R;
    
    ra_e(i) = rank(R, rtol);
    ortho_e(i) = norm( O, 'fro');
end

% Do it for the FP arithmetic
for (i=1:1:k+1)
    e = x - x_it(:,i);
    e_e(i) = e'*A*e;
end
for (i=1:1:k)
    R = r_it(:,1:i);
    O = eye(i) - R'*R;
    
    ra(i) = rank(R, rtol);
    ortho(i) = norm( O , 'fro');
end


%% Plot the rank
figure;
plot(1:1:k_e, ra_e);
hold on;
plot(1:1:k, ra, 'r');
xlabel('Iteration');
ylabel('Rank');
legend('Exact Arithmetic', 'FP Arithmetic');
title('Rank of the Krylov Subspace');
grid minor;


%% Plot the A-norm of the errors
figure;
semilogy(0:1:k, e_e./e_e(1));
hold on;
semilogy(0:1:k_e, e_it_e./e_it_e(1), 'r');
semilogy(1:1:k, ortho, 'r-');
xlim([0, max(k, k_e)+2]);
ylim([1e-16, 10]);
legend('Fixed Precision', 'Exact Arithmetic', 'Loss of Orthogonality');
xlabel('Iteration');
ylabel('A-norm of error');