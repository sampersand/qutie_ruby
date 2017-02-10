#ifndef QT_TYPES_DEFINED
#define QT_TYPES_DEFINED

#include <string>

class Parser;
class QT_Universe{
   
}

namespace QT_Types {
   typedef std::string String;

   class QT_Object {

   };

   class Plugin {
      public:
         virtual String next_token(QT_Universe* stream, QT_Universe* universe, Parser* parser) = 0;
   };

}
#endif
