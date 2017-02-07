 module Functions
  class BuiltinFunciton
    def initialize(&block)
      @func = block
    end
    def call(args, universe, stream, parser)
      @func.call(args, universe, stream, parser)
    end
    def to_s?
      false
    end

  end

  NoRet = Class.new()
  FUNCTIONS = {
    :switch => BuiltinFunciton.new{ |args, universe, stream, parser|
      switch_on = args.stack.fetch(0){ args.locals.fetch(:__switch_on) }
      if args.locals.include?(switch_on)
        args.locals[switch_on]
      else
        args.stack[switch_on]
      end
    },

    :return => BuiltinFunciton.new{ |args, universe, stream|

      value = args.stack[0]
      value = args.locals.fetch(:__value){ args.stack.fetch(0, NoRet) }
      levels = args.locals.fetch(:__levels){ args.stack.fetch(1, 1) }
      if levels > 0
        universe.program_stack.pop # to remove us
        throw :EOF, [levels, value]
      end
    },

    :if => BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      if_true  = args.locals.fetch(true){ args.stack.fetch(1){ args.locals.fetch(:true) }   }
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, nil) } }
      cond ? if_true : if_false
    },
    :while => BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      body = args.stack.fetch(1){ args.locals.fetch(:__body) }
      parser.parse(stream: body, universe: universe) while parser.parse(stream: cond, universe: universe).pop! 
    },
    :del => BuiltinFunciton.new{ |args, universe, stream, parser|
      pos = args.stack.fetch(0){ args.locals.fetch(:__pos) }
      type = args.stack.fetch(1){ args.locals.fetch(:__type, nil) }

      if type == :V || (type.nil? && universe.locals.include?(pos))
        universe.locals.delete(pos)
      elsif type == :s || (type.nil? && universe.stack.include?(pos))
        universe.stack.delete(pos)
      elsif type == :G
        universe.globals.delete(pos)
      else
        raise "Unknown type `#{type}`!"
      end
    },

    :for => BuiltinFunciton.new{ |args, universe, stream, parser|
      start = args.stack.fetch(0){ args.locals.fetch(:__start) }
      cond = args.stack.fetch(1){ args.locals.fetch(:__cond) }
      incr = args.stack.fetch(2){ args.locals.fetch(:__incr) }
      body = args.stack.fetch(3){ args.locals.fetch(:__body) }
      parser.parse(stream: start, universe: universe)
      while parser.parse(cond, stream: universe).pop! 
        parser.parse(body, stream: universe)
        parser.parse(incr, stream: universe)
      end
    },

    # i dont know how many of these work...

    :clone => BuiltinFunciton.new{ |args, universe, stream, parser|
      case args
      when true, false, nil, Numeric, Fixnum then args
      else qutie_func(args, universe, parser, :__clone){ |a| a.clone }
      end
    },
    :disp => BuiltinFunciton.new{ |args, universe, stream, parser|
      endl = args.get(:end) || "\n"
      sep  = args.get(:sep) || ""
      args.locals[:sep] = sep # forces it to be '' if not specified, but doesnt override text's default
      to_print=FUNCTIONS[:text].call(args, universe, stream, parser) 
      print(to_print + endl)
    },
    :syscall => BuiltinFunciton.new{ |args, universe, stream, parser|
      sep  = args.get(:sep) || " "
      args.locals[:sep] = sep # forces it to be '' if not specified, but doesnt override text's default
      to_call=FUNCTIONS[:text].call(args, universe, stream, parser) 
      `#{to_call}`

    },
    :stop => BuiltinFunciton.new{ |args, universe, stream, parser|
      exit_code = args.stack.last
      exit(exit_code || 0)
    },
    :text => BuiltinFunciton.new{ |args, universe, stream, parser|
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

    :num => BuiltinFunciton.new{ |args, universe, stream, parser|
      qutie_func(args, universe, parser, :__num){ |a| a.to_i }

    },

    :len => BuiltinFunciton.new{ |args, universe, stream, parser|
      arg = args.stack.last
      u = universe.clone
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
    uni = universe.spawn_frame
      uni.locals[:__self] = arg
    if arg.respond_to?(:locals) && arg.locals.include?(name)
      func = arg.locals[name] or fail "no #{name}` function for #{arg}"
      parser.parse(stream: func, universe: uni).stack.last
    else
      raise unless block_given?
      yield(arg, universe, parser)
    end
  end

end


