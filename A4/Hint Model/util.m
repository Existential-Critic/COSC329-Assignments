function val = util( readHints )
% function val = util( readHints )
%
% action = is to give hint
% readHints = 1 (false), 2 (true)
%
% utility_value \in [-5,+5]
%

% reference point
val = 0;

% doing stuff for the user gets a disruption penalty
val = val - 1; 

% help action given will largely depend on whether user reads hints
if readHints == 1,
  val = val - 3;
else
  val = val + 5;
end;
