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
      uni = universe.to_globals
      uni.locals['__self'] = args
      if args.respond_to?(:locals) && args.locals.include?('__text')
        __text = args.locals['__text'] or fail "no __text function for #{args}"
        res = parser.parse_all(__text, uni).stack.last
      else
        args.to_s
      end
    },

    'debug' => BuiltinFunciton.new{ |_, args, universe, parser|
      p [args.stack, args.locals.keys]
    },

  }

end











