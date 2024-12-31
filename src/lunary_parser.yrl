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
  const_assignment
  const_assignments
  const_block
  expr
  array
  array_elements
  module
  uri_path
  enum
.

Terminals
  double_colon
  identifier
  int
  uri
  at
  fn
  nil
  true
  false
  string
  newline
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
  '|'
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+' '-'.
Left 400 '*' '/'.
Left 500 '(' ')'.

root -> statements : '$1'.

statements -> newline statements : ['$2'].
statements -> statement newline: ['$1'].
statements -> statement statements : ['$1' | '$2'].
statements -> statement : ['$1'].
 
statement -> expr : ['$1'].
statement -> assignment : ['$1'].
statement -> fassignment : ['$1'].
statement -> const_block : ['$1'].
statement -> fdef : ['$1'].

const_block -> double_colon '(' const_assignments ')' : '$3'.

fdef -> fn identifier '->' '(' statements ')' : {fdef, '$2', [], '$5'}.
fdef -> fn identifier fparams '->' '(' statements ')' : {fdef, '$2', '$3', '$6'}.
fdef -> fn identifier '(' fparams ')' '->' '(' statements ')' : {fdef, '$2', '$4', '$8'}.

anon_fdef -> fn fparams '->' '(' statements ')' : {anon_fdef, '$2', '$5'}.
anon_fdef -> fn '(' fparams ')' '->' '(' statements ')' : {anon_fdef, '$3', '$7'}.

fparams -> fparam : ['$1'].
fparams -> fparam ',' fparams : ['$1' | '$3'].
fparam -> identifier : '$1'.

fcall -> identifier fargs : {fn, '$1', '$2'}.
fcall -> identifier '(' fargs ')' : {fn, '$1', '$3'}.

fcall -> double_colon identifier fargs : {const_fn, '$2', '$3'}.
fcall -> double_colon identifier '(' fargs ')' : {const_fn, '$2', '$4'}.

fargs -> farg : ['$1'].
fargs -> farg ',' fargs : ['$1' | '$3'].
farg -> expr : '$1'.

const_assignments -> newline const_assignments : '$2'.
const_assignments -> const_assignment newline: ['$1'].
const_assignments -> const_assignment : ['$1'].
const_assignments -> const_assignment const_assignments : ['$1' | '$2'].

const_assignment -> identifier ':' anon_fdef : {assign_const, '$1', '$3'}.
const_assignment -> identifier ':' expr : {assign_const, '$1', '$3'}.

fassignment -> identifier '=' anon_fdef : {fassign, '$1', '$3'}.
assignment -> identifier '=' expr : {assign, '$1', '$3'}.

module -> '&' identifier : {mod_ref, '$2'}.
module -> '&' uri_path : {mod_ref, '$2'}.

array -> '[' ']' : {array, []}.
array -> '[' array_elements ']' : {array, '$2'}.
array_elements -> expr : ['$1'].
array_elements -> expr ',' array_elements : ['$1' | '$3'].

uri_path -> uri : '$1'.

enum -> string at expr : {access, '$1', '$3'}.
enum -> string : unwrap('$1').
enum -> array at expr : {access, '$1', '$3'}.
enum -> array : '$1'.

expr -> fcall : '$1'.
expr -> int : unwrap('$1').
expr -> enum : '$1'.
expr -> '-' expr : {negate, '$2'}.
expr -> '(' ')' : {nil}.
expr -> '(' expr ')' : '$2'.
expr -> nil : {nil}.
expr -> true : {true}.
expr -> false : {false}.
expr -> identifier : '$1'.
expr -> double_colon identifier : {const_ref, '$2'}.
expr -> module : '$1'.
expr -> expr '~' expr : {range, '$1', '$3'}.
expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.

Erlang code.

unwrap({int, Line, Value}) when is_list(Value) -> {int, Line, list_to_integer(Value)};
unwrap({int, Line, Value}) when is_integer(Value) -> {int, Line, Value};
unwrap({string, Line, Value}) -> {string, Line, Value}.
