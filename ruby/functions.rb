require_relative 'plugins/default/default'
module Functions
  class QT_BuiltinFunciton < QT_Object
    def initialize(&block)
      @func = block
    end
    def qt_call(args, env)
      @func.call(args, env) || env.universe << QT_Null::INSTANCE
    end
    def to_s?
      false
    end

  end
  Ignore = Class.new

  NoRet = Class.new
  FUNCTIONS = {
    QT_Variable.new( :switch ) => QT_BuiltinFunciton.new{ |args, env|
      switch_on = fetch(args, 0, :__switch_on)
      args.qt_get(switch_on, env, type: QT_Variable.new( :BOTH ))
    },
    QT_Variable.new( :if ) => QT_BuiltinFunciton.new{ |args, env|
      cond     = fetch(args, 0, :__cond)
      if_true  = fetch(args, 1, QT_True::INSTANCE , :true)
      if_false = fetch(args, 2, QT_False::INSTANCE, :false, default: QT_Null::INSTANCE)
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, QT_Null::INSTANCE) } }
      cond.qt_to_bool(env).bool_val ? if_true : if_false
    },
    QT_Variable.new( :unless ) => QT_BuiltinFunciton.new{ |args, env|
      cond     = fetch(args, 0, :__cond)
      if_true  = fetch(args, 1, QT_True::INSTANCE , :true)
      if_false = fetch(args, 2, QT_False::INSTANCE, :false, default: QT_Null::INSTANCE)
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, QT_Null::INSTANCE) } }
      !cond.qt_to_bool(env).bool_val ? if_true : if_false
    },

    QT_Variable.new( :while ) => QT_BuiltinFunciton.new{ |args, env|
      cond = fetch(args, 0, :__cond)
      body = fetch(args, 1, :__body)
      while cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },
    QT_Variable.new( :until ) => QT_BuiltinFunciton.new{ |args, env|
      cond = fetch(args, 0, :__cond)
      body = fetch(args, 1, :__body)
      until cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },

    QT_Variable.new( :for ) => QT_BuiltinFunciton.new{ |args, env|
      start = fetch(args, 0, :__start)
      cond =  fetch(args, 1, :__cond)
      incr =  fetch(args, 2, :__incr)
      body =  fetch(args, 3, :__body)
      start.clone.qt_eval(env)
      while cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
        incr.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },

    QT_Variable.new( :disp ) => QT_BuiltinFunciton.new{ |args, env|

      endl = fetch(args, :end, default: QT_Text.new("\n"))
      sep = fetch(args, :sep, default: QT_Text.new(""))
      to_print = args.stack.collect{ |arg| arg.qt_to_text(env).text_val }.join(sep.qt_to_text(env).text_val)
      print(to_print + endl.qt_to_text(env).text_val)
      QT_Null::INSTANCE
    },
    QT_Variable.new( :prompt ) => QT_BuiltinFunciton.new{ |args, env|
      prompt = fetch(args, 0, :__prompt, default: QT_Text.new( '' ))
      prefix = fetch(args, 1, :__prefix, default: QT_Text.new( " = " ))
      endl = fetch(args, 2, :__endl, default: QT_Text.new( "\n" ))
      print prompt.text_val + prefix.text_val
      QT_Text.new( STDIN.gets(endl.text_val).chomp )
    },

    QT_Variable.new( :syscall ) => QT_BuiltinFunciton.new{ |args, env|
      sep = fetch(args, :sep, default: QT_Text.new(""))
      args.locals[QT_Variable.new( :sep ) ] ||= sep
      to_call = FUNCTIONS[ QT_Variable.new( :text ) ].qt_call(args, env) 
      QT_Text.new( `#{to_call}` )
    },


    QT_Variable.new( :text ) => QT_BuiltinFunciton.new{ |args, env|
      to_text = fetch(args, 0, :__to_text, default: QT_Text::EMPTY)
      quote1   = fetch(args, 1, :quote, :__quote,  :quote1, :__quote1, default: QT_Text.new( '"' ))
      quote2   = fetch(args, 2, :quote2, :__quote2, default: quote1)
      res = to_text.qt_to_text(env)
      res.quotes = [quote1.qt_to_text(env), 
                    quote2.qt_to_text(env)]
      res
    },

    QT_Variable.new( :num ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, 0, :__to_num, default: QT_Number::ZERO).qt_to_num(env)
    },

    QT_Variable.new( :stop ) => QT_BuiltinFunciton.new{ |args, env|
      exit fetch(args, 0, :__code, default: QT_Number::ZERO).qt_to_num(env).num_val
    },


    QT_Variable.new( :bool ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, 0, :__to_num, default: QT_False::INSTANCE).qt_to_bool(env)
    },

    QT_Variable.new( :type ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, 0, :__to_type).qt_to_type(env)
    },

    QT_Variable.new( :len ) => QT_BuiltinFunciton.new{ |args, env|
      arg = fetch(args, 0, :__arg)
      arg.qt_length( env, type: fetch(args, 1, :__type, default: QT_Variable.new( :BOTH )))
    },


    # i dont know how many of these work...

    QT_Variable.new( :clone ) => QT_BuiltinFunciton.new{ |args, env|
      # qutie_func(args, universe, parser, :qt_clone){ |a| a.clone }
    },


    QT_Variable.new( :return ) => QT_BuiltinFunciton.new{ |args, env|

      # value = args.locals.fetch(:__value){ args.stack.fetch(0, NoRet) }
      # levels = args.locals.fetch(:__levels){ args.stack.fetch(1, 1) }
      # if levels > 0
      #   universe.program_stack.pop # to remove us
      #   throw :EOF, [levels, value]
      # end
      QT_Null::INSTANCE
    },

    QT_Variable.new( :import ) => QT_BuiltinFunciton.new{ |args, env|
      file = args.stack.fetch(0){ args.locals.fetch(:__file) }
      # passed_args = args.stack.fetch(1){ args.locals.fetch(:__args, universe.class.new) }
      pre_process = args.stack.fetch(2){ args.locals.fetch(:__preprocess, true) }

      imported = open(file).read

      PreParser.pre_process!(imported) if pre_process
      # parser.process(input: imported, additional_builtins: passed_args.locals)

    },

    QT_Variable.new( :del ) => QT_BuiltinFunciton.new{ |args, env|
        
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
      QT_Null::INSTANCE
    },
  }

  module_function

  def fetch(args, *search_fors, default: Ignore)
    search_fors.each do |search_for|
      res = (search_for.is_a?(Integer) ? args.stack : args.locals).fetch(
              (search_for.is_a?(Symbol) ? QT_Variable.new( search_for ) : search_for), Ignore)
      return res unless res.equal?( Ignore )
    end
    raise "Cannot find args for #{search_fors}" if default.equal?(Ignore)
    default
  end

  # def qutie_func(arg, universe, parser, name)
  #   uni = UniverseOLD.new(globals: universe.globals.clone.update(universe.locals))
  #   uni.locals[:__self] ||= arg
  #   if arg.respond_to?(:locals) && arg.locals.include?(name)
  #     func = arg.locals[name] or fail "no #{name}` function for #{arg}"
  #     parser.parse!(stream: func.clone, universe: uni).stack.last
  #   else
  #     raise unless block_given?
  #     yield(arg, universe, parser)
  #   end
  # end

end


