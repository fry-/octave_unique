function [uniqueAr, ia, ic] = unique_stable (array, varargin)

  if (nargin < 1)
    print_usage ();
  elseif (!(isnumeric (A) || islogical (A) || ischar (A) || iscellstr (A)))
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
  #default values
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

  index = 1;
  if optrows
    for x = dir
      for y = 1:index
        if sum(uniqueAr(y,:)==array(x,:)) == length(array(x,:))
          ic(x) = y;
          break
        elseif y == index
          uniqueAr(index,:) = array(x,:);
          ia(index) = x;
          ic(x) = index;
          index = index + 1;
        endif
      endfor
    endfor
    uniqueAr = uniqueAr(1:index,:);
    ia = ia(1:index);
    if optstable == false
      [uniqueAr, sortIndex] = sortrows(uniqueAr);
      ia = ia(sortIndex);
      ic = sortIndex(ic);
    endif
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
      endif
    endfor
    uniqueAr = uniqueAr(1:index-1);
    ia = ia(1:index-1);
    if optstable == false
      [uniqueAr, sortIndex] = sort(uniqueAr);
      ia = ia(sortIndex);
      ic = sortIndex(ic);
    endif
  endif
  
endfunction



%!assert (unique ([1 1 2; 1 2 1; 1 1 2]), [1;2])
%!assert (unique ([1 1 2; 1 0 1; 1 1 2],"rows"), [1 0 1; 1 1 2])
%!assert (unique ([]), [])
%!assert (unique ([1]), [1])
%!assert (unique ([1 2]), [1 2])
%!assert (unique ([1;2]), [1;2])
%!assert (unique ([1,NaN,Inf,NaN,Inf]), [1,Inf,NaN,NaN])
%!assert (unique ({"Foo","Bar","Foo"}), {"Bar","Foo"})
%!assert (unique ({"Foo","Bar","FooBar"}'), {"Bar","Foo","FooBar"}')
%!assert (unique (zeros (1,0)), zeros (0,1))
%!assert (unique (zeros (1,0), "rows"), zeros (1,0))
%!assert (unique (cell (1,0)), cell (0,1))
%!assert (unique ({}), {})
%!assert (unique ([1,2,2,3,2,4], "rows"), [1,2,2,3,2,4])
%!assert (unique ([1,2,2,3,2,4]), [1,2,3,4])
%!assert (unique ([1,2,2,3,2,4]', "rows"), [1,2,3,4]')
%!assert (unique (sparse ([2,0;2,0])), [0,2]')
%!assert (unique (sparse ([1,2;2,3])), [1,2,3]')
%!assert (unique ([1,2,2,3,2,4]', "rows"), [1,2,3,4]')
%!assert (unique (single ([1,2,2,3,2,4]), "rows"), single ([1,2,2,3,2,4]))
%!assert (unique (single ([1,2,2,3,2,4])), single ([1,2,3,4]))
%!assert (unique (single ([1,2,2,3,2,4]'), "rows"), single ([1,2,3,4]'))
%!assert (unique (uint8 ([1,2,2,3,2,4]), "rows"), uint8 ([1,2,2,3,2,4]))
%!assert (unique (uint8 ([1,2,2,3,2,4])), uint8 ([1,2,3,4]))
%!assert (unique (uint8 ([1,2,2,3,2,4]'), "rows"), uint8 ([1,2,3,4]'))

%!test
%! [a,i,j] = unique ([1,1,2,3,3,3,4]);
%! assert (a, [1,2,3,4]);
%! assert (i, [2,3,6,7]);
%! assert (j, [1,1,2,3,3,3,4]);
%!
%!test
%! [a,i,j] = unique ([1,1,2,3,3,3,4]', "first");
%! assert (a, [1,2,3,4]');
%! assert (i, [1,3,4,7]');
%! assert (j, [1,1,2,3,3,3,4]');
%!
%!test
%! [a,i,j] = unique ({"z"; "z"; "z"});
%! assert (a, {"z"});
%! assert (i, [3]');
%! assert (j, [1;1;1]);
%!
%!test
%! A = [1,2,3;1,2,3];
%! [a,i,j] = unique (A, "rows");
%! assert (a, [1,2,3]);
%! assert (A(i,:), a);
%! assert (a(j,:), A);

## Test input validation
%!error unique ()
%!error <X must be an array or cell array of strings> unique ({1})
%!error <options must be strings> unique (1, 2)
%!error <cannot specify both "first" and "last"> unique (1, "first", "last")
%!error <invalid option> unique (1, "middle")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption1", "UnknownOption2")
%!error <invalid option> unique ({"a", "b", "c"}, "rows", "UnknownOption2")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption1", "last")
%!warning <"rows" is ignored for cell arrays> unique ({"1"}, "rows");