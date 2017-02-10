#ifndef UNIVERSE_CLASS
#define UNIVERSE_CLASS
#include <vector>
class QT_Object;

namespace Universe {

   typedef std::vector<QT_Object*> Objects;
   
   class QT_Universe: QT_Types::Plugin {
      public:
         Objects objects;
         QT_Universe(): objects() {}  

         void push(QT_Object* object){
            objects.push_back(object);
         }
   };
}
#endif