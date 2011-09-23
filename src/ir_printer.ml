open Ir
open Printf

let rec string_of_val_type = function
  | Int(w) -> sprintf "i%d" w
  | UInt(w) -> sprintf "u%d" w
  | Float(w) -> sprintf "f%d" w
  | IntVector(w, n) -> sprintf "i%dx%d" w n
  | UIntVector(w, n) -> sprintf "u%dx%d" w n
  | FloatVector(w, n) -> sprintf "f%dx%d" w n

and string_of_op = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"

and string_of_cmp = function
  | EQ -> "=="
  | NE -> "!="
  | LT -> "<"
  | LE -> "<="
  | GT -> ">"
  | GE -> ">="

and string_of_expr = function
  | IntImm(i) -> string_of_int i
  | UIntImm(i) -> string_of_int i ^ "u"
  | FloatImm(f) -> string_of_float f
  | Cast(t, e) -> "cast" ^ "<" ^ string_of_val_type t ^ ">" ^ "(" ^ string_of_expr e ^")"
  | Bop(op, l, r) -> "(" ^ string_of_expr l ^ string_of_op op ^ string_of_expr r ^ ")"
  | Cmp(op, l, r) -> "(" ^ string_of_expr l ^ string_of_cmp op ^ string_of_expr r ^ ")"
  | Select(c, t, f) ->
    "(" ^ string_of_expr c ^ "?" ^ string_of_expr t ^ ":" ^ string_of_expr f ^ ")"
  | Var(s) -> s
  | Load(t, b, i) -> "load(" ^ string_of_val_type t ^ "," ^ string_of_buffer b ^ "[" ^ string_of_expr i ^ "])"
  | Call(name, t, args) -> name ^ "<" ^ string_of_val_type t ^ ">(" ^ (String.concat ", " (List.map string_of_expr args)) ^ ")"
  | MakeVector l -> "vec[" ^ (String.concat ", " (List.map string_of_expr l)) ^ "]"
  | Broadcast(e, n) -> "[" ^ string_of_expr e ^ "x" ^ string_of_int n ^ "]"
  | ExtractElement(a, b) -> "(" ^ string_of_expr a ^ "@" ^ string_of_expr b ^ ")"
  | _ -> "<<UNHANDLED>>"

and string_of_stmt = function
  (*  | If(e, s) -> "if (" ^ string_of_expr e ^ ") " ^ string_of_stmt s *)
  (* | IfElse(e, ts, fs) -> "if (" ^ string_of_expr e ^ ") " ^ string_of_stmt ts ^ 
                         " else " ^ string_of_stmt fs *)
  | Map(n, min, max, s) -> sprintf "map (%s from %s to %s) %s" n (string_of_expr min) (string_of_expr max) (string_of_stmt s)
  | Block(stmts) -> "{" ^ "\n" ^
                    String.concat ";\n" (List.map string_of_stmt stmts) ^
                    "\n}" ^ "\n"
  (* | Reduce(op, e, mr) -> string_of_memref mr ^ string_of_reduce_op op ^ string_of_expr e *)
  | Store(e, b, i) -> string_of_buffer b ^ "[" ^ string_of_expr i ^ "] = " ^ string_of_expr e
  | Let(name, ty, size, produce, consume) -> 
    "let " ^ name ^ "[" ^ string_of_expr size ^ "]\n defined by: " ^ string_of_stmt produce ^ "\n in: " ^ string_of_stmt consume

(*
and string_of_reduce_op = function
  | AddEq -> "+="
  | SubEq -> "-="
  | MulEq -> "*="
  | DivEq -> "/="
 *)

and string_of_buffer b = b

and string_of_toplevel (a, s) = "func(" ^ String.concat ", " (List.map string_of_arg a) ^ ") = " ^ (string_of_stmt s)

and string_of_arg = function 
  | Buffer (b) -> b
  | Scalar (s, t) -> (string_of_val_type t) ^ " " ^ s
