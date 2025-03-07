Nonterminals
  root
  statement
  statements
  assignment
  fdef
  anon_fdef
  fparam
  fparams
  fcall
  farg
  fargs
  fassignment
  const_block
  expr
  array
  array_elements
  import
  module
  uri_path
  enum
  map
  map_element
  map_elements
  logic
  chain
.

Terminals
  template_string
  identifier
  int
  atom
  uri
  use
  at
  from
  and
  or
  xor
  not
  fn
  nil
  bool
  string
  newline
  comment
  '::'
  '.'
  '#'
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
  '&'
  '_'
  '~'
  '|>'
.

Rootsymbol
   root
.

Right 50 '='.
Right 100 '|>'.
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
 
% statement -> assignment newline : ['$1'].
statement -> assignment : ['$1'].
statement -> chain newline : ['$1'].
statement -> chain : ['$1'].
statement -> module newline : ['$1'].
statement -> module : ['$1'].
statement -> const_block newline : ['$1'].
statement -> const_block : ['$1'].
statement -> expr newline : ['$1'].
statement -> expr : ['$1'].
statement -> fassignment newline : ['$1'].
statement -> fassignment : ['$1'].
statement -> fdef newline : ['$1'].
statement -> fdef : ['$1'].
statement -> comment newline : ['$1'].
statement -> comment : ['$1'].

module -> use identifier from expr : {module, '$2', '$4'}.

const_block -> '::' '(' ')' : {const_block, []}.
const_block -> '::' '(' map_elements newline ')' : {const_block, '$3'}.
const_block -> '::' '(' map_elements ')' : {const_block, '$3'}.

fdef -> fn identifier '->' '(' statements ')' : {fdef, '$2', [], '$5'}.
fdef -> fn identifier fparams '->' '(' statements ')' : {fdef, '$2', '$3', '$6'}.
fdef -> fn identifier '(' fparams ')' '->' '(' statements ')' : {fdef, '$2', '$4', '$8'}.

anon_fdef -> fn fparams '->' '(' statements ')' : {anon_fdef, '$2', '$5'}.
anon_fdef -> fn '(' fparams ')' '->' '(' statements ')' : {anon_fdef, '$3', '$7'}.

chain -> chain '|>' identifier : {chain, '$1', {fn, '$3', []}}.
chain -> chain newline '|>' identifier : {chain, '$1', {fn, '$4', []}}.
chain -> chain '|>' fcall : {chain, '$1', '$3'}.
chain -> chain newline '|>' fcall : {chain, '$1', '$4'}.
chain -> expr '|>' identifier : {chain, '$1', {fn, '$3', []}}.
chain -> expr newline '|>' identifier : {chain, '$1', {fn, '$4', []}}.
chain -> expr '|>' fcall : {chain, '$1', '$3'}.
chain -> expr newline '|>' fcall : {chain, '$1', '$4'}.

fparams -> fparam : ['$1'].
fparams -> fparam ',' fparams : ['$1' | '$3'].
fparam -> identifier : '$1'.

fcall -> identifier fargs : {fn, '$1', '$2'}.
fcall -> identifier '(' fargs ')' : {fn, '$1', '$3'}.
fcall -> enum fargs : {fn, '$1', '$2'}.
fcall -> enum '(' fargs ')' : {fn, '$1', '$3'}.

fcall -> '::' identifier fargs : {const_fn, '$2', '$3'}.
fcall -> '::' identifier '(' fargs ')' : {const_fn, '$2', '$4'}.

fargs -> farg : ['$1'].
fargs -> farg ',' fargs : ['$1' | '$3'].
farg -> expr : '$1'.

fassignment -> identifier '=' anon_fdef newline : {fassign, '$1', '$3'}.
assignment -> identifier '=' chain newline : {assign, '$1', '$3'}.
assignment -> identifier '=' expr newline : {assign, '$1', '$3'}.

import -> '&' identifier : {import, '$2'}.
import -> '&' uri_path : {import, '$2'}.

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

map_element -> expr ':' anon_fdef : ['$1', '$3'].
map_element -> expr ':' expr : ['$1', '$3'].

uri_path -> uri : '$1'.

enum -> expr at expr : {access, '$1', '$3'}.
enum -> expr from expr : {access, '$3', '$1'}.
enum -> expr '.' expr : {access, '$1', '$3'}.
% enum -> identifier at expr : {access, '$1', '$3'}.
enum -> string at expr : {access, '$1', '$3'}.
enum -> template_string : '$1'.
enum -> string : unwrap('$1').
% enum -> array at expr : {access, '$1', '$3'}.
enum -> array : '$1'.
% enum -> map at expr : {access, '$1', '$3'}.
enum -> map : '$1'.

logic -> not expr : {'not', '$2'}.
logic -> expr and expr : {'and', '$1', '$3'}.
logic -> expr or expr : {'or', '$1', '$3'}.
logic -> expr xor expr : {'xor', '$1', '$3'}.

expr -> fcall : '$1'.
expr -> '(' expr ')' : '$2'.
expr -> enum : '$1'.
expr -> int : unwrap('$1').
expr -> '-' expr : {negate, '$2'}.
expr -> nil : {nil}.
expr -> bool : '$1'.
expr -> atom : '$1'.
expr -> identifier : '$1'.
expr -> '::' identifier : {const_ref, '$2'}.
expr -> import : '$1'.
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
