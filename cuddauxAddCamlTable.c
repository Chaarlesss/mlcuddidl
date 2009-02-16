/**CFile***********************************************************************

  FileName    [cuddauxTable.c]

  PackageName [cuddaux]

  Synopsis    [Allows to put pointers in constant ADD node]

  Description [Miscellaneous operations..]

	    External procedures included in this module:
		<ul>
		<li>
		</ul>
	    Internal procedures included in this module:
		<ul>
		<li>
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

#include "caml/memory.h"

extern intnat caml_stat_compactions;
static intnat old_compactions = -1;

typedef union myhack {
    CUDD_VALUE_TYPE dbl;
    value value;
    unsigned int bits[2];
} myhack;

/*---------------------------------------------------------------------------*/
/* Definition of exported functions                                          */
/*---------------------------------------------------------------------------*/

/**Function********************************************************************

  Synopsis    [Checks the unique table for the existence of a constant node.]

  Description [Copy of cuddUniqueConst.
  Checks the unique table for the existence of a constant node.
  If it does not exist, it creates a new one.  Does not
  modify the reference count of whatever is returned.  A newly created
  internal node comes back with a reference count 0.  Returns a
  pointer to the new node.]

  SideEffects [None]

***************************************************************************/

DdNode *
Cuddaux_addCamlConst(
  DdManager * unique,
  value value)
{
    int pos;
    DdNodePtr *nodelist;
    DdNode *looking;
    myhack split;

    if (
	value==((struct cuddauxDdNode*)unique->one)->type.value ||
	value==((struct cuddauxDdNode*)unique->zero)->type.value ||
	value==((struct cuddauxDdNode*)unique->plusinfinity)->type.value ||
	value==((struct cuddauxDdNode*)unique->minusinfinity)->type.value
	){
      fprintf(stderr,"\ncuddaux/mlcuddidl: big problem: CAML value assimilated to ZERO, ONE, PLUS_INFINITY or MINUS_INFINITY double value\nContact Bertrand Jeannet\n");
      abort();
    }

#ifdef DD_UNIQUE_PROFILE
    unique->uniqueLookUps++;
#endif

    if (unique->constants.keys > unique->constants.maxKeys) {
      if (unique->gcEnabled && ((unique->dead > unique->minDead) ||
				(10 * unique->constants.dead > 9 * unique->constants.keys))) {	/* too many dead */
	(void) cuddGarbageCollect(unique,1);
      } else {
	cuddauxAddCamlConstRehash(unique,1);
	old_compactions = caml_stat_compactions;
      }
    }
    
    if (0<=old_compactions && old_compactions < caml_stat_compactions){
      cuddauxAddCamlConstRehash(unique,0);
    }
    old_compactions = caml_stat_compactions;
    
    split.value = value >> 2;
    pos = ddHash(split.bits[0], split.bits[1], unique->constants.shift);
    nodelist = unique->constants.nodelist;
    looking = nodelist[pos];

    while (looking != NULL) {
      if ( ((struct cuddauxDdNode*)looking)->type.value == value) {
	    if (looking->ref == 0) {
		cuddReclaim(unique,looking);
	    }
	    return(looking);
	}
	looking = looking->next;
#ifdef DD_UNIQUE_PROFILE
	unique->uniqueLinks++;
#endif
    }

    unique->keys++;
    unique->constants.keys++;

    looking = cuddAllocNode(unique);
    if (looking == NULL) return(NULL);
    looking->index = CUDD_CONST_INDEX;
    ((struct cuddauxDdNode*)looking)->type.value = value;
    if (Is_block(value))
      caml_register_generational_global_root(&((struct cuddauxDdNode*)looking)->type.value);
    looking->next = nodelist[pos];
    nodelist[pos] = looking;

    return(looking);

} /* end of cuddaux_addCamlConst */


/**Function********************************************************************

  Synopsis    [Free ADD OCaml value for enabling garbage collection.]

  Description []

  SideEffects [None]

  SeeAlso     []

******************************************************************************/

int Cuddaux_addCamlPreGC(DdManager* unique, const char* s, void* data)
{
  DdNodePtr	*nodelist;
  int		j;
  DdNode	*node;
  int		slots;

  if (unique->constants.dead == 0) return 1;

  nodelist = unique->constants.nodelist;
  slots = unique->constants.slots;
  for (j = 0; j < slots; j++) {
    node = nodelist[j];
    while (node != NULL) {
      if (node->ref == 0) {
	value value = ((struct cuddauxDdNode *)node)->type.value;
	if (Is_block(value))
	  caml_remove_generational_global_root(&((struct cuddauxDdNode *)node)->type.value);
      }
      node = node->next;
    }
  }
  return 1;
}


/*---------------------------------------------------------------------------*/
/* Definition of internal functions                                          */
/*---------------------------------------------------------------------------*/

DdNode* cuddauxUniqueType(int is_value, DdManager* man, cuddauxType* type)
{
  return is_value ?
    Cuddaux_addCamlConst(man,type->value) :
    cuddUniqueConst(man,type->dbl);
}

void cuddauxAddCamlConstRehash(DdManager* unique, int offset)
{
  unsigned int slots, oldslots;
  int shift, oldshift;
  int j, pos;
  DdNodePtr *nodelist, *oldnodelist;
  DdNode *node, *next;
  DdNode *sentinel = &(unique->sentinel);
  myhack split;
  extern DD_OOMFP MMoutOfMemory;
  DD_OOMFP saveHandler;
    
  oldslots = unique->constants.slots;
  oldshift = unique->constants.shift;
  oldnodelist = unique->constants.nodelist;

  /* The constant subtable is never subjected to reordering.
  ** Therefore, when it is resized, it is because it has just
  ** reached the maximum load. We can safely just double the size,
  ** with no need for the loop we use for the other tables.
  */
  slots = oldslots << offset;
  shift = oldshift - offset;
  saveHandler = MMoutOfMemory;
  MMoutOfMemory = Cudd_OutOfMem;
  nodelist = ALLOC(DdNodePtr, slots);
  MMoutOfMemory = saveHandler;
  if (nodelist == NULL) {
    int j;
    (void) fprintf(unique->err,
		   "Unable to resize constant subtable for lack of memory\n");
    (void) cuddGarbageCollect(unique,1);
    for (j = 0; j < unique->size; j++) {
      unique->subtables[j].maxKeys <<= 1;
    }
    unique->constants.maxKeys <<= 1;
    return;
  }
  unique->constants.slots = slots;
  unique->constants.shift = shift;
  unique->constants.maxKeys = slots * DD_MAX_SUBTABLE_DENSITY;
  unique->constants.nodelist = nodelist;
  for (j = 0; (unsigned) j < slots; j++) {
    nodelist[j] = NULL;
  }
  for (j = 0; (unsigned) j < oldslots; j++) {
    node = oldnodelist[j];
    while (node != NULL) {
      next = node->next;
      split.value = cuddauxCamlV(node) >> 2;
      pos = ddHash(split.bits[0], split.bits[1], shift);
      node->next = nodelist[pos];
      nodelist[pos] = node;
      node = next;
    }
  }
  FREE(oldnodelist);

#ifdef DD_VERBOSE
  (void) fprintf(unique->err,
		 "rehashing constants: keys %d dead %d new size %d\n",
		 unique->constants.keys,unique->constants.dead,slots);
#endif
}
