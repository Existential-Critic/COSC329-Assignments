%As we have to handcraft this CPT, I have to come up with reasonable
%parameters for when a student will need help, based on the difficulty of
%the question. It is my opinion that if the difficulty is easy, then a
%student will probably only need help 10% of the time, as the questions are
%easy. This is shown by the CPT for how likely it is for a student to be
%correct. If the questions are hard however, it goes up to 40% of the time,
%as shown by the accuracy CPT.
neHeCPT = zeros(1,2,2);
neHeCPT(1,1,:) = [0.9 0.1];
neHeCPT(1,2,:) = [0.6 0.4];
bnet.CPD{NeHe} = tabular_CPD(bnet, NeHe, 'CPT', neHeCPT);