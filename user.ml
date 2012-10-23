(** Custom operations for MTBDDs *)

open Custom

type ('a,'b) op1 = ('a,'b) Custom.op1
type ('a,'b,'c) op2 = (Man.v,'a,'b,'c) Custom.op2
type ('a,'b,'c,'d) op3 = (Man.v,'a,'b,'c,'d) Custom.op3
type ('a,'b) opN = (Man.v,'a,'b) Custom.opN
type ('a,'b) opG = (Man.v,'a,'b) Custom.opG
type ('a,'b) test2 = (Man.v,'a,'b) Custom.test2
type 'a exist = (Man.v,'a) Custom.exist
type 'a existand = (Man.v,'a) Custom.existand
type ('a,'b) existop1 = (Man.v,'a,'b) Custom.existop1
type ('a,'b) existandop1 = (Man.v,'a,'b) Custom.existandop1

let make_op1 = Custom.make_op1
let make_op2 = Custom.make_op2
let make_op3 = Custom.make_op3
let make_opN = Custom.make_opN
let make_opG = Custom.make_opG
let make_test2 = Custom.make_test2
let make_exist = Custom.make_exist
let make_existand = Custom.make_existand
let make_existop1 = Custom.make_existop1
let make_existandop1 = Custom.make_existandop1

let apply_op1 = Custom.apply_op1
let apply_op2 = Custom.apply_op2
let apply_op3 = Custom.apply_op3
let apply_opN = Custom.apply_opN
let apply_opG = Custom.apply_opG
let apply_test2 = Custom.apply_test2
let apply_exist = Custom.apply_exist
let apply_existand = Custom.apply_existand
let apply_existop1 = Custom.apply_existop1
let apply_existandop1 = Custom.apply_existandop1

let clear_op1 = Custom.clear_op1
let clear_op2 = Custom.clear_op2
let clear_op3 = Custom.clear_op3
let clear_opN = Custom.clear_opN
let clear_opG = Custom.clear_opG
let clear_test2 = Custom.clear_test2
let clear_exist = Custom.clear_exist
let clear_existand = Custom.clear_existand
let clear_existop1 = Custom.clear_existop1
let clear_existandop1 = Custom.clear_existandop1

let map_op1 = Custom.map_op1
let map_op2 = Custom.map_op2
let map_op3 = Custom.map_op3
let map_opN = Custom.map_opN
let map_test2 = Custom.map_test2
