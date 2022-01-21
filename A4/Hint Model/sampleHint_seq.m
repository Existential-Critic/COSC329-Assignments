function ev = sampleHint_seq( dbn, readval, T )

% create empty evidence for T time steps
ev = cell(dbn.nnodes_per_slice, T);

% get index of observation variable
onode = dbn.names('TimeOpen');

for t=1:T,
  % sample value of variable
  oval = stoch_obs( 'TimeOpen', dbn, readval );

  % store sampled value into evidence structure
  ev{onode, t} = oval;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function only used in this file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = stoch_obs( varname, dbn, parentval )
cpt = get_field( dbn.CPD{ dbn.names( varname )}, 'cpt' );
val = sampleRow( cpt( parentval, : ) );

