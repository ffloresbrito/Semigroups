#############################################################################
##
#W  inverse.gi
#Y  Copyright (C) 2011-12                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Notes: everything here uses LambdaSomething, so don't use RhoAnything

# the first three functions should be updated!

# methods for inverse acting semigroups consisting of acting elements with a
# ^-1 operator. 

# new for 1.0! - \in - "for an acting semigroup with inversion and elt"
##############################################################################

InstallMethod(\in, "for inverse acting elt and acting semigroup with inversion",
[IsInverseActingElt, IsActingSemigroupWithInverseOp],
function(f, s)
  local dom, o, rho, rho_l, lambda_l, lambda, m, schutz, scc, g;
  
  if not ElementsFamily(FamilyObj(s))=FamilyObj(f) then 
    Error("the element and semigroup are not of the same type,");
    return;
  fi;

  if HasAsSSortedList(s) then 
    return f in AsSSortedList(s); 
  fi;

  dom:=RhoDomain(s);

  if dom=[] then 
    return Degree(f)=0;
  # any way of using points here? JDM
  fi;

  o:=RhoOrb(s);
  rho:=RhoFunc(s)(f);

  if IsClosed(o) then
    rho_l:=Position(o, rho);
    if rho_l=fail or (rho_l=1 and not IsMonoidAsSemigroup(s)) then
      return false;
    fi;
    lambda_l:=Position(o, LambdaFunc(s)(f));
    if lambda_l=fail then
      return false;
    fi;
  else

    rho_l:=Position(o, rho);
    if rho_l=fail then
      o!.looking:=true; o!.lookingfor:=function(o, x) return x=rho; end;
      o!.lookfunc:=o!.lookingfor;
      Enumerate(o);
      rho_l:=PositionOfFound(o);
      o!.found:=false; o!.looking:=false;
      Unbind(o!.lookingfor); Unbind(o!.lookfunc);

      if rho_l=false then
        return false;
      fi;
    fi;

    if rho=[] then
      return true;
    elif rho_l=1 and not IsMonoidAsSemigroup(s) then
      return false;
    fi;

    lambda:=LambdaFunc(s)(f);
    
    if IsClosed(o) then
      lambda_l:=Position(o, lambda);
      if lambda_l=fail then
        return false;
      fi;
    else 
      o:=GradedRhoOrb(s, f, false);
      Enumerate(o, infinity);
      rho_l:=1;
      lambda_l:=Position(o, lambda);
      if lambda_l=fail then
        return false;
      fi;
    fi;
  fi;

  m:=OrbSCCLookup(o)[rho_l];

  if OrbSCCLookup(o)[lambda_l]<>m then
    return false;
  fi;

  schutz:=RhoOrbStabChain(o, m);

  if schutz=true then
    return true;
  fi;

  scc:=OrbSCC(o)[m];
  g:=f;
  if lambda_l<>scc[1] then 
    g:=g*RhoOrbMults(o, m)[lambda_l][1];
  fi;

  if rho_l<>scc[1] then 
    g:=RhoOrbMults(o, m)[rho_l][2]*g;
  fi;

  if IsIdempotent(g) then 
    return true;
  elif schutz=false then
    return false;
  fi;

  #JDM really One? certainly not! See \in in regular.gi
  #return SiftGroupElement(schutz, LambdaPerm(s)(One(g), g)).isone;
  return SiftedPermutation(schutz, LambdaPerm(s)(One(g), g))=(); 
end);

# new for 1.0! - \in - "for acting elt and inverse op L-class of acting semigp"
#############################################################################

InstallMethod(\in, "for acting elt and inverse op L-class of acting semigp.",
[IsActingElt, IsInverseOpLClass and IsActingSemigroupGreensClass],
function(f, l)
  local rep, s, m, o, i, schutz, g, p;

  rep:=Representative(l);
  s:=ParentSemigroup(l);

  if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) or Degree(f) <> Degree(rep)
   or Rank(f) <> Rank(rep) or LambdaFunc(s)(f) <> LambdaFunc(s)(rep) then
    Info(InfoCitrus, 1, "degree, rank, or lambda value not equal to those of",
    " any of the L-class elements,");
    return false;
  fi;

  m:=LambdaOrbSCCIndex(l);
  o:=LambdaOrb(l);
 
  if not IsClosed(o) then
    Enumerate(o, infinity);
  fi;

  i:=Position(o, RhoFunc(s)(f));

  if i = fail or OrbSCCLookup(o)[i]<>m then
    return false;
  fi;

  schutz:=LambdaOrbStabChain(o, m);

  if schutz=true then
    Info(InfoCitrus, 3, "Schutz. group of L-class is symmetric group");
    return true;
  fi;

  if i<>OrbSCC(o)[m][1] then  
    g:=LambdaOrbMult(o, m, i)[1]*f;
  else
    g:=f;
  fi;

  if g=rep then
    Info(InfoCitrus, 3, "element with rectified rho value equals ",
    "L-class representative");
    return true;
  elif schutz=false then
    Info(InfoCitrus, 3, "Schutz. group of L-class is trivial");
    return false;
  fi;

  #return SiftGroupElement(schutz, LambdaPerm(s)(rep, g)).isone;
  return SiftedPermutation(schutz,  LambdaPerm(s)(rep, g))=();
end);

#DDD

# new for 1.0! - DClassReps - "for an acting semigroup with inversion"
##############################################################################

InstallOtherMethod(DClassReps, "for an acting semigroup with inversion",
[IsActingSemigroupWithInverseOp],
function(s)            
  local o, r, out, f, m;
  
  o:=RhoOrb(s);
  r:=Length(OrbSCC(o));
  out:=EmptyPlist(r);
  
  for m in [2..r] do 
    f:=RhoOrbRep(o, m);
# JDM method for RightOne of inverse acting element required.
    out[m-1]:=RightOne(f);
  od;
  return out;
end);

#EEE

# mod for 1.0! - Enumerator - "for L-class of an inverse op acting semigroup"
##############################################################################

InstallMethod(Enumerator, "for L-class of an acting semigroup",
[IsInverseOpLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, mults, scc;

  o:=LambdaOrb(l); 
  m:=LambdaOrbSCCIndex(l);
  mults:=LambdaOrbMults(o, m);
  scc:=OrbSCC(o)[m];

  return EnumeratorByFunctions(l, rec(

    schutz:=Enumerator(SchutzenbergerGroup(l)),

    len:=Size(SchutzenbergerGroup(l)),

    #########################################################################

    ElementNumber:=function(enum, pos)
      local n, m, q;

      if pos>Length(enum) then 
        return fail;
      fi;

      if pos<=Length(enum!.schutz) then 
        return Representative(l)*enum!.schutz[pos];
      fi;

      n:=pos-1; m:=enum!.len;
      
      q:=QuoInt(n, m); 
      pos:=[ q, n - q * m]+1;
     
     return mults[scc[pos[1]]][2]*enum[pos[2]];
    end,

    #########################################################################
    
    NumberElement:=function(enum, f)
      local s, rep, o, m, i, g, j;

      s:=ParentSemigroup(l);
      rep:=Representative(l);
      
      if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) or 
       Degree(f) <> Degree(rep) or Rank(f) <> Rank(rep) or 
       LambdaFunc(s)(f) <> LambdaFunc(s)(rep) then 
        return fail;
      fi;
      
      if f=rep then 
        return 1;
      fi;

      o:=RhoOrb(l); m:=RhoOrbSCCIndex(l);
      i:=Position(o, RhoFunc(s)(f));

      if i = fail or OrbSCCLookup(o)[i]<>m then 
        return fail;
      fi;
     
      j:=Position(enum!.schutz, LambdaPerm(s)(rep, mults[i][1]*f));

      if j=fail then 
        return fail;
      fi;
      return enum!.len*(Position(scc, i)-1)+j;
    end,

    #########################################################################

    Membership:=function(elm, enum)
      return elm in l;
    end,

    Length:=enum-> Size(l),

    PrintObj:=function(enum)
      Print("<enumerator of L-class>");
      return;
    end));
end);

#GGG

# new for 1.0! - GreensHClasses - for an acting semigroup with inverse op
############################################################################

InstallOtherMethod(GreensHClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local lambda_o, lambda_scc, len, out, type, hrel, n, lambda_mults, f, h, lambda_m, j, k;
  
  lambda_o:=Enumerate(LambdaOrb(s), infinity);
  lambda_scc:=OrbSCC(lambda_o);
  len:=Length(lambda_scc);
  
  out:=EmptyPlist(NrHClasses(s));
  type:=HClassType(s);
  hrel:=GreensHRelation(s);
  n:=0; 
    
  for lambda_m in [2..len] do
    lambda_mults:=LambdaOrbMults(lambda_o, lambda_m);
    f:=RightOne(LambdaOrbRep(lambda_o, lambda_m));
    for j in lambda_scc[lambda_m] do
      f:=f*lambda_mults[j][1];
      for k in lambda_scc[lambda_m] do
        n:=n+1;
        h:=Objectify(type, rec());
        SetParentSemigroup(h, s);
        SetLambdaOrb(h, lambda_o);
        SetLambdaOrbSCCIndex(h, lambda_m);
        SetRepresentative(h, lambda_mults[k][1]*f);
        SetEquivalenceClassRelation(h, hrel);
        SetIsGreensClassNC(h, false);
        out[n]:=h;
      od;
    od;
  od;
  return out;
end);

# new for 1.0! - GreensHClasses - "for inverse op L-class of acting semigroup"
##############################################################################

InstallOtherMethod(GreensHClasses, "for inverse op L-class of acting semigroup",
[IsInverseOpLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, nc, s, out, k, j;
  
  o:=LambdaOrb(l);
  m:=LambdaOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  
  f:=Representative(l);
  nc:=IsGreensClassNC(l);
  s:=ParentSemigroup(l);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for j in scc do
    k:=k+1;
    out[k]:=CreateHClass(s, mults[j][2]*f, o, m, fail, fail, nc);
    SetLClassOfHClass(out[k], l);
  od;
  
  return out;
end);

# new for 0.7! - GreensRClasses - for acting semigroup with inverse op
##############################################################################
                    
InstallOtherMethod(GreensRClasses, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)         
  local l, o, scc, out, type, rrel, i, f, mults, r, m, j;
                    
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);   
  out:=EmptyPlist(Length(o));
  type:=RClassType(s);
  rrel:=GreensRRelation(s);

  i:=0;             
                    
  for m in [2..Length(scc)] do
    f:=RightOne(LambdaOrbRep(o, m));
    mults:=LambdaOrbMults(o, m);
    for j in scc[m] do
      i:=i+1;       
      r:=Objectify(type, rec());
      SetParentSemigroup(r, s);
      SetLambdaOrbSCCIndex(r, m);
      SetLambdaOrb(r, o);
      SetRepresentative(r, mults[j][1]*f);
      SetEquivalenceClassRelation(r, rrel);
      SetIsGreensClassNC(r, false);
      out[i]:=r;
    od;             
  od;

  return out;
end);

# mod for 1.0! - GroupHClass - "for an inverse op D-class"
#############################################################################

InstallOtherMethod(GroupHClass, "for an inverse op D-class",
[IsInverseOpDClass and IsActingSemigroupGreensClass], 
d-> GreensHClassOfElementNC(d, Representative(d)));

#III

# new for 1.0! - Idempotents - for D-class of acting semigroup with inverse op
###############################################################################

InstallOtherMethod(Idempotents, "for an inverse op D-class",
[IsInverseOpDClass and IsActingSemigroupGreensClass], 
function(d)
  local creator, o;

  creator:=IdempotentLambdaRhoCreator(ParentSemigroup(d));
  o:=LambdaOrb(d);
  return List(LambdaOrbSCC(d), x-> creator(o[x], o[x]));
end);

# new for 1.0! - Idempotents - for L-class of acting semigroup with inverse op
###############################################################################

InstallOtherMethod(Idempotents, "for an inverse op L-class",
[IsInverseOpLClass and IsActingSemigroupGreensClass], 
l-> [RightOne(Representative(l))]);

# new for 1.0! - Idempotents - for R-class of acting semigroup with inverse op
###############################################################################

InstallOtherMethod(Idempotents, "for an inverse op R-class",
[IsInverseOpRClass and IsActingSemigroupGreensClass], 
r-> [LeftOne(Representative(r))]);

# new for 1.0! - Idempotents - for acting semigroup with inverse op
###############################################################################

InstallOtherMethod(Idempotents, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], 
function(s)
  local o, creator, r, out, i;

  o:=LambdaOrb(s);
  if not IsClosed(o) then      
    Enumerate(o, infinity);
  fi;

  creator:=IdempotentLambdaRhoCreator(s);
  r:=Length(o);
  out:=EmptyPlist(r-1);

  for i in [2..r] do
    out[i-1]:=creator(o[i], o[i]);
  od;
  return out;
end);

# new for 1.0! - RClassReps - for acting semigroup with inverse op
##############################################################################
                    
InstallOtherMethod(RClassReps, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)         
  local o, scc, nr, out, n, f, mults, m, j;
                    
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);   
  
  nr:=Length(scc);
  out:=EmptyPlist(Length(o));
  n:=0;             
                    
  for m in [2..nr] do
    f:=RightOne(LambdaOrbRep(o, m));
    mults:=LambdaOrbMults(o, m);
    for j in scc[m] do
      n:=n+1;       
      out[n]:=mults[j][1]*f;
    od;             
  od;
  return out;
end);

# new for 1.0! - RClassReps - for D-class of acting semigroup with inverse op
##############################################################################

InstallOtherMethod(RClassReps, "for a D-class of an acting semigroup",
[IsActingSemigroupGreensClass and IsInverseOpDClass],
d-> List(LClassReps(d), x-> x^-1));

# new for 0.7! - Random - "for an acting semigroup with inverse op"
#############################################################################

InstallMethod(Random, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, gens, i, w, k, m, l, g;

  o:=LambdaOrb(s);

  if not IsClosed(o) then
    gens:=GeneratorsOfSemigroup(s);    
    i:=Random([1..Int(Length(gens)/2)]);
    w:=List([1..i], x-> Random([1..Length(gens)]));
    return EvaluateWord(gens, w);
  fi;
  k:=Random([1..Length(o)]);
  m:=OrbSCCLookup(o)[k];
  l:=Random(OrbSCC(o)[m]);
  g:=Random(LambdaOrbSchutzGp(o, m));
  return o!.mults[k][1]*g*o!.mults[l][1];
end);

#SSS

# new for 1.0! - SchutzenbergerGroup - for an acting semigroup with inverse op
##############################################################################

InstallOtherMethod(SchutzenbergerGroup, "for an inverse op L-class",
[IsInverseOpLClass and IsActingSemigroupGreensClass],
l-> LambdaOrbSchutzGp(LambdaOrb(l), LambdaOrbSCCIndex(l))); 

# new for 1.0! - Size - "for an acting semigroup with inversion"
##############################################################################

InstallOtherMethod(Size, "for an acting semigroup with inversion",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, r, nr, m;

  o:=LambdaOrb(s);   
  scc:=OrbSCC(o);
  r:=Length(scc); 
  nr:=0;

  for m in [2..r] do 
    nr:=nr+Length(scc[m])^2*Size(LambdaOrbSchutzGp(o, m));
  od;
  return nr;
end);

# new for 1.0! - Size - "for an inverse op D-class"
##############################################################################

InstallOtherMethod(Size, "for an inverse op D-class",
[IsInverseOpDClass and IsActingSemigroupGreensClass],
d-> Size(SchutzenbergerGroup(d))*Length(LambdaOrbSCC(d))^2);


#HHH

# new for 1.0! - HClassReps - for an acting semigroup with inverse op
############################################################################

InstallOtherMethod(HClassReps, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc, len, out, n, mults, f, m, j, k;
  
  o:=Enumerate(LambdaOrb(s), infinity);
  scc:=OrbSCC(o);
  len:=Length(scc);
  
  out:=EmptyPlist(NrHClasses(s));
  n:=0; 
    
  for m in [2..len] do
    mults:=LambdaOrbMults(o, m);
    f:=RightOne(LambdaOrbRep(o, m));
    for j in scc[m] do
      f:=f*mults[j][1];
      for k in scc[m] do
        n:=n+1;
        out[n]:=mults[k][1]*f;
      od;
    od;
  od;
  return out;
end);

# new for 1.0! - HClassReps - "for a inverse op D-class of an acting semigroup"
##############################################################################

InstallOtherMethod(HClassReps, "for a inverse op D-class of acting semigroup",
[IsInverseOpDClass and IsActingSemigroupGreensClass],
function(d)
  local o, m, scc, mults, f, out, k, g, i, j;
  
  o:=LambdaOrb(d); 
  m:=LambdaOrbSCCIndex(d);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  
  f:=Representative(d);
  
  out:=EmptyPlist(Length(scc)^2);
  k:=0;
  
  for i in scc do
    g:=f*mults[i][1];
    for j in scc do
      k:=k+1;
      out[k]:=mults[j][1]*g;
    od;
  od;
  return out;
end);

# new for 1.0! - HClassReps - "for an inverse op L-class"
##############################################################################

InstallOtherMethod(HClassReps, "for an inverse op L-class",
[IsInverseOpLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, out, k, i;
  
  o:=LambdaOrb(l); 
  m:=LambdaOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  f:=Representative(l);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for i in scc do
    k:=k+1;
    out[k]:=mults[i][2]*f;
  od;
  return out;
end);

# new for 0.7! - IteratorOfRClassData - "for acting semigroup with inverse op
###############################################################################

InstallMethod(IteratorOfRClassData, "for acting semigp with inverse op",
[IsActingSemigroupWithInverseOp], 
function(s)
local iter, scc;
  if not IsClosed(LambdaOrb(s)) then 
    
    iter:=IteratorByFunctions( rec(

      i:=1,

      IsDoneIterator:=iter-> IsClosed(LambdaOrb(s)) and 
       iter!.i>=Length(LambdaOrb(s)),

      NextIterator:=function(iter)
        local i, o, r, f;
        
        o:=LambdaOrb(s); i:=iter!.i;

        if IsClosed(o) and i>=Length(o) then 
          return fail;  
        fi;
        
        i:=i+1;
        
        if i>Length(o) then 
          if not IsClosed(o) then 
            Enumerate(o, i);
            if i>Length(o) then 
              return fail;
            fi;
          else 
            return fail;
          fi;
        fi;

        iter!.i:=i; 
        #JDM is f correct here? Not canonical rep?
        f:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, i)); 
        return [s, 1, GradedLambdaOrb(s, o[i], true), f, false];
      end,

      ShallowCopy:=iter-> rec(i:=1)));
  else ####

    scc:=OrbSCC(LambdaOrb(s));

    iter:=IteratorByFunctions( rec(
                 
      m:=1, 
     
      i:=0,      

      scc_limit:=Length(scc),

      i_limit:=Length(scc[Length(scc)]),

      IsDoneIterator:=iter-> iter!.m=iter!.scc_limit and 
       iter!.i=iter!.i_limit,

      NextIterator:=function(iter)
        local i, o, m, scc, f, r, mults;
        
        i:=iter!.i; 
        m:=iter!.m; 

        if m=iter!.scc_limit and i=iter!.i_limit then
          return fail; 
        fi;

        o:=LambdaOrb(s); scc:=OrbSCC(o);

        if i<Length(scc[m]) then 
          i:=i+1;
        else
          i:=1; m:=m+1;
        fi;

        iter!.i:=i; iter!.m:=m;
 
        # f ok here? JDM
        f:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, scc[m][i])); 
        return [s, m, LambdaOrb(s), f, false];
      end,

      ShallowCopy:=iter-> rec(m:=1, i:=0,
      scc_limit:=iter!.scc_limit, i_limit:=iter!.i_limit)));
  fi;
  
  return iter;
end);

# new for 0.7! - IteratorOfLClassReps - "for acting semigroup with inverse op"
###############################################################################

InstallMethod(IteratorOfLClassReps, "for acting semigp with inverse op",
[IsActingSemigroupWithInverseOp],
s-> IteratorByIterator(IteratorOfRClassData(s), x-> x[4]^-1,
[IsIteratorOfLClassReps]));

# new for 0.7! - IteratorOfLClasses - "for acting semigroup with inverse op" 
###############################################################################

InstallMethod(IteratorOfLClasses, "for acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
s-> IteratorByIterator(IteratorOfRClassData(s), x->
CallFuncList(CreateLClassNC, x), [IsIteratorOfLClasses]));

#NNN

# new for 0.7! - NaturalPartialOrder - "for an inverse semigroup"
##############################################################################
# C function for me!

InstallMethod(NaturalPartialOrder, "for an inverse semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup],
function(s)
  local elts, n, out, i, j;

  elts:=Elements(s);  n:=Length(elts);
  out:=List([1..n], x-> EmptyPlist(n));
  for i in [n, n-1..1] do
    for j in [i-1,i-2 ..1] do
      if NaturalLeqPP(elts[j], elts[i]) then
        AddSet(out[i], j);
      fi;
    od;
  od;
  Perform(out, ShrinkAllocationPlist);
  return out;
end);

# new for 1.0! - NrIdempotents - for an acting semigroup with inverse op
##############################################################################

InstallOtherMethod(NrIdempotents, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], 
s-> Length(Enumerate(LambdaOrb(s), infinity))-1);     

# new for 1.0! - NrIdempotents - for an inverse op D-class
##############################################################################

InstallOtherMethod(NrIdempotents, "for an inverse op D-class",
[IsInverseOpDClass and IsActingSemigroupGreensClass], NrLClasses);   

# new for 1.0! - NrIdempotents - for an inverse op L-class
##############################################################################

InstallOtherMethod(NrIdempotents, "for an inverse op L-class",
[IsInverseOpLClass and IsActingSemigroupGreensClass], l-> 1);   

# new for 1.0! - NrIdempotents - for an inverse op R-class
##############################################################################

InstallOtherMethod(NrIdempotents, "for an inverse op R-class",
[IsInverseOpRClass and IsActingSemigroupGreensClass], r-> 1);   

# mod for 1.0! - NrRClasses - for an acting semigroup with inverse op
##############################################################################

InstallOtherMethod(NrRClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp], NrLClasses);

# mod for 1.0! - NrRClasses - for inverse op D-class 
##############################################################################

InstallOtherMethod(NrRClasses, "for inverse op D-class",
[IsInverseOpDClass and IsActingSemigroupGreensClass], NrLClasses);

# mod for 1.0! - NrHClasses - for an acting semigroup with inverse op
##############################################################################

InstallOtherMethod(NrHClasses, "for an acting semigroup with inverse op",
[IsActingSemigroupWithInverseOp],
function(s)
  local o, scc;
  o:=Enumerate(LambdaOrb(s), infinity);
  scc:=OrbSCC(o);

  return Sum(List(scc, m-> Length(m)^2))-1;
end);

# new for 0.7! - PartialOrderOfDClasses - "for acting semigp with inverse op
############################################################################## 
 
InstallMethod(PartialOrderOfDClasses, "for acting semigp with inverse op",
[IsActingSemigroupWithInverseOp],      
function(s)            
  local d, n, out, o, gens, lookup, l, lambdafunc, i, x, f;
                       
  d:=GreensDClasses(s);
  n:=Length(d);
  out:=List([1..n], x-> EmptyPlist(n)); 
  o:=LambdaOrb(s);        
  gens:=o!.gens;
  lookup:=OrbSCCLookup(o);
  lambdafunc:=LambdaFunc(s);
 
  for i in [1..n] do  
    for x in gens do  
      for f in RClassReps(d[i]) do
        AddSet(out[i], lookup[Position(o, lambdafunc(x*f))]-1);      
        AddSet(out[i], lookup[Position(o, lambdafunc(f^-1*x))]-1);     
      od; 
    od;
  od; 
 
  Perform(out, ShrinkAllocationPlist);
  return out; 
end);

