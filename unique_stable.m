function [C, ia, ic] = unique_stable (A, varargin)

  if (nargin < 1)
    print_usage ();
  elseif (!(isnumeric (A) || islogical (A) || ischar (A) || iscellstr (A)))
    error ("unique: A must be an array or cell array of strings");
  elseif (nargin > 1 && ! iscellstr (varargin))
    error ("unique: options must all be strings");
  endif

  optrows   = false;
  optfirst  = false;
  optlast   = false;
  optstable = false;
  optsorted = false;
  optlegacy = false;
  for o = varargin'
    switch (tolower (o{1}))
      case "rows",    optrows   = true;
      case "first",   optfirst  = true;
      case "last",    optlast   = true;
      case "stable",  optstable = true;
      case "sorted",  optsorted = true;
      case "legacy",  optlegacy = true;
      otherwise,
        error ("unique: invalid option %s", o{1});
    endswitch
  endfor

  if (optfirst && optlast)
    error ("unique: options ""first"" and ""last"" are mutually exclusive");
  elseif (optstable && optlast)
    error ("unique: options ""first"" and ""last"" are mutually exclusive");
  elseif (optrows && iscellstr (A))
    warning ("unique: option ""rows"" is ignored for cell arrays");
    optrows = false;
  endif

  if optrows
    range = size(A,1);
    C = NaN(size(A));
    ia = NaN(size(A,1),1);
    ic = NaN(size(A,1),1);
  else
    range = numel(A);
    if isempty(A)
      C = [];
      break
    elseif optlegacy && size(A,1) < size(A,2)
      C = NaN(1,numel(A));
      ia = NaN(1,numel(A));
      ic = NaN(1,numel(A));
    else
      ia = NaN(numel(A),1);
      ic = NaN(numel(A),1);
      if ~optlegacy && (any(size(A) == 1)
        C = NaN(1,numel(A));
      else
        C = NaN(numel(A),1);
      endif
    endif
    
  endif

  if optlast
    dir = range:-1:1;
  else
    dir = 1:range;
  endif

  index = 1;
  if optrows
    for x = dir
      for y = 1:index
        if (sum(C(y,:)==A(x,:)) == length(A(x,:))) ||...
        (strcmp(C(y,:),A(x,:)))
          ic(x) = y;
          break
        elseif y == index
          C(index,:) = A(x,:);
          ia(index) = x;
          ic(x) = index;
          index += 1;
        endif
      endfor
    endfor
    C = C(1:index-1,:);
    ia = ia(1:index-1);
    if optstable == false
      [C, sortIndex] = sortrows(C);
      ia = ia(sortIndex);
      ic = sortIndex(ic);
    endif
  else
    for x = dir
      if ~any(C == A(x)) || strcmp(C,A(x))
        C(index) = A(x);
        ia(index) = x;
        ic(x) = index;
        index += 1;
      else
        [~,pos] = min(abs(C-A(x)));
        ic(x) = pos;
      endif
    endfor
    C = C(1:index-1);
    ia = ia(1:index-1);
    if optstable == false
      [C, sortIndex] = sort(C);
      ia = ia(sortIndex);
      ic = sortIndex(ic);
    endif
  endif
  
endfunction



%!assert (unique_stable ([1 1 2; 1 2 1; 1 1 2]), [1;2])
%!assert (unique_stable ([1 1 2; 1 0 1; 1 1 2],"rows"), [1 0 1; 1 1 2])
%!assert (unique_stable ([]), [])
%!assert (unique_stable ([1]), [1])
%!assert (unique_stable ([1 2]), [1 2])
%!assert (unique_stable ([1;2]), [1 2])
%!assert (unique_stable ([1;2],'legacy'), [1;2])
%!assert (unique_stable ([1,NaN,Inf,NaN,Inf]), [1,Inf,NaN,NaN])
%!assert (unique_stable ({"Foo","Bar","Foo"}), {"Bar","Foo"})
%!assert (unique_stable ({"Foo","Bar","FooBar"}'), {"Bar","Foo","FooBar"}')
%!assert (unique_stable (zeros (1,0)), zeros (0,1))
%!assert (unique_stable (zeros (1,0), "rows"), zeros (1,0))
%!assert (unique_stable (cell (1,0)), cell (0,1))
%!assert (unique_stable ({}), {})
%!assert (unique_stable ([1,2,2,3,2,4], "rows"), [1,2,2,3,2,4])
%!assert (unique_stable ([1,2,2,3,2,4]), [1,2,3,4])
%!assert (unique_stable ([1,2,2,3,2,4]', "rows"), [1,2,3,4]')
%!assert (unique_stable (sparse ([2,0;2,0])), [0,2]')
%!assert (unique_stable (sparse ([1,2;2,3])), [1,2,3]')
%!assert (unique_stable ([1,2,2,3,2,4]', "rows"), [1,2,3,4]')
%!assert (unique_stable (single ([1,2,2,3,2,4]), "rows"), single ([1,2,2,3,2,4]))
%!assert (unique_stable (single ([1,2,2,3,2,4])), single ([1,2,3,4]))
%!assert (unique_stable (single ([1,2,2,3,2,4]'), "rows"), single ([1,2,3,4]'))
%!assert (unique_stable (uint8 ([1,2,2,3,2,4]), "rows"), uint8 ([1,2,2,3,2,4]))
%!assert (unique_stable (uint8 ([1,2,2,3,2,4])), uint8 ([1,2,3,4]))
%!assert (unique_stable (uint8 ([1,2,2,3,2,4]'), "rows"), uint8 ([1,2,3,4]'))

%!test
%! [a,i,j] = unique_stable ([1,1,2,3,3,3,4]);
%! assert (a, [1,2,3,4]);
%! assert (i, [2,3,6,7]);
%! assert (j, [1,1,2,3,3,3,4]);
%!
%!test
%! [a,i,j] = unique_stable ([1,1,2,3,3,3,4]', "first");
%! assert (a, [1,2,3,4]');
%! assert (i, [1,3,4,7]');
%! assert (j, [1,1,2,3,3,3,4]');
%!
%!test
%! [a,i,j] = unique_stable ({"z"; "z"; "z"});
%! assert (a, {"z"});
%! assert (i, [3]');
%! assert (j, [1;1;1]);
%!
%!test
%! A = [1,2,3;1,2,3];
%! [a,i,j] = unique_stable (A, "rows");
%! assert (a, [1,2,3]);
%! assert (A(i,:), a);
%! assert (a(j,:), A);

## Test input validation
%!error unique_stable ()
%!error <X must be an array or cell array of strings> unique_stable ({1})
%!error <options must be strings> unique_stable (1, 2)
%!error <cannot specify both "first" and "last"> unique_stable (1, "first", "last")
%!error <invalid option> unique_stable (1, "middle")
%!error <invalid option> unique_stable ({"a", "b", "c"}, "UnknownOption")
%!error <invalid option> unique_stable ({"a", "b", "c"}, "UnknownOption1", "UnknownOption2")
%!error <invalid option> unique_stable ({"a", "b", "c"}, "rows", "UnknownOption2")
%!error <invalid option> unique_stable ({"a", "b", "c"}, "UnknownOption1", "last")
%!warning <"rows" is ignored for cell arrays> unique_stable ({"1"}, "rows");
