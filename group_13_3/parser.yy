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
     // #include "symbol.hh"
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
     std::vector<std::string> printf_loc;
     int current_lab=0;
     int next_needed=0;
     

#undef yylex
#define yylex IPL::Parser::scanner.yylex

}




%define api.value.type variant
%define parse.assert

%start program

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
%token MAIN
%token PRINTF
%token <std::string> IDENTIFIER
%token <std::string> OTHERS

%nterm <int> translation_unit 
%nterm <int> struct_specifier 
%nterm <int> function_definition 
%nterm <int> main_definition
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
%nterm <proccall_astnode*> printf_call 
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

program:
     
     main_definition
     {
          
          for(auto x:printf_loc){

               std::cout<<x<<"\n";
          }
     }

     | translation_unit main_definition
     {
          // std::cout<<"{\"globalST\":"<<std::endl;
          // std::cout<<"["<<std::endl;
          // sort(global_symbol_table.begin(), global_symbol_table.end());
          // for(uint i = 0; i < global_symbol_table.size(); i++){
          //      global_symbol_table[i].second->print();
          //      if(i!=global_symbol_table.size()-1){
          //           std::cout<<","<<std::endl;
          //      }
          // }
          // std::cout<<"],"<<std::endl;
          // int current_struct = 0; //to keep track of commas
          // std::cout<<"\"structs\": ["<<std::endl;
          // std::sort(local_symbol_table_struct_pairs.begin(), local_symbol_table_struct_pairs.end());
          // for(auto lst: local_symbol_table_struct_pairs){
          //      current_struct += 1;
          //      std::cout<<"{"<<std::endl;
          //      std::cout<<"\"name\": "<<"\""<<lst.first<<"\","<<std::endl;
          //      std::cout<<"\"localST\": "<<std::endl;
          //      std::cout<<"["<<std::endl;
          //      std::sort(lst.second.begin(),lst.second.end(),cmp_lst);
          //      for(uint j = 0; j < lst.second.size();j++){
          //           lst.second[j]->print();
          //           if(j!=lst.second.size()-1){
          //                std::cout<<",";
          //           }
          //           std::cout<<std::endl;
          //      }
          //      std::cout<<"]"<<std::endl;
          //      std::cout<<"}"<<std::endl;

          //       if(current_struct!=tot_struct){
          //           std::cout<<","<<std::endl;
          //      }
          // }
          // std::cout<<"],"<<std::endl;

          // std::cout<<"\"functions\": ["<<std::endl;
          
          // int current_fun = 0; //to put commas 
          // std::sort(local_symbol_table_function_pairs.begin(), local_symbol_table_function_pairs.end());
          // for(auto lst: local_symbol_table_function_pairs){
          //      current_fun += 1;
          //      std::cout<<"{"<<std::endl;
          //      std::cout<<"\"name\": "<<"\""<<lst.first<<"\","<<std::endl;
          //      std::cout<<"\"localST\": "<<std::endl;
          //      std::cout<<"["<<std::endl;
          //      std::sort(lst.second.begin(),lst.second.end(),cmp_lst);
          //      for(uint j = 0; j < lst.second.size();j++){
          //           lst.second[j]->print();
          //           if(j!=lst.second.size()-1){
          //                std::cout<<",";
          //           }
          //           std::cout<<std::endl;
          //      }
          //      std::cout<<"],"<<std::endl;
          //      //print ast now
          //      std::cout<<"\"ast\": {"<<std::endl;
          //      ast_map[lst.first]->print(0);
          //      std::cout<<"}"<<std::endl;
          //      std::cout<<"}"<<std::endl;
          //      if(current_fun!=tot_fun){
          //           std::cout<<","<<std::endl;
          //      }
          // }
          // std::cout<<"]"<<std::endl;
          // std::cout<<"}"<<std::endl;

          for(auto x:printf_loc){

               std::cout<<x<<"\n";
          }
     }
     ;

main_definition:
     INT MAIN '(' ')' 
     {
          current_lst = std::vector<symbol_description*>(0);
          in_function=1;
          current_fun_name = "main";
          current_fun_type = "int";
     }
     compound_statement
     {
          symbol_description* desc = new symbol_description();
          current_gsym = desc;
          desc->name = "main"; //$2 is action
          desc->symbol_class = "fun";
          desc->scope = "global";
          desc->symbol_type = "int";
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
          ast_map[desc->name] = $6;
          tot_fun += 1;
          current_lst.resize(0); //clearing it

          std::cout<<"main:\n";
          std::cout<<"   pushl     %ebp\n";
          std::cout<<"   movl      %esp, %ebp\n";
          std::cout<<"   subl $"<<-current_offset<<", %esp\n";

          auto &nd=$6->seq.back();
          next_needed=0;
          std::vector<std::string> s;
          int curr_pos=0;
          int pres=0;
          std::vector<std::vector<std::string>> tcode;
          // printf("%d",nd->location.size());
          // assert(nd->location.size()==1);

          // printf("HULA HULA%d",nd->location.size());
          for(int i=0;i<int(nd->location.size());i++){

               while(curr_pos<=nd->location[i]){

                    s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
                    curr_pos++;
               }

               if(nd->patch[i]==2){

                    s.push_back(nd->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    pres=1;
               }

               tcode.push_back(s);
               s.clear();
          }

          // for(auto x:tcode){

          //      for (auto y:x){

          //           std::cout<<y;
          //      }
               
          // }
          // std::cout<<"TOPTOP"<<pres<<" "<<nd->patch[0]<<"\n";

          while(curr_pos<int(nd->code.size())){

               s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
               curr_pos++;
          }
          if(pres){
               s.push_back(".L"+std::to_string(current_lab)+": \n");
               current_lab+=1;
          }
          tcode.push_back(s);
          nd->code=tcode;
          nd->location.resize(0);
          nd->patch.resize(0);
          nd->jump_inst.resize(0);
     
          for(auto &x:$6->seq){

               for(auto &y:x->code){

                    for(auto &z:y){

                         std::cout<<z;
                    }
               }
          }

          // std::cout<<"   addl $"<<-current_offset<<", %esp\n";
          
          current_offset = 0;

          // std::cout<<"   leave\n";
          // std::cout<<"   ret\n";
          std::cout<<"   .globl    main\n";
          std::cout<<"   .type    main, @function\n";

     }
     ;

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
          
          //adding into map
          local_symbol_table_function[desc->name] = current_lst;
          local_symbol_table_function_pairs.push_back({desc->name,current_lst});
          ast_map[desc->name] = $4;
          
          std::cout<<current_fun_name+":\n";
          std::cout<<"   pushl     %ebp\n";
          std::cout<<"   movl      %esp, %ebp\n";
          std::cout<<"   subl $"<<-current_offset<<", %esp\n";
          // current_offset = 0;

          auto &nd=$4->seq.back();
          next_needed=0;
          std::vector<std::string> s;
          int curr_pos=0;
          int pres=0;
          std::vector<std::vector<std::string>> tcode;
          // printf("%d",nd->location.size());
          // assert(nd->location.size()==1);

          // printf("HULA HULA%d",nd->location.size());
          for(int i=0;i<int(nd->location.size());i++){

               while(curr_pos<=nd->location[i]){

                    s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
                    curr_pos++;
               }

               if(nd->patch[i]==2){

                    s.push_back(nd->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    pres=1;
               }

               tcode.push_back(s);
               s.clear();
          }

          // for(auto x:tcode){

          //      for (auto y:x){

          //           std::cout<<y;
          //      }
               
          // }
          // std::cout<<"TOPTOP"<<pres<<" "<<nd->patch[0]<<"\n";

          while(curr_pos<int(nd->code.size())){

               s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
               curr_pos++;
          }
          if(pres){
               s.push_back(".L"+std::to_string(current_lab)+": \n");
               current_lab+=1;
          }
          tcode.push_back(s);
          nd->code=tcode;
          nd->location.resize(0);
          nd->patch.resize(0);
          nd->jump_inst.resize(0);
     
          for(auto &x:$4->seq){

               for(auto &y:x->code){

                    for(auto &z:y){

                         std::cout<<z;
                    }
               }
          }

          if($1->name=="void"){

               std::cout<<"   addl $"+std::to_string(-current_offset)+", %esp\n";
               
               std::cout<<"   leave\n";
               std::cout<<"   ret\n";

               std::cout<<"   .globl    "<<current_fun_name<<"\n";
               std::cout<<"   .type    "<<current_fun_name<<", @function\n";

               in_function = 0;
               current_fun_type = "";
               tot_fun += 1;
               current_lst.resize(0); //clearing it
               current_fun_name = ""; //out of function now
               current_offset = 0;

          }else{

               // std::cout<<"   addl $"+std::to_string(-current_offset)+", %esp\n";
               
               std::cout<<"   .globl    "<<current_fun_name<<"\n";
               std::cout<<"   .type    "<<current_fun_name<<", @function\n";
               in_function = 0;
               current_fun_type = "";
               tot_fun += 1;
               current_lst.resize(0); //clearing it
               current_fun_name = ""; //out of function now
               current_offset = 0;
          }

          
     }
    ;

type_specifier:
     VOID{
          $$ = new Type_specifier("void");
     }
     | INT{
          $$ = new Type_specifier("int");
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
          $2->type_specifier = new Type_specifier($1);
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
               $2->declarators[i]->type_specifier = new Type_specifier($1);
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
     | '{' declaration_list 
     
     {

     }
     
     statement_list '}'
     {
          $$ = new seq_astnode($4);
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

          auto &nd=$1.back();
          next_needed=0;
          std::vector<std::string> s;
          int curr_pos=0;
          int pres=0;
          std::vector<std::vector<std::string>> tcode;
          // printf("%d",nd->location.size());
          // assert(nd->location.size()==1);
          for(int i=0;i<int(nd->location.size());i++){

               while(curr_pos<=nd->location[i]){

                    s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
                    curr_pos++;
               }

               if(nd->patch[i]==2){

                    s.push_back(nd->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    pres=1;
               }

               tcode.push_back(s);
               s.clear();
          }

          while(curr_pos<int(nd->code.size())){

               s.insert(s.end(),nd->code[curr_pos].begin(),nd->code[curr_pos].end());
               curr_pos++;
          }
          if(pres){
               s.push_back(".L"+std::to_string(current_lab)+": \n");
               current_lab+=1;
          }
          tcode.push_back(s);

          nd->code=tcode;
          nd->location.resize(0);
          nd->patch.resize(0);
          nd->jump_inst.resize(0);
     
          $$=$1;
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

          for(int i=0;i<int($2.size());i++){

               int curr_pos=0;
               std::vector<std::string> s;
               for(int j=0;j<int($2[i]->location.size());j++){

                    while(curr_pos<=int($2[i]->location[j])){
                  
                         s.insert(s.end(),$2[i]->code[curr_pos].begin(),$2[i]->code[curr_pos].end());
                         curr_pos++;
                    }
                    $$->code.push_back(s);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back($2[i]->patch[j]);
                    $$->jump_inst.push_back($2[i]->jump_inst[j]);
                    s.clear();
               }

               while(curr_pos<int($2[i]->code.size())){
                    s.insert(s.end(),$2[i]->code[curr_pos].begin(),$2[i]->code[curr_pos].end());
                    curr_pos++;
               }
               $$->code.push_back(s);
          }
          // for(auto &x:$2){

          //      $$->code.insert($$->code.end(),x->code.begin(),x->code.end());
          // }
          // $$->patch=$2.back()->patch;
          // $$->location=$2.back()->location;
          // $$->jump_inst=$2.back()->jump_inst;
          // if(!$$->location.empty()){

          //      $$->location.back()=$$->code.size()-1;
          // }
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

     | printf_call
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

          int curr_pos=0;
          int lab_need=0;

          std::vector<std::string> s;
          
          for(int j=0;j<int($2->location.size());j++){

               while(curr_pos<=$2->location[j]){

                    s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                    curr_pos++;
               }
               // std::cout<<"REACHED "<<i<<std::endl;


               // If true, then go to next expression set stack to 1

               if($2->patch[j]==1){

                    s.push_back($2->jump_inst[j]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($2->jump_inst[j]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($2->code.size())){

               s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
               $$->code.push_back(s);
               s.clear();
          }

          std::string ty=$2->type;

          if(ty.back()==']'&&ty.find('(')==std::string::npos){

               if($2->offset_loc==-1){

                    s.push_back("  movl (%esp), %eax\n");
                    s.push_back("  addl $4, %esp\n");
                    // s.push_back("  pushl %edx\n");

               }else if($2->offset_loc==0){

                    s.push_back("  movl (%esp), %eax\n");
                    s.push_back("  addl $4, %esp\n");
                    // s.push_back("  pushl %edx\n");
               }else{

                    s.push_back("  leal "+std::to_string($2->offset_loc)+"(%ebp), %eax\n");
                    // s.push_back("  pushl %edx\n");
               }
          }else{

               if(ty.find('*')==std::string::npos && ty.substr(0,7)=="struct "){

                    //copy struct TODO HOW TO RETURN STRUCT??
                    if($2->offset_loc==0){

                         s.push_back("  movl (%esp), %eax\n");
                         
                    }else{
                         s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %eax\n");
                         
                    }
               }else{

                    if($2->offset_loc==-1){

                         s.push_back("  movl (%esp), %eax\n");
                         s.push_back("  addl $4, %esp\n");
                         // s.push_back("  pushl %edx\n");

                    }else if($2->offset_loc==0){

                         s.push_back("  movl (%esp), %eax\n");
                         s.push_back("  addl $4, %esp\n");
                         s.push_back("  movl (%eax), %eax\n");
                         // s.push_back("  pushl %edx\n");
                    }else{

                         s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %eax\n");
                         // s.push_back("  pushl %edx\n");
                    }
               }
          }

          s.push_back("   addl $"+std::to_string(-current_offset)+", %esp\n");
          s.push_back("  leave\n");
          s.push_back("  ret\n");

          $$->code.push_back(s);
          s.clear();
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

          // std::cout<<"WHAT THE\n";
          $$->lval = 0;
          $$->type = $1->type; //i think this is useless, just assigning to $1->type
          // I think so too
          std::vector<std::string> s;

          $$->code=$1->code;

          // std::cout<<"FUTA\n";

          // for(auto x:$3->code){

          //      for(auto y:x){

          //           for(auto z:y){

          //                std::cout<<z;
          //           }
          //      }
          // }

          // std::cout<<"FUTA\n";

          // if($3->isBool){
               
          int curr_pos=0;
          int lab_need=0;
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    lab_need=1;
               }else if($3->patch[i]==0){
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
                    lab_need=1;
               }else{

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+2)+"\n");
                    lab_need=1;
               }
               $$->code.push_back(s);
               s.clear();
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          // std::cout<<"BUTA\n";

          // for(auto x:s){

          //      std::cout<<x;
          // }

          // std::cout<<"BUTA\n";
          $$->code.push_back(s);

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;


               // std::cout<<"BUTA2\n";

               // for(auto x:s){

               //      std::cout<<x;
               // }

               // std::cout<<"BUTA2\n";
               $$->code.push_back(s);
               s.clear();
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");
               s.push_back("   addl $4, %esp\n");
               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{
               
               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");
               // s.push_back("   movl %eax, "+std::to_string($1->offset_loc)+"(%ebp)\n");

          }

          if($1->offset_loc==0){

               s.push_back("   movl (%esp), %eax\n");
               s.push_back("   movl %edx, (%eax)\n");
               s.push_back("   addl $4, %esp\n");
     
          }else{

               s.push_back("   movl %edx, "+std::to_string($1->offset_loc)+"(%ebp)\n");
          }
          // $$->code=$1->code;
          // $$->code.insert($$->code.end(),$3->code.begin(),$3->code.end());
          $$->code.push_back(s);

          // std::cout<<"BUTA3\n";

          // for(auto x:s){

          //      std::cout<<x;
          // }

          // std::cout<<"BUTA3\n";
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
          
          std::vector<std::string> s;
          
          s.push_back("  call "+$1+"\n");

          $$->code.push_back(s);
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

          int co=4;
          std::vector<std::string> s;

          for(int i=0;i<int($3.size());i++){
               
               int sz=4;
               for(int j=0;j<int(global_symbol_table.size());j++){

                    if(global_symbol_table[j].first==$3[i]->type){

                        sz=global_symbol_table[j].second->size; 
                    }
               }

               co+=sz;

               int curr_pos=0;
               int lab_need=0;
               
               for(int j=0;j<int($3[i]->location.size());j++){

                    while(curr_pos<=$3[i]->location[j]){

                         s.insert(s.end(),$3[i]->code[curr_pos].begin(),$3[i]->code[curr_pos].end());
                         curr_pos++;
                    }
                    // std::cout<<"REACHED "<<i<<std::endl;


                    // If true, then go to next expression set stack to 1

                    if($3[i]->patch[j]==1){

                         s.push_back($3[i]->jump_inst[j]+" .L"+std::to_string(current_lab)+"\n");
                    }else{
                         s.push_back($3[i]->jump_inst[j]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($3[i]->code.size())){

                    s.insert(s.end(),$3[i]->code[curr_pos].begin(),$3[i]->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               s.clear();

               curr_pos=0;

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    current_lab+=3;
                    $$->code.push_back(s);
                    s.clear();
               }

               std::string ty=$3[i]->type;

               if(ty.back()==']'&&ty.find('(')==std::string::npos){

                    if($3[i]->offset_loc==-1){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                         s.push_back("  pushl %edx\n");

                    }else if($3[i]->offset_loc==0){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                         s.push_back("  pushl %edx\n");
                    }else{

                         s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                         s.push_back("  pushl %edx\n");
                    }
               }else{

                    if(ty.find('*')==std::string::npos && ty.substr(0,7)=="struct "){

                         //copy struct
                         if($3[i]->offset_loc==0){

                              int t=0;
                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");

                              while(t<sz){
                                   s.push_back("  pushl     (%edx)\n");
                                   s.push_back("  addl $4, %edx\n");
                                   t+=4;
                              }
                              
                         }else{

                              int t=0;
                              s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                              
                              while(t<sz){
                                   s.push_back("  pushl     (%edx)\n");
                                   s.push_back("  addl $4, %edx\n");
                                   t+=4;
                              }
                         }
                    }else{

                         if($3[i]->offset_loc==-1){

                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");
                              s.push_back("  pushl %edx\n");

                         }else if($3[i]->offset_loc==0){

                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");
                              s.push_back("  movl (%edx), %edx\n");
                              s.push_back("  pushl %edx\n");
                         }else{

                              s.push_back("  movl "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                              s.push_back("  pushl %edx\n");
                         }
                    }
               }


               $$->code.push_back(s);
               s.clear();
               
               // } if(ty.find('*')!=ty.end()&&ty.find('(')==ty.end()){

               //      //value
               // }else if(ty.find("(")!=ty.end()){

               //      //value
               // }else if(ty.substr(0,6)=="struct"){

               //      //value
               // }else{

               //      //value
               // }

               // if($3[i]->offset_loc==-1){

               //      s.push_back("  movl %(esp), %edx\n");
               //      s.push_back("  addl $4, %esp\n");
               //      s.push_back("  pushl %edx\n");

               // }else if($3[i]->offset_loc==0){

               //      s.push_back("  movl %(esp), %edx\n");
               //      s.push_back("  addl $4, %esp\n");
               //      s.push_back("  pushl %edx\n");
               // }else{

               //      s.push_back("  leal $"+std::to_string($3[i]->offset_loc)+", %(edx)\n");
               //      s.push_back("  pushl %edx\n");
               // }
          }
          s.push_back("  pushl     %eax\n");

          s.push_back("  call "+$1+"\n");
          s.push_back("  addl $"+std::to_string(co)+", %esp\n");

          $$->code.push_back(s);
     }
     ;

printf_call:
     PRINTF '(' STRING_LITERAL ')' ';'
     {
          $$=new proccall_astnode();
          
          std::string s=".LC"+std::to_string(printf_loc.size())+": \n";
          s+=" .string   "+$3+"\n";
          s+=" .text     \n";
          s+=" .globl    "+current_fun_name+"\n";
          s+=" .type     "+current_fun_name+", @function\n";

          std::vector<std::string> cd;

          cd.push_back("   pushl     $.LC"+std::to_string(printf_loc.size())+"\n");
          cd.push_back("   call      printf\n");
          cd.push_back(" addl $4, %esp\n");
          printf_loc.push_back(s);

          $$->code.push_back(cd);
     }

     | PRINTF '(' STRING_LITERAL ',' expression_list ')' ';'
     {
          $$=new proccall_astnode();
          
          std::string s1=".LC"+std::to_string(printf_loc.size())+": \n";
          s1+=" .string   "+$3+"\n";
          s1+=" .text     \n";
          s1+=" .globl    "+current_fun_name+"\n";
          s1+=" .type     "+current_fun_name+", @function\n";
          //TODO PUSH PARAMETERS IN REVERSE ( DO AFTER ASSIGNING AND FUNCTIONS)

          std::vector<std::string> s;

          for(int i=$5.size()-1;i>=0;i--){
               int lab_need=0;
               int curr_pos=0;
               s.clear();

               // std::cout<<"RED\n";
               // for(auto x:$5[i]->code){
               //      for(auto y:x){
               //           for(auto z:y){

               //                std::cout<<z;
               //           }
               //      }
               //      std::cout<<"BREAK\n";
               // }
               // for(auto x:$5[i]->location){

               //      std::cout<<x<<" ";
               // }
               // std::cout<<"\n";
               // std::cout<<"RED\n";

               for(int j=$5[i]->location.size()-1;j>=0;j--){

                    while(curr_pos<=$5[i]->location[j]){

                         s.insert(s.end(),$5[i]->code[curr_pos].begin(),$5[i]->code[curr_pos].end());
                         curr_pos++;
                    }
                    if($5[i]->patch[j]==1){

                         s.push_back($5[i]->jump_inst[j]+" .L"+std::to_string(current_lab)+"\n");
                    }else if($5[i]->patch[j]==0){
                         s.push_back($5[i]->jump_inst[j]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }else{

                         s.push_back($5[i]->jump_inst[j]+" .L"+std::to_string(current_lab+2)+"\n");
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($5[i]->code.size())){

                    s.insert(s.end(),$5[i]->code[curr_pos].begin(),$5[i]->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               s.clear();

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    $$->code.push_back(s);
                    s.clear();
                    
                    current_lab+=3;
               }

               if($5[i]->offset_loc==-1){
                    $$->code.back().push_back("   movl (%esp), %edx\n");
                    $$->code.back().push_back("   addl $4, %esp\n");            
               }else if($5[i]->offset_loc==0){

                    $$->code.back().push_back("  movl (%esp), %edx\n");
                    $$->code.back().push_back("  movl (%edx), %edx\n");
                    $$->code.back().push_back("  addl $4, %esp\n");
                    
               }else{

                    $$->code.back().push_back("   movl "+std::to_string($5[i]->offset_loc)+"(%ebp), %edx\n");
               }
               $$->code.back().push_back("   pushl     %edx\n");
          }

          $$->code.back().push_back("   pushl     $.LC"+std::to_string(printf_loc.size())+"\n");
          $$->code.back().push_back("   call      printf\n");
          $$->code.back().push_back("   addl $"+std::to_string(($5.size()+1)*4)+", %esp\n");
          printf_loc.push_back(s1);
     }
     ;

expression: 
     logical_and_expression
     {
          // $$->string_type = $1->string_type;
          // $$->lval=$1->lval;
          // $$->offset_loc = $1->offset_loc;
          // $$->code = $1->code;
          // $$->patch=$1->patch;
          // $$->jump_inst = $1->jump_inst;
          // $$->location = $1->location;
          //type and lval are copied
          // int fall=$$->fall;
          $$=$1;
          // std::cout<<"FINAEXP\n";
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:x){

          //                std::cout<<z;
          //           }
          //      }
          // }

          // std::cout<<"FINAEXP\n";
          /*std::cout<<"FIKNSDFexp\n";

          for(auto &x:$$->code){

               for(auto &y:x){

                    std::cout<<y;
               }
          }
          std::cout<<"FIKNSDFexp\n";*/

          // $$->fall=fall;
          $$->isBool=$1->isBool;
     }
     
     |
     expression 
     
     OR_OP 
     
     logical_and_expression
     {
          // int fall=$$->fall;
          
          $$ = new op_binary_astnode("OR_OP",$1,$3);
          //both can be int float or pointers
          /* 
          if(($1->type=="int" || $1->type=="float" || dereference($1->type)!="") && ($3->type=="int" || $3->type=="float" || dereference($3->type)!="")){
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               std::string err="Error in OR, can't take || or "+$1->type+" and "+$3->type+"\n";
               IPL::Parser::error(@1,err);
          }
          */
          // $$->fall=fall;
          // std::vector<std::vector<std::string> temp_code;

          //If isBool is false TODO

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               if($1->patch[i]==0){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    lab_need=1;
               }else{

                    $$->code.push_back(s);
                    $$->patch.push_back(1);
                    $$->jump_inst.push_back($1->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    s.clear();
               }
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          if(!$1->isBool){
               
               if($1->offset_loc==-1){
                    $$->code.back().push_back("   movl (%esp), %edx\n");
                    $$->code.back().push_back("   addl $4, %esp\n");               
               }else if($1->offset_loc==0){

                    $$->code.back().push_back("  movl (%esp), %edx\n");
                    $$->code.back().push_back("  movl (%edx), %edx\n");
                    $$->code.back().push_back("  addl $4, %esp\n");
                    
               }else{

                    $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");
               }
               $$->code.back().push_back("   cmpl $0, %edx\n");
               $$->code.back().push_back("   je .L"+std::to_string(current_lab)+"\n");
               lab_need=1;
               std::vector<std::string> emp;
               $$->code.push_back(emp);
               $$->jump_inst.push_back("     jne");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(1);
          }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               current_lab++;
          }
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               $$->patch.push_back($3->patch[i]);
               $$->jump_inst.push_back($3->jump_inst[i]);
               $$->location.push_back($$->code.size()-1);
               s.clear();
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          if(!$3->isBool){

               if($3->offset_loc==-1){
                    $$->code.back().push_back("   movl (%esp), %edx\n");
                    $$->code.back().push_back("   addl $4, %esp\n");               
               }else if($3->offset_loc==0){

                    $$->code.back().push_back("  movl (%esp), %edx\n");
                    $$->code.back().push_back("  movl (%edx), %edx\n");
                    $$->code.back().push_back("  addl $4, %esp\n");
                    
               }else{

                    $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");
               }
               $$->code.back().push_back("   cmpl $0, %edx\n");
               $$->jump_inst.push_back("     jne");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(1);

               std::vector<std::string> emp;
               $$->code.push_back(emp);
               $$->jump_inst.push_back("     je");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(0);
          }
          $$->isBool=true;
          $$->type="int";
     }    
     ;

logical_and_expression: 
     equality_expression
     {
          // int fall=$$->fall;
          $$ = $1;
          // $$->fall=fall;
          $$->isBool=$1->isBool;
          // std::cout<<"FINALOGAND\n";
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:x){

          //                std::cout<<z;
          //           }
          //      }
          // }

          // std::cout<<"FINALOGAND\n";
          /*std::cout<<"FIKNSDFand\n";

          for(auto &x:$$->code){

               for(auto &y:x){

                    std::cout<<y;
               }
          }
          std::cout<<"FIKNSDFand\n";*/
     }
          
     | 
     logical_and_expression AND_OP equality_expression
     {    
          //TODO what about structs? No check?
          //TODO test all combinations of this, not too sure about this, including arrays, structs
          
          $$ = new op_binary_astnode("AND_OP",$1,$3);
          /*
          if(($1->type=="int" || $1->type=="float" || dereference($1->type)!="") && ($3->type=="int" || $3->type=="float" || dereference($3->type)!="")){
               $$->type = "int";
               $$->lval = 0;
          }
          else {
               std::cout<<"Error in AND, can't take && "<<$1->type<<" and "<<$3->type<<std::endl;
               exit(0);
          }*/

          $$->isBool = true;

          $$->type="int";

          //TODO If isBool is false and rest of code
     
          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    lab_need=1;
               }else{

                    $$->code.push_back(s);
                    $$->patch.push_back(0);
                    $$->jump_inst.push_back($1->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    s.clear();
               }
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          if(!$1->isBool){
               
               if($1->offset_loc==-1){
                    $$->code.back().push_back("   movl (%esp), %edx\n");
                    $$->code.back().push_back("   addl $4, %esp\n");               
               }else if($1->offset_loc==0){

                    $$->code.back().push_back("  movl (%esp), %edx\n");
                    $$->code.back().push_back("  movl (%edx), %edx\n");
                    $$->code.back().push_back("  addl $4, %esp\n");
                    
               }else{

                    $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");
               }
               $$->code.back().push_back("   cmpl $0, %edx\n");
               $$->code.back().push_back("   jne .L"+std::to_string(current_lab)+"\n");
               lab_need=1;
               std::vector<std::string> emp;
               $$->code.push_back(emp);
               $$->jump_inst.push_back("     je");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(0);
          }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               current_lab++;
          }
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               $$->patch.push_back($3->patch[i]);
               $$->jump_inst.push_back($3->jump_inst[i]);
               $$->location.push_back($$->code.size()-1);
               s.clear();
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          if(!$3->isBool){

               if($3->offset_loc==-1){
                    $$->code.back().push_back("   movl (%esp), %edx\n");
                    $$->code.back().push_back("   addl $4, %esp\n");               
               }else if($3->offset_loc==0){

                    $$->code.back().push_back("  movl (%esp), %edx\n");
                    $$->code.back().push_back("  movl (%edx), %edx\n");
                    $$->code.back().push_back("  addl $4, %esp\n");
                    
               }else{

                    $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");
               }
               $$->code.back().push_back("   cmpl $0, %edx\n");
               $$->jump_inst.push_back("     jne");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(1);

               std::vector<std::string> emp;
               $$->code.push_back(emp);
               $$->jump_inst.push_back("     je");
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back(0);
          }
     }
     ;

equality_expression: 
     relational_expression
     {
          // int fall=$$->fall;
          $$ = $1;

          // std::cout<<"FINAEQUAL\n";
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:x){

          //                std::cout<<z;
          //           }
          //      }
          // }

          // std::cout<<"FINAEQUAL\n";
          // $$->fall=fall;
          $$->isBool=$1->isBool;
          /*std::cout<<"FIKNSDFrel\n";

          for(auto &x:$$->code){

               for(auto &y:x){

                    std::cout<<y;
               }
          }
          std::cout<<"FIKNSDFrel\n";*/

     }
          
     |
     equality_expression EQ_OP relational_expression
     {
          // std::cerr<<$3->type<<"\n";
          
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
               $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
               
               /*//error
               
               std::string err = "error in EQ_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";

               IPL::Parser::error( @2, err );
               //TODO Tsest this
               //exit(0);*/
          }
          

          // $$ = new exp_astnode();
          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          // std::cout<<"REACHED"<<std::endl;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }
               // std::cout<<"REACHED "<<i<<std::endl;


               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // std::cout<<"REACHED"<<std::endl;

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          // std::cout<<"REACHED2"<<std::endl;

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     je");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jne");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
          /*std::cout<<"FIKNSDFeq\n";

          for(auto &x:$$->code){

               for(auto &y:x){

                    std::cout<<y;
               }
          }
          std::cout<<"FIKNSDFeq\n";*/


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
               
               $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
               /*std::string err = "error in NE_OP, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               std::cerr<<"Hello";
               IPL::Parser::error( @2, err );
               //exit(0);*/
          }

          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jne");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     je");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
     }
     
relational_expression: 
     additive_expression
     {
          // int fall=$$->fall;
          $$ = $1;
          // $$->fall=fall;
          $$->isBool=$1->isBool;
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

          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               s.clear();
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jl");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jge");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
          
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
          // TODO isBool handle and add equality CMP instruction as well

          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jg");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jle");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
          
          // std::cout<<"FUKAKA\n";
          
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:y){

          //                std::cout<<z;
          //           }
          //      }
          // }
          // std::cout<<"FUKAKA\n";

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

          
          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               // std::cout<<"HULA\n";

               // for(auto x:s){

               //      std::cout<<x;
               // }
               // std::cout<<"HULA\n";
               s.clear();
               lab_need=1;
          }

          ;

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }
          // std::cout<<"HULA2\n";

          // for(auto x:s){

          //      std::cout<<x;
          // }
          // std::cout<<"HULA2\n";

          $$->code.push_back(s);

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               // std::cout<<"HULA3\n";

               // for(auto x:s){

               //      std::cout<<x;
               // }
               // std::cout<<"HULA3\n";
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          // std::cout<<"HULA4\n";

          // for(auto x:s){

          //      std::cout<<x;
          // }
          // std::cout<<"HULA4\n";

          $$->code.push_back(s);

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          // std::cout<<"HULA6\n";

          // for(auto x:s){

          //      std::cout<<x;
          // }
          // std::cout<<"HULA6\n";
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jle");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jg");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
          // std::cout<<"FINA\n";
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:x){

          //                std::cout<<z;
          //           }
          //      }
          //      std::cout<<"BREAK\n";
          // }

          // for(auto x:$$->location){

          //      std::cout<<"LOC "<<x<<"\n";
          // }

          // std::cout<<"FINA\n";
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
     
          
          $$->isBool=true;
          // TODO isBool handle and add equality CMP instruction as well

          std::vector<std::string> s;
          
          int curr_pos=0;

          int lab_need=0;
          
          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }

               // If true, then go to next expression set stack to 1

               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // For other expression

          // if(!$1->isBool){
               
          //      if($1->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($1->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx\n");

          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          curr_pos=0;

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          lab_need=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);

          // if(!$3->isBool){

          //      if($3->offset_loc==-1){
          //           $$->code.back().push_back("   movl -4(%esp), %edx\n");
          //           $$->code.back().push_back("   addl $4, %esp\n");               
          //      }else{

          //           $$->code.back().push_back("   movl "+std::to_string($3->offset_loc)+",(%ebp), %edx\n");
          //      }
          //      $$->code.back().push_back("   cmpl $0, %edx");
          //      $$->jump_inst.push_back("     jne");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(true);

          //      std::vector<std::string> emp;
          //      $$->code.push_back(emp);
          //      $$->jump_inst.push_back("     je");
          //      $$->location.push_back($$->code.size()-1);
          //      $$->patch.push_back(false);
          // }

          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               current_lab+=3;
          }

          if($3->offset_loc==-1){

               s.push_back("   movl (%esp), %edx\n");               
               s.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               s.push_back("   movl (%esp), %eax\n");               
               s.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  movl (%eax), %eax\n");
               s.push_back("  addl $4, %esp\n");
                   
          }else{

               s.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          s.push_back("   cmp %edx, %eax\n");
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jge");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(1);
          s.clear();
          
          $$->code.push_back(s);
          $$->jump_inst.push_back("     jl");
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(0);
          
          $$->isBool=true;
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
          int mul=1;
          int c1=0;
          int c3=0;
          
          if($1->type==$3->type && $1->type=="int")
          {
               $$ = new op_binary_astnode("PLUS_INT",$1,$3);
               $$->type = "int";
               $$->lval = 0;
               // mul*=get_size_of_element($1->type);
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
               // mul*=get_size_of_element($1->type);

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
               mul*=get_size_of_element($3->type,global_symbol_table);
               c1=1;

          }
          else if ($3->type=="int" && dereference($1->type)!=""){
               $$ = new op_binary_astnode("PLUS_INT",$1,$3);
               $$->type = $1->type;
               $$->lval = 0;
               mul*=get_size_of_element($1->type,global_symbol_table);
               c3=1;
          }
          else {
               //error
               std::string err = "error in ADD, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error

          }

          std::vector<std::string> s;
          int curr_pos=0;
          int lab_need=0;

          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }
               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }
          s.clear();
          lab_need=0;
          curr_pos=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }


          std::vector<std::string> cd;

          if($3->offset_loc==-1){

               cd.push_back("   movl (%esp), %edx\n");               
               cd.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               cd.push_back("  movl (%esp), %edx\n");
               cd.push_back("  movl (%edx), %edx\n");
               cd.push_back("  addl $4, %esp\n");
                   
          }
          else if($3->type.find('[')!=std::string::npos){

               cd.push_back("   leal "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }else{

               cd.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if(c3){

               cd.push_back(" imull     $"+std::to_string(mul)+", %edx\n");
          }
          
          if($1->offset_loc==-1){

               cd.push_back("   movl (%esp), %eax\n");               
               cd.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               cd.push_back("  movl (%esp), %eax\n");
               cd.push_back("  movl (%eax), %eax\n");
               cd.push_back("  addl $4, %esp\n");
               // cd.push_back("  addl %eax, %edx\n");
                   
          }else if($1->type.find('[')!=std::string::npos){

               cd.push_back("   leal "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }else{

               cd.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }

          if(c1){

               cd.push_back(" imull     $"+std::to_string(mul)+", %eax\n");
          }

          cd.push_back("  addl %eax, %edx\n");

          cd.push_back("   subl $4, %esp\n");
          cd.push_back("   movl %edx, (%esp)\n");

          $$->code.push_back(cd);
          $$->isBool=false;
     }
          
     | additive_expression '-' multiplicative_expression
     {
          // $$ = new op_binary_astnode("MINUS_X",$1,$3);
          int mul=1;
          int c1=0,c3=0;
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
               mul*=get_size_of_element($1->type,global_symbol_table);
               c1=1;
          }
          else if (dereference($1->type)!="" && $3->type=="int"){
               $$ = new op_binary_astnode("MINUS_INT",$1,$3);
               $$->type = $1->type;
               $$->lval = 0;
               mul*=get_size_of_element($1->type,global_symbol_table);
               c3=1;
          }
          else {
               //error
               std::string err = "error in MINUS, type mistmatch, LHS: "+$1->type+" RHS: "+$3->type+"\n";
               IPL::Parser::error( @2, err );
               //TODO Modify Error
               //exit(0);
          }

          
          std::vector<std::string> s;
          int curr_pos=0;
          int lab_need=0;

          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }
               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }
          s.clear();
          lab_need=0;
          curr_pos=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }


          std::vector<std::string> cd;

          if($3->offset_loc==-1){

               cd.push_back("   movl (%esp), %edx\n");               
               cd.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
               // s.push_back("  addl %eax, %edx");
                   
          }else if($3->type.find('[')!=std::string::npos){

               cd.push_back("   leal "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }else{

               cd.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }
          cd.push_back("    neg  %edx\n");

          if(c3){

               cd.push_back(" imull     $"+std::to_string(mul)+", %edx\n");
          }

          if($1->offset_loc==-1){

               cd.push_back("   movl (%esp), %eax\n");               
               cd.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               cd.push_back("  movl (%esp), %eax\n");
               cd.push_back("  movl (%eax), %eax\n");
               cd.push_back("  addl $4, %esp\n");
               // cd.push_back("  addl %eax, %edx\n");
                   
          }else if($1->type.find('[')!=std::string::npos){

               cd.push_back("   leal "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }else{

               cd.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");
          }

          if(c1){

               cd.push_back(" imull     $"+std::to_string(mul)+", %eax\n");
          }

          cd.push_back("   addl %eax, %edx\n");
          cd.push_back("   subl $4, %esp\n");
          cd.push_back("   movl %edx, (%esp)\n");

          $$->code.push_back(cd);
          $$->isBool=false;
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
               $$->isBool=false;

               std::vector<std::string> s;
               
               int curr_pos=0;

               int lab_need=0;
               
               for(int i=0;i<int($2->location.size());i++){

                    while(curr_pos<=$2->location[i]){

                         s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                         curr_pos++;
                    }

                    // If true, then go to next expression set stack to 1

                    if($2->patch[i]==1){

                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    }else{
                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($2->code.size())){

                    s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                    curr_pos++;
               }

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    current_lab+=3;
               }


               $$->code.push_back(s);
               s.clear();

               $$->offset_loc=-1;

               if($2->offset_loc!=0){

                    s.push_back("  leal "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");
                    // s.push_back("  addl $"+std::to_string($2->offset_loc)+", %edx\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl %edx, (%esp)\n");
               
               }else{

                    // s.push_back("  movl (%esp), %edx\n");
                    // // s.push_back("  movl (%edx), %edx\n");
                    // // s.push_back("  addl $4, %esp\n");
                    // s.push_back("  movl %edx, (%esp)\n");
                    
               }

               $$->code.push_back(s);
               
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

               std::vector<std::string> s;
               
               int curr_pos=0;

               int lab_need=0;
               
               for(int i=0;i<int($2->location.size());i++){

                    while(curr_pos<=$2->location[i]){

                         s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                         curr_pos++;
                    }

                    // If true, then go to next expression set stack to 1

                    if($2->patch[i]==1){

                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    }else{
                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($2->code.size())){

                    s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                    curr_pos++;
               }

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    current_lab+=3;
               }


               $$->code.push_back(s);
               s.clear();
               $$->offset_loc=0;

               $$->isBool=false;
               // std::vector<std::string> s;

               if($2->offset_loc==-1){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               }else if($2->offset_loc==0){

                    s.push_back("  movl (%esp), %edx\n");
                    // s.push_back("  movl (%edx), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               
               }else{
                    
                    if($2->offset_loc>0){

                         s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");
                         // s.push_back("  addl %eax, %edx\n");
                              
                    }else{

                         s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");
                         // s.push_back("  movl (%edx), %edx\n");
                         
                         // s.push_back("  addl %eax, %edx\n");
                    
                    }
                    // s.push_back("  leal "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");
                    
               }
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl %edx, (%esp)\n");

               $$->code.push_back(s);
          }
          else if($1 == "NOT"){
               if($2->type!="int" && $2->type!="float" && dereference($2->type)==""){
                    std::string err="Type Error in Not" +$2->type +"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);    
               }
               $$->type = "int";
               $$->lval = 0;
               $$->isBool=true;

               std::vector<std::string> s;
               
               int curr_pos=0;

               // int lab_need=0;
               
               for(int i=0;i<int($2->location.size());i++){

                    while(curr_pos<=$2->location[i]){

                         s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                         curr_pos++;
                    }

                    // If true, then go to next expression set stack to 1

                    if($2->patch[i]==1){

                         $$->patch.push_back(0);
                    }else if($2->patch[i]==0){
                         $$->patch.push_back(1);
                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }else{

                         $$->patch.push_back(2);
                    }
                    $$->code.push_back(s);
                    $$->location.push_back($$->code.size()-1);
                    $$->jump_inst.push_back($2->jump_inst[i]);

                    s.clear();
               }

               while(curr_pos<int($2->code.size())){

                    s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                    curr_pos++;
               }


               $$->code.push_back(s);
               s.clear();

               if(!$2->isBool){

                    if($2->offset_loc==-1){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                    }else if($2->offset_loc==0){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  movl (%edx), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                    
                    }else{

                         s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");                         
                    }
                    s.push_back("  cmp $0, %edx\n");
                    $$->code.push_back(s);
                    s.clear();
                    $$->location.push_back($$->code.size()-1);
                    $$->jump_inst.push_back("     jne");
                    $$->patch.push_back(0);
                    
                    $$->code.push_back(s);
                    $$->location.push_back($$->code.size()-1);
                    $$->jump_inst.push_back("     je");
                    $$->patch.push_back(1);
                    
               }
               // std::cout<<"FUTTT\n";

               // for(auto x:$$->code){

               //      for(auto y:x){

               //           for(auto z:y){

               //                std::cout<<z;
               //           }
               //      }
               // }
               // std::cout<<"FUTTT\n";

               // std::cout<<"BHAI "<<$2->offset_loc<<"\n";
          }

          else if($1=="TO_FLOAT"){
               if($2->type!="int" || $2->type!="float"){
                    std::string err="Error in to_float type"+$2->type+"\n";
                    
                    IPL::Parser::error( @2, err );

                    //exit(0);    
               }
               $$->type = "float";
               $$->lval = $2->lval;
               $$->isBool=false;

          }

          else if($1=="TO_INT"){
               if($2->type!="int" || $2->type!="float"){
                    std::string err="Error in to_int type"+$2->type+"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);    
               }
               $$->type = "int";
               $$->isBool=false;
               $$->lval = $2->lval;
          }
          else{
               //UMINUS
               if($2->type!="int" && $2->type!="float"){
                    std::string err="Error in minus with types "+$2->type+"\n";
                    IPL::Parser::error( @2, err );
                    //exit(0);
               }
               std::vector<std::string> s;
               
               int curr_pos=0;

               int lab_need=0;
               
               for(int i=0;i<int($2->location.size());i++){

                    while(curr_pos<=$2->location[i]){

                         s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                         curr_pos++;
                    }

                    // If true, then go to next expression set stack to 1

                    if($2->patch[i]==1){

                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
                    }else{
                         s.push_back($2->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($2->code.size())){

                    s.insert(s.end(),$2->code[curr_pos].begin(),$2->code[curr_pos].end());
                    curr_pos++;
               }

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    current_lab+=3;
               }


               $$->code.push_back(s);
               s.clear();
               $$->type = $2->type;
               $$->isBool=false;
               $$->lval = 0;

               // std::vector<std::string> s;

               if($2->offset_loc==-1){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               }else if($2->offset_loc==0){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  movl (%edx), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               
               }else{
                    s.push_back("  movl "+std::to_string($2->offset_loc)+"(%ebp), %edx\n");
               }
               s.push_back("  neg  %edx\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl %edx, (%esp)\n");

               $$->code.push_back(s);
          }

     }
     ;

multiplicative_expression: 
     unary_expression
     {
          $$ = $1;
          // std::vector<std::string> cd;

          // if($1->offset_loc==-1){

          //      cd.push_back("   movl -4(%esp), %edx\n");               
          //      cd.push_back("   addl $4, %esp\n");               
          // }else{

          //      cd.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");               
          // }
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

          std::vector<std::string> s;
          int curr_pos=0;
          int lab_need=0;

          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }
               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }
          s.clear();
          lab_need=0;
          curr_pos=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }

          std::vector<std::string> cd;

          if($3->offset_loc==-1){

               cd.push_back("   movl (%esp), %edx\n");               
               cd.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               cd.push_back("  movl (%esp), %edx\n");
               cd.push_back("  movl (%edx), %edx\n");
               cd.push_back("  addl $4, %esp\n");
          
          }else{

               cd.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");               
          }

          if($1->offset_loc==-1){

               cd.push_back("   imull     (%esp), %edx\n");               
               cd.push_back("   addl $4, %esp\n");
               
          }else if($1->offset_loc==0){

               cd.push_back("  movl (%esp), %eax\n");
               cd.push_back("  movl (%eax), %eax\n");
               cd.push_back("  addl $4, %esp\n");
               cd.push_back(" imull     %eax, %edx\n");               
          
          }else{

               cd.push_back("   imull     "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");               
          }

          cd.push_back("   subl $4, %esp\n");
          cd.push_back("   movl %edx, (%esp)\n");

          $$->code.push_back(cd);
          $$->isBool=false;
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

          std::vector<std::string> s;
          int curr_pos=0;
          int lab_need=0;

          for(int i=0;i<int($1->location.size());i++){

               while(curr_pos<=$1->location[i]){

                    s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
                    curr_pos++;
               }
               if($1->patch[i]==1){

                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($1->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($1->code.size())){

               s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }
          s.clear();
          lab_need=0;
          curr_pos=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               $$->code.push_back(s);
               
               current_lab+=3;
          }

          std::vector<std::string> cd;

          if($3->offset_loc==-1){

               cd.push_back("   movl (%esp), %ecx\n");               
               cd.push_back("   addl $4, %esp\n");               
          }else if($3->offset_loc==0){

               cd.push_back("  movl (%esp), %ecx\n");
               cd.push_back("  movl (%ecx), %ecx\n");
               cd.push_back("  addl $4, %esp\n");
          
          }else{

               cd.push_back("   movl "+std::to_string($3->offset_loc)+"(%ebp), %ecx\n");               
          }
          if($1->offset_loc==-1){

               cd.push_back("   movl (%esp), %eax\n");               
               cd.push_back("   addl $4, %esp\n");
          }else if($1->offset_loc==0){

               cd.push_back("  movl (%esp), %eax\n");
               cd.push_back("  movl (%eax), %eax\n");
               cd.push_back("  addl $4, %esp\n");
          
          }else{

               cd.push_back("   movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");               
          }
          
          cd.push_back("   movl $0, %edx\n");
          cd.push_back("   cltd\n");
          cd.push_back("   idivl   %ecx\n");
          cd.push_back("   subl $4, %esp\n");
          cd.push_back("   movl %eax, (%esp)\n");

          $$->code.push_back(cd);
          $$->isBool=false;
     }
     ;

postfix_expression: 
     primary_expression
     {
          $$ = $1;
          // std::cout<<"FINAPRIM\n";
          // for(auto x:$$->code){

          //      for(auto y:x){

          //           for(auto z:x){

          //                std::cout<<z;
          //           }
          //      }
          // }

          // std::cout<<"FINAPRIM\n";
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

          $$->code=$1->code;
          $$->location=$1->location;
          $$->jump_inst=$1->jump_inst;
          $$->patch=$1->patch;

          $$->isBool=false;

          std::vector<std::string> s;

          int lab_need=0;
          int curr_pos=0;

          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }
               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");

                    // $$->patch.push_back(false);
                    // $$->jump_inst.push_back($1->jump_inst[i]);
                    // lab_need=1;
                    // $$->location.push_back($$->code.size()-1);
               }
               $$->code.push_back(s);
               s.clear();
               lab_need=1;
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          if(lab_need){

               s.push_back(".L"+std::to_string(current_lab)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $1, (%esp)\n");
               s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

               s.push_back(".L"+std::to_string(current_lab+1)+":\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl $0, (%esp)\n");

               s.push_back(".L"+std::to_string(current_lab+2)+":\n");
               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  addl $4, %esp\n");

               $$->code.push_back(s);
               s.clear();
               
               current_lab+=3;
          }

          if(!$3->isBool){

               if($3->offset_loc==-1){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               }else if($3->offset_loc==0){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  movl (%edx), %edx\n");
                    s.push_back("  addl $4, %esp\n");
                    
               }else{
                    s.push_back("  movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");
               }
          }

          int sz=get_size_of_element($1->type,global_symbol_table);

          s.push_back("  imull     $"+std::to_string(sz)+", %edx\n");

          if($1->offset_loc==-1){

               s.push_back("  movl (%esp), %eax\n");
               s.push_back("  addl $4, %esp\n");
               s.push_back("  addl %eax, %edx\n");
          }else if($1->offset_loc==0){

               s.push_back("  movl (%esp), %eax\n");
               // s.push_back("  movl (%edx), %edx\n");
               s.push_back("  addl $4, %esp\n");
               s.push_back("  addl %eax, %edx\n");
               
          }else{
               
               if($1->offset_loc>0){

                    s.push_back("  movl "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");
                    s.push_back("  addl %eax, %edx\n");
                         
               }else{

                    s.push_back("  leal "+std::to_string($1->offset_loc)+"(%ebp), %eax\n");
                    s.push_back("  addl %eax, %edx\n");
               
               }
               
          }
          s.push_back("  subl $4, %esp\n");
          s.push_back("  movl %edx, (%esp)\n");
          $$->code.push_back(s);
          $$->offset_loc=0;

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

          std::vector<std::string> s;

          s.push_back("  call "+$1+"\n");
          s.push_back("  subl $4, %esp\n");
          s.push_back("  movl %eax, (%esp)\n");

          $$->code.push_back(s);
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

               std::vector<std::string> types;

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

          
          std::vector<std::string> s;
          // s.push_back("  pushl     %eax\n");

          int co=4;

          for(int i=0;i<int($3.size());i++){
               
               int sz=4;
               for(int j=0;j<int(global_symbol_table.size());j++){

                    if(global_symbol_table[j].first==$3[i]->type){

                        sz=global_symbol_table[j].second->size; 
                    }
               }
               co+=sz;

               int curr_pos=0;
               int lab_need=0;
               
               for(int j=0;j<int($3[i]->location.size());j++){

                    while(curr_pos<=$3[i]->location[j]){

                         s.insert(s.end(),$3[i]->code[curr_pos].begin(),$3[i]->code[curr_pos].end());
                         curr_pos++;
                    }
                    // std::cout<<"REACHED "<<i<<std::endl;


                    // If true, then go to next expression set stack to 1

                    if($3[i]->patch[j]==1){

                         s.push_back($3[i]->jump_inst[j]+" .L"+std::to_string(current_lab)+"\n");
                    }else{
                         s.push_back($3[i]->jump_inst[j]+" .L"+std::to_string(current_lab+1)+"\n");

                         // $$->patch.push_back(false);
                         // $$->jump_inst.push_back($1->jump_inst[i]);
                         // lab_need=1;
                         // $$->location.push_back($$->code.size()-1);
                    }
                    $$->code.push_back(s);
                    s.clear();
                    lab_need=1;
               }

               while(curr_pos<int($3[i]->code.size())){

                    s.insert(s.end(),$3[i]->code[curr_pos].begin(),$3[i]->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               s.clear();

               curr_pos=0;

               if(lab_need){

                    s.push_back(".L"+std::to_string(current_lab)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $1, (%esp)\n");
                    s.push_back("  jmp  .L"+std::to_string(current_lab+2)+"\n");

                    s.push_back(".L"+std::to_string(current_lab+1)+":\n");
                    s.push_back("  subl $4, %esp\n");
                    s.push_back("  movl $0, (%esp)\n");

                    s.push_back(".L"+std::to_string(current_lab+2)+":\n");
                    current_lab+=3;
                    $$->code.push_back(s);
                    s.clear();
               }

               // std::string ty=$3[i]->type;

               std::string ty=params[i]->symbol_type;

               if(ty.back()==']'){

                    if($3[i]->offset_loc==-1){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                         s.push_back("  pushl %edx\n");

                    }else if($3[i]->offset_loc==0){

                         s.push_back("  movl (%esp), %edx\n");
                         s.push_back("  addl $4, %esp\n");
                         s.push_back("  pushl %edx\n");
                    }else /*if(params[i]->symbol_type.find('[')!=std::string::npos)*/{

                         if($3[i]->type.find('[')!=std::string::npos){

                              s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                              s.push_back("  pushl %edx\n");
                         }else{
                              s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                              s.push_back("  pushl %edx\n");
                         } 
                         
                         s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                         s.push_back("  pushl %edx\n");
                    }/*else{

                         s.push_back("  movl "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                         s.push_back("  pushl %edx\n");
                    }*/
               }else{

                    if(ty.find('*')==std::string::npos && ty.substr(0,7)=="struct "){

                         //copy struct
                         if($3[i]->offset_loc==0){

                              int t=0;
                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");

                              while(t<sz){
                                   s.push_back("  pushl     (%edx)\n");
                                   s.push_back("  addl $4, %edx\n");
                                   t+=4;
                              }
                              
                         }else{

                              int t=0;
                              s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                              
                              while(t<sz){
                                   s.push_back("  pushl     (%edx)\n");
                                   s.push_back("  addl $4, %edx\n");
                                   t+=4;
                              }
                         }
                    }else{

                         if($3[i]->offset_loc==-1){

                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");
                              s.push_back("  pushl %edx\n");

                         }else if($3[i]->offset_loc==0){

                              s.push_back("  movl (%esp), %edx\n");
                              s.push_back("  addl $4, %esp\n");
                              s.push_back("  movl (%edx), %edx\n");
                              s.push_back("  pushl %edx\n");
                         }else{

                              if($3[i]->type.find('[')!=std::string::npos){

                                   s.push_back("  leal "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                                   s.push_back("  pushl %edx\n");
                              }else{
                                   s.push_back("  movl "+std::to_string($3[i]->offset_loc)+"(%ebp), %edx\n");
                                   s.push_back("  pushl %edx\n");
                              }               
                         }
                    }
               }

               $$->code.push_back(s);
               s.clear();
               
               // } if(ty.find('*')!=ty.end()&&ty.find('(')==ty.end()){

               //      //value
               // }else if(ty.find("(")!=ty.end()){

               //      //value
               // }else if(ty.substr(0,6)=="struct"){

               //      //value
               // }else{

               //      //value
               // }

               // if($3[i]->offset_loc==-1){

               //      s.push_back("  movl %(esp), %edx\n");
               //      s.push_back("  addl $4, %esp\n");
               //      s.push_back("  pushl %edx\n");

               // }else if($3[i]->offset_loc==0){

               //      s.push_back("  movl %(esp), %edx\n");
               //      s.push_back("  addl $4, %esp\n");
               //      s.push_back("  pushl %edx\n");
               // }else{

               //      s.push_back("  leal $"+std::to_string($3[i]->offset_loc)+", %(edx)\n");
               //      s.push_back("  pushl %edx\n");
               // }
          }
          s.push_back("  pushl     %eax\n");
          s.push_back("  call "+$1+"\n");
          s.push_back("  addl $"+std::to_string(co)+", %esp\n");
          s.push_back("  subl $4, %esp\n");
          s.push_back("  movl %eax, (%esp)\n");


          $$->code.push_back(s);
     }
          
     | postfix_expression '.' IDENTIFIER
     {
          $$ = new member_astnode($1,new identifier_astnode($3));
          int offset=0;
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
                         offset=lst[i]->offset;
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

          $$->code=$1->code;
          $$->location=$1->location;
          $$->jump_inst=$1->jump_inst;
          $$->patch=$1->patch;

          $$->isBool=false;

          std::vector<std::string> s;

          if($1->offset_loc!=0){

               s.push_back("  leal "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");
          }else{

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  addl $4, %esp\n");                  
          }
          s.push_back("  addl $"+std::to_string(offset)+", %edx\n");
          s.push_back("  subl $4, %esp\n");
          s.push_back("  movl %edx, (%esp)\n");  
          $$->offset_loc=0;
          $$->isBool=false;
          $$->code.push_back(s);
          s.clear();

     }
     
     | postfix_expression PTR_OP IDENTIFIER
     {
          $$ = new arrow_astnode($1,new identifier_astnode($3));
          int offset_var=0;
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
                         offset_var=lst[i]->offset;
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

          $$->code=$1->code;
          $$->location=$1->location;
          $$->jump_inst=$1->jump_inst;
          $$->patch=$1->patch;
          $$->offset_loc=0;

          $$->isBool=false;

          std::vector<std::string> s;

          if($1->offset_loc!=0){

               if($1->offset_loc==-1){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               }else{

                    s.push_back("  movl "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");
               }
          }else{

               s.push_back("  movl (%esp), %edx\n");  
               s.push_back("  addl $4, %esp\n");                  
               s.push_back("  movl (%edx), %edx\n");

          }
          s.push_back("  addl $"+std::to_string(offset_var)+", %edx\n");
          s.push_back("  subl $4, %esp\n");
          s.push_back("  movl %edx, (%esp)\n");  
          $$->offset_loc=0;
          $$->isBool=false;
          $$->code.push_back(s);
          s.clear();
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

          // for(int i=0;i<int($1->location.size());i++){

          //      while(curr_pos<=$1->location[i]){

          //           s.insert(s.end(),$1->code[curr_pos].begin(),$1->code[curr_pos].end());
          //           curr_pos++;
          //      }
          //      $$->code.push_back(s);
          //      $$->location
          //      s.clear();
          //      lab_need=1;
          // }

          // while(curr_pos<int($3->code.size())){

          //      s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
          //      curr_pos++;
          // }

          // $$->code.push_back(s);
          // s.clear();

          $$->code=$1->code;
          $$->location=$1->location;
          $$->jump_inst=$1->jump_inst;
          $$->patch=$1->patch;

          $$->isBool=false;

          std::vector<std::string> s;

          if($1->offset_loc!=0){

               s.push_back("  movl "+std::to_string($1->offset_loc)+"(%ebp), %edx\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl %edx, (%esp)\n");
               s.push_back("  addl $1, %edx\n");
               s.push_back("  movl %edx, "+std::to_string($1->offset_loc)+"(%ebp)\n");

          }else{

               s.push_back("  movl (%esp), %edx\n");
               s.push_back("  addl $4, %esp\n");
               s.push_back("  subl $4, %esp\n");
               s.push_back("  movl %eax, (%esp)\n");
               s.push_back("  addl $1, %eax\n");
               s.push_back("  movl %eax, (%edx)\n");
          }

          
          $$->offset_loc=-1;

          $$->code.push_back(s);
          s.clear();
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
                    $$->offset_loc = current_lst[i]->offset;
                    break;
               }
          }
          if(found==0){ //not in lst, search gst
               for(int i = 0; i < (int)global_symbol_table.size(); i++){
                    if(global_symbol_table[i].first==$1){
                         found = 1;
                         $$->type = global_symbol_table[i].second->symbol_type;
                         $$->lval = 1;
                         $$->offset_loc = current_lst[i]->offset;
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

          $$->isBool=false;
     }
                    
     | INT_CONSTANT
     {
          $$ = new intconst_astnode($1); //its string
          $$->type = "int";
          $$->lval = 0;

          std::string s1,s2;
          s1="   subl $4, %esp\n";
          s2="   movl $"+$1+", (%esp)\n";

          std::vector<std::string> cd;
          cd.push_back(s1);
          cd.push_back(s2);

          $$->code.push_back(cd);
          $$->isBool=false;
     }
          
     | '(' expression ')'
     {
          $$ = $2;
          // std::cout<<"   subl $4, %esp\n";
          // std::cout<<"   movl %eax, -4(%esp)\n";
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

          std::vector<std::string> s;
          
          int curr_pos=0;
          // std::cout<<"FIKNSDFch\n";

          // for(auto &x:$3->code){

          //      for(auto &y:x){

          //           std::cout<<y;
          //      }
          //      std::cout<<"Hel\n";
          // }
          // std::cout<<$3->location.size()<<"\n";
          // std::cout<<"FIKNSDFch\n";

          
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }

               if($3->patch[i]==0){

                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab+1)+"\n");
               }else{
                    s.push_back($3->jump_inst[i]+" .L"+std::to_string(current_lab)+"\n");
               }
               $$->code.push_back(s);
               s.clear();
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();
          /*std::cout<<"FIKNSDF\n";

          for(auto &x:$$->code){

               for(auto &y:x){

                    std::cout<<y;
               }
          }
          std::cout<<"FIKNSDF\n";*/

          if(!$3->isBool){

               if($3->offset_loc==-1){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  addl $4, %esp\n");
               }else if($3->offset_loc==0){

                    s.push_back("  movl (%esp), %edx\n");
                    s.push_back("  movl (%edx), %edx\n");
                    s.push_back("  addl $4, %esp\n");
                    
               }else{

                    s.push_back("  movl "+std::to_string($3->offset_loc)+"(%ebp), %edx\n");
               }
               s.push_back("  cmp $0, %edx\n");

               s.push_back("  jne  .L"+std::to_string(current_lab)+"\n");
               s.push_back("  je  .L"+std::to_string(current_lab+1)+"\n");
               $$->code.push_back(s);
               s.clear();
          }

          curr_pos=0;

          s.push_back(".L"+std::to_string(current_lab)+": \n");
          // assert($5->location.size()==0);

          for(int i=0;i<int($5->location.size());i++){

               while(curr_pos<=$5->location[i]){

                    s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
                    curr_pos++;
               }

               $$->code.push_back(s);
               $$->jump_inst.push_back($5->jump_inst[i]);
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back($5->patch[i]);

               s.clear();
          }

          while(curr_pos<int($5->code.size())){

               s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(2);
          $$->jump_inst.push_back("     jmp ");
          // next_needed=1;

          s.clear();

          s.push_back(".L"+std::to_string(current_lab+1)+": \n");
          
          // assert($7->location.size()==0);

          curr_pos=0;
          for(int i=0;i<int($7->location.size());i++){

               while(curr_pos<=$7->location[i]){

                    s.insert(s.end(),$7->code[curr_pos].begin(),$7->code[curr_pos].end());
                    curr_pos++;
               }

               
               $$->code.push_back(s);
               $$->jump_inst.push_back($7->jump_inst[i]);
               $$->location.push_back($$->code.size()-1);
               $$->patch.push_back($7->patch[i]);
               s.clear();
          }

          while(curr_pos<int($7->code.size())){

               s.insert(s.end(),$7->code[curr_pos].begin(),$7->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          $$->location.push_back($$->code.size()-1);
          $$->patch.push_back(2);
          $$->jump_inst.push_back("     jmp ");
          // $$->code.push_back(s);
          s.clear();
          current_lab+=2;
     }
     ;

iteration_statement: 
     WHILE '(' expression ')' statement
     {
          $$ = new while_astnode($3,$5);
          int curr_pos=0;
          std::vector<std::string> s;
          s.push_back(".L"+std::to_string(current_lab)+":\n");
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }

               if($3->patch[i]==1){

                    s.push_back($3->jump_inst[i]+"     .L"+std::to_string(current_lab+1)+"\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($3->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back(2);
                    s.clear();
               }
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          // $$->location.push_back($$->code.size()-1);
          // $$->patch.push_back(2);
          // $$->jump_inst.push_back("     jmp ");
          // next_needed=1;

          s.clear();

          curr_pos=0;

          s.push_back(".L"+std::to_string(current_lab+1)+":\n");

          for(int i=0;i<int($5->location.size());i++){

               while(curr_pos<=$5->location[i]){

                    s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
                    curr_pos++;
               }

               if($5->patch[i]==2){

                    s.push_back("  jmp  .L"+std::to_string(current_lab)+"\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($5->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back($5->patch[i]);
                    s.clear();
               }
          }

          while(curr_pos<int($5->code.size())){

               s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
               curr_pos++;
          }

          s.push_back("  jmp  .L"+std::to_string(current_lab)+"\n");

          $$->code.push_back(s);
          s.clear();
          current_lab+=2;

     }
     | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
     {
          $$ = new for_astnode($3,$5,$7,$9);
          int curr_pos=0;

          std::vector<std::string> s;

          // s.push_back("  jmp .L"+std::to_string(current_lab)+"\n");
          for(int i=0;i<int($3->location.size());i++){

               while(curr_pos<=$3->location[i]){

                    s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
                    curr_pos++;
               }

               if($3->patch[i]==2){

                    s.push_back($3->jump_inst[i]+"     .L"+std::to_string(current_lab)+":\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($3->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back($3->patch[i]);
                    s.clear();
               }
          }

          while(curr_pos<int($3->code.size())){

               s.insert(s.end(),$3->code[curr_pos].begin(),$3->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          // $$->location.push_back($$->code.size()-1);
          // $$->patch.push_back(2);
          // $$->jump_inst.push_back("     jmp ");
          // next_needed=1;

          s.clear();

          curr_pos=0;

          s.push_back(".L"+std::to_string(current_lab)+":\n");

          for(int i=0;i<int($5->location.size());i++){

               while(curr_pos<=$5->location[i]){

                    s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
                    curr_pos++;
               }

               if($5->patch[i]){

                    s.push_back($5->jump_inst[i]+"   .L"+std::to_string(current_lab+1)+"\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($5->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back(2);
                    s.clear();
                         
               }

               // s.clear();
          }

          while(curr_pos<int($5->code.size())){

               s.insert(s.end(),$5->code[curr_pos].begin(),$5->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          curr_pos=0;

          s.push_back(".L"+std::to_string(current_lab+1)+":\n");

          for(int i=0;i<int($9->location.size());i++){

               while(curr_pos<=$9->location[i]){

                    s.insert(s.end(),$9->code[curr_pos].begin(),$9->code[curr_pos].end());
                    curr_pos++;
               }

               if($9->patch[i]==2){

                    s.push_back($9->jump_inst[i]+"   .L"+std::to_string(current_lab+2)+"\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($9->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back($9->patch[i]);
                    s.clear();
                         
               }

               // s.clear();
          }

          while(curr_pos<int($9->code.size())){

               s.insert(s.end(),$9->code[curr_pos].begin(),$9->code[curr_pos].end());
               curr_pos++;
          }

          $$->code.push_back(s);
          s.clear();

          curr_pos=0;

          s.push_back(".L"+std::to_string(current_lab+2)+":\n");

          for(int i=0;i<int($7->location.size());i++){

               while(curr_pos<=$7->location[i]){

                    s.insert(s.end(),$7->code[curr_pos].begin(),$7->code[curr_pos].end());
                    curr_pos++;
               }

               if($7->patch[i]){

                    s.push_back($7->jump_inst[i]+"   .L"+std::to_string(current_lab+1)+"\n");
               }else{

                    $$->code.push_back(s);
                    $$->jump_inst.push_back($7->jump_inst[i]);
                    $$->location.push_back($$->code.size()-1);
                    $$->patch.push_back(0);
                    s.clear();       
               }

               // s.clear();
          }

          while(curr_pos<int($7->code.size())){

               s.insert(s.end(),$7->code[curr_pos].begin(),$7->code[curr_pos].end());
               curr_pos++;
          }
          s.push_back("  jmp  .L"+std::to_string(current_lab)+"\n");

          $$->code.push_back(s);
          s.clear();
          current_lab+=3;
          
     }
     ;


%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message;
   exit(1);
}


