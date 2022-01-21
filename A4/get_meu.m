function [action,eu_hint,eu_help] = get_meu(prRead,prNeedHelp)

%Set default
action = 'None';

%Compute expected utility of each action
%EU(A) = sum_NeedHelp Pr(NeedHelp) x U(A,NeedHelp)
eu_none = 0;
eu_hint = prRead*util(2)+(1-prRead)*util(1);
eu_help = prNeedHelp*util_help(2)+(1-prNeedHelp)*util_help(1);

%Find the best action by comparing all expected utility options
whichAction = [eu_none eu_hint eu_help];
bestAction = max(whichAction);
if bestAction == eu_hint
    action = 'Hint';
elseif bestAction == eu_help
    action = 'Auto-complete';
end