#include <vector>
#include "types.cpp"
class Parser
{
   typedef std::vector<QT_Types::Plugin*> Plugins;

   Plugins plugins;

   public:
      Parser(): plugins(){
         // plugins.push_back(DefaultPlugin);
      }
      void add_plugin(QT_Types::Plugin* pl){
         plugins.push_back(pl);
      } 
};