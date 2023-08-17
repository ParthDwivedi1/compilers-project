%{
// This part goes directly into the generated parser

#include "scanner.hh"
#include "parser.tab.hh"

// YY_DECL is bound to the type of the scanner. The default is 
// #define YY_DECL int Scanner::yylex()
// which is generated anyway.

//If you want the type of the generated scanner to be different, do this

#undef  YY_DECL
#define YY_DECL int IPL::Scanner::yylex( IPL::Parser::semantic_type * const lval, IPL::Parser::location_type *location )

//We want these to be the first action after a token is recognized. 

#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

// token_type is a short hand for IPL::Parser::token

typedef IPL::Parser::token token_type;

%}


/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++

%%

%{ /** Code executed at the beginning of yylex **/

      yylval = lval;

%}
\/\*.*?\*\/                                             //skip
[ \t]                                                     //skip                                         return ':';    
"\n"                                                      //skip
"||"                                                      return token_type::OR_OP;
"&&"                                                      return token_type::AND_OP;
"=="                                                      return token_type::EQ_OP;
"!="                                                      return token_type::NE_OP;
"++"                                                      return token_type::INC_OP;
"<="                                                      return token_type::LE_OP;
">="                                                      return token_type::GE_OP;
"->"                                                      return token_type::PTR_OP;
"+"                                                       return '+';
"-"                                                       return '-';
"*"                                                       return '*';
"/"                                                       return '/';
","                                                       return ',';
"("                                                       return '(';
")"                                                       return ')';
"{"                                                       return '{';
"}"                                                       return '}';
"["                                                       return '[';
"]"                                                       return ']';
";"                                                       return ';';
"="                                                       return '=';
"!"                                                       return '!';
"&"                                                       return '&';
"<"                                                       return '<';
">"                                                       return '>';
"\."                                                      return '.';
([1-9][0-9]*)|(0[bB][01]*)|(0[0-7]*)|(0[xX][0-9a-fA-F]*)  {yylval->emplace< std::string >( YYText() ); return token_type::INT_CONSTANT;}
([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?       {yylval->emplace< std::string >( YYText() ); return token_type::FLOAT_CONSTANT;}
\"((\\t)|(\\n)|(\\\\)|(\\\")|([^\\\"]))*\"                {yylval->emplace< std::string >( YYText() ); return token_type::STRING_LITERAL;}
"while"                                                   return token_type::WHILE;
"for"                                                     return token_type::FOR;
"void"                                                    return token_type::VOID;
"int"                                                     return token_type::INT;
"float"                                                   return token_type::FLOAT;
"return"                                                  return token_type::RETURN;
"struct"                                                  return token_type::STRUCT;
"if"                                                      return token_type::IF;
"else"                                                    return token_type::ELSE;
[a-zA-Z_]([a-zA-Z_0-9])*                                  {yylval->emplace< std::string >( YYText() ); return token_type::IDENTIFIER;}
<<EOF>>                                                   yyterminate();
.				                                  {yylval->emplace< std::string >( YYText() ); return token_type::OTHERS;}
%%

