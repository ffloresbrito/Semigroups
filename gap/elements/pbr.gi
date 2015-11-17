############################################################################
##
#W  pbr.gi
#Y  Copyright (C) 2015                                   Attila Egri-Nagy
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains an intitial implementation of partitioned binary
# relations (PBRs) as defined in:
#
# Paul Martin and Volodymyr Mazorchuk, Partitioned binary relatons,
# Mathematica Scandinavica, v113, n1, p. 30-52, http://arxiv.org/abs/1102.0862

# Internally a PBR is stored as the adjacency list of digraph with
# vertices [1 .. 2 * n] for some n. More precisely if <x> is a PBR, then:
#
#   * <x![1]> is equal to <n>
#
#   * <x![i + 1]> is the vertices adjacent to <i>
#
# The number <n> is the *degree* of <x>.

#############################################################################
# Pickler
#############################################################################

InstallMethod(IO_Pickle, "for a PBR",
[IsFile, IsPBR],
function(file, x)
  if IO_Write(file, "PABR") = fail then
    return IO_Error;
  fi;
  if IO_Pickle(file, List([1 .. 2 * x![1] + 1], i -> x![i])) = IO_Error then
    return IO_Error;
  fi;
  return IO_OK;
end);

IO_Unpicklers.PABR :=
function(file)
  local x;
  x := IO_Unpickle(file);
  if x = IO_Error then
    return IO_Error;
  fi;
  return Objectify(PBRType, x);
end;

#############################################################################
# TODO the embeddings from the paper, AsPBR for a pbr (extend or restrict),
#############################################################################

InstallMethod(EmptyPBR, "for a pos int", [IsPosInt],
n -> PBRNC(List([1 .. n], y -> []), List([1 .. n], y -> [])));

InstallMethod(IdentityPBR, "for a pos int", [IsPosInt],
n -> PBRNC(List([1 .. n], y -> [-y]), List([1 .. n], y -> [y])));

InstallMethod(UniversalPBR, "for a pos in", [IsPosInt],
function(n)
  local x;
  x := Concatenation([-n .. -1], [1 .. n]);
  return PBRNC(List([1 .. n], y -> x), List([1 .. n], y -> x));
end);

# FIXME the following is temporary, with the current definition of
# IsGeneratorsOfInverseSemigroup for a pbr collection, the One of any element
# in the collection does not satisfy IsGeneratorsOfInverseSemigroup, and so it
# cannot be inverted.

InstallMethod(InverseMonoidByGenerators,
[IsPBRCollection],
function(coll)
  ErrorMayQuit("Semigroups: InverseMonoidByGenerators",
               "(for a pbr collection):\nnot yet implemented,");
end);

# FIXME see the comment above, this is not really correct.

InstallOtherMethod(InverseMutable, "for a PBR", [IsPBR],
function(x)
  #TODO change IsBlockBijection(AsBipartition(x)) to
  # IsBlockBijectionPBR.
  if IsPartialPermPBR(x) or
      (IsBipartitionPBR(x) and IsBlockBijection(AsBipartition(x))) then
    return Star(x);
  fi;
  return fail;
end);

# FIXME see the comment above, this is not really correct.

InstallMethod(IsGeneratorsOfInverseSemigroup, "for a pbr collection",
[IsPBRCollection],
function(coll)
  return ForAll(coll, IsBipartitionPBR)
         and IsGeneratorsOfInverseSemigroup(List(coll, AsBipartition));
end);

InstallMethod(StarOp, "for a pbr", [IsPBR],
function(x)
  local ext;
  ext := ShallowCopy(ExtRepOfPBR(x) * - 1);
  Apply(ext, ShallowCopy);
  Apply(ext[1], ShallowCopy);
  Apply(ext[2], ShallowCopy);
  return PBR(ext[2], ext[1]);
end);

InstallMethod(DegreeOfPBRCollection, "for a PBR collection",
[IsPBRCollection],
function(coll)
  local deg;

  if IsPBRSemigroup(coll) then
    return DegreeOfPBRSemigroup(coll);
  fi;

  deg := DegreeOfPBR(coll[1]);
  if not ForAll(coll, x -> DegreeOfPBR(x) = deg) then
    ErrorMayQuit("Semigroups: DegreeOfPBRCollection: usage,\n",
                 "the argument <coll> must be a collection of PBRs ",
                 "of equal degree,");
  fi;

  return deg;
end);

InstallMethod(IsBipartitionPBR, "for a pbr",
[IsPBR],
function(x)
  return IsEquivalenceBooleanMat(AsBooleanMat(x));
end);

# TODO is this the correct definition
InstallMethod(IsTransformationPBR, "for a pbr",
[IsPBR],
function(x)
  return IsBipartitionPBR(x) and IsTransBipartition(AsBipartition(x));
end);

InstallMethod(IsBlockBijectionPBR, "for a pbr",
[IsPBR],
function(x)
  return IsBipartitionPBR(x) and IsBlockBijection(AsBipartition(x));
end);

InstallMethod(IsPartialPermPBR, "for a pbr",
[IsPBR],
function(x)
  return IsBipartitionPBR(x) and IsPartialPermBipartition(AsBipartition(x));
end);

InstallMethod(IsPermPBR, "for a pbr",
[IsPBR],
function(x)
  return IsBipartitionPBR(x) and IsPermBipartition(AsBipartition(x));
end);

InstallMethod(IsDualTransformationPBR, "for a pbr",
[IsPBR],
function(x)
  return IsBipartitionPBR(x) and IsDualTransBipartition(AsBipartition(x));
end);

InstallMethod(NumberPBR, "for a pbr",
[IsPBR],
function(x)
  return NumberBooleanMat(AsBooleanMat(x));
end);

InstallMethod(PBRNumber, "for pos int and pos int",
[IsPosInt, IsPosInt],
function(nr, deg)
  return AsPBR(BooleanMatNumber(nr, 2 * deg));
end);

InstallMethod(IsEmptyPBR, "for a partition binary relation",
[IsPBR],
function(x)
  local n, i;

  n := x![1];
  for i in [2 .. 2 * n + 1] do
    if Length(x![i]) > 0 then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsIdentityPBR, "for a partition binary relation",
[IsPBR],
function(x)
  local n, i;

  n := x![1];
  for i in [2 .. n + 1] do
    if Length(x![i]) <> 1 or x![i][1] <> i + n - 1 then
      return false;
    fi;
  od;
  for i in [n + 2 .. 2 * n + 1] do
    if Length(x![i]) <> 1 or x![i][1] <> i - n - 1 then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsUniversalPBR, "for a partition binary relation",
[IsPBR],
function(x)
  local n, i;

  n := x![1];
  for i in [2 .. 2 * n + 1] do
    if Length(x![i]) < 2 * n then
      return false;
    fi;
  od;
  return true;
end);

#FIXME: this should probably be more specific, 1 method for transformations, 1
# for partial perms, etc

InstallMethod(AsPBR, "for an associative element",
[IsAssociativeElement], x -> AsPBR(AsBipartition(x)));

InstallMethod(AsPBR,
"for an associative element and pos int",
[IsAssociativeElement, IsPosInt],
function(x, n)
  return AsPBR(AsBipartition(x, n));
end);

InstallMethod(AsPBR, "for a bipartition",
[IsBipartition], x -> AsPBR(x, DegreeOfBipartition(x)));

InstallMethod(AsPBR, "for a bipartition and pos int",
[IsBipartition, IsPosInt],
function(x, n)
  local deg, blocks, out, dom, block, i;

  deg    := DegreeOfBipartition(x);
  blocks := ExtRepOfBipartition(x);
  out    := [[], []];
  dom := Union([-n .. -1], [1 .. n]);

  for block in blocks do
    for i in block do
      if AbsInt(i) <= n then
        if i < 0 then
          out[2][-i] := Intersection(block, dom);
        else
          out[1][i] := Intersection(block, dom);
        fi;
      fi;
    od;
  od;
  for i in [deg + 1 .. n] do
    Add(out[1], []);
    Add(out[2], []);
  od;

  return PBRNC(out[1], out[2]);
end);

InstallMethod(AsPBR, "for a boolean matrix",
[IsBooleanMat],
function(x)
  local dim, succ;

  dim := DimensionOfMatrixOverSemiring(x);
  if not IsEvenInt(dim) then
    ErrorMayQuit("Semigroups: AsPBR: usage,\n",
                 "the boolean matrix <x> must be of even dimension,");
  fi;
  succ := Successors(x);
  return PBRNC(succ{[1 .. dim / 2]}, succ{[dim / 2 + 1 .. dim]});
end);

InstallMethod(AsPBR, "for a boolean mat and pos int",
[IsBooleanMat, IsPosInt],
function(mat, n)
  local m, nbs, k, i, j;

  if not IsEvenInt(n) then
    ErrorMayQuit("Semigroups: AsPBR: usage,\n",
                 "the second argument <n> must be even,");
  fi;

  m := DimensionOfMatrixOverSemiring(mat);

  if not IsEvenInt(m) then
    ErrorMayQuit("Semigroups: AsPBR: usage,\n",
                 "the boolean matrix <x> must be of even dimension,");
  fi;

  nbs := [List([1 .. n / 2], x -> []),
          List([1 .. n / 2], x -> [])];

  if n <= m then
    for i in [1 .. n / 2] do
      for j in [1 .. n] do
        if mat[i][j] then
          Add(nbs[1][i], j);
        fi;
      od;
    od;
    for i in [n / 2 + 1 .. n] do
      for j in [1 .. n] do
        if mat[i][j] then
          Add(nbs[2][i - n / 2], j);
        fi;
      od;
    od;
  else
    k := (n - m) / 2;

    for i in [1 .. m / 2] do
      for j in [1 .. m / 2] do
        if mat[i][j] then
          Add(nbs[1][i], j);
        fi;
      od;
      for j in [m / 2 + 1 .. m] do
        if mat[i][j] then
          Add(nbs[1][i], j + k);
        fi;
      od;
    od;
    for i in [m / 2 + 1 .. m] do
      for j in [1 .. m / 2] do
        if mat[i][j] then
          Add(nbs[2][i - m / 2], j);
        fi;
      od;
      for j in [m / 2 + 1 .. m] do
        if mat[i][j] then
          Add(nbs[2][i - m / 2], j + k);
        fi;
      od;
    od;
  fi;

  return PBRNC(nbs[1], nbs[2]);
end);

# TODO 2 arg version of this

InstallMethod(AsTransformation, "for a pbr",
[IsPBR],
function(x)
  if not IsTransformationPBR(x) then
    ErrorMayQuit("Semigroups: AsTransformation: usage,\n",
                 "the argument <x> must be a transformation PBR,");
  fi;
  return AsTransformation(AsBipartition(x));
end);

# TODO 2 arg version of this

InstallMethod(AsPartialPerm, "for a pbr",
[IsPBR],
function(x)
  if not IsPartialPermPBR(x) then
    ErrorMayQuit("Semigroups: AsPartialPerm: usage,\n",
                 "the argument <x> must be a partial perm PBR,");
  fi;
  return AsPartialPerm(AsBipartition(x));
end);

# TODO 2 arg version of this

InstallMethod(AsPermutation, "for a pbr",
[IsPBR],
function(x)
  if not IsPermPBR(x) then
    ErrorMayQuit("Semigroups: AsPermutation: usage,\n",
                 "the argument <x> must be a permutation PBR,");
  fi;
  return AsPermutation(AsBipartition(x));
end);

InstallMethod(RandomPBR, "for a pos int", [IsPosInt],
function(n)
  local digraph;
  digraph := RandomDigraph(2 * n);
  return PBRNC(OutNeighbours(digraph){[1 .. n]},
               OutNeighbours(digraph){[n + 1 .. 2 * n]});
end);

InstallMethod(RandomPBR, "for a pos int", [IsPosInt, IsFloat],
function(n, p)
  local digraph;
  digraph := RandomDigraph(2 * n, p);
  return PBRNC(OutNeighbours(digraph){[1 .. n]},
               OutNeighbours(digraph){[n + 1 .. 2 * n]});
end);

InstallMethod(PBR, "for pair of dense list",
[IsDenseList, IsDenseList],
function(left, right)
  local deg, i;

  if Length(left) <> Length(right) then
    ErrorMayQuit("Semigroups: PBR: usage,\n",
                 "the arguments must have equal lengths,");
  fi;

  deg := Length(left);

  for i in [1 .. deg] do
    if not IsHomogeneousList(left[i]) or not IsHomogeneousList(right[i]) then
      ErrorMayQuit("Semigroups: PBR: usage,\n",
                   "the entries in the arguments must be homogeneous lists,");
    elif   not ForAll(left[i], j -> IsInt(j) and j <> 0
                                    and j <= deg and j >= -deg)
        or not ForAll(right[i], j -> IsInt(j) and j <> 0
                                     and j <= deg and j >= -deg) then
      ErrorMayQuit("Semigroups: PBR: usage,\n",
                   "the entries in the first argument must be integers ",
                   "in [", -deg, " .. -1]\n or [1 .. ", deg, "],");
    fi;
  od;
  return PBRNC(left, right);
end);

InstallGlobalFunction(PBRNC,
function(arg)
  local left, right, n, i, j;

  arg   := ShallowCopy(arg);
  left  := arg[1];  # things adjacent to positives
  right := arg[2];  # things adjacent to negatives

  n := Length(left);

  for i in [1 .. n] do
    for j in [1 .. Length(left[i])] do
      if left[i][j] < 0 then
        left[i][j] := -left[i][j] + n;
      fi;
    od;
    left[i] := ShallowCopy(left[i]);
    Sort(left[i]);
    for j in [1 .. Length(right[i])] do
      if right[i][j] < 0 then
        right[i][j] := -right[i][j] + n;
      fi;
    od;
    right[i] := ShallowCopy(right[i]);
    Sort(right[i]);
  od;
  MakeImmutable(arg);
  arg := Concatenation([Length(arg[1])], Concatenation(arg));
  return Objectify(PBRType, arg);
end);

InstallMethod(DegreeOfPBR, "for a pbr",
[IsPBR], pbr -> pbr![1]);

# can't we use some sort of Floyd-Warshall Algorithm here, the current method
# involves searching in the same part of the graph repeatedly??

InstallMethod(\*, "for pbrs",
[IsPBR, IsPBR],
function(x, y)
  local n, out, x_seen, y_seen, empty, x_dfs, y_dfs, i;

  n := x![1];

  out := Concatenation([n], List([1 ..  2 * n], x -> []));

  x_seen := BlistList([1 .. 2 * n], []);
  y_seen := BlistList([1 .. 2 * n], []);
  empty  := BlistList([1 .. 2 * n], []);

  x_dfs := function(i, adj) # starting in x
    local j;
    if x_seen[i] then
      return;
    fi;
    x_seen[i] := true;
    for j in x![i + 1] do
      if j <= n then
        AddSet(adj, j);
      else # j > n
        y_dfs(j - n, adj);
      fi;
    od;
    return;
  end;

  y_dfs := function(i, adj) # starting in y
    local j;
    if y_seen[i] then
      return;
    fi;
    y_seen[i] := true;
    for j in y![i + 1] do
      if j > n then
        AddSet(adj, j);
      else # j <= n
        x_dfs(j + n, adj);
      fi;
    od;
    return;
  end;

  for i in [1 .. n] do # find everything connected to vertex i
    IntersectBlist(x_seen, empty);
    IntersectBlist(y_seen, empty);
    x_dfs(i, out[i + 1]);
  od;

  for i in [n + 1 .. 2 * n] do # find everything connected to vertex i
    IntersectBlist(x_seen, empty);
    IntersectBlist(y_seen, empty);
    y_dfs(i, out[i + 1]);
  od;

  return Objectify(PBRType, out);
end);

InstallMethod(ExtRepOfPBR, "for a pbr",
[IsPBR],
function(x)
  local n, out, i, j, k;

  n := x![1];
  out := [[], []];
  for i in [0, 1] do
    for j in [1 + n * i .. n + n * i] do
      Add(out[i + 1], []);
      for k in x![j + 1] do
        if k > n then
          AddSet(out[i + 1][j - n * i], -(k - n));
        else
          AddSet(out[i + 1][j - n * i], k);
        fi;
      od;
    od;
  od;

  return out;
end);

# These ViewObj and PrintObj methods are here because Print(ext[1]) produces
# nices output than Print(ViewString(ext[1])). The ViewString and PrintString
# methods are required for use in things like Green's relations.

InstallMethod(ViewObj, "for a pbr", [IsPBR], PrintObj);

InstallMethod(PrintObj, "for a pbr", [IsPBR],
function(x)
  local ext;

  ext := ExtRepOfPBR(x);
  Print("\>\>PBR(\>\>", ext[1], "\<\<,");

  if Length(String(ext[1])) > 72 or Length(String(ext[2])) > 72 then
    Print("\n");
  else
    Print(" ");
  fi;

  Print("\>\>", ext[2], "\<\<\<\<)");
end);

InstallMethod(ViewString, "for a pbr", [IsPBR], PrintString);

InstallMethod(PrintString, "for a pbr",
[IsPBR],
function(x)
  local ext, str;

  ext := ExtRepOfPBR(x);

  str := Concatenation("\>\>PBR(\>\>", ViewString(ext[1]), "\<\<,");

  if Length(String(ext[1])) > 72 or Length(String(ext[2])) > 72 then
    Append(str, "\n");
  else
    Append(str, " ");
  fi;

  Append(str, "\>\>");
  Append(str, ViewString(ext[2]));
  Append(str, "\<\<\<\<)");
  return str;
end);

InstallMethod(\=, "for pbrs",
[IsPBR, IsPBR],
function(x, y)
  local n, i;

  n := x![1];
  for i in [1 .. 2 * n + 1] do
    if x![i] <> y![i] then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(\<, "for pbrs",
[IsPBR, IsPBR],
function(x, y)
  local n, i;

  n := x![1];
  for i in [1 .. 2 * n + 1] do
    if x![i] < y![i] then
      return true;
    elif x![i] > y![i] then
      return false;
    fi;
  od;
  return false;
end);

InstallMethod(OneMutable, "for a pbr",
[IsPBR],
function(x)
  local n, out, i;

  n := x![1];
  out := [n];
  for i in [1 .. n] do
    out[i + 1] := [i + n];
    out[i + n + 1] := [i];
  od;
  return Objectify(PBRType, out);
end);