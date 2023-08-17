%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{

   namespace IPL {
     class Scanner;
     class symbol_description;
     class abstract_astnode;
     class exp_astnode;
     class statement_astnode;
     class ref_astnode;
     class empty_astnode;
     class seq_astnode;
     class assignS_astnode;
     class return_astnode;
     class if_astnode;
     class while_astnode;
     class for_astnode;
     class proccall_astnode;
     class identifier_astnode;
     class arrayref_astnode;
     class member_astnode;
     class arrow_astnode;
     class op_binary_astnode;
     class op_unary_astnode;
     class assignE_astnode;
     class funcall_astnode;
     class intconst_astnode;
     class floatconst_astnode;
     class stringconst_astnode;
     class Type_specifier;
     class Declarator;
     class Declarator_list;
     class Fun_declarator;
     bool cmp_lst(symbol_description* a, symbol_description*b);
     //std::string reference(std::string);
     //std::string dereference(std::string);
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } OTHERS

%parse-param { Scanner  &scanner  }
%locations
%code{
     #include <iostream>
     #include <cstdlib>
     #include <fstream>
     #include <string>
     #include <vector>
     #include <map>
     #include <bits/stdc++.h>
     #include "scanner.hh"
     #include "astnode.hh"
     #include "aux.hh"
     // #include "astnode.cpp"
     #include "symbol.hh"
     //#include "symbol.cpp"
     //#include "typeExp.hh"
     //using namespace std;
     using namespace IPL;
     int nodeCount = 0;

     std::vector<std::pair<std::string,symbol_description*>> global_symbol_table;
     std::map<std::string,std::vector<symbol_description*>> local_symbol_table_struct; //lst of structs map
     std::map<std::string,std::vector<symbol_description*>> local_symbol_table_function; //lst of functions map
     std::vector<std::pair<std::string,std::vector<symbol_description*>>> local_symbol_table_struct_pairs;
     std::vector<std::pair<std::string,std::vector<symbol_description*>>> local_symbol_table_function_pairs;
     int tot_struct = 0;
     int tot_fun = 0;
     std::map<std::string,seq_astnode*> ast_map;
     std::vector<symbol_description*> current_lst(0);
     int current_offset = 0;
     symbol_description* current_gsym;
     int in_struct = 0;
     int in_function = 0;
     std::string current_fun_name = "";
     std::string current_fun_type = "";
     std::string current_struct_name = "";
     

#undef yylex
#define yylex IPL::Parser::scanner.yylex

}




%define api.value.type variant
%define parse.assert

%start translation_unit_prime

%token '+' '-' '*' '/' ',' '(' ')' '{' '}'
%token '[' ']' ';' '=' '!' '&' '<' '>' '.' 
%token OR_OP
%token AND_OP 
%token EQ_OP
%token NE_OP
%token INC_OP
%token LE_OP
%token GE_OP
%token PTR_OP
%token <std::string> INT_CONSTANT 
%token <std::string> FLOAT_CONSTANT
%token <std::string> STRING_LITERAL
%token WHILE
%token FOR
%token VOID
%token INT
%token FLOAT
%token RETURN
%token STRUCT
%token IF
%token ELSE
%token <std::string> IDENTIFIER
%token <std::string> OTHERS

%nterm <int> translation_unit 
%nterm <int> struct_specifier 
%nterm <int> function_definition 
%nterm <Type_specifier*> type_specifier
%nterm <Declarator_list*> declarator_list 
//%nterm <std::vector<symbol_description*>> declaration_list
//%nterm <Declaration*> declaration 
%nterm <Declarator*> declarator 
%nterm <Declarator*> declarator_arr 
%nterm <Fun_declarator*> fun_declarator
%nterm <Declarator_list*> parameter_list 
%nterm <Declarator*> parameter_declaration
%nterm <seq_astnode*> compound_statement
%nterm <std::vector<statement_astnode*>> statement_list
%nterm <statement_astnode*> statement 
%nterm <assignS_astnode*> assignment_statement //left and right
%nterm <assignE_astnode*> assignment_expression
%nterm <exp_astnode*> unary_expression 
%nterm <exp_astnode*> expression 
%nterm <exp_astnode*> postfix_expression
%nterm <std::string> unary_operator //ya enum
%nterm <exp_astnode*> primary_expression 
%nterm <std::vector<exp_astnode*>> expression_list
%nterm <proccall_astnode*> procedure_call 
%nterm <exp_astnode*> logical_and_expression
%nterm <exp_astnode*> equality_expression 
%nterm <exp_astnode*> relational_expression
%nterm <exp_astnode*> additive_expression
%nterm <exp_astnode*> multiplicative_expression
%nterm <if_astnode*> selection_statement 
%nterm <statement_astnode*> iteration_statement //can be while or for
/*
*/
%%

translation_unit_prime:
     translation_unit 
     {
          std::cout<<"{\"globalST\":"<<std::endl;
          std::cout<<"["<<std::endl;
          sort(global_symbol_table.begin(), global_symbol_table.end());
          for(uint i = 0; i < global_symbol_table.size(); i++){
               global_symbol_table[i].second->print();
               if(i!=global_symbol_table.size()-1){
                    std::cout<<","<<std::endl;
               }
          }
          std::cout<<"],"<<std::endl;
          int current_struct = 0; //to keep track of commas
          std::cout<<"\"structs\": ["<<std::endl;
          std::sort(local_symbol_table_struct_pairs.begin(), local_symbol_table_struct_pairs.end());
          for(auto lst: local_symbol_table_struct_pairs){
               current_struct += 1;
               std::cout<<"{"<<std::endl;
               std::cout<<"\"name\": "<<"\""<<lst.first<<"\","<<std::endl;
               std::cout<<"\"localST\": "<<std::endl;
               std::cout<<"["<<std::endl;
               std::sort(lst.second.begin(),lst.second.end(),cmp_lst);
               for(uint j = 0; j < lst.second.size();j++){
                    lst.second[j]->print();
                    if(j!=lst.second.size()-1){
                         std::cout<<",";
                    }
                    std::cout<<std::endl;
               }
               std::cout<<"]"<<std::endl;
               std::cout<<"}"<<std::endl;

                if(current_struct!=tot_struct){
                    std::cout<<","<<std::endl;
               }
          }
          std::cout<<"],"<<std::endl;

          std::cout<<"\"functions\": ["<<std::endl;
          
          int current_fun = 0; //to put commas 
          std::sort(local_symbol_table_function_pairs.begin(), local_symbol_table_function_pairs.end());
          for(auto lst: local_symbol_table_function_pairs){
               current_fun += 1;
               std::cout<<"{"<<std::endl;
               std::cout<<"\"name\": "<<"\""<<lst.first<<"\","<<std::endl;
               std::cout<<"\"localST\": "<<std::endl;
               std::cout<<"["<<std::endl;
               std::sort(lst.second.begin(),lst.second.end(),cmp_lst);
               for(uint j = 0; j < lst.second.size();j++){
                    lst.second[j]->print();
                    if(j!=lst.second.size()-1){
                         std::cout<<",";
                    }
                    std::cout<<std::endl;
               }
               std::cout<<"],"<<std::endl;
               //print ast now
               std::cout<<"\"ast\": {"<<std::endl;
               ast_map[lst.first]->print(0);
               std::cout<<"}"<<std::endl;
               std::cout<<"}"<<std::endl;
               if(current_fun!=tot_fun){
                    std::cout<<","<<std::endl;
               }
          }
          std::cout<<"]"<<std::endl;
          std::cout<<"}"<<std::endl;
     }

translation_unit:
     struct_specifier
     
     | function_definition
     

     | translation_unit struct_specifier
     

     | translation_unit function_definition
          ;

struct_specifier:
     STRUCT IDENTIFIER 
     {
          in_struct = 1;
          current_struct_name = "struct "+$2;
          current_lst = std::vector<symbol_description*>(0);
     }
     '{' declaration_list '}' ';'
     {
          //push current_lst into map
          //given single name mapping, creating map object
          symbol_description* desc = new symbol_description();
          current_gsym = desc;
          desc->name="struct "+$2;
          desc->symbol_class="struct";
          desc->symbol_type="-";
          desc->size=0;
          desc->offset=-1;
          desc->scope="global";
          for(uint i = 0; i < current_lst.size();i++){
               desc->size += current_lst[i]->size;
          }
          global_symbol_table.push_back({desc->name,desc});
          local_symbol_table_struct["struct "+$2] = current_lst;
          local_symbol_table_struct_pairs.push_back({desc->name,current_lst});
          tot_struct += 1;
          current_lst.resize(0);
          // std::cout<<"added to map for "<<$2<<"\n";
          in_struct = 0;
          current_struct_name = "";
          current_offset = 0;
     }
     ;

function_definition: 
     type_specifier {current_lst = std::vector<symbol_description*>(0);in_function=1;current_fun_type=$1->name;} 
     fun_declarator 
     compound_statement
     {
          symbol_description* desc = new symbol_description();
          current_gsym = desc;
          desc->name = $3->name; //$2 is action
          desc->symbol_class = "fun";
          desc->scope = "global";
          desc->symbol_type = $1->name;
          //check if function name already exists
          for (uint i = 0; i < global_symbol_table.size(); i++)
          {
               if(global_symbol_table[i].first==desc->name){
                    
                    std::string err="Function "+desc->name+" already declared\n";
                    IPL::Parser::error( @3, err );
                    ////exit(0);
               }
          }
          global_symbol_table.push_back({desc->name,desc});
          in_function = 0;
          current_fun_name = ""; //out of function now
          current_fun_type = "";
          //adding into map
          local_symbol_table_function[desc->name] = current_lst;
          local_symbol_table_function_pairs.push_back({desc->name,current_lst});
          ast_map[desc->name] = $4;
          tot_fun += 1;
          current_lst.resize(0); //clearing it
          current_offset = 0;
     }
    ;

type_specifier:
     VOID{
          $$ = new Type_specifier("void");
     }
     | INT{
          $$ = new Type_specifier("int");
     }
     
     | FLOAT{
          $$ = new Type_specifier("float");
     }
     
     | STRUCT IDENTIFIER{
          $$ = new Type_specifier("struct "+$2);
          //not in constructor

          symbol_description* gst_entry_of_struct =  get_gst_entry_with_name(global_symbol_table,"struct "+$2);
          //not in gst and neither is the case of recursive pointer to struct
          // std::cout<<"here "<<current_struct_name<<" "<<"struct "+$2<<" "<<current_struct_name.compare("struct "+$2)<<std::endl;
          int compare_res = current_struct_name.compare("struct "+$2);
          if(gst_entry_of_struct!=0){
               $$->size = gst_entry_of_struct->size;
          }
          else if(gst_entry_of_struct==0 && !(in_struct && compare_res==0)){
               std::cout<<"struct "<<$2<<" not declared"<<std::endl;
               //exit(0);
          }
          // TODO Confirm with Parshant, don't need anything here, right?
     }

     ;

fun_declarator: 
     IDENTIFIER '(' parameter_list ')'
     {
          $$ = new Fun_declarator();
          $$->name = $1;
          //adds the expression in parameter_list to current_lst and setting their offset accordingly
          $3->add_to_lst(current_lst,current_offset);
          current_fun_name = $1;
          // std::cout<<"inside parameter list"<<std::endl;
          // TODO Recursive Function
     }
          
     | IDENTIFIER '(' ')' {
          $$ = new Fun_declarator();
          $$->name = $1;
          current_fun_name = $1;
          // std::cout<<"inside 0 parameter list"<<std::endl;
     }
     ;

parameter_list: 
     parameter_declaration
          {
               $$ = new Declarator_list();
               $$->is_parameter_list = 1;
               $$->declarators.push_back($1);
               // std::cout<<"added to param list "<<$1->name<<std::endl;
          }
     | parameter_list ',' parameter_declaration
     {
          $$ = $1;
          $$->declarators.push_back($3);
     }
          ;

parameter_declaration: 
     type_specifier declarator
     {    
          $2->type_specifier = $1;
          $2->block = "parameter";
          $$ = $2; //have same nterm, design choice

         
          if($1->name.substr(0,6)=="struct"){
                    if(local_symbol_table_struct.count($1->name)!=0){
                         if($2->num_stars!=0){
                              $2->type_specifier->size = 4; //pointer of size 4 only
                         } //non pointer case is handled when adding to lst by looking at size of struct from gst
                    }
                    else {
                         std::cout<<"struct "<<$1->name<<" not declared"<<std::endl;
                         //exit(0);    
                    }
          }

          if($1->name=="void" && $2->num_stars==0){
               std::cout<<"can't have parameter of type void declared"<<std::endl;
               //exit(0);
          }
          
     }
     ;

declarator_arr: 
     IDENTIFIER 
     {
          $$ = new Declarator(); 
          $$->name = $1;
          if(in_struct)$$->block = "struct";
          else if(in_function)$$->block = "function";
          else $$->block = "none";
          $$->symbol_class="var"; //will be over-written if its a function parameter
          // std::cout<<"found declarator with name "<<$$->name<<std::endl;
     }
     
     | declarator_arr '[' INT_CONSTANT ']'
     {
          $$ = $1;
          $$->arr_indices.push_back($3);
          // std::cout<<"pushing in arr "<<$3<<std::endl;
     }
     ;

declarator: 
     declarator_arr
     {
          $$ = $1;
          $$->arr_indices = $1->arr_indices;
     }
          
     | '*' declarator
     {
          $$ = $2;
          $$->num_stars++;
     }
     ;

declaration_list: 
     declaration
          
     | declaration_list declaration
          ;

declaration: 
     type_specifier declarator_list ';'
     {
          //std::cout<<"inside declaration with type "<<type_name<<"\n";
          //this place is always for vaiable declarations not a param
          
          //if struct, then check it exists
          int struct_exists = 0;
          if($1->name.substr(0,6)=="struct"){
               if(local_symbol_table_struct.count($1->name)!=0){
                    struct_exists = 1;
               }
          }

          for(uint i = 0; i < $2->declarators.size();i++)
          {
               $2->declarators[i]->type_specifier = $1;
               //case 1 - you are struct type and inside your own struct 
               if(in_struct && $1->name == current_struct_name){
                    //only recursive pointers allowed , struct *a[10] allowed in struct a
                    if($2->declarators[i]->num_stars==0){
                         std::string err="Can't have variable of "+$1->name+" declared in itself\n";
                         IPL::Parser::error( @1, err );
                         //exit(0);
                    }
                    else {
                         $2->declarators[i]->type_specifier->size = 4; //pointer of size 4 only
                    }
               }
               //case 2 - you are struct type - but inside anything 
               //check if that struct exists, and if uska pointer hai then size = 4
               else if($1->name.substr(0,6)=="struct"){
                    if(struct_exists){
                         if($2->declarators[i]->num_stars!=0){
                              $2->declarators[i]->type_specifier->size = 4; //pointer of size 4 only
                         } //non pointer case is handled when adding to lst by looking at size of struct from gst
                    }
                    else {
                         std::string err="struct "+$1->name+" not declared\n";
                         IPL::Parser::error( @1, err );
                         
                         //exit(0);    
                    }
               }
               //case 3, can't have void declarator
               if($1->name=="void" && $2->declarators[i]->num_stars==0){
                    std::string err="can't have variable of type void declared\n";
                    IPL::Parser::error( @1, err );

                    //exit(0);
               }
          }
          //push into current_lst for each declarator
          $2->add_to_lst(current_lst,current_offset);
     }
     ;

declarator_list: 

     declarator
     {
          //push the declarator things to list 
          $$ = new Declarator_list();
          $$->is_parameter_list = 0;
          // std::cout<<"pushing to declarator list"<<std::endl;
          for (int i = 0; i < (int)current_lst.size(); i++)
          {
               //var and param same name not accepted
               if(current_lst[i]->name==$1->name){
                    std::string err="Error in declarator list, same name variable "+$1->name+" declared already\n";
                    
                    IPL::Parser::error( @1, err );
                    
                    //exit(0);
               }
          }

          $$->declarators.push_back($1);
     }
     |
     declarator_list ',' declarator
     {
          //check if same name declarator is not in that list like int a,b,a[2],
          for (int i = 0; i < (int)$1->declarators.size(); i++)
          {
               if($1->declarators[i]->name==$3->name){
                    std::string err="Error in declarator list, same name variable "+$3->name+" declared already\n";
                    IPL::Parser::error( @3, err );
                    //exit(0);
               }
          }
          //if not, check if it is already declared in prev lists 
          for (int i = 0; i < (int)current_lst.size(); i++)
          {
               if(current_lst[i]->name==$3->name){
                    std::string err="Error in declarator list, same name variable "+$3->name+" declared already\n";
                    IPL::Parser::error( @3, err );
                    //exit(0);
               }
          }
          $$ = $1;
          $$->declarators.push_back($3);
     }
     ;


compound_statement: 
     '{' '}'
     {
          $$ = new seq_astnode();
     }          
     | '{' statement_list '}'
     {
          $$ = new seq_astnode($2);
     }     
     | '{' declaration_list '}'
     {
          $$ = new seq_astnode();
     }      
     | '{' declaration_list statement_list '}'
     {
          $$ = new seq_astnode($3);
     }
     ;

statement_list: 
     statement
     {
          $$ = std::vector<statement_astnode*>(0);
          $$.push_back($1);
     }
     | statement_list statement
     {
          $$ = $1;
          $$.push_back($2);
     }
     ;

statement: 
     ';'
     {
          $$ = new empty_astnode();
     }
     | '{' statement_list '}'
     {
          $$ = new seq_astnode($2);
     }
          
     | selection_statement
     {
          $$ = $1;
     }
          
     | iteration_statement
     {
          $$ = $1;
     }
          
     | assignment_statement
     {
          $$ = $1;
     }
             
     | procedure_call
     {
          $$ = $1;
     }
          
     | RETURN expression ';'
     {
          if(in_function==0){
               std::string err="Error : cannot return from non function\n";
               IPL::Parser::error( @1, err );
               
               //TODO Write a program where this is displayed
               //exit(0);
          }
          //check return type of current function
          std::string return_type;
          // int found = 0;
          // for (int i = 0; i < (int)global_symbol_table.size(); i++)
          // {
          //      if(global_symbol_table[i].first==current_fun_name && global_symbol_table[i].second->symbol_class=="fun"){
          //           return_type = global_symbol_table[i].second->symbol_type;
          //           found = 1;
          //           break;
          //      }
          // }
          // if(found==0){
          //      std::cout<<"Error: function not found with return"<<std::endl;
          //      //exit(0);
          // }
          return_type = current_fun_type;
          if($2->type=="int" && return_type=="float"){
               $$ = new return_astnode(new op_unary_astnode("TO_FLOAT",$2));
          }
          else if ($2->type=="float" && return_type=="int"){
               $$ = new return_astnode(new op_unary_astnode("TO_INT",$2));
          }
          else if ($2->type == return_type){
               $$ = new return_astnode($2);
          }
          else{
               std::string err="Error in return expression of "+current_fun_name+" with return type acc to defn "+return_type+" , return expression type "+$2->type+"\n";
               IPL::Parser::error( @2, err );
               
               //TODO Modify error message
               // //exit(0);
          }
     }
     ;

assignment_expression: 
     unary_expression '=' expression
     {
          //$$ = new assignE_astnode($1,$3);
          //$$->lval = 0;
          //check for errors
          if($1->lval==0){
               std::string err="Error in assinE, left side should have lval\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
          if($1->type=="int" && $3->type=="float")
          {
               $$ = new assignE_astnode($1,new op_unary_astnode("TO_INT",$3));
          }
          else if ($1->type=="float" && $3->type=="int"){
               $$ = new assignE_astnode($1,new op_unary_astnode("TO_FLOAT",$3));
          }
          else if (dereference($1->type)!="" && dereference($1->type).find('[')==std::string::npos && dereference($3->type)==dereference($1->type)){//pointers to compatible types
               $$ = new assignE_astnode($1,$3);
          }
          else if (dereference($1->type)!="" && dereference($1->type).find('[')==std::string::npos && dereference($3->type)!="" && ($1->type=="void*" || $3->type=="void*"))//both pointers and atleast one of them is void*
          {
               $$ = new assignE_astnode($1,$3);
          }
          else if ($1->type==$3->type){ //same struct or other type
               $$ = new assignE_astnode($1,$3);
          }
          else if($1->type[$1->type.size()-1]=='*' && $3->astnode_type==typeExp::INTCONST_ASTNODE && ((intconst_astnode*)$3)->intconst==0){ //pointer to 0
               $$ = new assignE_astnode($1,$3);
          }
          else {
               std::string err="Error in assignE, can't assign types "+$1->type+" "+$3->type+"\n";
               IPL::Parser::error( @1, err );

               //TODO Modify error message
               //exit(0);
          }
          $$->lval = 0;
          $$->type = $1->type; //i think this is useless, just assigning to $1->type
          // I think so too
     }
     ;

assignment_statement: 
     assignment_expression ';'
     {
          $$ = new assignS_astnode($1);
          // $$->lval = 0;
          // $$->type = $1->type;
     }
     ;

procedure_call: 
     IDENTIFIER '(' ')' ';'
     {
          int found = 0;
          
          for (int i = 0; i < (int)global_symbol_table.size(); i++)
          {
               if (global_symbol_table[i].first==$1){
                    //found it
                    found = 1;
                    //$$->type = global_symbol_table[i].second->symbol_type;
                    break;
               }
          }
          // TODO recursive calls
          if(!found && $1!="printf" && $1!="scanf" && $1!=current_fun_name){
               std::string err="Function "+$1+" not declared\n";
               IPL::Parser::error( @1, err );
               // TODO Modify Error
               //exit(0);
          }
          //$$->lval = 0;

          int count = 0;
          std::vector<symbol_description*> lst;
          if($1!="printf" && $1!="scanf"){
               if($1!=current_fun_name)lst = local_symbol_table_function[$1];
               else lst = current_lst;
               for (int i = 0; i < (int)lst.size(); i++)
               {
                    if(lst[i]->scope=="param")count++;
               }
               if(count!=0){
                    std::string err="function parameters of "+$1+" not same\n";
                    IPL::Parser::error( @1, err );
                    //exit(0);
               }
          }
          $$ = new proccall_astnode(new identifier_astnode($1));
     }
                      
     | IDENTIFIER '(' expression_list ')' ';'
     {
          // $$ = new proccall_astnode(new identifier_astnode($1),$3);
          // TODO recursive calls
          
          int found = 0;
          std::string return_type;
          for (int i = 0; i < (int)global_symbol_table.size(); i++)
          {
               if (global_symbol_table[i].first==$1){
                    //found it
                    found = 1;
                    return_type = global_symbol_table[i].second->symbol_type;
                    break;
               }
          }
          if(!found && $1!="printf" && $1!="scanf" && $1!=current_fun_name){
               std::string err = "Function "+$1+" not declared\n";
               IPL::Parser::error( @1, err );
               //TODO Modify Error
               //exit(0);
          }

          //check same number of arguments and typecast if necessary
          int count = 0;
          std::vector<symbol_description*> lst, params;
          std::vector<exp_astnode*> expressions;

          if($1!="printf" && $1!="scanf"){
               if($1!=current_fun_name)lst = local_symbol_table_function[$1];
               else lst = current_lst;
               for (int i = 0; i < (int)lst.size(); i++)
               {
                    if(lst[i]->scope=="param")
                    {
                         count++;
                         params.push_back(lst[i]);
                    }
               }
               if(count!=(int)$3.size()){
                    std::string err="function parameters of "+$1+ " not same\n";
                    IPL::Parser::error( @1, err );
                    //exit(0);
               }
               //type cast the params
               
               for (int i = 0; i < count; i++)
               {
                    if($3[i]->type=="int" && params[i]->symbol_type=="float"){
                         expressions.push_back(new op_unary_astnode("TO_FLOAT",$3[i]));
                    }

                    else if($3[i]->type=="float" && params[i]->symbol_type=="int"){
                         expressions.push_back(new op_unary_astnode("TO_INT",$3[i]));
                    }
                    //compatible pointers typecast or typecast to void*
                    else if ((dereference(params[i]->symbol_type)=="void" || dereference($3[i]->type) == dereference(params[i]->symbol_type)) && dereference($3[i]->type)!=""){
                         expressions.push_back($3[i]);
                    }
                    //compatible pointers typecast or typecast from void*
                    else if ((dereference($3[i]->type)=="void" || dereference($3[i]->type) == dereference(params[i]->symbol_type)) && dereference(params[i]->symbol_type)!=""){
                         expressions.push_back($3[i]);
                    } //exact same type
                    else if($3[i]->type==params[i]->symbol_type){
                         expressions.push_back($3[i]);    
                    }
                    else {
                         std::string err="Error in type conversion here is arguments of types "+params[i]->symbol_type+" "+$3[i]->type+" for param "+params[i]->name+"\n";
                         IPL::Parser::error( @3, err );
                         //exit(0);
                    }
               }
               $$ = new proccall_astnode(new identifier_astnode($1), expressions);
          }
          else {
               $$ = new proccall_astnode(new identifier_astnode($1), $3);
          }
          //$$->lval = 0;
          //$$->type = return_type;
     }
     ;

expression: 
     logical_and_expression
     {
          $$ = $1;
          //type and lval are copied
     }
     
     | expression OR_OP logical_and_expression
     {
          $$ = new op_binary_astnode("OR_OP",$1,$3);
          //both can be int float or pointers 
          if(($1->type=="int" || $1->type=="float" || dereference($1->type)!="") && ($3->type=="int" || $3->type=="float" || dereference($3->type)!="")){
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               std::string err="Error in OR, can't take || or "+$1->type+" and "+$3->type+"\n";
               IPL::Parser::error(@1,err);
          }
          
     }    
     ;

logical_and_expression: 
     equality_expression
     {
          $$ = $1;
     }
          
     | logical_and_expression AND_OP equality_expression
     {    
          //TODO what about structs? No check?
          //TODO test all combinations of this, not too sure about this, including arrays, structs
          
          $$ = new op_binary_astnode("AND_OP",$1,$3);

          if(($1->type=="int" || $1->type=="float" || dereference($1->type)!="") && ($3->type=="int" || $3->type=="float" || dereference($3->type)!="")){
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               std::cout<<"Error in AND, can't take && "<<$1->type<<" and "<<$3->type<<std::endl;
               exit(0);
          }
     }
     ;

equality_expression: 
     relational_expression
     {
          $$ = $1;
     }
          
     | equality_expression EQ_OP relational_expression
     {
          std::cerr<<$3->type<<"\n";
          
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type==$3->type && $1->type=="float"){
               $$ = new op_binary_astnode("EQ_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;    
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("EQ_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("EQ_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if (dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          } //both of them are of void*
          else if ($1->type=="void*" && $3->type=="void*"){ 
               $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          // else if($1->type[$1->type.size()-1]=='*' && $3->astnode_type==typeExp::INTCONST_ASTNODE && ((intconst_astnode*)$3)->intconst==0){ //pointer to 0
          //      $$ = new assignE_astnode($1,$3);
          //      $$->type = "int";
          //      $$->lval = 0;
          // }

          //TODO nullptr case not handled
          else {
               //error
               std::string err = "error in EQ_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";

               IPL::Parser::error( @2, err );
               //TODO Tsest this
               //exit(0);
          }
     }
     
     | equality_expression NE_OP relational_expression
     {
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type==$3->type && $1->type=="float"){
               $$ = new op_binary_astnode("NE_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;    
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("NE_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("NE_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if (dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          } //both of them are void*
          else if ($1->type=="void*" && $3->type=="void*"){ 
               $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          // TODO nullptr case we have to think about
          else {
               //error
               std::string err = "error in NE_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               std::cerr<<"Hello";
               IPL::Parser::error( @2, err );
               //exit(0);
          }
     }
     
relational_expression: 
     additive_expression
     {
          $$ = $1;
     }
          
     | relational_expression '<' additive_expression
     {
          //need tp get _INT _FLOAT right at this place
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("LT_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("LT_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("LT_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("LT_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if (dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("LT_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               //error
               // std::cout<<"error in LT_OP"<<std::endl;
               std::string err = "error in LT_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               
               //Modify Error
               //exit(0);
          }
     }
          
     | relational_expression '>' additive_expression
     {
          //need tp get _INT _FLOAT right at this place
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("GT_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("GT_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("GT_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("GT_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if(dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("GT_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in GT_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error
          }
     }
          
     | relational_expression LE_OP additive_expression
     {
          //need tp get _INT _FLOAT right at this place
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("LE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("LE_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("LE_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("LE_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if (dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("LE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in LE_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error

          }
     }
          
     | relational_expression GE_OP additive_expression
     {
          //need tp get _INT _FLOAT right at this place
         if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("GE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("GE_OP_FLOAT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("GE_OP_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("GE_OP_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "int";
               $$->lval = 0;
          }
          else if(dereference($1->type)==dereference($3->type) && dereference($3->type)!=""){
               //compatible types
               $$ = new op_binary_astnode("GE_OP_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in GE_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error

          }
     }
     ;

additive_expression: 
     multiplicative_expression
     {
          $$ = $1;
     }
          
     | additive_expression '+' multiplicative_expression
     {
          //need tp get _INT _FLOAT right at this place
          // $$ = new op_binary_astnode("PLUS_X",$1,$3);
          
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("PLUS_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("PLUS_FLOAT",$1,$3);
               $$->type = "float";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("PLUS_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "float";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("PLUS_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "float";
               $$->lval = 0;
          } //one int and other pointer
          else if ($1->type=="int" && dereference($3->type)!=""){
               $$ = new op_binary_astnode("PLUS_INT",$1,$3);
               $$->type = $3->type;
               $$->lval = 0;
          }
          else if ($3->type=="int" && dereference($1->type)!=""){
               $$ = new op_binary_astnode("PLUS_INT",$1,$3);
               $$->type = $1->type;
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in ADD, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error

          }
     }
          
     | additive_expression '-' multiplicative_expression
     {
          // $$ = new op_binary_astnode("MINUS_X",$1,$3);
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("MINUS_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("MINUS_FLOAT",$1,$3);
               $$->type = "float";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("MINUS_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "float";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("MINUS_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "float";
               $$->lval = 0;
          }
          else if (dereference($3->type)==dereference($1->type) && dereference($3->type)!=""){ //compatible
               $$ = new op_binary_astnode("MINUS_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }
          else if (dereference($1->type)!="" && $3->type=="int"){
               $$ = new op_binary_astnode("MINUS_INT",$1,$3);
               $$->type = $1->type;
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in MINUS, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error
               //exit(0);

          }
     }
     ;

unary_expression: 
     postfix_expression
     {
          $$ = $1; 
     }
          
     | unary_operator unary_expression 
     {
          $$ = new op_unary_astnode($1,$2);
          //type 
          if($1 == "ADDRESS"){
               if($2->lval==0){
                    std::string err = "error in referencing, cannot reference non l value\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);
               }
               $$->type = reference($2->type);
               $$->lval = 0; //DOUBT
          }
          else if($1 == "DEREF"){               
               if(dereference($2->type)!="" && $2->type!="void*"){
                    $$->lval = 1;
                    $$->type = dereference($2->type);
               }
               else {
                    std::string err = "error in dereferencing type"+$2->type+"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);    
               }
               //TODO take care of assignment to arrays

          }
          else if($1 == "NOT"){
               if($2->type!="int" && $2->type!="float" && dereference($2->type)==""){
                    std::string err="Type Error in Not" +$2->type +"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);    
               }
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1=="TO_FLOAT"){
               if($2->type!="int" || $2->type!="float"){
                    std::string err="Error in to_float type"+$2->type+"\n";
                    
                    IPL::Parser::error( @2, err );

                    //exit(0);    
               }
               $$->type = "float";
               $$->lval = $2->lval;

          }

          else if($1=="TO_INT"){
               if($2->type!="int" || $2->type!="float"){
                    std::string err="Error in to_int type"+$2->type+"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);    
               }
               $$->type = "int";
               $$->lval = $2->lval;
          }
          else{
               //UMINUS
               if($2->type!="int" && $2->type!="float"){
                    std::string err="Error in minus with types "+$2->type+"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);
               }
               $$->type = $2->type;
               $$->lval = 0;
          }

     }
     ;

multiplicative_expression: 
     unary_expression
     {
          $$ = $1;
     }
     | multiplicative_expression '*' unary_expression
     {
          // $$ = new op_binary_astnode("MULT_X",$1,$3);
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("MULT_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("MULT_FLOAT",$1,$3);
               $$->type = "float";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("MULT_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "float";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("MULT_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "float";
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in MULT, type mismatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               
          }
     }
     
     | multiplicative_expression '/' unary_expression
     {
          // $$ = new op_binary_astnode("DIV_X",$1,$3);

          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("DIV_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
          }

          else if($1->type==$3->type && $1->type=="float")
          {
               $$ = new op_binary_astnode("DIV_FLOAT",$1,$3);
               $$->type = "float";
               $$->lval = 0;
          }

          else if($1->type=="int" && $3->type=="float"){
               $$ = new op_binary_astnode("DIV_FLOAT",new op_unary_astnode("TO_FLOAT",$1),$3);
               $$->type = "float";
               $$->lval = 0;
          }
          else if($1->type=="float" && $3->type=="int"){
               $$ = new op_binary_astnode("DIV_FLOAT",$1,new op_unary_astnode("TO_FLOAT",$3));
               $$->type = "float";
               $$->lval = 0;
          }
          else {
               //error
               std::string err = "error in DIV, type mismatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
          }
     }
     ;

postfix_expression: 
     primary_expression
     {
          $$ = $1;
          // std::cout<<"inside postfix , lval of "<<$$->lval<<std::endl;
     }
          
     | postfix_expression '[' expression ']'
     {
          if(dereference($1->type)!="" && $1->type!="void*" && $3->type=="int")
          {
               $$ = new arrayref_astnode($1,$3);
               $$->type = dereference($1->type);
               //remove the inner [..]
               //DOUBT - what if it doesn't have []
               

               $$->lval = $1->lval; //DOUBT
               //TODO Also cannot assign to arrays so keeping that in mind as well
          }
          else {
               std::string err = "Error in arrayref, type of identifier "+$1->type+" type of index "+$3->type+"\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
     }
          
     | IDENTIFIER '(' ')'
     {
          $$ = new funcall_astnode(new identifier_astnode($1)); 
          //search gst for type
          int found = 0;
          for (int i = 0; i < (int)global_symbol_table.size(); i++)
          {
               if (global_symbol_table[i].first==$1){
                    //found it
                    found = 1;
                    
                    $$->type = global_symbol_table[i].second->symbol_type;
                    break;
               }
          }
          if(!found && $1!="printf" && $1!="scanf" && $1!=current_fun_name){
               std::string err="Function "+$1+" not declared\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
          $$->lval = 0;
          //check same number of arguments and typecast if necessary
          int count = 0;
          std::vector<symbol_description*> lst;
          if($1!="printf" && $1!="scanf"){
               if($1!=current_fun_name) lst = local_symbol_table_function[$1];
               else 
               {
                    lst = current_lst;
                    $$->type = current_fun_type;
               }

               for (int i = 0; i < (int)lst.size(); i++)
               {
                    if(lst[i]->scope=="param")count++;
               }
               if(count!=0){
                    std::string err="function parameters not same\n";
                    IPL::Parser::error( @1, err );
                    ////exit(0);
               }
          }
          else{
               $$->type = "void"; //for printf scanf
          }
     }
          
     | IDENTIFIER '(' expression_list ')'
     {
          int found = 0;
          std::string return_type;
          for (int i = 0; i < (int)global_symbol_table.size(); i++)
          {
               if (global_symbol_table[i].first==$1){
                    //found it
                    found = 1;

                    return_type = global_symbol_table[i].second->symbol_type;
                    break;
               }
          }
          if(!found && $1!="printf" && $1!="scanf" && $1!=current_fun_name){
               std::string err="Function "+$1+" not declared\n";
               IPL::Parser::error( @1, err );
               ////exit(0);
          }

          //check same number of arguments and typecast if necessary
          int count = 0;
          std::vector<symbol_description*> lst, params;
          if($1!="printf" && $1!="scanf"){
               if($1!=current_fun_name)lst = local_symbol_table_function[$1];
               else lst = current_lst;                    
               

               for (int i = 0; i < (int)lst.size(); i++)
               {
                    if(lst[i]->scope=="param")
                    {
                         count++;
                         params.push_back(lst[i]);
                    }
               }
               if(count!=(int)$3.size()){
                    std::string err="function parameters not same\n";
                    IPL::Parser::error( @3, err );

                    //exit(0);
               }
               //type cast the params
               
               std::vector<exp_astnode*> expressions;

               for (int i = 0; i < count; i++)
               {
                    if($3[i]->type=="int" && params[i]->symbol_type=="float"){
                         expressions.push_back(new op_unary_astnode("TO_FLOAT",$3[i]));
                    }

                    else if($3[i]->type=="float" && params[i]->symbol_type=="int"){
                         expressions.push_back(new op_unary_astnode("TO_INT",$3[i]));
                    }
                    //compatible pointers typecast or typecast to void*
                    else if ((dereference(params[i]->symbol_type)=="void" || dereference($3[i]->type) == dereference(params[i]->symbol_type)) && dereference($3[i]->type)!=""){
                         expressions.push_back($3[i]);
                    }
                    //compatible pointers typecast or typecast from void*
                    else if ((dereference($3[i]->type)=="void" || dereference($3[i]->type) == dereference(params[i]->symbol_type)) && dereference(params[i]->symbol_type)!=""){
                         expressions.push_back($3[i]);
                    } //exact same type
                    else if($3[i]->type==params[i]->symbol_type){
                         expressions.push_back($3[i]);    
                    }
                    //CONTINUE
                    else {
                         std::string err="Error in type conversion here is arguments of types "+params[i]->symbol_type+" AND "+$3[i]->type+"\n";
                         IPL::Parser::error( @3, err );
                         //exit(0);
                    }
               }
               $$ = new funcall_astnode(new identifier_astnode($1), expressions);
               $$->lval = 0;
               if($1==current_fun_name)$$->type = current_fun_type;
               else $$->type = return_type;
          }
          else {
               $$ = new funcall_astnode(new identifier_astnode($1), $3);
               $$->lval = 0;
               $$->type = "void";
          }
     }
          
     | postfix_expression '.' IDENTIFIER
     {
          $$ = new member_astnode($1,new identifier_astnode($3));
          if($1->type.substr(0,6)=="struct" && dereference($1->type)==""){ //of type struct X
               //check for member
               int found = 0;
               std::string struct_name = $1->type;
               if(local_symbol_table_struct.count(struct_name)==0){
                    //check global symbol table too
                    int found_gst = 0;
                    for (int i = 0; i < (int)global_symbol_table.size(); i++)
                    {
                         if(global_symbol_table[i].first==$1->type){
                              found_gst = 1;
                              break;
                         }
                    }
                    if(found_gst==0)
                    {
                         std::string err=$1->type+" doesn't exist"+"\n";
                         IPL::Parser::error( @1, err );
                         //exit(0);
                    }
               }

               std::vector<symbol_description*> lst = local_symbol_table_struct[struct_name];
               for(uint i =0; i < lst.size(); i++){
                    //std::cout<<"checking for "<<$1->type<<" "<<lst[i]->name<<std::endl;
                    if(lst[i]->name==$3){
                         found = 1;
                         $$->type = lst[i]->symbol_type;
                         $$->lval = 1;
                         break;
                    }
               }
               if(!found){
                    std::string err="error in .  not a member"+$3+ "\n";
                    IPL::Parser::error( @3, err );

                    //exit(0);
               }

          }
          else {
               std::string err="error in . not a struct"+$1->type+"\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }

     }
     
     | postfix_expression PTR_OP IDENTIFIER
     {
          $$ = new arrow_astnode($1,new identifier_astnode($3));
          
          if($1->type.substr(0,6)=="struct" && dereference($1->type).substr(0,6)=="struct" && dereference(dereference($1->type))==""){ //of type struct X* or struct X[10] pointer to struct
               //check for member
               int found = 0;
               std::string struct_name = dereference($1->type); //to which it is pointer, struct X* ya struct X[10] ka struct X basically
               if(local_symbol_table_struct.count(struct_name)==0){
                    std::string err=struct_name+" doesn't exist\n";
                    IPL::Parser::error( @1, err );

                    //exit(0);
               }
               std::vector<symbol_description*> lst = local_symbol_table_struct[dereference($1->type)];
               for(uint i =0; i < lst.size(); i++){
                    if(lst[i]->name==$3){
                         found = 1;
                         $$->type = lst[i]->symbol_type;
                         $$->lval = 1;
                         break;
                    }
               }
               if(!found){
                    std::string err="error in ->  not a member"+$3+ "\n";
                    IPL::Parser::error( @3, err );

                    //exit(0);
               }
          }
          else {
               std::string err="error in -> not a struct pointer"+$1->type+"\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
     }
          
     | postfix_expression INC_OP
     {
          $$ = new op_unary_astnode("PP",$1);;
          if($1->lval == 1 && (($1->type[$1->type.size()-1]=='*')||$1->type=="int"||$1->type=="float")) //DOUBT - pointer here means uske last me * hai
          {
               $$->type = $1->type;
               $$->lval = 0;
          }
          else {
               std::string err="error in ++, type "+$1->type+"\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
     }
     ;

primary_expression: 
     IDENTIFIER
     {
          $$ = new identifier_astnode($1);
          //check if variable is present in the scope we are in
          //in current_lst
          int found = 0;
          for(int i = 0; i < (int)current_lst.size(); i++){
               if(current_lst[i]->name==$1){
                    found = 1;
                    $$->type = current_lst[i]->symbol_type;
                    $$->lval = 1;
                    break;
               }
          }
          if(found==0){ //not in lst, search gst
               for(int i = 0; i < (int)global_symbol_table.size(); i++){
               if(global_symbol_table[i].first==$1){
                    found = 1;
                    $$->type = global_symbol_table[i].second->symbol_type;
                    $$->lval = 1;
                    break;
               }
               }
          }

          // Would fail for recursive functions/procedures

          if(found==0){
               std::string err="error in variable not present"+$1+"\n";
               IPL::Parser::error( @1, err );
               //exit(0);
          }
     }
                    
     | INT_CONSTANT
     {
          $$ = new intconst_astnode($1); //its string
          $$->type = "int";
          $$->lval = 0;
     }

     | FLOAT_CONSTANT
     {
          $$ = new floatconst_astnode($1); //its string
          $$->type = "float";
          $$->lval = 0;
     }
          
     | STRING_LITERAL
     {
          $$ = new stringconst_astnode($1);
          $$->type = "string";  //idk if that is used anywhere
          // Probably used in printf or such
          $$->lval = 0;
     }
          
     | '(' expression ')'
     {
          $$ = $2;
     }
     ;

expression_list: 
     expression
     {
          std::vector<exp_astnode*> elist(1);
          elist[0] = $1;
          $$ = elist;
     }
     | expression_list ',' expression
     {
          $$ = $1;
          $$.push_back($3);
     }
     ;

unary_operator: 
     '-'
     {
          $$ = "UMINUS";
     }
     | '!'
     {
          $$ = "NOT";
     }
          
     | '&'
     {
          $$ = "ADDRESS";
     }
          
     | '*'
     {
          $$ = "DEREF";
     }
     ;

selection_statement: 
     IF '(' expression ')' statement ELSE statement
     {
          $$ = new if_astnode($3,$5,$7);
     }
     ;

iteration_statement: 
     WHILE '(' expression ')' statement
     {
          $$ = new while_astnode($3,$5);
     }
     | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
     {
          $$ = new for_astnode($3,$5,$7,$9);
     }
          ;


%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message;
   exit(1);
}


