% The Definitions section defines regexps for each token.

Definitions.

INT        = [0-9]+
AT         = at
NAME       = [a-zA-Z_][a-zA-Z0-9_]*[?!]*
COMMENT    = #.*
ATOM       = :{NAME}
STRING     = "(\\\"|[^\"]|\\.)*"
WHITESPACE = [\s\t]
NEWLINE    = [\r\n]
URI        = {NAME}(/{NAME})*
NIL        = nil
BOOL       = true|false
AND        = and
OR         = or
XOR        = xor
NOT        = not
FUNC       = fn


% The Rule section defines what to return for each token. Typically you'd
% want the TokenLine and the TokenChars to capture the matched
% expression.


Rules.

\+            : {token, {'+', TokenLine}}.
\-            : {token, {'-', TokenLine}}.
\*            : {token, {'*', TokenLine}}.
\/            : {token, {'/', TokenLine}}.
\=            : {token, {'=', TokenLine}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
\[            : {token, {'[', TokenLine}}.
\]            : {token, {']', TokenLine}}.
\{            : {token, {'{', TokenLine}}.
\}            : {token, {'}', TokenLine}}.
\:            : {token, {':', TokenLine}}.
\::           : {token, {double_colon, '::'}}.
\&            : {token, {'&', TokenLine}}.
\->           : {token, {'->', TokenLine}}.
\,            : {token, {',', TokenLine}}.
{FUNC}        : {token, {'fn', TokenLine}}.
\|            : {token, {'|', TokenLine}}.
\~            : {token, {'~', TokenLine}}.
{AT}          : {token, {at, TokenLine}}.  
{NIL}         : {token, {nil, TokenLine}}.
{AND}         : {token, {'and', TokenLine}}.
{OR}          : {token, {'or', TokenLine}}.
{XOR}         : {token, {'xor', TokenLine}}.
{NOT}         : {token, {'not', TokenLine}}. 
{BOOL}        : {token, {bool, TokenLine, list_to_atom(TokenChars)}}.
{NAME}        : {token, {identifier, TokenLine, list_to_binary(TokenChars)}}.
{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{INT}         : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{URI}         : {token, {uri, TokenLine, list_to_binary(TokenChars)}}.
{STRING}      : {token, process_string(TokenChars, TokenLine)}.
{COMMENT}     : {token, {comment, TokenLine, process_comment(TokenChars)}}.
{NEWLINE}+    : {token, {newline, TokenLine}}.
{WHITESPACE}+ : skip_token.


% The Erlang code section (which is mandatory), is where you can add
% erlang functions you can call in the Definitions. In this case we
% have a to_token to create a token for each named variable (this is
% not good style, but just to show how to use the code section).

Erlang code.

to_atom([$:|Chars]) ->
    list_to_atom(Chars).

process_comment(Chars) ->
    Bin = unicode:characters_to_binary(Chars),
    Content = binary:part(Bin, 1, byte_size(Bin)-2),
    Content.

process_string(Chars, TokenLine) ->
    Bin = unicode:characters_to_binary(Chars),
    Content = binary:part(Bin, 1, byte_size(Bin)-2),
    case re:split(Content, "(\\{[^}]*\\})", [{return, binary}, {parts, 0}]) of
        [Single] -> 
            {string, TokenLine, Single};
        Parts ->
            Res = lists:map(fun(Part) ->
                case re:run(Part, "^\\{(.*)\\}$", [{capture, [1], binary}]) of
                    {match, [Expr]} -> 
                        {string_interp, TokenLine, Expr};
                    nomatch -> 
                        {string, TokenLine, Part}
                end
            end, Parts),
            {template_string, TokenLine, Res}
    end.