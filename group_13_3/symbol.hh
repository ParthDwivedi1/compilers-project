#include <iostream>
#include <vector>
#include <string> 

namespace IPL{
     class symbol_description
     {
          public:
          std::string name;
          std::string symbol_class;
          std::string scope;
          int size=0;
          int offset=-1;
          std::string symbol_type;
          void print();
          //symbol_description();
     };

     class Type_specifier
     {
          public:
          std::string name;
          int size;
          Type_specifier(std::string name);
          Type_specifier();
          Type_specifier(Type_specifier* type_spec);
     };

     class Declarator
     {
          public:
          std::string name;
          Type_specifier *type_specifier;
          int num_stars = 0;
          std::string block;
          std::string symbol_class;
          int size = 0;
          std::vector<std::string> arr_indices;
          Declarator();
          int get_size();
          std::string get_type();
     };

     class Declarator_list
     {
          public:
               int is_parameter_list = 0;
               std::vector<Declarator*> declarators;
          void add_to_lst(std::vector<symbol_description*> &lst, int &offset);
     };

     class Fun_declarator
     {
          public:
          std::string name;
     };

     class Function_list
     {
          public:
               std::vector<Declarator*> declarators;
          void add_to_lst(std::vector<symbol_description*> &lst, int &offset);
     };

     symbol_description* get_gst_entry_with_name(std::vector<std::pair<std::string,symbol_description*>>gst, std::string name);

}

