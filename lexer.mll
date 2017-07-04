{
  open Parser

  exception LexicalError of string
}

let var = ['a'-'z'] ['a'-'z' 'A'-'Z' 0-9 _]*
let constr = ['A'-'Z'] ['a'-'z' 'A'-'Z' 0-9 _]*
let comment = "--" [^ '\r' '\n']*

rule read = parse
  | [' ' '\t' '\r' '\n'] { read lexbuf }
  | comment              { read lexbuf }
  | ['0'-'9']+           { INT (int_of_string(Lexing.lexeme lexbuf)) }
  | "Int"                { TINT }
  | "Bool"               { TBOOL }
  | "true"               { TRUE }
  | "false"              { FALSE }
  | "case"          { CASE }
  | "if"            { IF }
  | "then"          { THEN }
  | "else"          { ELSE }
  | "let"           { LET }
  | "in"            { IN }
  | "return"        { RETURN }
  | "handle"        { HANDLE }
  | "with"          { WITH }
  | "do"            { DO }
  | '\\'            { LAMBDA }
  | ";;"            { SEMISEMI }
  | ';'             { SEMI }
  | '"'             {  (read_string (Buffer.create 17) lexbuf)  }
  | '='             { EQUAL }
  | '<'             { LESS }
  | "->"            { TARROW }
  | "=>"            { HARROW }
  | ':'             { COLON }
  | '('             { LPAREN }
  | ')'             { RPAREN }
  | '+'             { PLUS }
  | '-'             { MINUS }
  | '*'             { TIMES }
  | ','             { COMMA }
  | var             { VAR (Lexing.lexeme lexbuf) }
  | constr          { CONSTR (Lexing.lexeme lexbuf) }
  | eof { EOF }

and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | '\\' '"'  { Buffer.add_char buf '"'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (lexeme lexbuf);
      read_string buf lexbuf
    }
  | eof { raise (SyntaxError ("String is not terminated")) }
  | _ { raise (SyntaxError ("Illegal string character: " ^ lexeme lexbuf)) }

and read_multiline_comment =
  parse
  | "-}"      { read lexbuf }
  | eof       { raise (LexicalError ("Comment is not terminated")) }
  | _         { read_multiline_comment lexbuf }