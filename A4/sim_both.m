function [prRead prNeedHelp] = sim_both(dbnR,dbnNH,ex)
% ARGS: 
%       dbnR = dynamic bayes net model specified by BNT syntax for the read
%       model
%       dbnNH = dynamic bayes net model specified by BNT syntax for the
%       needHelpmodel
%       exR = a specific setting used to generate evidence
engineR = bk_inf_engine(dbnR); %Set up inference engine for Read
engineNH = bk_inf_engine(dbnR); %Set up inference engine for NeedHelp
T = 50; %Define number of time steps in problem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generate a series of evidence in advance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex == 1 %Random evidence
  evR = sample_dbn(dbnR,T);
  evNH = sample_dbn(dbnNH,T);
  evidenceR = cell(3,T);
  oNodesR = dbnR.observed;
  evidenceNH = cell(3,T);
  oNodesNH = dbnNH.observed;
  evidenceR(oNodesR,:) = evR(oNodesR,:); %All cells besides oNodes are empty
  graph(dbnR,dbnNH,engineR,T,evidenceR,'blue','Random Evidence - Read','read');
  evidenceNH(oNodesNH,:) = evNH(oNodesNH,:); %All cells besides oNodes are empty
  graph(dbnR,dbnNH,engineNH,T,evidenceNH,'red','Random Evidence - Need Help','needHelp');
  legend;
elseif ex == 2 %Fixed evidence
    evidenceR = cell(2,T);
    evidenceNH = cell(3,T);
    for ii=1:T
        evidenceR{2,ii} = 2;
        evidenceNH{2,ii} = 1;
        evidenceNH{3,ii} = 3;
    end
    graph(dbnR,dbnNH,engineR,T,evidenceR,'red','Pr(Read)','read');
    graph(dbnR,dbnNH,engineNH,T,evidenceR,'blue','Pr(NeedHelp)','needHelp');
    legend;
else %Controlled randomness
    readVal = 2;
    needHelpVal = 1;
    evidenceR = sampleHint_seq(dbnR,readVal,T);
    evidenceNH = sampleHelp_seq(dbnNH,needHelpVal,T);
    graph(dbnR,dbnNH,engineR,T,evidenceR,'blue','Controlled Randomness, Read = True','read');
    graph(dbnR,dbnNH,engineNH,T,evidenceR,'red','Controlled Randomness, NeedHelp = True','needHelp');
    legend;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inference process: infer if user is reading hints over T time steps
%Keep track of results and plot as we go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function graph(dbnR,dbnNH,engine,T,evidence,colour,name,type)
%Setup results to be stored
belief = [];
exputil = [];
subplot(1,2,1); %Setup plot for graph

%At t=0, no evidence has been entered, so the probability is same as the
%prior encoded in the DBN itself
prRead = get_field(dbnR.CPD{dbnR.names('Read')},'cpt');
prNeedHelp = get_field(dbnNH.CPD{dbnNH.names('NeedHelp')},'cpt');
if strcmp(type,'read')
    belief = [belief,prRead(2)];
else
    belief = [belief, prNeedHelp(2)];
end
subplot(1,2,1);
plot(belief,'o-','Color',colour,'DisplayName',name);
hold on

%Log best decision
[bestA,euHint,euHelp] = get_meu(prRead(2),prNeedHelp(2));
if strcmp(type,'read')
    exputil = [exputil,euHint]; 
    disp(sprintf('t=%d: Best action = %s, euHint = %f',0,bestA,euHint));
else
    exputil = [exputil,euHelp]; 
    disp(sprintf('t=%d: Best action = %s, euHelp = %f',0,bestA,euHelp));
end
subplot(1,2,2);
plot(exputil,'*-','Color',colour,'DisplayName',name);
hold on

%At t=1: initialize the belief state
if strcmp(type,'read')
    [engine,ll(1)] = dbn_update_bel1(engine, evidence(:,1));
    marg = dbn_marginal_from_bel(engine, 1);
    prRead = marg.T;
    belief = [belief,prRead(2)];
else
    [engine,ll(1)] = dbn_update_bel1(engine,evidence(:,1));
    marg = dbn_marginal_from_bel(engine,1);
    prNeedHelp = marg.T;
    belief = [belief,prNeedHelp(2)];
end
subplot(1,2,1);
plot(belief,'o-','Color',colour,'HandleVisibility','off');

%Log best decision
[bestA,euHint,euHelp] = get_meu(prRead(2),prNeedHelp(2));
if strcmp(type,'read')
    exputil = [exputil,euHint]; 
    disp(sprintf('t=%d: Best action = %s, euHint = %f',1,bestA,euHint));
else
    exputil = [exputil,euHelp]; 
    disp(sprintf('t=%d: Best action = %s, euHelp = %f',1,bestA,euHelp));
end
subplot(1,2,2);
plot(exputil,'*-','Color',colour,'HandleVisibility','off');

%Repeat inference steps for each time step
for t=2:T
  %Update belief with evidence at current time step
  if strcmp(type,'read')
    [engine,ll(t)] = dbn_update_bel1(engine,evidence(:,t-1:t));
    %Extract marginals of the current belief state
    i = 1;
    marg = dbn_marginal_from_bel(engine, i);
    prRead = marg.T;
    belief = [belief,prRead(2)];
  else
    [engine,ll(t)] = dbn_update_bel1(engine,evidence(:,t-1:t));
    %Extract marginals of the current belief state
    i = 1;
    marg = dbn_marginal_from_bel(engine,i);
    prNeedHelp = marg.T;
    belief = [belief,prNeedHelp(2)];
  end
  %Log best decision
  [bestA,euHint,euHelp] = get_meu(prRead(2),prNeedHelp(2));
  if strcmp(type,'read')
    exputil = [exputil,euHint]; 
    disp(sprintf('t=%d: Best action = %s, euHint = %f',t,bestA,euHint));
  else
    exputil = [exputil,euHelp]; 
    disp(sprintf('t=%d: Best action = %s, euHelp = %f',t,bestA,euHelp));
  end
  subplot(1,2,2);
  plot(exputil,'*-','Color',colour,'HandleVisibility','off');
  xlabel('Time Steps');
  ylabel('Expected Utility');
  axis([0 T -5 5]);
  %Keep track of results and plot it
  if strcmp(type,'read')
    belief = [belief,prRead(2)];
  else
    belief = [belief,prNeedHelp(2)];
  end
  subplot(1,2,1);
  plot(belief,'o-','Color',colour,'HandleVisibility','off');
  xlabel('Time Steps');
  ylabel('Probability');
  axis([0 T 0 1]);
  pause(0.25);
end