function DBN = mk_hints

names = {'Read', 'TimeOpen'};   % easier to refer to later
ss    = length( names );
DBN   = names;

% intra-stage dependencies
intrac = {...
'Read', 'TimeOpen'};
[intra, names] = mk_adj_mat( intrac, names, 1 );
DBN = names;   % potentially re-ordered names

%inter-stage dependencies
interc = {...
'Read', 'Read'};
inter = mk_adj_mat( interc, names, 0 );

% observations
onodes = [ find(cellfun(@isempty, strfind(names,'TimeOpen'))==0) ];

% discretize nodes
Q      = 2;     % two hidden states
O      = 3;     % three observable states
ns     = [Q O];
dnodes = 1:ss;

% define equivalence classes
ecl1 = [1 2];
ecl2 = [3 2];   % node 4 is tied to node 2

% create the dbn structure based on the components defined above
bnet = mk_dbn( intra, inter, ns, ...
  'discrete', dnodes, ...
  'eclass1', ecl1, ...
  'eclass2', ecl2, ...
  'observed', onodes, ...
  'names', names );
DBN  = bnet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to define CPTs for 
% prior, Pr(Read0)
% transition function, Pr(Read_t|Read_t-1)
% observation function, Pr(TimeOpen_t|Read_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Read0    = 1;
TimeOpen = 2;
Read1    = 3;

% prior, Pr(Read0)
cpt = normalize( ones(Q,1) );
bnet.CPD{Read0} = tabular_CPD( bnet, Read0, 'CPT', cpt );

% transition function, Pr(Read_t|Read_t-1)
% R0   R1=false, true
%  false  0.8     0.2
%  true   0.1     0.9
cpt = [.8 .1 .2 .9];
bnet.CPD{Read1} = tabular_CPD( bnet, Read1, 'CPT', cpt );

% observation function, Pr(TimeOpen_t|Read_t)
% R     time=short, onTask, long
% false  0.7          0.1    0.2   % user tends to close box and not ignore it
% true   0.1          0.8    0.1   % user will be reading
cpt = [.7 .1 ...
       .1 .8 ...
       .2 .1];
bnet.CPD{TimeOpen} = tabular_CPD(bnet, TimeOpen, 'CPT', cpt ); 

DBN = bnet;
