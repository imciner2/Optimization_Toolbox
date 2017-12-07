classdef AugmentedLagrangian_QP_LT
    %AugmentedLagrangian_QP_LT The linear coefficient vector for Augmented Lagrangian
    %
    % The Augmented Lagrangian for QPs solves the problem of the form:
    %         min 1/2 x'Ax - b'x
    %         s.t. Cx = d
    % by introducing a quadratic penalty term and also the Lagrange
    % multipler vector for the constraint. This then creates a saddle-point
    % optimization problem:
    %         max min 1/2 x'Ax - b'x + u'*(Cx - d) + rho*(Cx - d)^2
    %          u   x
    % The linear coefficient vector can take on two forms (depending on if
    % it is looked at as coefficients for the primal or the dual variables):
    %       Primal:
    %         b + C'*(rho*d - u)
    %       Dual:
    %         (Cx - d)
    %
    % Properties:
    %   b   - The linear coefficients for the objective function
    %   C   - The LHS matrix of the constraints
    %   d   - The constaints for the constraints
    %   u   - The current Lagrange multipliers (only used in primal form)
    %   x   - The current primal variables (only used in dual form)
    %   rho - The penalty parameter
    %   pri - Use the primal form of the vector if 1, dual if 0
    %   tra - If 1 compute the transpose of the vector
    %
    % Methods:
    %   compute     - Compute the compute of the Hessian
    %   usePrimal - Use the primal form of the vector (e.g. vec'*x)
    %   useDual   - Use the dual form of the vector (e.g. vec'*u)
    properties
        b       % The linear coefficients for the objective function
        C       % The LHS matrix of the constraints
        d       % The constaints for the constraints
        u       % The current Lagrange multipliers (only used in primal form)
        x       % The current primal variables (only used in dual form)
        rho     % The penalty parameter
        pri     % Use the primal form of the vector if 1, dual if 0
        tra     % If 1, compute the transpose of the vector
    end
    methods
        function obj = AugmentedLagrangian_QP_LT(b, C, d, rho)
            %AugmentedLagrangian_QP_LT Create the vector
            %
            %  Creates the vector object.
            %
            % Usage:
            %  [ vec ] = AugmentedLagrangian_QP_Hessian(b, C, d, rho)
            %
            % Inputs:
            %  b   - The linear coefficients for the objective function
            %  C   - The LHS matrix of the constraints
            %  d   - The constaints for the constraints
            %  rho - The penalty parameter
            %
            % Outpus:
            %  vec - The vector object
            obj.b = b;
            obj.C = C;
            obj.d = d;
            obj.rho = rho;
            
            obj.u = 0;
            obj.x = 0;
            obj.tra = 0;
            obj.pri = 1;
        end
        
        function res = compute(a)
            %compute Evaluate the linear coefficients and return the vector
            if (a.pri)
                % Use the primal form

                % Determine which order to do operations
                switch( a.tra )
                case 0
                    % Compute using no transpose
                    res = (a.b) + (a.C)'*((a.rho)*(a.d) - (a.u));
                case 1
                    % Compute using the conjugate transpose
                    res = (a.b).' + ((a.rho)*(a.d) - (a.u)).'*(a.C);
                case 2
                    % Compute using the normal transpose
                    res = (a.b)' + ((a.rho)*(a.d) - (a.u))'*(a.C);
                otherwise
                    % Default to no transpose
                    res = (a.b) + (a.C)'*((a.rho)*(a.d) - (a.u));
                end

            else
                % Use the dual form

                % Determine which order to do operations
                switch( a.tra )
                case 0
                    % Compute using no transpose
                    res = ( (a.C)*(a.x) - (a.d));
                case 1
                    % Compute using the conjugate transpose
                    res = ( (a.C)*(a.x) - (a.d))';
                case 2
                    % Compute using the normal transpose
                    res = ( (a.C)*(a.x) - (a.d)).';
                otherwise
                    % Default to no transpose
                    res = ( (a.C)*(a.x) - (a.d));
                end
            end
        end
        
        function res = subsref(a, b)
            %subsref Get the Hessian compute at specific indices
            
            % Test the type of reference to make sure it is right
            if ( ~strcmp(b.type, '()') )
                error('Unsupported reference type');
            end
            
            % Make sure there are enough subscripts
            [t1, t2] = size(b.subs);
            if ( (t1 ~= 1) && (t2 ~= 2) )
                error('Incorrect number of subscripts');
            end
            
            % Compute the value of the vector
            vec = compute(a);
            
            
            % Get the relevant indices to pull from
            [brow, bcol] = size(vec);
            if ( b.subs{1} == ':' )
                % It is all the elements in the column
                rowIndices = 1:1:brow;
            else
                % It is only specific elements in the column
                rowIndices = b.subs{1};
            end
            
            if ( b.subs{2} == ':' )
                % It is all the elements in the column
                colIndices = 1:1:bcol;
            else
                % It is only specific elements in the column
                colIndices = b.subs{2};
            end
            
            res = vec(rowIndices, colIndices);

        end
        
        function res = transpose(a)
            %transpose Compute the transpose of the coefficient vector
            res = a;
            res.tra = 1;
        end
        
        function res = ctranspose(a)
            %ctranspose Compute the conjugate transpose of the coefficient vecotor
            res = a;
            res.tra = 2;
        end
        
        function res = plus(a, b)
            %minus Perform subtraction using this vector
            
            if ( isa(a, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                lv = compute(a);
            else
                % Otherwise just pass it through
                lv = a;
            end
            
            if ( isa(b, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                rv = compute(b);
            else
                % Otherwise just pass it through
                rv = b;
            end
            
            res = lv + rv;
        end
        
        function res = minus(a, b)
            %minus Perform subtraction using this vector
            
            if ( isa(a, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                lv = compute(a);
            else
                % Otherwise just pass it through
                lv = a;
            end
            
            if ( isa(b, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                rv = compute(b);
            else
                % Otherwise just pass it through
                rv = b;
            end
            
            res = lv - rv;
        end
        
        function res = mtimes(a, b)
            %mtimes Compute the matrix multiplication of the Hessian
            
            if ( isa(a, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                lv = compute(a);
            else
                % Otherwise just pass it through
                lv = a;
            end
            
            if ( isa(b, 'AugmentedLagrangian_QP_LT') )
                % Compute the vector compute if it is the coefficients
                rv = compute(b);
            else
                % Otherwise just pass it through
                rv = b;
            end
            
            res = lv*rv;
        end
        
    end
end