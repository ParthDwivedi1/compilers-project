#include <iostream>
#include <string>
#include "symbol.hh"

std::string dereference(std::string type)
{
    //if (*) exists
    if (type.find("(") != std::string::npos)
    {
        int pos = (int)type.find("(");
        type.erase(pos, 3);
        return type;
    }
    //else if [] exists
    else if (type.find("[") != std::string::npos)
    {
        //remove first occurenece
        int pos1 = (int)type.find("[");
        int pos2 = (int)type.find("]");
        type.erase(pos1, pos2 - pos1 + 1);
        return type;
    }
    //*should be there, remove it
    else if (type[type.size() - 1] == '*')
    {
        type.pop_back();
        return type;
    }
    return "";
    //else empty
}

std::string reference(std::string type)
{
    //if [] doens't exist then appennd *
    if (type.find("[") == std::string::npos)
    {
        type.append("*");
        return type;
    } //[] exists in it then add to (*)
    else
    {
        int pos = (int)type.find("[");
        type.insert(pos, "(*)");
        return type;
    }
    return "";
}

int get_size(std::string type,std::vector<std::pair<std::string,IPL::symbol_description*>> &global_symbol_table){

    int s=1;
    std::string temp="";
    std::string fin="";
    // int val1=0;
    int val2=0;
    for(int i=0;i<int(type.length());i++){

        if(type[i]=='['){
            val2=1;    
            temp.clear();
            continue;
        }

        if(type[i]==']'){
            
            s*=stoi(temp);
            temp.clear();
            continue;
        }
        temp+=type[i];
        if(val2==0){
            fin+=type[i];
        }
    }
    for (uint i = 0; i < global_symbol_table.size(); i++)
    {
        if(global_symbol_table[i].first==fin){
            
            return s*global_symbol_table[i].second->size;
            ////exit(0);
        }
    }
    return 4*s;

}

int get_size_of_element(std::string type,std::vector<std::pair<std::string,IPL::symbol_description*>> &global_symbol_table){
    
    return get_size(dereference(type),global_symbol_table);
}


