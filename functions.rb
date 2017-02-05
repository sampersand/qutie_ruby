 module Functions
  class BuiltinFunciton
    def initialize(&block)
      @func = block
    end
    def call(func, args, universe, parser)
      @func.call(args, universe, parser)
    end
  end
  FUNCTIONS = {
    'clone' => BuiltinFunciton.new{ |args, universe, parser|
      case args
      when true, false, nil, Numeric, Fixnum then args
      else args.clone
      end
    },
    'disp' => BuiltinFunciton.new{ |args, universe, parser|
      # p args
      endl = args.get('end') || "\n"
      sep  = args.get('sep') || " "
      to_print = args.stack.collect do |arg|
        FUNCTIONS['text'].call(nil, arg, universe, parser) 
      end.join(sep)
      print(to_print + endl)

    },
    'stop' => BuiltinFunciton.new{ |args, universe, parser|
      exit_code = args.stack.last;
      exit(exit_code || 0)
    },
    'text' => BuiltinFunciton.new{ |args, universe, parser|
      endl = args.get('end') || "\n"
      sep  = args.get('sep') || " "
      to_texts = args.stack.collect do |arg|
        uni = universe.to_globals
        uni.locals['__self'] = arg
        if arg.respond_to?(:locals) && arg.locals.include?('__text')
          __text = arg.locals['__text'] or fail "no __text function for #{arg}"
          parser.parse_all(__text, uni).stack.last
        else
          arg.to_s
        end
      end.join(sep)
    },

    'debug' => BuiltinFunciton.new{ |_, args, universe, parser|
      p [args.stack, args.locals.keys]
    },

  }

end











