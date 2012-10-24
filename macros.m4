dnl This file is part of the MLCUDDIDL Library, released under LGPL license.
dnl Please read the COPYING file packaged in the distribution
dnl
changequote([[, ]])dnl
dnl
dnl **********************************************************************
dnl General conversion functions
dnl **********************************************************************
dnl
dnl arguments: 1:returned value, 2:some (boolean) 3:type 4:value (of type)
define([[OPTION_c2ml]], [[
if ($2){
  value v_$4 = cudd_caml_$3_c2ml($4);
  Begin_roots(v_$4){
    $1 = caml_alloc_small(1,0);
    Field($1,0) = v_$4;
  } End_roots()
}
else
  v = Val_int(0);
]])dnl
dnl arguments: 1:returned value (caml), 2:type 3:array 4:size
define([[ARRAY_c2ml]], [[
if ($4==0) $1 = Atom(0);
else {
  $1 = caml_alloc($4,0);
  for (int i=0; i<$4; i++){
    value v_$1_v = cudd_caml_$2_c2ml($3[i]);
    Store_field($1,i,v_$1_v);
  }
}
]])dnl
dnl arguments: 1:returned array (of type $3), 2:its size, 3:type 4:value (caml)
define([[ARRAY_ml2c]], [[
int $2 = Wosize_val($4);
$3* $1 = malloc($2*sizeof($3));
for (int i=0; i<$2; i++){
  $1[i] = cudd_caml_$3_ml2c(Field($4,i));
}
]])dnl
dnl
dnl
dnl **********************************************************************
dnl General wrappers
dnl **********************************************************************
dnl
define([[FUN_1]],[[
CAMLprim value cudd_caml_$1_$2(value v1)
{
  CAMLparam1(v1);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  ifelse($4,[[unit]],,[[$4 xr;]])
  ifelse($5,[[]],[[ifelse($4,[[unit]],,[[xr=]])$2(x1);]],$5)
  value vr = ifelse($4,[[unit]],[[Val_unit]],[[cudd_caml_$4_c2ml(xr)]]);
  CAMLreturn(vr);
}
]])dnl
dnl
define([[FUN_2]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam2(v1,v2);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  ifelse($5,[[unit]],,[[$5 xr;]])
  ifelse($6,[[]],[[ifelse($5,[[unit]],,[[xr=]])$2(x1,x2);]],$6)
  value vr = ifelse($5,[[unit]],[[Val_unit]],[[cudd_caml_$5_c2ml(xr)]]);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_3]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  ifelse($6,[[unit]],,[[$6 xr;]])
  ifelse($7,[[]],[[ifelse($6,[[unit]],,[[xr=]])$2(x1,x2,x3);]],$7)
  value vr = ifelse($6,[[unit]],[[Val_unit]],[[cudd_caml_$6_c2ml(xr)]]);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_4]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3, value v4)
{
  CAMLparam4(v1,v2,v3,v4);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  $6 x4 = cudd_caml_$6_ml2c(v4);
  ifelse($7,[[unit]],,[[$7 xr;]])
  ifelse($8,[[]],[[ifelse($7,[[unit]],,[[xr=]])$2(x1,x2,x3,x4);]],$8)
  value vr = ifelse($7,[[unit]],[[Val_unit]],[[cudd_caml_$7_c2ml(xr)]]);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_5]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3, value v4, value v5)
{
  CAMLparam5(v1,v2,v3,v4,v5);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  $6 x4 = cudd_caml_$6_ml2c(v4);
  $7 x5 = cudd_caml_$7_ml2c(v5);
  ifelse($8,[[unit]],,[[$8 xr;]])
  ifelse($9,[[]],[[ifelse($8,[[unit]],,[[xr=]])$2(x1,x2,x3,x4,x5);]],$9)
  value vr = ifelse($8,[[unit]],[[Val_unit]],[[cudd_caml_$8_c2ml(xr)]]);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_6]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3, value v4, value v5, value v6)
{
  CAMLparam5(v1,v2,v3,v4,v5);CAMLxparam1(v6);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  $6 x4 = cudd_caml_$6_ml2c(v4);
  $7 x5 = cudd_caml_$7_ml2c(v5);
  $8 x6 = cudd_caml_$8_ml2c(v6);
  ifelse($9,[[unit]],,[[$9 xr;]])
  ifelse($10,[[]],[[ifelse($9,[[unit]],,[[xr=]])$2(x1,x2,x3,x4,x5);]],$10)
  value vr = ifelse($9,[[unit]],[[Val_unit]],[[cudd_caml_$9_c2ml(xr)]]);
  CAMLreturn(vr);
}
CAMLprim value cudd_caml_$1_$2_bytecode(value* argv, int argn)
{
  return cudd_caml_$1_$2(argv[0],argv[1],argv[2], argv[3], argv[4], argv[5]);
}
]])dnl
dnl
define([[FUN_1_unsafe]],[[
CAMLprim value cudd_caml_$1_$2(value v1)
{
  $3 x1 = cudd_caml_$3_ml2c(v1);
  ifelse($4,[[unit]],,[[$4 xr;]])
  ifelse($5,[[]],[[ifelse($4,[[unit]],,[[xr=]])$2(x1);]],$5)
  value vr = ifelse($4,[[unit]],[[Val_unit]],[[cudd_caml_$4_c2ml(xr)]]);
  return vr;
}
]])dnl
define([[FUN_2_unsafe]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  ifelse($5,[[unit]],,[[$5 xr;]])
  ifelse($6,[[]],[[ifelse($5,[[unit]],,[[xr=]])$2(x1,x2);]],$6)
  value vr = ifelse($5,[[unit]],[[Val_unit]],[[cudd_caml_$5_c2ml(xr)]]);
  return vr;
}
]])dnl
define([[FUN_node1_1]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam2(v1,v2);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 xr;
  ifelse($6,[[]],[[xr = $2(x1.man->man,x1.node,x2);]],$6)
  value vr = cudd_caml_$5_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node2]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam2(v1,v2);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  if (x1.man!=x2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  $5 xr;
  ifelse($6,[[]],[[xr = $2(x1.man->man,x1.node,x2.node);]],$6)
  value vr = cudd_caml_$5_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node2_1]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  if (x1.man!=x2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  $6 xr;
  ifelse($7,[[]],[[xr = $2(x1.man->man,x1.node,x2.node,x3.node);]],$7)
  value vr = cudd_caml_$6_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node3]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  if (x1.man!=x2.man || x1.man!=x3.man)
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  $6 xr;
  ifelse($7,[[]],[[xr = $2(x1.man->man,x1.node,x2.node,x3.node);]],$7)
  value vr = cudd_caml_$6_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node1_node]],[[
CAMLprim value cudd_caml_$1_$2(value v1)
{
  CAMLparam1(v1);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 xr;
  xr.man = x1.man;
  xr.node = $2(x1.man->man,x1.node);
  value vr = cudd_caml_$4_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node1_1_node]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam2(v1,v2);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 xr;
  xr.man = x1.man;
  xr.node = $2(x1.man->man,x1.node,x2);
  value vr = cudd_caml_$5_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node2_node]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam2(v1,v2);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  if (x1.man!=x2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  $5 xr;
  xr.man = x1.man;
  xr.node = $2(x1.man->man,x1.node,x2.node);
  value vr = cudd_caml_$5_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node2_1_node]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2)
{
  CAMLparam3(v1,v2,v3);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  if (x1.man!=x2.man)
    caml_invalid_argument("Cudd: binary function called with nodes belonging to different managers !");
  $6 xr;
  xr.man = x1.man;
  xr.node = $2(x1.man->man,x1.node,x2.node,x3);
  value vr = cudd_caml_$6_c2ml(xr);
  CAMLreturn(vr);
}
]])dnl
define([[FUN_node3_node]],[[
CAMLprim value cudd_caml_$1_$2(value v1, value v2, value v3)
{
  CAMLparam3(v1,v2,v3);
  $3 x1 = cudd_caml_$3_ml2c(v1);
  $4 x2 = cudd_caml_$4_ml2c(v2);
  $5 x3 = cudd_caml_$5_ml2c(v3);
  if (x1.man!=x2.man || x1.man!=x3.man){
    caml_invalid_argument("Cudd: ternary function called with nodes belonging to different managers !");
  }
  $6 xr;
  xr.man = x1.man;
  xr.node = $2(x1.man->man,x1.node,x2.node,x3.node);
  value vr = cudd_caml_$6_c2ml(xr);
  CAMLreturn(vr);
}
]])