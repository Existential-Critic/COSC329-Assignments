function ev = sampleHelp_seq(dbn,needHelpVal,T)

%Create empty evidence for T time steps
ev = cell(dbn.nnodes_per_slice,T);

%Get index of observation variables
oNodesTT = dbn.names('TaskTime');
oNodesC = dbn.names('Correct');

for t=1:T
  %Sample value of variable
  ovalTT = stoch_obs('TaskTime',dbn,needHelpVal);
  ovalC = stoch_obs('Correct',dbn,needHelpVal);
  %Store sampled value into evidence structure
  ev{oNodesTT,t} = ovalTT;
  ev{oNodesC,t} = ovalC;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Helper function only used in this file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = stoch_obs(varname,dbn,parentval)
cpt = get_field(dbn.CPD{dbn.names(varname)},'cpt');
val = sampleRow(cpt(parentval,:));