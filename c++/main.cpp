#include "parser.cpp"
#include "types.cpp"
#include "plugins/universe/universe_class.cpp"
#include "plugins/default/default_plugin.cpp"
#include <iostream>
int main(int argc, char const *argv[])
{
   Parser *p = new Parser();

   p->add_plugin(new Default::Plugin());
   return 0;
}