/* TaskScan v2 (v1 + escape fix) -- scanner for the "task command" language (Lab01 JFlex project). */
package taskscan;

%%

%public
%class TaskScanner
%unicode
%line
%column
%type Token

%{
  /** Build a token; JFlex counters are 0-based, so add 1 for display. */
  private Token tok(TokenType t) {
    return new Token(t, yytext(), yyline + 1, yycolumn + 1, null);
  }
  private Token err(String msg) {
    return new Token(TokenType.ERROR, yytext(), yyline + 1, yycolumn + 1, msg);
  }
%}

%eofval{
  return new Token(TokenType.EOF, "<EOF>", yyline + 1, yycolumn + 1, null);
%eofval}

/* ---- named macros ---- */
Letter      = [A-Za-z_]
Digit       = [0-9]
Identifier  = {Letter}({Letter}|{Digit})*
Integer     = {Digit}+
Newline     = \r\n | \n | \r
Blank       = [ \t\f]
Comment     = "#" [^\r\n]*
/* v2: a backslash escapes the next character, so \" does not end the string */
StringChar  = [^\"\\\r\n] | \\ [^\r\n]
String      = \" {StringChar}* \"
BadString   = \" {StringChar}*

%%

/* keywords must come BEFORE Identifier: same length -> earliest rule wins */
"add" | "done" | "remove" | "list" | "show" | "where"  { return tok(TokenType.KEYWORD); }

{Identifier}   { return tok(TokenType.IDENTIFIER); }
{Integer}      { return tok(TokenType.INTEGER); }
{String}       { return tok(TokenType.STRING); }

"=="  { return tok(TokenType.EQ); }
"!="  { return tok(TokenType.NE); }
"<="  { return tok(TokenType.LE); }
">="  { return tok(TokenType.GE); }
"="   { return tok(TokenType.ASSIGN); }
"<"   { return tok(TokenType.LT); }
">"   { return tok(TokenType.GT); }
";"   { return tok(TokenType.SEMICOLON); }
","   { return tok(TokenType.COMMA); }

{Blank} | {Newline} | {Comment}   { /* skipped */ }

{BadString}    { return err("unterminated string literal"); }
[^]            { return err("unexpected character '" + yytext() + "'"); }
