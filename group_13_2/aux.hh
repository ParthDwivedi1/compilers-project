#include <iostream>
#include <string>

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


