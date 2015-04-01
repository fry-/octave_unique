clc

array = [3, 2, 1, 1, 2, 3; 6,  4, 5, 6, 5, 4; 3, 2, 1, 1, 2, 3;...
    9, 2, 9, 5, 2, 9; 9, 2, 9, 0, 2, 9; 9, 2, 9, NaN, 2, 9;
    NaN, NaN, NaN, NaN, NaN, NaN];
array = array(:,1);


[C, ia, ic] = unique_stable(array,'first','legacy')


% dont forget "make check" if all is done!