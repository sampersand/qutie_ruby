#include <vector>

class Plugin;
namespace DefaultPlugin {

};

typedef namespace DefaultPlugin DefaultPlugin;

class Parser
{
   typedef std::vector<Plugin*> Plugins;
   Plugins plugins;
   public:
      Parser(): plugins(){
         plugins.push_back(DefaultPlugin);
      }
   
};