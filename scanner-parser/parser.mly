/* Ocamlyacc parser for Propeller */

%{ open Ast %}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA FN ARROW ASSIGN PLUS MINUS TIMES DIVIDE MODULO
%token INT BOOL FLOAT STR VOID
%token <int> ILIT
%token <float> FLIT
%token <bool> BLIT
%token <string> SLIT
%token <string> ID
%token EOF

%start program
%type <Ast.program> program

%right ASSIGN
%left PLUS MINUS
%left TIMES DIVIDE MODULO

%%

program:
    decls EOF { $1 }

decls:
    /* nothing */ { ([], [])               }
  | decls vdecl   { (($2 :: fst $1), snd $1) }
  | decls fdecl   { (fst $1, ($2 :: snd $1)) }

fdecl:
  FN ID LPAREN formals_opt RPAREN ARROW ftyp LBRACE vdecl_list stmt_list RBRACE
    { { typ     = $7;
        fname   = $2;
        formals = List.rev $4;
        locals  = List.rev $9;
        body    = List.rev $10 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    vtyp ID                   { [($1, $2)] }
  | formal_list COMMA vtyp ID { ($3, $4) :: $1 }

vtyp:
    INT   { Int }
  | BOOL  { Bool }
  | FLOAT { Float}
  | STR   { Str }

ftyp:
    INT   { Int }
  | BOOL  { Bool }
  | FLOAT { Float}
  | STR   { Str }
  | VOID  { Void }

vdecl_list:
    /* nothing */ { [] }
  | vdecl_list vdecl { $2 :: $1 }
  
vdecl:
    vtyp ID SEMI { ($1, $2) }

stmt_list:
    /* nothing */ { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr($1) }

expr:
    ILIT { Iliteral($1) }
  | FLIT { Fliteral($1) }
  | BLIT { Bliteral($1) }
  | SLIT { Sliteral($1) }
  | ID { Id($1) }
  | expr PLUS   expr { Binop($1, Add, $3)   }
  | expr MINUS  expr { Binop($1, Sub, $3)   }
  | expr TIMES  expr { Binop($1, Mlt, $3)   }
  | expr DIVIDE expr { Binop($1, Div, $3)   }
  | expr MODULO expr { Binop($1, Mod, $3) }
  | ID ASSIGN expr { Assign($1, $3) }
  | LPAREN expr RPAREN { $2 }