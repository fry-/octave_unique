%clc
%
%array = [3, 2, 1, 1, 2, 3; 6,  4, 5, 6, 5, 4; 3, 2, 1, 1, 2, 3;...
%    9, 2, 9, 5, 2, 9; 9, 2, 9, 0, 2, 9; 9, 2, 9, NaN, 2, 9;
%    NaN, NaN, NaN, NaN, NaN, NaN];
% array = array(1,:);


% [C, ia, ic] = unique(array,'stable')



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
%!error <X must be an A or cell A of strings> unique ({1})
%!error <options must be strings> unique (1, 2)
%!error <cannot specify both "first" and "last"> unique (1, "first", "last")
%!error <invalid option> unique (1, "middle")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption1", "UnknownOption2")
%!error <invalid option> unique ({"a", "b", "c"}, "rows", "UnknownOption2")
%!error <invalid option> unique ({"a", "b", "c"}, "UnknownOption1", "last")
%!warning <"rows" is ignored for cell As> unique ({"1"}, "rows");