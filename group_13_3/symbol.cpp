#include <iostream>
#include <vector>
#include <algorithm>
#include "symbol.hh"

namespace IPL{
    bool cmp_lst(symbol_description* a, symbol_description*b){
        return a->name < b->name;
    }

    void symbol_description::print(){

        std::cout<<"[ ";
        std::cout<<"\""<<name<<"\","<<"\n";
        std::cout<<"\""<<symbol_class<<"\","<<"\n";
        std::cout<<"\""<<scope<<"\","<<"\n";
        std::cout<<size<<",\n";
        if(symbol_class=="fun"){
            std::cout<<0<<",\n";
        }
        else if(symbol_class=="struct"){
            std::cout<<"\"-\""<<",\n";
        }
        else {
            std::cout<<offset<<",\n";
        }
        std::cout<<"\""<<symbol_type<<"\""<<"\n";
        std::cout<<"]"<<std::endl;
    }

    Type_specifier::Type_specifier(std::string name){
        this->name = name;
        if(name=="int"){
            this->size = 4;
        }
        else if(name=="float"){
            this->size = 4;
        }
        else this->size = -1;
    }

     Type_specifier::Type_specifier(){
        this->name = "";
        if(name=="int"){
            this->size = 4;
        }
        else if(name=="float"){
            this->size = 4;
        }
        else this->size = -1;
    }
    Type_specifier::Type_specifier(Type_specifier* type_spec){
        this->name = type_spec->name;
        this->size = type_spec->size;
    }

    Declarator::Declarator(){
        std::string name = "";
        num_stars = 0;
        size = 0;
        arr_indices.resize(0);
        type_specifier = new Type_specifier();
    }

    int Declarator::get_size(){
        int type_size = this->type_specifier->size;
        std::string type_name = this->type_specifier->name;
        int temp_size = 1;
        
        for(uint j = 0; j < this->arr_indices.size(); j++){
            temp_size *= stoi(this->arr_indices[j]);
        }
        
        if(type_name=="int" || type_name == "float" || type_name.substr(0,6)=="struct"){ //struct* also included
            return  type_size * temp_size;
        }
        else if(type_name == "void" && this->num_stars!=0){
            return 4 * temp_size; //HARDCODED 
        }
        // else if(this->get_type()){
        //     //pointer to struct 
        //     return 4;
        // }
        return -1;
    }

    std::string Declarator::get_type(){
        std::string type_name = this->type_specifier->name;
        std::string type = type_name;

        for(int j = 0; j < this->num_stars; j++){
            type += '*';
        }

        for(uint j = 0; j < this->arr_indices.size(); j++){
            type += '[';
            type += this->arr_indices[j];
            type += ']';
        }

        return type;
    }

    /*
    std::vector reverse(std::vector<Declarator> v){
        std::vector<Declarator> v_copy = v;
        for(uint i = 0; i < v.size(); i++){
            v_copy[i] = v[v.size()-i-1];
        }
        return v_copy;
    }*/

    void Declarator_list::add_to_lst(std::vector<symbol_description*> &lst, int &offset){
        int prev_offset = 12; //hardcoded for function parameters case
        if(this->is_parameter_list){
            std::reverse(declarators.begin(), declarators.end());
        }
        std::vector<symbol_description*> lst_copy;

        for(uint i = 0; i <  declarators.size(); i++){
            //NOTE - running this loop opposite for smooth offset setting of function parameters case
            symbol_description *symbol_inst = new symbol_description();
            symbol_inst->name = declarators[i]->name;
            
            // std::cout<<"Inside add to lst with symbol name "<<symbol_inst->name<<std::endl;
            if(this->is_parameter_list){
                symbol_inst->scope = "param";  
            }
            else symbol_inst->scope = "local";
            symbol_inst->symbol_class = declarators[i]->symbol_class;
            symbol_inst->offset = -1;
            //size and type
            symbol_inst->size = declarators[i]->get_size();
            symbol_inst->symbol_type = declarators[i]->get_type();
            //set offset
            if(declarators[i]->block=="struct"){
                symbol_inst->offset = offset;
                offset += symbol_inst->size; //this variable is by reference, so updating
            }
            else if(declarators[i]->block=="function") {
                offset -= symbol_inst->size;
                symbol_inst->offset = offset;
                // std::cout<<"setting offset of the function variable\n";
            }
            else if(declarators[i]->block=="parameter"){
                symbol_inst->offset = prev_offset;
                prev_offset += symbol_inst->size;
            }
            lst_copy.push_back(symbol_inst); 
        }

        if(this->is_parameter_list){
            std::reverse(declarators.begin(), declarators.end());
            std::reverse(lst_copy.begin(), lst_copy.end());
        }
        
        for (int i = 0; i < (int)lst_copy.size(); i++)
        {
            lst.push_back(lst_copy[i]);
        }
        
        
        // std::cout<<"Added into current lst\n";
    }
    symbol_description* get_gst_entry_with_name(std::vector<std::pair<std::string,symbol_description*>>gst, std::string name){
        for (int i = 0; i < (int)gst.size(); i++)
        {
            if(gst[i].first==name){
                return gst[i].second;
            }
        }
        return 0;
    }
}