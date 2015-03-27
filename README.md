Attempt to recreate Matlab's unique function for Octave.

Difference to the current unique.m from Octave is:
- it will be non-recursive
- it will allow 'stable' and 'legacy' inputs (latter is for compatibility with newer Matlab code)
