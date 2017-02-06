 module Functions
  class BuiltinFunciton
    def initialize(&block)
      @func = block
    end
    def call(args, universe, parser)
      @func.call(args, universe, parser)
    end
    def to_s?
      false
    end

  end

  FUNCTIONS = {
    :switch => BuiltinFunciton.new{ |args, universe, parser|
      switch_on = args.stack.fetch(0){ args.locals.fetch(:__switch_on) }
      if args.locals.include?(switch_on)
        args.locals[switch_on]
      else
        args.stack[switch_on]
      end
    },
    :if => BuiltinFunciton.new{ |args, universe, parser|
      cond     = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      if_true  = args.locals.fetch(true){ args.stack.fetch(1){ args.locals.fetch(:true) }   }
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, nil) } }
      cond ? if_true : if_false
    },
    :while => BuiltinFunciton.new{ |args, universe, parser|
      cond = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      body = args.stack.fetch(1){ args.locals.fetch(:__body) }
      parser.parse(body, universe) while parser.parse(cond, universe).pop! 
    },
    :del => BuiltinFunciton.new{ |args, universe, parser|
      pos = args.stack.fetch(0){ args.locals.fetch(:__pos) }
      type = args.stack.fetch(1){ args.locals.fetch(:__type, nil) }

      if type == :V || (type.nil? && universe.locals.include?(pos))
        universe.locals.delete(pos)
      elsif type == :s || (type.nil? && universe.stack.include?(pos))
        universe.stack.delete(pos)
      elsif type == :G
        universe.globals.delete(pos)
      else
        raise "Unknown type `#{type}`!";
      end
    },

    :for => BuiltinFunciton.new{ |args, universe, parser|
      start = args.stack.fetch(0){ args.locals.fetch(:__start) }
      cond = args.stack.fetch(1){ args.locals.fetch(:__cond) }
      incr = args.stack.fetch(2){ args.locals.fetch(:__incr) }
      body = args.stack.fetch(3){ args.locals.fetch(:__body) }
      parser.parse(start, universe);
      while parser.parse(cond, universe).pop! 
        parser.parse(body, universe)
        parser.parse(incr, universe)
      end
    },

    # i dont know how many of these work...

    :clone => BuiltinFunciton.new{ |args, universe, parser|
      case args
      when true, false, nil, Numeric, Fixnum then args
      else qutie_func(args, universe, parser, :__clone){ |a| a.clone }
      end
    },
    :disp => BuiltinFunciton.new{ |args, universe, parser|
      endl = args.get(:end) || "\n"
      sep  = args.get(:sep) || ""
      args.locals[:sep] = sep # forces it to be '' if not specified, but doesnt override text's default
      to_print=FUNCTIONS[:text].call(args, universe, parser) 
      print(to_print + endl)

    },
    :stop => BuiltinFunciton.new{ |args, universe, parser|
      exit_code = args.stack.last;
      exit(exit_code || 0)
    },
    :text => BuiltinFunciton.new{ |args, universe, parser|
      if args.respond_to?(:get)
        sep  = args.get(:sep) || " "
        args.stack.collect{ |arg|
            # p args.stack.length
            qutie_func(arg, universe, parser, :__text){ |a| a.to_s }
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
      u.globals[:__type] = args.get(:__type)
      qutie_func(arg, u, parser, :__len){ |a|
        case args.get(:__type)
        when /g/i then a.respond_to?(:globals) && a.globals.length
        when /v|l/i then a.respond_to?(:locals) && a.locals.length
        when /a|s/i then a.respond_to?(:stack) && a.stack.length
        when nil
          lcls = a.respond_to?(:locals) ? a.locals.length : 0
          stck = a.respond_to?(:stack)  ? a.stack.length : 0
          raise "unspecified type yielded both lcls and stack" unless (lcls == 0) || (stck == 0)
          lcls == 0 ? stck : lcls
        else raise "unknown type `#{args.get(:__type).inspect}`"
        end or raise "`#{a}` doesn't repsond to type param `#{args.get(:__type)}`"
      }
    },

  }

  module_function
  def qutie_func(arg, universe, parser, name)
    uni = universe.to_globals
      uni.locals[:__self] = arg
    if arg.respond_to?(:locals) && arg.locals.include?(name)
      func = arg.locals[name] or fail "no #{name}` function for #{arg}"
      parser.parse(func, uni).stack.last
    else
      raise unless block_given?
      yield(arg, universe, parser)
    end
  end

end











