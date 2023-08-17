#include <vector>
#include <string>
#include "typeExp.hh"
namespace IPL
{
     class abstract_astnode
     {
     public:
          virtual void print(int blanks) = 0;
          enum typeExp astnode_type;
           //doing a jugaad

          //protected:
     };

     class statement_astnode : public abstract_astnode
     {
          public:
               std::vector<std::vector<std::string>> code; //Blocks of code with gaps for true and false
               std::vector<int> patch; //Whether the instruction following code block is for true or false
               std::vector<std::string> jump_inst; // The actual jump instruction
               std::vector<int> location; // The location of the jump instruction in "code"
          
     };

     class exp_astnode : public abstract_astnode
     {
          public:
               std::string type;
               int lval;
               int offset_loc=-1;
               bool fall;
               bool isBool;
               std::vector<std::vector<std::string>> code; //Blocks of code with gaps for true and false
               std::vector<int> patch; //Whether the instruction following code block is for true or false or next
               std::vector<std::string> jump_inst; // The actual jump instruction
               std::vector<int> location; // The location of the jump instruction in "code"
               exp_astnode() {}
               virtual void print(int blanks);
               virtual ~exp_astnode() {}
     };

     class ref_astnode : public exp_astnode
     {
          public:
               virtual ~ref_astnode() {}
     };

     class empty_astnode : public statement_astnode
     {
          
          public:
          empty_astnode();
          void print(int blanks);
     };

     class seq_astnode : public statement_astnode
     {
          public:
               std::vector<statement_astnode*> seq;
               seq_astnode();
               seq_astnode(std::vector<statement_astnode*> seq_);
               void print(int blanks);
     };

     class assignE_astnode : public exp_astnode
     {
     public:
          exp_astnode *left;
          exp_astnode *right;
          assignE_astnode(exp_astnode*,exp_astnode*);
          void print(int blanks);
     };

     class assignS_astnode : public statement_astnode
     {
     public:
          exp_astnode *left;
          exp_astnode *right;
          assignS_astnode(assignE_astnode *Node);
          void print(int blanks);
     };

     class return_astnode : public statement_astnode
     {
     public:
          exp_astnode *return_exp;
          return_astnode(exp_astnode *return_exp_);
          void print(int blanks);
     };

     class if_astnode : public statement_astnode
     {
     public:
          exp_astnode *cond;
          statement_astnode *then;
          statement_astnode *else_exp;
          if_astnode(exp_astnode*cond_,statement_astnode*then_,statement_astnode*else_exp_);
          void print(int blanks);
     };

     class while_astnode : public statement_astnode
     {
     public:
          exp_astnode *cond;
          statement_astnode *stmt;
          while_astnode( exp_astnode *cond_,statement_astnode *stmt_);
          void print(int blanks);
     };

     class for_astnode : public statement_astnode
     {
     public:
          assignE_astnode *init;
          exp_astnode *guard;
          assignE_astnode *step;
          statement_astnode *body;
          for_astnode(assignE_astnode *init_, exp_astnode *guard_, assignE_astnode *step_, statement_astnode *body_);
          void print(int blanks);
     };

     class identifier_astnode : public ref_astnode
     {
     public:
          std::string identifier_name;
          identifier_astnode(std::string identifier_name_);
          void print(int blanks);
     };

     class proccall_astnode : public statement_astnode
     {
     public:
          identifier_astnode *fname;
          std::vector<exp_astnode*> params;
          proccall_astnode();
          proccall_astnode(identifier_astnode* fname_);
          proccall_astnode(identifier_astnode* fname_,std::vector<exp_astnode*> params_);
          void print(int blanks);
     };

     class arrayref_astnode : public ref_astnode
     {
     public:
          exp_astnode *array;
          exp_astnode *index;
          arrayref_astnode(exp_astnode*array_,exp_astnode*index_);
          void print(int blanks);
     };

     class member_astnode : public ref_astnode
     {
     public:
          exp_astnode *struct_exp;
          identifier_astnode* field;
          member_astnode(exp_astnode* struct_exp_,identifier_astnode* field_);
          void print(int blanks);
     };

     class arrow_astnode : public ref_astnode
     {
     public:
          exp_astnode *pointer;
          identifier_astnode* field;
          arrow_astnode(exp_astnode* pointer_,identifier_astnode* field_);
          void print(int blanks);
     };

     class op_binary_astnode : public exp_astnode
     {
     public:
          std::string op;
          exp_astnode *left;
          exp_astnode *right;
          op_binary_astnode(std::string op_,exp_astnode*left_,exp_astnode*right_);
          void print(int blanks);
     };

     class op_unary_astnode : public exp_astnode
     {
     public:
          std::string op;
          exp_astnode *child;
          op_unary_astnode(std::string op_,exp_astnode *child_);
          void print(int blanks);
     };

    

     class funcall_astnode : public exp_astnode
     {
     public:
          identifier_astnode* fname; //ASSUME it is always an identifier
          std::vector<exp_astnode*> params;
          funcall_astnode(identifier_astnode* fname_);
          funcall_astnode(identifier_astnode* fname_,std::vector<exp_astnode*> params_);
          void print(int blanks);
     };

     class intconst_astnode : public exp_astnode
     {
     public:
          int intconst;
          intconst_astnode(std::string intconst_);
          void print(int blanks);
     };

     class floatconst_astnode : public exp_astnode
     {
     public:
          float floatconst;
          floatconst_astnode(std::string floatconst_);
          void print(int blanks);
     };

     class stringconst_astnode : public exp_astnode
     {
     public:
          std::string stringconst;
          stringconst_astnode(std::string stringconst_);
          void print(int blanks);
     };

}