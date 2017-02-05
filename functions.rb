 module Functions
  class BuiltinFunciton
    def initialize(&block)
      @func = block
    end
    def call(args, universe, parser)
      @func.call(args, universe, parser)
    end
  end

  FUNCTIONS = {
    # i dont know how many of these work...
    :switch => BuiltinFunciton.new{ |args, universe, parser|
      switch_on = args.stack.fetch(0){ args.locals.fetch('__switch_on') }
      if args.locals.include?(switch_on)
        args.locals[switch_on]
      else
        args.stack[switch_on]
      end
    },
    :if => BuiltinFunciton.new{ |args, universe, parser|
      cond     = args.stack.fetch(0){ args.locals.fetch('__cond') }
      if_true  = args.locals.fetch(true){ args.stack.fetch(0){ args.locals.fetch('true') }   }
      if_false = args.locals.fetch(false){ args.stack.fetch(1){ args.locals.fetch('false') } }
      cond ? if_true : if_false
    },
    :while => BuiltinFunciton.new{ |args, universe, parser|
      cond = args.stack.fetch(0){ args.locals.fetch('__cond') }
      body = args.stack.fetch(0){ args.locals.fetch('__body') }
      parser.parse(body, universe) while parser.parse(cond, universe).pop! 
    },

    :clone => BuiltinFunciton.new{ |args, universe, parser|
      case args
      when true, false, nil, Numeric, Fixnum then args
      else qutie_func(args, universe, parser, '__clone'){ |a| a.clone }
      end
    },
    :disp => BuiltinFunciton.new{ |args, universe, parser|
      endl = args.get('end') || "\n"
      sep  = args.get('sep') || " "
      to_print=FUNCTIONS[:text].call(args, universe, parser) 
      print(to_print + endl)

    },
    :stop => BuiltinFunciton.new{ |args, universe, parser|
      exit_code = args.stack.last;
      exit(exit_code || 0)
    },
    :text => BuiltinFunciton.new{ |args, universe, parser|
      if args.respond_to?(:get)
        sep  = args.get('sep') || " "
        args.stack.collect{ |arg|
            # p args.stack.length
            qutie_func(arg, universe, parser, '__text'){ |a| a.to_s }
          }.join(sep)
      else
        args.to_s 
      end
    },
    :debug => BuiltinFunciton.new{ |args, universe, parser|
      p [args.stack, args.locals.keys]
    },

    :len => BuiltinFunciton.new{ |args, universe, parser|
      arg = args.stack.last;
      u = universe.to_globals
      u.globals['type'] = args.get('type')
      qutie_func(arg, u, parser, '__len'){ |a|
        case args.get('type')
        when /g/i then a.respond_to?(:globals) && a.globals.length
        when /v|l/i then a.respond_to?(:locals) && a.locals.length
        when /a|s/i then a.respond_to?(:stack) && a.stack.length
        when nil
          lcls = a.respond_to?(:locals) ? a.locals.length : 0
          stck = a.respond_to?(:stack)  ? a.stack.length : 0
          raise "unspecified type yielded both lcls and stack" unless (lcls == 0) || (stck == 0)
          lcls == 0 ? stck : lcls
        else raise "unknown type `#{args.get('type').inspect}`"
        end or raise "`#{a}` doesn't repsond to type param `#{args.get('type')}`"
      }
    },

  }

  module_function
  def qutie_func(arg, universe, parser, name)
    uni = universe.to_globals
    uni.locals['__self'] = arg
    if arg.respond_to?(:locals) && arg.locals.include?(name)
      func = arg.locals[name] or fail "no #{name}` function for #{arg}"
      parser.parse_all(func, uni).stack.last
    else
      raise unless block_given?
      yield(arg, universe, parser)
    end
  end

end











