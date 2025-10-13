Nonterminals
  root
  statement
  statements
  assignment
  inline_assignment
  fdef
  anon_fdef
  fparam
  fparams
  fcall
  farg
  fargs
  const_block
  expr
  array
  array_elements
  moddef
  kmodcall
  mod_load
  uri_path
  enum
  map
  map_element
  map_elements
  logic
  chain
  for_loop
  comparison
  enum_assignment
.

Terminals
  template_string
  identifier
  compare
  int
  atom
  uri
  use
  at
  from
  if
  unless
  for
  and
  or
  xor
  not
  in
  fn
  mod
  nil
  bool
  string
  newline
  comment
  kernel_mod
  '::'
  '.'
  '('
  ')'
  '['
  ']'
  ':'
  '+'
  '-'
  '*'
  '/'
  '='
  ','
  '->'
  '<-'
  '&'
  '~'
  '|>'
.

Rootsymbol
   root
.

Right 50 '='.
Right 100 '|>'.
Left 100 '->'.
Left 200 'at'.
Left 200 'from'.
Left 250 '~'.
Left 300 'and'.
Left 400 '+' '-'.
Left 500 '*' '/'.
Left 550 '.'.
Left 600 '(' ')'.

root -> statements : '$1'.

statements -> newline statements newline : ['$2'].
statements -> newline statements : ['$2'].
statements -> statement statements : ['$1' | '$2'].
statements -> statement : ['$1'].
 
statement -> inline_assignment 'if' expr newline : [{if_statement, '$1', '$3'}].
statement -> inline_assignment 'if' expr : [{if_statement, '$1', '$3'}].
statement -> inline_assignment 'unless' expr newline : [{unless_statement, '$1', '$3'}].
statement -> inline_assignment 'unless' expr : [{unless_statement, '$1', '$3'}].
statement -> assignment newline : ['$1'].
statement -> assignment : ['$1'].
statement -> enum_assignment newline : ['$1'].
statement -> enum_assignment : ['$1'].
statement -> chain newline : ['$1'].
statement -> chain : ['$1'].
statement -> mod_load newline : ['$1'].
statement -> mod_load : ['$1'].
statement -> const_block newline : ['$1'].
statement -> const_block : ['$1'].
statement -> expr newline : ['$1'].
statement -> expr : ['$1'].
statement -> fdef newline : ['$1'].
statement -> fdef : ['$1'].
statement -> moddef newline : ['$1'].
statement -> moddef : ['$1'].
statement -> comment newline : ['$1'].
statement -> comment : ['$1'].

kmodcall -> kernel_mod '.' identifier '(' fargs ')' : {kfcall, '$1', '$3', '$5'}.
kmodcall -> kernel_mod '.' identifier fargs : {kfcall, '$1', '$3', '$4'}.

mod_load -> use identifier : {module_load, '$2'}.

moddef -> 'mod' identifier '(' statements ')' : {moddef, '$2', '$4'}.

const_block -> '::' '(' ')' : {const_block, []}.
const_block -> '::' '(' map_elements newline ')' : {const_block, '$3'}.
const_block -> '::' '(' map_elements ')' : {const_block, '$3'}.

fdef -> fn identifier '->' '(' statements ')' : {fdef, '$2', [], '$5'}.
fdef -> fn identifier fparams '->' '(' statements ')' : {fdef, '$2', '$3', '$6'}.
fdef -> fn identifier '(' fparams ')' '->' '(' statements ')' : {fdef, '$2', '$4', '$8'}.

anon_fdef -> fn '->' '(' statements ')' : {anon_fdef, [], '$4'}.
anon_fdef -> fn fparams '->' '(' statements ')' : {anon_fdef, '$2', '$5'}.
anon_fdef -> fn '(' fparams ')' '->' '(' statements ')' : {anon_fdef, '$3', '$7'}.

chain -> chain '|>' identifier : {chain, '$1', {fn, '$3', []}}.
chain -> chain newline '|>' identifier : {chain, '$1', {fn, '$4', []}}.
chain -> chain '|>' fcall : {chain, '$1', '$3'}.
chain -> chain newline '|>' fcall : {chain, '$1', '$4'}.
chain -> chain '|>' expr : {chain, '$1', '$3'}.
chain -> chain newline '|>' expr : {chain, '$1', '$4'}.

chain -> expr '|>' identifier : {chain, '$1', {fn, '$3', []}}.
chain -> expr newline '|>' identifier : {chain, '$1', {fn, '$4', []}}.
chain -> expr '|>' fcall : {chain, '$1', '$3'}.
chain -> expr newline '|>' fcall : {chain, '$1', '$4'}.
chain -> expr '|>' expr : {chain, '$1', '$3'}.
chain -> expr newline '|>' expr : {chain, '$1', '$4'}.

fparams -> fparam : ['$1'].
fparams -> fparam ',' fparams : ['$1' | '$3'].
fparam -> identifier : '$1'.

fcall -> identifier '(' fargs ')' : {fn, '$1', '$3'}.
fcall -> identifier '(' ')' : {fn, '$1', []}.
% fcall -> identifier fargs : {fn, '$1', '$2'}.

% fcall -> enum fargs : {fn, '$1', '$2'}.
% fcall -> enum '(' fargs ')' : {fn, '$1', '$3'}.

fcall -> '::' identifier fargs : {const_fn, '$2', '$3'}.
fcall -> '::' identifier '(' fargs ')' : {const_fn, '$2', '$4'}.

fargs -> farg : ['$1'].
fargs -> farg ',' fargs : ['$1' | '$3'].
farg -> expr : '$1'.

for_loop -> 'for' identifier 'in' expr '->' '(' statements ')' : {for_loop, '$2', '$4', '$7'}.

inline_assignment -> identifier '=' chain : {assign, '$1', '$3'}.
inline_assignment -> identifier '=' expr : {assign, '$1', '$3'}.
inline_assignment -> identifier '=' enum_assignment : {assign, '$1', '$3'}.
% assignment -> identifier '=' expr 'if' expr : {assign_if, '$1', '$3', '$5'}.
assignment -> identifier '=' chain newline : {assign, '$1', '$3'}.
% assignment -> identifier '=' chain newline : {assign, '$1', '$3'}.
assignment -> identifier '=' expr newline : {assign, '$1', '$3'}.
assignment -> identifier '=' enum_assignment newline : {assign, '$1', '$3'}.

% import -> '&' identifier : {import, '$2'}.
% import -> '&' uri_path : {import, '$2'}.

array -> '[' ']' : {list, []}.
array -> '[' array_elements ']' : {list, '$2'}.
array -> '[' newline array_elements ']' : {list, '$3'}.
array_elements -> expr : ['$1'].
array_elements -> expr newline : ['$1'].
array_elements -> expr ',' array_elements : ['$1' | '$3'].
array_elements -> expr ',' newline array_elements : ['$1' | '$4'].

map -> '(' ')' : {map, []}.
map -> '(' map_elements newline ')' : {map, '$2'}.
map -> '(' map_elements ')' : {map, '$2'}.

map_elements -> newline map_element ',' map_elements : ['$2' | '$4'].
map_elements -> map_element ',' map_elements : ['$1' | '$3'].
map_elements -> map_element : ['$1'].
map_elements -> newline map_element : ['$2'].

% map_element -> expr ':' anon_fdef : ['$1', '$3'].
map_element -> expr ':' expr : ['$1', '$3'].

uri_path -> uri : '$1'.

enum_assignment -> expr at expr '<-' expr : {assign_enum, {access, '$1', '$3'}, '$5'}.

enum -> expr at expr : {access, '$1', '$3'}.
enum -> expr from expr : {access, '$3', '$1'}.
% enum -> fcall '.' identifier : {atom_access, '$1', '$3'}.
enum -> expr '.' fcall : {func_access, '$1', '$3'}.
enum -> expr '.' identifier : {atom_access, '$1', '$3'}.
% enum -> expr '.' expr : {access, '$1', '$3'}.
% enum -> identifier at expr : {access, '$1', '$3'}.
enum -> string at expr : {access, '$1', '$3'}.
enum -> template_string : '$1'.
enum -> string : unwrap('$1').
% enum -> array at expr : {access, '$1', '$3'}.
enum -> array : '$1'.
% enum -> map at expr : {access, '$1', '$3'}.
enum -> map : '$1'.

comparison -> expr compare expr : {compare, '$2', '$1', '$3'}.

logic -> not expr : {'not', '$2'}.
logic -> expr and expr : {'and', '$1', '$3'}.
logic -> expr or expr : {'or', '$1', '$3'}.
logic -> expr xor expr : {'xor', '$1', '$3'}.

expr -> kmodcall : '$1'.
expr -> fcall : '$1'.
expr -> for_loop : '$1'.
expr -> comparison : '$1'.
expr -> anon_fdef : '$1'.
expr -> enum : '$1'.
expr -> '(' expr ')' : '$2'.
expr -> int : unwrap('$1').
expr -> '-' expr : {negate, '$2'}.
expr -> nil : {nil}.
expr -> bool : '$1'.
expr -> atom : '$1'.
expr -> identifier : '$1'.
expr -> '::' identifier : {const_ref, '$2'}.
% expr -> import : '$1'.
expr -> expr '~' expr : {range, '$1', '$3'}.
expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.
expr -> logic : '$1'.

Erlang code.

unwrap({int, Line, Value}) when is_list(Value) -> {int, Line, list_to_integer(Value)};
unwrap({int, Line, Value}) when is_integer(Value) -> {int, Line, Value};
unwrap({string, Line, Value}) -> {string, Line, Value}.
