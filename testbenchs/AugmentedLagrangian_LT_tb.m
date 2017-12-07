numTests = 100;
numVar = 10;
numCon = 100;

tol = 1e-6;

rightPriTestPass = 0;
rightDualTestPass = 0;

leftPriTestPass = 0;
leftDualTestPass = 0;

transPriTestPass = 0;
transDualTestPass = 0;

ctransPriTestPass = 0;
ctransDualTestPass = 0;

subsPriTestPass = 0;
subsDualTestPass = 0;

subtractPriTestPass = 0;
subtractDualTestPass = 0;

addPriTestPass = 0;
addDualTestPass = 0;

for (i = 1:1:numTests)
    % Randomly generate the A and C matrices
    b = rand(numVar, 1);
    C = rand(numCon, numVar);
    d = rand(numCon, 1);
    x = rand(numVar, 1);
    u = rand(numCon, 1);
    
    rho = rand(1,1);
    
    % Create the Hessian
    ltVec = AugmentedLagrangian_QP_LT(b, C, d, rho);
    ltVec.x = x;
    ltVec.u = u;
    
    vec1 = rand(numVar, 1);
    vec2 = rand(numCon, 1);
    
    %% Test right multiplication
    ltVec.pri = 1;
    priTest = vec1'*ltVec;
    
    ltVec.pri = 0;
    dualTest = vec2'*ltVec;
    
    priTruth = vec1'*(b+C'*(rho.*d - u));
    dualTruth = vec2'*(C*x - d);
    
    if ( abs(priTest - priTruth) > tol )
        warning('Failed right multiplication Primal test');
    else
        rightPriTestPass = rightPriTestPass + 1;
    end
    
    if ( abs(dualTest - dualTruth) > tol )
        warning('Failed right multiplication Dual test');
    else
        rightDualTestPass = rightDualTestPass + 1;
    end
    
    %% Test left multiplication
    ltVec.pri = 1;
    priTest = ltVec'*vec1;
    
    ltVec.pri = 0;
    dualTest = ltVec'*vec2;
    
    priTruth = (b+C'*(rho.*d - u))'*vec1;
    dualTruth = (C*x - d)'*vec2;
    
    if ( abs(priTest - priTruth) > tol )
        warning('Failed left multiplication Primal test');
    else
        leftPriTestPass = leftPriTestPass + 1;
    end
    
    if ( abs(dualTest - dualTruth) > tol )
        warning('Failed left multiplication Dual test');
    else
        leftDualTestPass = leftDualTestPass + 1;
    end
    
    %% Test subtraction
    ltVec.pri = 1;
    priTest1 = ltVec + vec1;
    priTest2 = vec1 + ltVec;
    
    ltVec.pri = 0;
    dualTest1 = ltVec + vec2;
    dualTest2 = vec2 + ltVec;
    
    priTruth1 = (b+C'*(rho.*d - u)) + vec1;
    priTruth2 = vec1 + (b+C'*(rho.*d - u));
    
    dualTruth1 = (C*x - d) + vec2;
    dualTruth2 = vec2 + (C*x - d);
    
    if ( abs(priTest1 - priTruth1) > tol )
        warning('Failed left addition Primal test');
    elseif ( abs(priTest2 - priTruth2) > tol )
        warning('Failed right addition Primal test');
    else
        addPriTestPass = addPriTestPass + 1;
    end
    
    if ( abs(dualTest1 - dualTruth1) > tol )
        warning('Failed left subtraction Dual test');
    elseif ( abs(dualTest2 - dualTruth2) > tol )
        warning('Failed right subtraction Dual test');
    else
        addDualTestPass = addDualTestPass + 1;
    end
    
    %% Test subtraction
    ltVec.pri = 1;
    priTest1 = ltVec - vec1;
    priTest2 = vec1 - ltVec;
    
    ltVec.pri = 0;
    dualTest1 = ltVec - vec2;
    dualTest2 = vec2 - ltVec;
    
    priTruth1 = (b+C'*(rho.*d - u)) - vec1;
    priTruth2 = vec1 - (b+C'*(rho.*d - u));
    
    dualTruth1 = (C*x - d) - vec2;
    dualTruth2 = vec2 - (C*x - d);
    
    if ( abs(priTest1 - priTruth1) > tol )
        warning('Failed left subtraction Primal test');
    elseif ( abs(priTest2 - priTruth2) > tol )
        warning('Failed right subtraction Primal test');
    else
        subtractPriTestPass = subtractPriTestPass + 1;
    end
    
    if ( abs(dualTest1 - dualTruth1) > tol )
        warning('Failed left subtraction Dual test');
    elseif ( abs(dualTest2 - dualTruth2) > tol )
        warning('Failed right subtraction Dual test');
    else
        subtractDualTestPass = subtractDualTestPass + 1;
    end
    
    %% Test conjugate transpose
    ltVec.pri = 1;
    priTest = compute(ltVec');
    priTruth = (b+C'*(rho.*d - u))';
    
    ltVec.pri = 0;
    dualTest = compute(ltVec');
    dualTruth = (C*x - d)';
    
    if ( all(all(abs(priTest - priTruth) > tol)) )
        warning('Failed conjugate transpose Primal test');
    else
        ctransPriTestPass = ctransPriTestPass + 1;
    end
    
    if ( all(all(abs(dualTest - dualTruth) > tol)) )
        warning('Failed conjugate transpose Dual test');
    else
        ctransDualTestPass = ctransDualTestPass + 1;
    end
    
    %% Test transpose
    ltVec.pri = 1;
    priTest = compute(ltVec.');
    priTruth = (b+C'*(rho.*d - u)).';
    
    ltVec.pri = 0;
    dualTest = compute(ltVec.');
    dualTruth = (C*x - d).';
    
    if ( all(all(abs(priTest - priTruth) > tol)) )
        warning('Failed transpose Primal test');
    else
        transPriTestPass = transPriTestPass + 1;
    end
    
    if ( all(all(abs(dualTest - dualTruth) > tol)) )
        warning('Failed transpose Dual test');
    else
        transDualTestPass = transDualTestPass + 1;
    end
    
    %% Test subscript referencing
    numRefs = randi(numVar);
    row = randi(numVar, 1, numRefs);
    col = 1;
    
    ltVec.pri = 1;
    priTest = ltVec(row, col);
    priTruth = (b+C'*(rho.*d - u));
    priTruth = priTruth(row, col);
    
    ltVec.pri = 0;
    dualTest = ltVec(row, col);
    dualTruth = (C*x - d);
    dualTruth = dualTruth(row, col);
    
    
    if ( all(all(abs(priTest - priTruth) > tol)) )
        warning('Failed subscript referencing primal test');
    else
        subsPriTestPass = subsPriTestPass + 1;
    end
    
    if ( all(all(abs(dualTest - dualTruth) > tol)) )
        warning('Failed subscript referencing dual test');
    else
        subsDualTestPass = subsDualTestPass + 1;
    end
    
end

disp(['Right Primal multiplication test pass ', num2str(rightPriTestPass), ' out of ', num2str(numTests)]);
disp(['Right Dual multiplication test pass ', num2str(rightDualTestPass), ' out of ', num2str(numTests)]);

disp(['Left Primal multiplication test pass ', num2str(leftPriTestPass), ' out of ', num2str(numTests)]);
disp(['Left Dual multiplication test pass ', num2str(leftDualTestPass), ' out of ', num2str(numTests)]);

disp(['Primal addition test pass ', num2str(addPriTestPass), ' out of ', num2str(numTests)]);
disp(['Dual addition test pass ', num2str(addDualTestPass), ' out of ', num2str(numTests)]);

disp(['Primal subtraction test pass ', num2str(subtractPriTestPass), ' out of ', num2str(numTests)]);
disp(['Dual subtraction test pass ', num2str(subtractDualTestPass), ' out of ', num2str(numTests)]);

disp(['Conjugate Primal transpose test pass ', num2str(ctransPriTestPass), ' out of ', num2str(numTests)]);
disp(['Conjugate Dual transpose test pass ', num2str(ctransDualTestPass), ' out of ', num2str(numTests)]);

disp(['Transpose Primal test pass ', num2str(transPriTestPass), ' out of ', num2str(numTests)]);
disp(['Transpose Dual test pass ', num2str(transDualTestPass), ' out of ', num2str(numTests)]);

disp(['Subscript Primal reference test pass ', num2str(subsPriTestPass), ' out of ', num2str(numTests)]);
disp(['Subscript Dual reference test pass ', num2str(subsDualTestPass), ' out of ', num2str(numTests)]);