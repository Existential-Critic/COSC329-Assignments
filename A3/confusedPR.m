%This is the other CPT we have to handcraft. This time, we need to
%determine if a student is confused dependent on whether or not they need
%help with a question. It is my opinion that if a student needs help, there
%is a very high chance, say 80%, that they are confused. There are very few
%reasons that a student would need help other than confusion, but I want to
%give enough variance just in case. As for if a student does not need help,
%I am willing to say that if a student does not need help then there is a
%very low chance, 0.01, that they are confused.
conCPT = zeros(1,2,2);
conCPT(1,1,:) = [0.99 0.01];
conCPT(1,2,:) = [0.2 0.8];
bnet.CPD{Con} = tabular_CPD(bnet, Con, 'CPT', conCPT);