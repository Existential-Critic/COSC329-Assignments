%Set Difficulty to a uniform distribution
bnet.CPD{Dif} = tabular_CPD(bnet, Dif, 'CPT', [0.5 0.5]);
%Call the scripts to get the CPTs for Accuracy and Time, which are added to
%the bnet through their respective scripts
accuracyPR;
timePR;
%Call the scripts to get the handcrafted CPTs for Need Help and Confused
needHelpPR;
confusedPR;