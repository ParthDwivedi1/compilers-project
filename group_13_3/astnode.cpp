#include "astnode.hh"
#include <iostream>
#include <string>


namespace IPL
{
    int tab = 4;
    assignS_astnode::assignS_astnode(assignE_astnode* Node){
        this->left = Node->left;
        this->right = Node->right;
        this->code=Node->code;
    }

    assignE_astnode::assignE_astnode(exp_astnode* left,exp_astnode* right){
        this->left = left;
        this->right = right;
    }

    op_unary_astnode::op_unary_astnode(std::string op_,exp_astnode *child_){
        this->child = child_;
        this->op = op_;
    }

    arrayref_astnode::arrayref_astnode(exp_astnode*array_,exp_astnode*index_){
        this->array = array_;
        this->index = index_;
    }

    funcall_astnode::funcall_astnode(identifier_astnode* fname_){
        this->fname = fname_;
        this->params = std::vector<exp_astnode*>(0);
    }

    funcall_astnode::funcall_astnode(identifier_astnode* fname_,std::vector<exp_astnode*> params_){
        this->fname = fname_;
        this->params = params_;
    }

    member_astnode::member_astnode(exp_astnode* struct_exp_, identifier_astnode* field_){
        this->struct_exp = struct_exp_;
        this->field = field_;
    }

    arrow_astnode::arrow_astnode(exp_astnode* pointer_,identifier_astnode* field_){
        this->pointer = pointer_;
        this->field = field_;
    }

    identifier_astnode::identifier_astnode(std::string identifier_name_){
        this->identifier_name = identifier_name_;
    }

    proccall_astnode::proccall_astnode(){
        
        std::string s="printf";
        this->fname = new identifier_astnode(s);
        this->params = std::vector<exp_astnode*>(0);
    }

    proccall_astnode::proccall_astnode(identifier_astnode* fname_){
        this->fname = fname_;
        this->params = std::vector<exp_astnode*>(0);
    }

    proccall_astnode::proccall_astnode(identifier_astnode* fname_,std::vector<exp_astnode*> params_){
        this->fname = fname_;
        this->params = params_;
    }

    op_binary_astnode::op_binary_astnode(std::string op_,exp_astnode*left_,exp_astnode*right_){
        this->op = op_;
        this->left = left_;
        this->right = right_;
    }

    seq_astnode::seq_astnode(){
        this->seq = std::vector<statement_astnode*>(0);
    }

    seq_astnode::seq_astnode(std::vector<statement_astnode*> seq_){
        this->seq = seq_;
    }

    empty_astnode::empty_astnode(){
        astnode_type = typeExp::EMPTY_ASTNODE;
    }

    return_astnode::return_astnode(exp_astnode *return_exp_){
        this->return_exp = return_exp_;
    }

    if_astnode::if_astnode(exp_astnode*cond_,statement_astnode*then_,statement_astnode*else_exp_){
        this->cond = cond_;
        this->then = then_;
        this->else_exp = else_exp_;
    }

    for_astnode::for_astnode(assignE_astnode *init_, exp_astnode *guard_, assignE_astnode *step_, statement_astnode *body_){
        this->init = init_;
        this->guard = guard_;
        this->step = step_;
        this->body = body_;
    }

    while_astnode::while_astnode( exp_astnode *cond_,statement_astnode *stmt_){
        this->cond = cond_;
        this->stmt = stmt_;
    }

    intconst_astnode::intconst_astnode(std::string intconst_){
        this->intconst = std::stoi(intconst_);
        this->astnode_type = typeExp::INTCONST_ASTNODE;
    }

    floatconst_astnode::floatconst_astnode(std::string floatconst_){
        //convert string to float
        this->floatconst = std::stof(floatconst_);
    }

    stringconst_astnode::stringconst_astnode(std::string stringconst_){
        this->stringconst = stringconst_;
    
    }

    void exp_astnode::print(int blanks)
    {
        std::cout<<"\"should not happen\""<<std::endl;
    }

    void empty_astnode::print(int blanks)
    {
        std::cout<<"\"empty\""<<std::endl;
    }

    void seq_astnode::print(int blanks)
    {
        std::cout<<"\"seq\": ["<<std::endl;
    
        for (uint i = 0; i < this->seq.size(); i++)
        {
            
            if(seq[i]->astnode_type == typeExp::EMPTY_ASTNODE){
                this->seq[i]->print(0);    
            }
            else {
                std::cout<<"{";
                this->seq[i]->print(0);
                std::cout<<"}"<<std::endl;   
            }
            if(i!=this->seq.size()-1){
                std::cout<<",";
            }
            std::cout<<std::endl;
        }
        std::cout<<"]"<<std::endl;
    }
    void assignS_astnode::print(int blanks)
    {
        std::cout<<"\"assignS\": {"<<std::endl;
        std::cout<<"\"left\": {"<<std::endl;
        this->left->print(0);
        std::cout<<"},"<<std::endl;
        std::cout<<"\"right\": {"<<std::endl;
        this->right->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;
    }
    void return_astnode::print(int blanks)
    {
        std::cout<<"\"return\": {"<<std::endl; 
        this->return_exp->print(0);
        std::cout<<"}"<<std::endl;
    }
    void if_astnode::print(int blanks)
    {
        std::cout<<"\"if\": {"<<std::endl;
        std::cout<<"\"cond\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->cond->print(0);
        std::cout<<"},"<<std::endl;

        
        if(this->then->astnode_type != typeExp::EMPTY_ASTNODE){
            std::cout<<"\"then\": {"<<std::endl;
            this->then->print(0);
            std::cout<<"},"<<std::endl;
        }
        else{
            std::cout<<"\"then\": "<<std::endl;
            this->then->print(0);
            std::cout<<","<<std::endl;
        }

        if(else_exp->astnode_type != typeExp::EMPTY_ASTNODE){
            std::cout<<"\"else\": {"<<std::endl;
            this->else_exp->print(0);
            std::cout<<"}"<<std::endl;
        }
        else{
            std::cout<<"\"else\": "<<std::endl;
            this->else_exp->print(0);
            std::cout<<std::endl;
        }

        std::cout<<"}"<<std::endl;
    }
    void while_astnode::print(int blanks)
    {
        std::cout<<"\"while\": {"<<std::endl;
        std::cout<<"\"cond\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->cond->print(0);
        std::cout<<"},"<<std::endl;

        if(stmt->astnode_type != typeExp::EMPTY_ASTNODE){
            std::cout<<"\"stmt\": {"<<std::endl;
            this->stmt->print(0);
            std::cout<<"}"<<std::endl;
        }
        else{
            std::cout<<"\"stmt\": "<<std::endl;
            this->stmt->print(0);
        }
        std::cout<<"}"<<std::endl;
    }
    void for_astnode::print(int blanks)
    {
        std::cout<<"\"for\": {"<<std::endl;
        std::cout<<"\"init\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->init->print(0);
        std::cout<<"},"<<std::endl;

        std::cout<<"\"guard\": {"<<std::endl;
        this->guard->print(0);
        std::cout<<"},"<<std::endl;
        
        std::cout<<"\"step\": {"<<std::endl;
        this->step->print(0);
        std::cout<<"},"<<std::endl;

        
        if(this->body->astnode_type!=typeExp::EMPTY_ASTNODE){
            std::cout<<"\"body\": {"<<std::endl;
            this->body->print(0);
            std::cout<<"}"<<std::endl;
        }
        else {
            std::cout<<"\"body\": "<<std::endl;
            this->body->print(0);
            std::cout<<std::endl;
        }

        std::cout<<"}"<<std::endl;
    }
    void proccall_astnode::print(int blanks)
    {
        std::cout<<"\"proccall\": {"<<std::endl;
        std::cout<<"\"fname\": {"<<std::endl;
        this->fname->print(0);
        std::cout<<"},"<<std::endl;
      
        std::cout<<"\"params\": ["<<std::endl;
        for (uint i = 0; i < this->params.size(); i++)
        {
            std::cout<<"{";
            this->params[i]->print(0);
            std::cout<<"}"<<std::endl;
            if(i!=this->params.size()-1){
                std::cout<<",";
            }
            std::cout<<std::endl;
        }
        std::cout<<"]"<<std::endl;
        std::cout<<"}"<<std::endl;
    }

    void identifier_astnode::print(int blanks)
    {
        std::cout<<"\"identifier\": \""<<this->identifier_name<<"\""<<std::endl;
    }
    void arrayref_astnode::print(int blanks)
    {
        std::cout<<"\"arrayref\": {"<<std::endl; 
        std::cout<<"\"array\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->array->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<","<<std::endl;
        
        std::cout<<"\"index\": {"<<std::endl;
        this->index->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;
    }
    void member_astnode::print(int blanks)
    {
        std::cout<<"\"member\": {"<<std::endl; 
        std::cout<<"\"struct\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->struct_exp->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<","<<std::endl;
        
        std::cout<<"\"field\": {"<<std::endl;
        this->field->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;     

    }
    void arrow_astnode::print(int blanks)
    {
        std::cout<<"\"arrow\": {"<<std::endl; 
        std::cout<<"\"pointer\": "<<std::endl;
        std::cout<<"{"<<std::endl;
        this->pointer->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<","<<std::endl;
        
        std::cout<<"\"field\": {"<<std::endl;
        this->field->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;        

        
    }
    void op_binary_astnode::print(int blanks)
    {
        std::cout<<"\"op_binary\": {"<<std::endl;
        std::cout<<"\"op\": \""<<op<<"\""<<std::endl;
        std::cout<<","<<std::endl;
        std::cout<<"\"left\": {"<<std::endl;
        this->left->print(0);
        std::cout<<"},"<<std::endl;

        std::cout<<"\"right\": {"<<std::endl;
        this->right->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;
    }
    void op_unary_astnode::print(int blanks)
    {
        std::cout<<"\"op_unary\": {"<<std::endl; 
        std::cout<<"\"op\": \""<<op<<"\""<<std::endl;
        std::cout<<","<<std::endl;
        std::cout<<"\"child\": {"<<std::endl;
        this->child->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;
    }

    void assignE_astnode::print(int blanks)
    {
        std::cout<<"\"assignE\": {"<<std::endl;
        std::cout<<"\"left\": {"<<std::endl;
        this->left->print(0);
        std::cout<<"},"<<std::endl;
        std::cout<<"\"right\": {"<<std::endl;
        this->right->print(0);
        std::cout<<"}"<<std::endl;
        std::cout<<"}"<<std::endl;
    }
    void funcall_astnode::print(int blanks)
    {
        std::cout<<"\"funcall\": {"<<std::endl;
        std::cout<<"\"fname\": {"<<std::endl;
        this->fname->print(0);
        std::cout<<"},"<<std::endl;
      
        std::cout<<"\"params\": ["<<std::endl;
        for (uint i = 0; i < this->params.size(); i++)
        {
            std::cout<<"{";
            this->params[i]->print(0);
            std::cout<<"}"<<std::endl;
            if(i!=this->params.size()-1){
                std::cout<<",";
            }
            std::cout<<std::endl;
        }
        std::cout<<"]"<<std::endl;
        std::cout<<"}"<<std::endl;
    }
    void intconst_astnode::print(int blanks)
    {
        std::cout<<"\"intconst\": "<<this->intconst<<std::endl;
    }
    void floatconst_astnode::print(int blanks)
    {
        std::cout<<"\"floatconst\": "<<this->floatconst<<std::endl;
    }
    void stringconst_astnode::print(int blanks)
    {
        std::cout<<"\"stringconst\": "<<this->stringconst<<std::endl;
    }
}