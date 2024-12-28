% The Definitions section defines regexps for each token.

Definitions.

INT        = [0-9]+
AT         = at
NAME       = [a-zA-Z_][a-zA-Z0-9_]*[?!]*
ATOM       = :{NAME}
UNICODE    = [\x{0000}-\x{10FFFF}]
STRING     = "([^\"]|\\.|{UNICODE})*"
WHITESPACE = [\s\t\n\r]
URI        = {NAME}(/{NAME})*
NIL        = nil


% The Rule section defines what to return for each token. Typically you'd
% want the TokenLine and the TokenChars to capture the matched
% expression.


Rules.

\+            : {token, {'+',  TokenLine}}.
\-            : {token, {'-',  TokenLine}}.
\*            : {token, {'*',  TokenLine}}.
\/            : {token, {'/',  TokenLine}}.
\=            : {token, {'=',  TokenLine}}.
\/\/\(        : {token, {'//(',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
\[            : {token, {'[',  TokenLine}}.
\]            : {token, {']',  TokenLine}}.
\:            : {token, {':',  TokenLine}}.
\::           : {token, {double_colon, '::'}}.
\&            : {token, {'&',  TokenLine}}.
\\>           : {token, {'\\>', TokenLine}}.
\/>           : {token, {'/>', TokenLine}}.
\->           : {token, {'->', TokenLine}}.
\,            : {token, {',',  TokenLine}}.
\|            : {token, {'|',  TokenLine}}.
\~            : {token, {'~',  TokenLine}}.
{AT}          : {token, {at,   TokenLine}}.  
{NIL}         : {token, {nil,  TokenLine}}. 
{NAME}        : {token, {identifier, TokenLine, list_to_binary(TokenChars)}}.
{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{INT}         : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{URI}         : {token, {uri, TokenLine, list_to_binary(TokenChars)}}.
{STRING}      : {token, {string, TokenLine, process_string(TokenChars)}}.
{WHITESPACE}+ : skip_token.


% The Erlang code section (which is mandatory), is where you can add
% erlang functions you can call in the Definitions. In this case we
% have a to_token to create a token for each named variable (this is
% not good style, but just to show how to use the code section).

Erlang code.

to_atom([$:|Chars]) ->
    list_to_atom(Chars).

process_string(Chars) ->
    % Remove surrounding quotes
    Bin = unicode:characters_to_binary(Chars),
    Content = binary:part(Bin, 1, byte_size(Bin)-2),
    % Handle escapes if needed
    Content.