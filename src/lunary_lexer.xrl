% The Definitions section defines regexps for each token.

Definitions.

INT        = [0-9]+
NAME       = [@a-zA-Z_][a-zA-Z0-9_]*[?!]*
COMMENT    = #.*
ATOM       = :{NAME}
STRING     = "(\\\"|[^\"]|\\.)*"
WHITESPACE = [\s\t\f\v]
NEWLINE    = [\r\n]
NEWLINE_WS = ({WHITESPACE}*{NEWLINE}+)
URI        = {NAME}(/{NAME})*
NIL        = nil
BOOL       = true|false
AND        = and
OR         = or
XOR        = xor
NOT        = not
FUNC       = fn
MOD        = mod
USE        = use
AT         = at
FROM       = from
KERNEL_MOD = @kernel

% The Rule section defines what to return for each token. Typically you'd
% want the TokenLine and the TokenChars to capture the matched
% expression.

Rules.

\|>           : {token, {'|>', TokenLine}}.
\+            : {token, {'+', TokenLine}}.
\-            : {token, {'-', TokenLine}}.
\*            : {token, {'*', TokenLine}}.
\/            : {token, {'/', TokenLine}}.
\=            : {token, {'=', TokenLine}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
\[            : {token, {'[', TokenLine}}.
\]            : {token, {']', TokenLine}}.
\:            : {token, {':', TokenLine}}.
\::           : {token, {'::', TokenLine}}.
\.            : {token, {'.', TokenLine}}.
\&            : {token, {'&', TokenLine}}.
{KERNEL_MOD}  : {token, {kernel_mod, TokenLine}}.
% \@            : {token, {'@', TokenLine}}.
\->           : {token, {'->', TokenLine}}.
\,            : {token, {',', TokenLine}}.
{FUNC}        : {token, {'fn', TokenLine}}.
{MOD}         : {token, {'mod', TokenLine}}.
\|            : {token, {'|', TokenLine}}.
\~            : {token, {'~', TokenLine}}.
{AT}          : {token, {at, TokenLine}}.  
{USE}         : {token, {use, TokenLine}}.
{FROM}        : {token, {from, TokenLine}}.
{NIL}         : {token, {nil, TokenLine}}.
{AND}         : {token, {'and', TokenLine}}.
{OR}          : {token, {'or', TokenLine}}.
{XOR}         : {token, {'xor', TokenLine}}.
{NOT}         : {token, {'not', TokenLine}}. 
{BOOL}        : {token, {bool, TokenLine, list_to_atom(TokenChars)}}.
{NAME}        : {token, {identifier, TokenLine, list_to_binary(TokenChars)}}.
{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
% {MODULE}      : {token, {module_ref, TokenLine, list_to_binary(TokenChars)}}.
{INT}         : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{URI}         : {token, {uri, TokenLine, list_to_binary(TokenChars)}}.
{STRING}      : {token, process_string(TokenChars, TokenLine)}.
{COMMENT}     : {token, {comment, TokenLine, process_comment(TokenChars)}}.
{NEWLINE_WS}+ : {token, {newline, TokenLine}}.
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

unescape_string(Bin) ->
    % Convert to list for easier character handling
    Chars = binary_to_list(Bin),
    Unescaped = unescape_chars(Chars),
    list_to_binary(Unescaped).

unescape_chars([$\\, $" | Rest]) -> [$" | unescape_chars(Rest)];
unescape_chars([$\\, $\\ | Rest]) -> [$\\ | unescape_chars(Rest)];
unescape_chars([$\\, $n | Rest]) -> [$\n | unescape_chars(Rest)];
unescape_chars([$\\, $t | Rest]) -> [$\t | unescape_chars(Rest)];
unescape_chars([$\\, $r | Rest]) -> [$\r | unescape_chars(Rest)];
unescape_chars([C | Rest]) -> [C | unescape_chars(Rest)];
unescape_chars([]) -> [].

process_string(Chars, TokenLine) ->
    Bin = unicode:characters_to_binary(Chars),
    Content = binary:part(Bin, 1, byte_size(Bin)-2),
    Unescaped = unescape_string(Content),
    case re:split(Unescaped, "(\\#\\{[^}]*\\})", [{return, binary}, {parts, 0}]) of
        [Single] -> 
            {string, TokenLine, Single};
        Parts ->
            Res = lists:map(fun(Part) ->
                case re:run(Part, "^\\#\\{(.*)\\}$", [{capture, [1], binary}]) of
                    {match, [Expr]} -> 
                        {string_interp, TokenLine, Expr};
                    nomatch -> 
                        {string, TokenLine, Part}
                end
            end, Parts),
            {template_string, TokenLine, Res}
    end.
