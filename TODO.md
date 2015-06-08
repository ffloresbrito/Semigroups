#TODO#
###There are more TODOs in the source files this list is not exhaustive###

* try to find the full PBR monoid when n = 1, 2. 
* `AsBipartitionSemigroup`, `AsPBRSemigroup`
* tests for pbrs 
* semigroups of pbrs (`ViewString`, `IsPBRSemigroup`, etc)
* finish partitioned binary relation stuff (more tests and C++)
* check that nothing is missing in semigroup-matrix-*
* add tests for all Semigroupe manual example things
* remove C++11
* gmp problems?
* use namespace in the C++ code
* clean up the memory usage in semigroups.h, interface.cc
* add `_report` for all methods that call `enumerate` in semigroups.h
* `DClass(TransformationSemigroup, BooleanMat)` sometimes seg faults or returns an answers which it shouldn't!
* reporting in semigroups.h (toggle_report and _report)
* fix the relations methods
* `[ Transformation( [ 3, 3, 3, 3, 3 ] ), Transformation( [ 4, 4, 4, 4, 4 ] ),
  Transformation( [ 1, 3, 1, 5, 1 ] ), Transformation( [ 1, 1, 2, 1, 4 ] ),
  Transformation( [ 1, 1, 5, 1, 3 ] ), Transformation( [ 1, 4, 1, 2, 1 ] ) ]`
  the generic semigroup generated by these generators has a weird and wrong
  D-class diagram. 
* `T_PLIST_TAB` instead of `T_PLIST`? Double-check this is ok, and then implement if it is.

#DONE
* Boolean matrix stuff (`CanonicalRep` and things from semigroups-dev)
* replace `Permuted(gens, Random(SymmetricGroup...)` by `Shuffle`
* `TransposedMat` methods for matrix over semiring variants (so far only done boolean matrices and a generic method)
* make 2.6 branch with new style Green's class printing in tests.

#DO LATER
* non-prime finite fields

#Gaplint - Notes#

* `NrLeftBlocks`, `NrBlocks` are in gaplint_ignore since the every way to create 
  a bipartition sets these attribute just after creation. Hence if I install a
  method for these, then it will never be run, hence hurting our code coverage. 

#Code coverage - Notes#

* bipartition.tst tests factor.gi to 80%

#General notes:#

* need to check usage of `IsSemigroup` and `IsFinite`, the max-plus matrix
  semigroup examples can finite or infinite, we should check if they are finite
  (somehow) and then use `RightCayleyGraphSemigroup`...
* `HasGeneratorsOfMagmaIdeal` has been changed to `HasGeneratorsOfSemigroupIdeal`
  in lots of places.

#New features in this branch:#

* `IsSemigroupWithInverseOp` 
* `SEMIGROUPS_OptionsRec` is an attribute, has a component generic which is set to
  true or false