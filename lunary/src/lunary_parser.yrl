Nonterminals
  root
  statement
  statements
  assignment
  assignments
  const_assignment
  const_assignments
  const_block
  reference
  expr
.

Terminals
  double_colon
  identifier
  int
  '('
  ')'
  '//('
  ':'
  '+'
  '-'
  '*'
  '/'
  '='
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.

root -> statements : '$1'.

statements -> statement : ['$1'].
statements -> statement statements : ['$1' | '$2'].

statement -> expr : ['$1'].
statement -> assignment : ['$1'].
statement -> const_block : ['$1'].

const_block -> '//(' const_assignments ')' : '$2'.

assignments -> assignment : ['$1'].
assignments -> assignment assignments : ['$1' | '$2'].

const_assignments -> const_assignment : ['$1'].
const_assignments -> const_assignment const_assignments : ['$1' | '$2'].

const_assignment -> identifier ':' expr : {assign, '$1', '$3'}.
assignment -> identifier '=' expr : {assign, '$1', '$3'}.

expr -> int : unwrap('$1').
expr -> identifier : '$1'.
expr -> double_colon identifier : {reference, '$2'}.
expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.

Erlang code.

unwrap({int, Line, Value}) when is_list(Value) -> {int, Line, list_to_integer(Value)};
unwrap({int, Line, Value}) when is_integer(Value) -> {int, Line, Value}.
