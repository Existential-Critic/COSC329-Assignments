function val = sampleRow( row )
% function val = sampleRow( row )
%
% ARGS: row = a row vector (probability distribution) 
%
% randomly generates a number between 0 and 1
% then goes through the row until we find the index that adds up the
% probability seen so far
% returns that index as the value sampled
%
len = length(row);
c = rand;
tmp = 0;
for i=1:len,
  tmp = tmp + row(i);
  if c < tmp,
    val = i;
    break;
  end;
end;
