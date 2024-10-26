//////////////////////////////////////////////////////////////////////
//
//    Asl - Another simple language (grammar)
//
//    Copyright (C) 2017-2022  Universitat Politecnica de Catalunya
//
//    This library is free software; you can redistribute it and/or
//    modify it under the terms of the GNU General Public License
//    as published by the Free Software Foundation; either version 3
//    of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//    contact: José Miguel Rivero (rivero@cs.upc.edu)
//             Computer Science Department
//             Universitat Politecnica de Catalunya
//             despatx Omega.110 - Campus Nord UPC
//             08034 Barcelona.  SPAIN
//
//////////////////////////////////////////////////////////////////////

grammar Asl;

//////////////////////////////////////////////////
/// Parser Rules
//////////////////////////////////////////////////

// A program is a list of functions
program : function+ EOF
        ;

// A function has a name, a list of parameters and a list of statements
function
        : FUNC ID '(' ')' declarations statements ENDFUNC
        ;

declarations
        : (variable_decl)*
        ;

variable_decl
        : VAR ID ':' type
        ;

type    : INT
        | BOOL
        | FLOAT
        | CHAR
        ;

statements
        : (statement)*
        ;

// The different types of instructions
statement
          // Assignment
        : left_expr ASSIGN expr ';'           # assignStmt
          // if-then-else statement (else is optional)
        | IF expr THEN statements ENDIF       # ifStmt
          // A function/procedure call has a list of arguments in parenthesis (possibly empty)
        | ident '(' ')' ';'                   # procCall
          // Read a variable
        | READ left_expr ';'                  # readStmt
          // Write an expression
        | WRITE expr ';'                      # writeExpr
          // Write a string
        | WRITE STRING ';'                    # writeString
        ;

// Grammar for left expressions (l-values in C++)
left_expr
        : ident
        ;

// Grammar for expressions with boolean, relational and aritmetic operators
expr    : expr op=MUL expr                    # arithmetic
        | expr op=PLUS expr                   # arithmetic
        | expr op=MINUS expr                  # arithmetic
        | expr op=DIV expr                    # arithmetic
        | op=MINUS expr                       # unitariMinus
        | OP expr CP                          # parentesis
        | expr op=OR expr                     # boolean
        | expr op=AND expr                    # boolean 
        | op=NOT expr                         # not
        | expr op=EQUAL expr                  # relational
        | expr op=GL expr                     # relational
        | expr op=GLE expr                    # relational
        | expr op=GT expr                     # relational
        | expr op=GTE expr                    # relational
        | (INTVAL|CHARVAL|FLOATVAL)           # value
        | ident                               # exprIdent
        ;

// Identifiers
ident   : ID
        ;

//////////////////////////////////////////////////
/// Lexer Rules
//////////////////////////////////////////////////

ASSIGN    : '=' ;
EQUAL     : '==' ;
GL        : '<' ;
GLE       : '<=' ;
GT        : '>' ;
GTE       : '>=' ;
PLUS      : '+' ;
MINUS     : '-' ;
DIV       : '/' ;
MUL       : '*';
OP        : '(' ;
CP        : ')' ;
VAR       : 'var';
INT       : 'int';
BOOL      : 'bool';
FLOAT     : 'float';
CHAR      : 'char';
OR        : 'or' ;
AND       : 'and' ;
NOT       : 'not' ;
IF        : 'if' ;
THEN      : 'then' ;
ELSE      : 'else' ;
ENDIF     : 'endif' ;
FUNC      : 'func' ;
ENDFUNC   : 'endfunc' ;
READ      : 'read' ;
WRITE     : 'write' ;
ID        : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')* ;
INTVAL    : DIGIT+ ;
CHARVAL   : ('a'..'z'|'A'..'Z')+ ;
FLOATVAL  : SIMBOL (AMB_PUNT | SENSE_PUNT) ;
AMB_PUNT  : DIGIT* '.' DIGIT+ ;
SENSE_PUNT: DIGIT+ ;
SIMBOL    : '+' | '-' |  ;
DIGIT     : '0'..'9' ;

// Strings (in quotes) with escape sequences
STRING    : '"' ( ESC_SEQ | ~('\\'|'"') )* '"' ;

fragment
ESC_SEQ   : '\\' ('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\') ;

// Comments (inline C++-style)
COMMENT   : '//' ~('\n'|'\r')* '\r'? '\n' -> skip ;

// White spaces
WS        : (' '|'\t'|'\r'|'\n')+ -> skip ;
// Alternative description
// WS        : [ \t\r\n]+ -> skip ;
