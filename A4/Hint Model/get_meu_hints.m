function [action, eu_hint] = get_meu_hints( prRead )
% function [action, eu_hint] = get_meu_hints( prRead )
%

% set default
action = 'None';

% compute expected utility of each action
% EU(A) = sum_Read Pr(Read) x U(A, Read)
%
eu_none = 0;

eu_hint = prRead * util( 2 ) + ...
          (1 - prRead) * util( 1 );

% override default if hinting is a better action
if eu_hint > eu_none,
  action = 'Hint';
end;
