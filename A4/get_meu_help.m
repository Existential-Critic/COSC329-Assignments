function [action, eu_help] = get_meu_help(prNeedHelp)

%Set default
action = 'None';

%Compute expected utility of each action
%EU(A) = sum_NeedHelp Pr(NeedHelp) x U(A,NeedHelp)
eu_none = 0;
eu_help = prNeedHelp*util_help(2)+(1-prNeedHelp)*util_help(1);

% override default if hinting is a better action
if eu_help > eu_none
  action = 'Auto-complete';
end