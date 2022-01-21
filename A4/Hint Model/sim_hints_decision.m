function prRead = sim_hints_decision( dbn, ex )
% function prRead = sim_hints_decision( dbn, ex )
% ARGS: dbn = dynamic bayes net model specified by BNT syntax
%       ex  = a specific setting used to generate evidence
%

engine = bk_inf_engine( dbn );   % set up inference engine 
T = 10;                          % define number of time steps in problem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a series of evidence in advance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1,
  ev = sample_dbn( dbn, T);
  evidence = cell( 2, T);
  onodes   = dbn.observed;
  evidence( onodes, : ) = ev( onodes, : ); % all cells besides onodes are empty
elseif ex == 2,
  evidence = cell( 2, T);
  for ii=1:T,
    evidence{2,ii} = 2;
  end;
else
  readval = 2;
  evidence = sampleHint_seq( dbn, readval, T );
end;
evidence

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inference process: infer if user is reading hints over T time steps
% keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup results to be stored
belief = [];
exputil = [];
subplot( 1, 2, 1 );    % setup plot for graph

% at t=0, no evidence has been entered, so the probability is same as the
% prior encoded in the DBN itself
%
prRead = get_field( dbn.CPD{ dbn.names('Read') }, 'cpt' );
belief = [belief, prRead(2)];
subplot( 1, 2, 1 );
plot( belief, 'o-' );

% log best decision
[bestA, euHint] = get_meu_hints( prRead(2) );
exputil = [exputil, euHint]; 
disp(sprintf('t=%d: best action = %s, euHint = %f', 0, bestA, euHint));
subplot( 1, 2, 2 );
plot( exputil, '*-' );

% at t=1: initialize the belief state 
%
[engine, ll(1)] = dbn_update_bel1(engine, evidence(:,1));

marg = dbn_marginal_from_bel(engine, 1);
prRead = marg.T;
belief = [belief, prRead(2)];
subplot( 1, 2, 1 );
plot( belief, 'o-' );

% log best decision
[bestA, euHint] = get_meu_hints( prRead(2) );
exputil = [exputil, euHint]; 
disp(sprintf('t=%d: best action = %s, euHint = %f', 1, bestA, euHint));
subplot( 1, 2, 2 );
plot( exputil, '*-' );

% Repeat inference steps for each time step
%
for t=2:T,
  % update belief with evidence at current time step
  [engine, ll(t)] = dbn_update_bel(engine, evidence(:,t-1:t));
  
  % extract marginals of the current belief state
  i = 1;
  marg = dbn_marginal_from_bel(engine, i);
  prRead = marg.T;

  % log best decision
  [bestA, euHint] = get_meu_hints( prRead(2) );
  exputil = [exputil, euHint]; 
  disp(sprintf('t=%d: best action = %s, euHint = %f', t, bestA, euHint));
  subplot( 1, 2, 2 );
  plot( exputil, '*-' );
  xlabel( 'Time Steps' );
  ylabel( 'EU(Hint)' );
  axis( [ 0 T -5 5] );

  % keep track of results and plot it
  belief = [belief, prRead(2)];
  subplot( 1, 2, 1 );
  plot( belief, 'o-' );
  xlabel( 'Time Steps' );
  ylabel( 'Pr(Read)' );
  axis( [ 0 T 0 1] );
  pause(0.25);
end;
