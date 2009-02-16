/* $Id: cuddauxMisc.c,v 1.1.1.1 2002/05/14 13:04:04 bjeannet Exp $ */

/**CFile***********************************************************************

  FileName    [cuddauxMisc.c]

  PackageName [cuddaux]

  Synopsis    [Miscellaneous operations.]

  Description [Miscellaneous operations..]

            External procedures included in this module:
		<ul>
		<li> Cuddaux_IsVarIn()
		<li> Cuddaux_bddCubeUnion()
		<li> Cuddaux_NodesBelowLevel()
		<li> list_free()
		<li> Cuddaux_addGuardOfNode()
		</ul>
	    Internal procedures included in this module:
		<ul>
		<li> cuddauxIsVarInRecur()
		<li> cuddauxBddCubeUnionRecur()
		<li> cuddauxAddGuardOfNodeRecur()
		</ul>
	    Static procedures included in this module:
		<ul>
		<li> cuddauxNodesBelowLevelRecur()
		<li> list_add
		</ul>
		]

  Author      [Bertrand Jeannet]

  Copyright   []

******************************************************************************/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include "cuddInt.h"
#include "util.h"
#include "st.h"

#include "cuddauxInt.h"

static int list_add(list_t** const plist, DdNode* node);
static int cuddauxNodesBelowLevelRecur(DdManager* manager, DdNode* F, int level,
				       list_t** plist, st_table* visited,
				       size_t max, size_t *psize,
				       int take_background);


/*---------------------------------------------------------------------------*/
/* Definition of exported functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

  Synopsis    [Membership of a variable to the support of a BDD/ADD]

  Description [Tells wether a variable appear in the decision diagram
  of a function.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
int 
Cuddaux_IsVarIn(DdManager* dd, DdNode* f, DdNode* var)
{ 
  assert(Cudd_Regular(var));
  return (cuddauxIsVarInRecur(dd,f,var) == DD_ONE(dd));
}

/**Function********************************************************************

  Synopsis    [Smallest cube implied by the cubes f and g]

  Description ["Or" function within the set of cubes]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
DdNode*
Cuddaux_bddCubeUnion(DdManager* dd, DdNode* f, DdNode* g)
{ 
  DdNode *res;

  do {
    dd->reordered = 0;
    res = cuddauxBddCubeUnionRecur(dd,f,g);
  } while (dd->reordered == 1);
  return(res);
}

/* Given a \textsc{Bdd} or a \textsc{Add} $f$, and a variable level
  $l$, the function performs a depth-first search of the graph rooted
  at $f$ and select the first nodes encountered such that their
  variable level is equal or below the level $l$. If
  [[l==CUDD_MAXINDEX]], then the functions collects only constant
  nodes. */

/**Function********************************************************************

  Synopsis    [List of nodes below some level reachable from a root node.]

  Description [List of nodes below some level reachable from a root
  node. if max>0, the list is at most of size max (partial list).

  Given a BDD/ADD f and a variable level level the function
  performs a depth-first search of the graph rooted at $f$ and select
  the first nodes encountered such that their variable level is equal
  or below the level level. If level==CUDD_MAXINDEX, then the
  functions collects only constant nodes. The background node is not
  returned in the result if take_background==0.

  Returns the list of nodes, the index of which has its level equal or below
  level, and the size of the list in *psize, if successful; NULL
  otherwise. Nodes in the list are NOT referenced.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
list_t* 
Cuddaux_NodesBelowLevel(DdManager* manager, DdNode* f, int level, size_t max, size_t* psize, int take_background)
{
  list_t* res = 0;
  st_table* visited;
  
  visited = st_init_table(st_ptrcmp,st_ptrhash);
  if (visited==NULL) return NULL;
  *psize = 0;
  cuddauxNodesBelowLevelRecur(manager, Cudd_Regular(f), level, &res, visited, max, psize,take_background);
  if (res==NULL) *psize=0;
  assert (max>0 ? *psize<=max : 1);
  st_free_table(visited);
  return(res);
}

/**Function********************************************************************

  Synopsis    [Free a list returned by Cuddaux_NodesBelowLevel.]

  Description [Free a list returned by Cuddaux_NodesBelowLevel.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
void list_free(list_t* list)
{
  list_t* p;
  while (list!=0){
    p = list;
    list = list->next;
    free(p);
  }
}

/**Function********************************************************************

  Synopsis    [Logical guard of a node in an ADD.]

  Description [Logical guard of a node in an ADD.  h is supposed to be
  a ADD pointed from the ADD f. Returns a BDD which is the sum of the paths that
  leads from the root node f to the node h, if successful; NULL
  otherwise. ]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
DdNode* Cuddaux_addGuardOfNode(DdManager* manager, DdNode* f, DdNode* h)
{
  DdNode* res;
  do {
    manager->reordered = 0;
    res = cuddauxAddGuardOfNodeRecur(manager, f, h);
  } while (manager->reordered == 1);
  return res;
}

/*---------------------------------------------------------------------------*/
/* Definition of internal functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

  Synopsis    [Performs the recursive step of Cuddaux_IsVarIn.]

  Description [Performs the recursive step of Cuddaux_IsVarIn. var is
  supposed to be a BDD projection function. Returns the logical one or
  zero.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
DdNode* 
cuddauxIsVarInRecur(DdManager* manager, DdNode* f, DdNode* Var)
{
  DdNode *zero,*one, *F, *res;
  int topV,topF;

  one = DD_ONE(manager);
  zero = Cudd_Not(one);
  F = Cudd_Regular(f);
  
  if (cuddIsConstant(F)) return zero;
  if (Var==F) return(one);

  topV = Var->index;
  topF = F->index;
  if (topF == topV) return(one);
  if (cuddI(manager,topV) < cuddI(manager,topF)) return(zero);
  
  res = cuddCacheLookup2(manager,cuddauxIsVarInRecur, F, Var);
  if (res != NULL) return(res);
  res = cuddauxIsVarInRecur(manager,cuddT(F),Var);
  if (res==zero){
    res = cuddauxIsVarInRecur(manager,cuddE(F),Var);
  }
  cuddCacheInsert2(manager,cuddauxIsVarInRecur,F,Var,res);
  return(res);
}

/**Function********************************************************************

  Synopsis    [Performs the recursive step of Cuddaux_addGuardOfNode.]

  Description [Performs the recursive step of Cuddaux_addGuardOfNode.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/

DdNode* 
cuddauxAddGuardOfNodeRecur(DdManager* manager, DdNode* f, DdNode* h)
{
  DdNode *one, *res, *T, *E;
  int topf, toph;

  /* Handle terminal cases */
  one = DD_ONE(manager);
  if (f==h){ 
    return(one);
  }
  topf = cuddI(manager,f->index);
  toph = cuddI(manager,h->index);
  if (topf >= toph){
    return Cudd_Not(one);
  }
  
  /* Look in the cache */
  res = cuddCacheLookup2(manager,Cuddaux_addGuardOfNode,f,h);
  if (res != NULL) 
    return(res);

  T = cuddauxAddGuardOfNodeRecur(manager,cuddT(f),h);
  if (T == NULL)
    return(NULL);
  cuddRef(T);
  E = cuddauxAddGuardOfNodeRecur(manager,cuddE(f),h);
  if (E == NULL){
    Cudd_IterDerefBdd(manager, T);
    return(NULL);
  }
  cuddRef(E);
  if (T == E){
    res = T;
  }
  else {
    if (Cudd_IsComplement(T)){
      res = cuddUniqueInter(manager,f->index,Cudd_Not(T),Cudd_Not(E));
      if (res == NULL) {
	Cudd_IterDerefBdd(manager, T);
	Cudd_IterDerefBdd(manager, E);
	return(NULL);
      }
      res = Cudd_Not(res);
    } 
    else {
      res = cuddUniqueInter(manager,f->index,T,E);
      if (res == NULL) {
	Cudd_IterDerefBdd(manager, T);
	Cudd_IterDerefBdd(manager, E);
	return(NULL);
      }
    }
  }
  cuddDeref(T);
  cuddDeref(E);
  cuddCacheInsert2(manager,Cuddaux_addGuardOfNode,f,h,res);
  return(res);
}

/*---------------------------------------------------------------------------*/
/* Definition of static functions                                            */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

  Synopsis    [Performs the recursive step of Cuddaux_bddCubeUnion.]

  Description [Performs the recursive step of
  Cuddaux_bddCubeUnion. Returns the node if successfull, NULL otherwise.]


  SideEffects [None]

  SeeAlso     []

******************************************************************************/

DdNode *
cuddauxBddCubeUnionRecur(DdManager * manager,
		      DdNode * f,
		      DdNode * g)
{
  DdNode *F, *fv, *fnv, *G, *gv, *gnv;
  DdNode *one, *zero, *res1, *res;
  unsigned int topf, topg, index;

  one = DD_ONE(manager);
  zero = Cudd_Not(one);

  while (1){
    /* Terminal cases. */
    F = Cudd_Regular(f);
    G = Cudd_Regular(g);
    if (F == G) {
      if (f == g) return(f);
      else return(one);
    }
    if (F == one) {
      if (f == one) return(one);
      else return(g);
    }
    if (G == one) {
      if (g == one) return(one);
      else return(f);
    }
    /* At this point f and g are not constant. */
    
    /* Here we can skip the use of cuddI, because the operands are known
    ** to be non-constant.
    */
    topf = manager->perm[F->index];
    topg = manager->perm[G->index];
    
    /* Compute cofactors. */
    if (topf < topg){
      index = F->index;
      fv = cuddT(F);
      fnv = cuddE(F);
      if (Cudd_IsComplement(f)) {
	fv = Cudd_Not(fv);
	fnv = Cudd_Not(fnv);
      }
      if (fv == zero) f = fnv;
      else if (fnv == zero) f = fv;
      else {
	manager->errorCode = CUDD_INVALID_ARG;
	return NULL;
      }
    }
    else if (topg < topf){
      index = G->index;
      gv = cuddT(G);
      gnv = cuddE(G);
      if (Cudd_IsComplement(g)) {
	gv = Cudd_Not(gv);
	gnv = Cudd_Not(gnv);
      }
      if (gv == zero) g = gnv;
      else if (gnv == zero) g = gv;
      else {
	manager->errorCode = CUDD_INVALID_ARG;
	return NULL;
      }
    }
    else {
      index = F->index;
      fv = cuddT(F);
      fnv = cuddE(F);
      if (Cudd_IsComplement(f)) {
	fv = Cudd_Not(fv);
	fnv = Cudd_Not(fnv);
      }
      gv = cuddT(G);
      gnv = cuddE(G);
      if (Cudd_IsComplement(g)) {
	gv = Cudd_Not(gv);
	gnv = Cudd_Not(gnv);
      }
      if (fv==zero && gv==zero){
	res1 = cuddauxBddCubeUnionRecur(manager,fnv,gnv);
	if (res1==NULL) return(NULL);
	cuddRef(res1);
	res = cuddUniqueInter(manager,index,one,Cudd_Not(res1));
	if (res==NULL){
	  Cudd_IterDerefBdd(manager,res1);
	  return(NULL);
	}
	res = Cudd_Not(res);
	cuddDeref(res1);
	return(res);
      }
      else if (fnv==zero && gnv==zero){
	res1 = cuddauxBddCubeUnionRecur(manager,fv,gv);
	if (res1==NULL) return(NULL);
	cuddRef(res1);
	if (Cudd_IsComplement(res1)){
	  res = cuddUniqueInter(manager,index,Cudd_Not(res1),one);
	  if (res==NULL){
	    Cudd_IterDerefBdd(manager,res1);
	    return(NULL);
	  }
	  res = Cudd_Not(res);
	}
	else {
	  res = cuddUniqueInter(manager,index,res1,zero);
	  if (res==NULL){
	    Cudd_IterDerefBdd(manager,res1);
	    return(NULL);
	  }
	}
	cuddDeref(res1);
	return(res);
      }
      else {
	if (fv==zero) f = fnv;
	else if (fnv==zero) f = fv;
	else {
	  manager->errorCode = CUDD_INVALID_ARG;
	  return NULL;
	}
	if (gv == zero) g = gnv;
	else if (gnv == zero) g = gv;
	else {
	  manager->errorCode = CUDD_INVALID_ARG;
	  return NULL;
	}
      }
    }
  }
}


/**Function********************************************************************

  Synopsis    [Performs the recursive step of Cuddaux_NodesBelowLevelRecur.]

  Description [Performs the recursive step of
  Cuddaux_NodesBelowLevelRecur.  F is supposed to be a regular
  node. Returns 1 if successful, NULL otherwise. 
  The background node is not put in the list if take_background==0 ]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
static int 
cuddauxNodesBelowLevelRecur(DdManager* manager, DdNode* F, int level, 
			    list_t** plist, st_table* visited, 
			    size_t max, size_t* psize,
			    int take_background)
{
  int topF,res;

  if ((!take_background && F==DD_BACKGROUND(manager)) || st_is_member(visited, (char *) F) == 1){
    return 1;
  }
  topF = cuddI(manager,F->index);
  if (topF < level){
    res = cuddauxNodesBelowLevelRecur(manager, Cudd_Regular(cuddT(F)), level, plist, visited, max, psize, take_background);
    if (res==0) return 0;
    if (max == 0 || *psize<max){
      res = cuddauxNodesBelowLevelRecur(manager, Cudd_Regular(cuddE(F)), level, plist, visited, max, psize, take_background);
      if (res==0) return 0;
    }
  }
  else {
    res = list_add(plist,F);
    (*psize)++;
    if (res==0) return 0;
  }
  if (st_add_direct(visited, (char *) F, NULL) == ST_OUT_OF_MEM){
    list_free(*plist);
    return 0;
  }
  return 1;
}

/**Function********************************************************************

  Synopsis    [Add a node to a list of nodes.]

  Description [Add a node to a list of nodes. plist is the pointer to
  the list, and is an input/output parameter. Returns 1 if successful,
  0 otherwise.]

  SideEffects [None]

  SeeAlso     []

******************************************************************************/
static int 
list_add(list_t** const plist, DdNode* node)
{
  list_t* nlist = (list_t*)malloc(sizeof(list_t));
  if (nlist==NULL) return(0);
  nlist->node = node;
  nlist->next = *plist;
  *plist = nlist;
  return 1;
}
