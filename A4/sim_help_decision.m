function prNeedHelp = sim_help_decision(dbn,ex)
% ARGS: 
%       dbn = dynamic bayes net model specified by BNT syntax
%       ex  = a specific setting used to generate evidence
engine = bk_inf_engine(dbn); %Set up inference engine 
T = 50; %Define number of time steps in problem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generate a series of evidence in advance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1 %Random evidence
  ev = sample_dbn(dbn,T);
  evidence = cell(3,T);
  oNodes = dbn.observed;
  evidence(oNodes,:) = ev(oNodes,:); %All cells besides oNodes are empty
  graph(dbn,engine,T,evidence,'blue','Random Evidence');
  legend
elseif ex == 2 %Fixed evidence
  evidence = cell(3,T);
  for ii=1:T
    evidence{2,ii} = 1;
    evidence{3,ii} = 1;
  end
  graph(dbn,engine,T,evidence,'red','Short/Incorrect');
  for ii=1:T
    evidence{2,ii} = 1;
    evidence{3,ii} = 2;
  end
  graph(dbn,engine,T,evidence,'green','Short/Correct');
  for ii=1:T
    evidence{2,ii} = 2;
    evidence{3,ii} = 1;
  end
  graph(dbn,engine,T,evidence,'blue','OnTask/Incorrect');
  for ii=1:T
    evidence{2,ii} = 2;
    evidence{3,ii} = 2;
  end
  graph(dbn,engine,T,evidence,'cyan','OnTask,Correct');
  for ii=1:T
    evidence{2,ii} = 3;
    evidence{3,ii} = 1;
  end
  graph(dbn,engine,T,evidence,'magenta','Long/Incorrect');
  for ii=1:T
    evidence{2,ii} = 3;
    evidence{3,ii} = 2;
  end
  graph(dbn,engine,T,evidence,'yellow','Long/Correct');
  legend
else %Controlled randomness
  needHelpVal = 2;
  evidence = sampleHelp_seq(dbn,needHelpVal,T);
  graph(dbn,engine,T,evidence,'blue','Controlled Randomness, NeedHelp = 2');
  legend
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inference process: infer if user is reading hints over T time steps
%Keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function graph(dbn,engine,T,evidence,colour,name)
%Setup results to be stored
belief = [];
exputil = [];
subplot(1,2,1); %Setup plot for graph

%At t=0, no evidence has been entered, so the probability is same as the
%prior encoded in the DBN itself
prNeedHelp = get_field(dbn.CPD{dbn.names('NeedHelp')},'cpt');
belief = [belief, prNeedHelp(2)];
subplot(1,2,1);
plot(belief,'o-','Color',colour,'DisplayName',name);
hold on

%Log best decision
[bestA,euHelp] = get_meu_help(prNeedHelp(2));
exputil = [exputil,euHelp]; 
disp(sprintf('t=%d: Best action = %s, euHelp = %f',0,bestA,euHelp));
subplot(1,2,2);
plot(exputil,'*-','Color',colour,'DisplayName',name);
hold on

%At t=1: initialize the belief state
[engine,ll(1)] = dbn_update_bel1(engine,evidence(:,1));
marg = dbn_marginal_from_bel(engine,1);
prNeedHelp = marg.T;
belief = [belief, prNeedHelp(2)];
subplot(1,2,1);
plot(belief,'o-','Color',colour,'HandleVisibility','off');
%Log best decision
[bestA,euHelp] = get_meu_help(prNeedHelp(2));
exputil = [exputil,euHelp]; 
disp(sprintf('t=%d: Best action = %s, euHelp = %f',1,bestA,euHelp));
subplot(1,2,2);
plot(exputil,'*-','Color',colour,'HandleVisibility','off');

%Repeat inference steps for each time step
for t=2:T
  %Update belief with evidence at current time step
  [engine,ll(t)] = dbn_update_bel(engine,evidence(:,t-1:t));
  %Extract marginals of the current belief state
  i = 1;
  marg = dbn_marginal_from_bel(engine,i);
  prNeedHelp = marg.T;
  %Log best decision
  [bestA,euHelp] = get_meu_help(prNeedHelp(2));
  exputil = [exputil,euHelp]; 
  disp(sprintf('t=%d: Best action = %s, euHelp = %f',t,bestA,euHelp));
  subplot(1,2,2);
  plot( exputil,'*-','Color',colour,'HandleVisibility','off');
  xlabel('Time Steps');
  ylabel('EU(Help)');
  axis([0 T -5 5]);
  %Keep track of results and plot it
  belief = [belief,prNeedHelp(2)];
  subplot(1,2,1);
  plot(belief,'o-','Color',colour,'HandleVisibility','off');
  xlabel('Time Steps');
  ylabel('Pr(NeedHelp)');
  axis([0 T 0 1]);
  pause(0.25);
end