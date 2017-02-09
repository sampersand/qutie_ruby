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
      parser.parse(stream: body, universe: universe) while parser.parse(stream: cond, universe: universe).pop 
    },
    :unless => BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      if_true  = args.locals.fetch(true){ args.stack.fetch(1){ args.locals.fetch(:true) }   }
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, nil) } }
      cond ? if_false : if_true
    },
    :until => BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      body = args.stack.fetch(1){ args.locals.fetch(:__body) }
      parser.parse(stream: body, universe: universe) until parser.parse(stream: cond, universe: universe).pop 
    },





    :del => BuiltinFunciton.new{ |args, universe, stream, parser|
        
      uni = args.stack.fetch(0){ args.locals.fetch(:__uni) }
      pos = args.stack.fetch(1){ args.locals.fetch(:__pos) }
      type = args.stack.fetch(2){ args.locals.fetch(:__type, nil) }
      if(uni.is_a?(String))
        uni.slice!(pos)
      elsif type == :V || (type.nil? && uni.locals.include?(pos))
        uni.locals.delete(pos)
      elsif type == :S || (type.nil? && (0..uni.stack.length).include?(pos))
        uni.stack.delete_at(pos)
      elsif type == :G
        uni.globals.delete(pos)
      else
        raise "Unknown type `#{type.inspect}` with pos `#{pos}`"
      end
    },

    :for => BuiltinFunciton.new{ |args, universe, stream, parser|
      start = args.stack.fetch(0){ args.locals.fetch(:__start) }
      cond = args.stack.fetch(1){ args.locals.fetch(:__cond) }
      incr = args.stack.fetch(2){ args.locals.fetch(:__incr) }
      body = args.stack.fetch(3){ args.locals.fetch(:__body) }
      parser.parse(stream: start, universe: universe)
      while parser.parse(stream: cond, universe: universe).pop
        parser.parse(stream: body, universe: universe)
        parser.parse(stream: incr, universe: universe)
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

    :prompt => BuiltinFunciton.new{ |args, universe, stream, parser|
      prompt = args.stack.fetch(0){ args.locals.fetch(:__prompt, '') }
      prefix = args.stack.fetch(2){ args.locals.fetch(:__prefix, "\n>") }
      endl = args.stack.fetch(1){ args.locals.fetch(:__endl, "\n") }
      # args.locals[:sep] ||= '' # forces it to be '' if not specified, but doesnt override text's default
      # prefix=FUNCTIONS[:text].call(prefix, universe, stream, parser) 
      print prompt + prefix
      STDIN.gets endl
    },

    :syscall => BuiltinFunciton.new{ |args, universe, stream, parser|
      sep  = args.get(:sep) || " "
      args.locals[:sep] = sep # forces it to be '' if not specified, but doesnt override text's default
      to_call=FUNCTIONS[:text].call(args, universe, stream, parser) 
      `#{to_call}`
    },

    :import => BuiltinFunciton.new{ |args, universe, stream, parser|
      file = args.stack.fetch(0){ args.locals.fetch(:__file) }
      passed_args = args.stack.fetch(1){ args.locals.fetch(:__args, universe.class.new) }
      pre_process = args.stack.fetch(2){ args.locals.fetch(:__preprocess, true) }

      imported = open(file).read

      PreParser.pre_process!(imported) if pre_process
      parser.process(input: imported, additional_builtins: passed_args.locals)

    },

    :stop => BuiltinFunciton.new{ |args, universe, stream, parser|
      exit_code = args.stack.last
      exit(exit_code || 0)
    },
    :text => BuiltinFunciton.new{ |args, universe, stream, parser|
      if args.respond_to?(:get)
        sep  = args.get(:sep) || " "
        args.stack.collect{ |arg|
            qutie_func(arg, universe, parser, :__text){ |a| a.nil? ? a.inspect : a.to_s }
          }.join(sep)
      else
        args.nil? ? args.inspect : args.to_s 
      end
    },

    :num => BuiltinFunciton.new{ |args, universe, stream, parser|
      qutie_func(args, universe, parser, :__num){ |a| a.to_i }

    },

    :len => BuiltinFunciton.new{ |args, universe, stream, parser|
      arg = args.stack.fetch(0){ args.locals.fetch(:__arg) }
      type = args.stack.fetch(1){ args.locals.fetch(:__type, nil) }
      u = universe.clone
      u.globals[:__type] = type
      qutie_func(arg, u, parser, :__len){ |a|
        case type
        when :g, :G then a.respond_to?(:globals) && a.globals.length
        when :v, :V, :l, :L then a.respond_to?(:locals) && a.locals.length
        when :a, :A, :s, :S then a.respond_to?(:stack) && a.stack.length
        when nil
          lcls = a.respond_to?(:locals) ? a.locals.length : 0
          stck = a.respond_to?(:stack)  ? a.stack.length : 0
          raise "unspecified type yielded both lcls and stack" unless (lcls == 0) || (stck == 0)
          lcls == 0 ? stck : lcls
        else raise "unknown type `#{type.inspect}`"
        end or begin
          puts "Error: `#{a.inspect}` doesn't repsond to type param `#{type.inspect}`"
          exit(1)
        end
      }
    },

  }

  module_function
  def qutie_func(arg, universe, parser, name)
    uni = universe.class.new(globals: universe.globals.clone.update(universe.locals))
    uni.locals[:__self] ||= arg
    if arg.respond_to?(:locals) && arg.locals.include?(name)
      func = arg.locals[name] or fail "no #{name}` function for #{arg}"
      parser.parse(stream: func, universe: uni).stack.last
    else
      raise unless block_given?
      yield(arg, universe, parser)
    end
  end

end


