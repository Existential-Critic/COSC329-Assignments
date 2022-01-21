%Set nodes
Dif = 1; Acc = 2; Time = 3; NeHe = 4; Con = 5;
%Create the direction matrix
dag = zeros(5,5);
dag(Dif,[Acc Time NeHe]) = 1;
dag(NeHe,Con) = 1;
%Set the node sizes
ns = [2 2 3 2 2];
%Make the BN model structure
bnet = mk_bnet(dag,ns);
%Populate CPTs
populateCPTs