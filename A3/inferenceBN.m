%Call the script to create the BN structure, which will also populate CPTs
modelStructure;
%Create inference engine for the BN
engineBN1 = jtree_inf_engine(bnet);
%Define the variable for evidence
evidence1 = cell(1,5);
%We observe that the student is confused, IE Con = 2
evidence1{Con} = 2;
engineBN1 = enter_evidence(engineBN1, evidence1);
%Compute the marginal over the variable NeHe
marg1 = marginal_nodes(engineBN1,NeHe);
%Display the true value (at index 2) of the marginal
fprintf('Pr(NeHe=true|Con=true) = %5.3f\n', marg1.T(2))
%We see now that when the student is confused, they will need help 96.4% of
%the time.
%Now we need to reset the model and the engine, so that we can submit new
%evidence. Repeat the above except for the evidence.
modelStructure;
engineBN2 = jtree_inf_engine(bnet);
evidence2 = cell(1,5);
%Now we set confused as false (1), time as slow (1), and accuracy as high
%(2).
evidence2{Con} = 1;
evidence2{Time} = 1;
evidence2{Acc} = 2;
engineBN2 = enter_evidence(engineBN2, evidence2);
%Compute the marginal again
marg2 = marginal_nodes(engineBN2,NeHe);
%Display the true value (at index 2) of the marginal
fprintf('Pr(NeHe=true|Con=true,Time=slow,Acc=high) = %5.3f\n', marg2.T(2))