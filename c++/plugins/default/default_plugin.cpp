#ifndef DEFUALT_PLUGIN
#define DEFUALT_PLUGIN

namespace Default {
   class Plugin: QT_Types::Plugin {
      public:
      QT_Types::String next_token(QT_Universe* stream, QT_Universe* universe, Parser* parser){
         universe->push(stream->next());
      }
   };
}
#endif