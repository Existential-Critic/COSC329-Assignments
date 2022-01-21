%function DBNNH = mk_needhelp

names = {'NeedHelp','TaskTime','Correct'}; %To refer to later
ss = length(names);
DBNNH = names;

%Intra-stage dependencies
intra = zeros(3);
intra(1,[2 3]) = 1;

%Inter-stage dependencies
inter = zeros(3);
inter(1,1) = 1;

%Observations for both TaskTime and Correct
oNodes = [2,3];

%Discretize nodes
Hid = 2; %Two hidden states
Obs1 = 3; %Three observable states
Obs2 = 2; %Two observable states
ns = [Hid Obs1 Obs2];
dnodes = 1:ss;

%Define equivalence classes
ecl1 = [1 2 3];
ecl2 = [4 2 3]; %Node 4 is tied to nodes 1 and 3

% create the dbn structure based on the components defined above
bnet = mk_dbn(intra,inter,ns,'discrete',dnodes,'eclass1',ecl1,'eclass2',ecl2,'observed',oNodes,'names',names);
DBNNH  = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to define CPTs for: 
% 1. Prior, Pr(NeedHelp0)
% 2. Transition function, Pr(NeedHelp_t|NeedHelp_t-1)
% 3. Observation function, Pr(TaskTime_t|NeedHelp_t) and
%    Pr(Correct_t|NeedHelp_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NeedHelp0 = 1;
TaskTime = 2;
Correct = 3;
NeedHelp1 = 4;

%Prior, Pr(Read0)
bnet.CPD{NeedHelp0} = tabular_CPD(bnet,NeedHelp0,'CPT',[0.5 0.5]);

%Transition function, Pr(NeedHelp_t|NeedHelp_t-1)
% NH0 --> NH1 = false, true
%False:  0.8     0.2
%True:   0.1     0.9
transCPT = zeros(1,2,2);
transCPT(1,1,:) = [0.8 0.2];
transCPT(1,2,:) = [0.1 0.9];
bnet.CPD{NeedHelp1} = tabular_CPD(bnet,NeedHelp1,'CPT',transCPT);

%Observation functions, Pr(TaskTime_t|NeedHelp_t) and
%Pr(Correct_t|NeedHelp_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TaskTime: time=short,onTask,long
%NeedHelp=false: 0.25, 0.55, 0.2 %When not needing help, student will
%average a lot with a small mix of short and long
%NeedHelp=true: 0.1, 0.3, 0.6    %When needing help, student will take much
%longer to complete tasks
ttCPT = zeros(1,2,3);
ttCPT(1,1,:) = [0.25 0.55 0.2];
ttCPT(1,2,:) = [0.1 0.3 0.6];
bnet.CPD{TaskTime} = tabular_CPD(bnet,TaskTime,'CPT',ttCPT); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct: correct=false,true
%NeedHelp=false: 0.2, 0.8  %When not needing help, student will most likely
%be able to solve questions correctly, leading me to assign 80%
%NeedHelp=true: 0.7, 0.3     %When needing help, student will not know what
%to do and will be incorrect much more frequently
cCPT = zeros(1,2,2);
cCPT(1,1,:) = [0.2 0.8];
cCPT(1,2,:) = [0.7 0.3];
bnet.CPD{Correct} = tabular_CPD(bnet,Correct,'CPT',cCPT); 

DBNNH = bnet;