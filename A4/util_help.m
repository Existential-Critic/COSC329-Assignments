function val = util_help(needHelp)
%Action = to give hint
%Autocomplete = 1 (false), 2 (true)
%
%Utility_value in [-5,+5]

%Reference point
val = 0;

%Doing stuff for the user gets a disruption penalty. -2 as autocompleting
%multiple questions consecutively is not good for learning
val = val-2; 

%Autocomplete action given will largely depend on whether or not the user
%needs help. If they do not need help, -2 for autocomplete. If they do need
%help, +3 as we want to make sure they can continue with their work
if needHelp == 1
  val = val-2;
else
  val = val+3;
end