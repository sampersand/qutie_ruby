class Parser;
class Universe;
class Stream;
class Object;

class Plugin {
public:
   virtual Object next_object(Stream* stream, Universe* universe, Parser* parser) = 0;
};