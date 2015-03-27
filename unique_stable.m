
clc

array = [3, 2, 1, 1, 2, 3; 6,  4, 5, 6, 5, 4; 3, 2, 1, 1, 2, 3;...
    9, 2, 9, 5, 2, 9; 9, 2, 9, 0, 2, 9; 9, 2, 9, NaN, 2, 9;
    NaN, NaN, NaN, NaN, NaN, NaN];
% array = array(1,:);

function [C, ia, ic] = unique (A, varargin)

  if (nargin < 1)
    print_usage ();
  elseif (! (isnumeric (A) || islogical (A) || ischar (A) || iscellstr (A)))
    error ("unique: 'A' must be an array or cell array of strings");
  endif

  if (nargin > 1)
    ## parse options
    if (! iscellstr (varargin))
      error ("unique: options must be strings");
    endif

    optrows  = any (strcmp ("rows", varargin));
    optfirst = any (strcmp ("first", varargin));
    optlast  = any (strcmp ("last", varargin));
    optstable = any (strcmp ("stable", varargin));
    optsorted = any (strcmp ("sorted", varargin));
    optlegacy = any (strcmp ("legacy", varargin));
    if (optfirst && optlast)
      error ('unique: cannot specify both "first" and "last"');
    elseif (optstable && optlast)
      error ("unique: cannot specify 'stable' with 'last'");
    elseif (optfirst + optlast + optrows...
    + optstable + optsorted + optlegacy != nargin-1)
      error ("unique: invalid option");
    endif

    if (optrows && iscellstr (x))
      warning ('unique: "rows" is ignored for cell arrays');
      optrows = false;
    endif
  else
    optrows = false;
    optfirst = true;
    optstable = false;
  endif

if optrows
    range = size(array,1);
    ia = NaN(size(array,1),1);
    ic = NaN(size(array,1),1);
else
    range = numel(array);
    ia = NaN(numel(array),1);
    ic = NaN(numel(array),1);
endif

if optfirst
    dir = 1:range;
else
    dir = range:-1:1;
endif

if optrows
    uniqueAr = NaN(size(array));
elseif any(size(array) == 1)
    uniqueAr = NaN(1,numel(array));
else
    uniqueAr = NaN(numel(array),1);
endif

% [C, ia, ic] = unique(array,'stable')


[C, ia ,ic] = unique(array,szHandle,'stable')

index = 1;
if strcmp(szHandle,'rows')
    index = 1;
    uniqueAr(index,:) = array(1,:);
    for x = 2:size(array,1)
        for y = 1:index
            if sum(uniqueAr(y,:)==array(x,:)) == length(array(x,:))
                break
            elseif y == index
                index = index + 1;
                uniqueAr(index,:) = array(x,:);
            end
        end
    end
    uniqueAr = uniqueAr(1:index,:);
    ia = ia(1:index);
else
    for x = dir
        if ~any(uniqueAr == array(x))
            uniqueAr(index) = array(x);
            ia(index) = x;
            ic(x) = index;
            index = index + 1;
        else
            [~,pos] = min(abs(uniqueAr-array(x)));
            ic(x) = pos;
        end
    end
    uniqueAr = uniqueAr(1:index-1);
    ia = ia(1:index-1);
end