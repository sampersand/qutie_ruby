module Functions
  class QT_BuiltinFunciton < QT_Object
    def initialize(&block)
      @func = block
    end
    def qt_call(args, universe, stream, parser)
      @func.call(args, universe, stream, parser) || universe << QT_Null::INSTANCE
    end
    def to_s?
      false
    end

  end
  Ignore = Class.new

  NoRet = Class.new
  FUNCTIONS = {
    QT_Variable.new( :switch ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      switch_on = fetch(args, 0, :__switch_on)
      args.qt_get(switch_on, type: :BOTH)
    },
    QT_Variable.new( :if ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = fetch(args, 0, :__cond)
      if_true  = fetch(args, 1, QT_True::INSTANCE , :true)
      if_false = fetch(args, 2, QT_False::INSTANCE, :false, default: QT_Null::INSTANCE)
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, QT_Boolean::NIL) } }
      cond.qt_to_bool.bool_val ? if_true : if_false
    },
    QT_Variable.new( :unless ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = fetch(args, 0, :__cond)
      if_true  = fetch(args, 1, QT_True::INSTANCE , :true)
      if_false = fetch(args, 2, QT_False::INSTANCE, :false, default: QT_Null::INSTANCE)
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, QT_Boolean::NIL) } }
      !cond.qt_to_bool.bool_val ? if_true : if_false
    },

    QT_Variable.new( :while ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = fetch(args, 0, :__cond)
      body = fetch(args, 1, :__body)
      while cond.clone.qt_eval(universe, stream, parser).pop.qt_to_bool.bool_val
        body.clone.qt_eval(universe, stream, parser)
      end
      true
    },
    QT_Variable.new( :until ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = fetch(args, 0, :__cond)
      body = fetch(args, 1, :__body)
      until cond.clone.qt_eval(universe, stream, parser).pop.qt_to_bool.bool_val
        body.clone.qt_eval(universe, stream, parser)
      end
      true
    },

    QT_Variable.new( :for ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      start = fetch(args, 0, :__start)
      cond =  fetch(args, 1, :__cond)
      incr =  fetch(args, 2, :__incr)
      body =  fetch(args, 3, :__body)
      start.clone.qt_eval(universe, stream, parser)
      while cond.clone.qt_eval(universe, stream, parser).pop.qt_to_bool.bool_val
        body.clone.qt_eval(universe, stream, parser)
        incr.clone.qt_eval(universe, stream, parser)
      end
      true
    },



    QT_Variable.new( :return ) => QT_BuiltinFunciton.new{ |args, universe, stream|

      # value = args.locals.fetch(:__value){ args.stack.fetch(0, NoRet) }
      # levels = args.locals.fetch(:__levels){ args.stack.fetch(1, 1) }
      # if levels > 0
      #   universe.program_stack.pop # to remove us
      #   throw :EOF, [levels, value]
      # end
    },

    QT_Variable.new( :del ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
        
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

    QT_Variable.new( :disp ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|

      endl = fetch(args, :end, default: QT_Text.new("\n"))
      sep = fetch(args, :sep, default: QT_Text.new(""))
      args = args.clone
      args.locals[QT_Variable.new( :sep ) ] ||= sep
      to_print = FUNCTIONS[ QT_Variable.new( :text ) ].qt_call(args, universe, stream, parser) 
      print(to_print.qt_add( endl ).text_val)
      true
    },
    QT_Variable.new( :prompt ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      prompt = fetch(args, 0, :__prompt, default: QT_Text.new( '' ))
      prefix = fetch(args, 2, :__prefix, default: QT_Text.new( " = " ))
      endl = fetch(args, 1, :__endl, default: QT_Text.new( "\n" ))
      print prompt.text_val + prefix.text_val
      QT_Text.new( STDIN.gets endl.text_val )
    },

    QT_Variable.new( :syscall ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      sep = fetch(args, :sep, default: QT_Text.new(""))
      args.locals[QT_Variable.new( :sep ) ] ||= sep
      to_call = FUNCTIONS[ QT_Variable.new( :text ) ].qt_call(args, universe, stream, parser) 
      QT_Text.new( `#{to_call}` )
    },

    # i dont know how many of these work...

    QT_Variable.new( :clone ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      qutie_func(args, universe, parser, :qt_clone){ |a| a.clone }
    },


    QT_Variable.new( :import ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      file = args.stack.fetch(0){ args.locals.fetch(:__file) }
      passed_args = args.stack.fetch(1){ args.locals.fetch(:__args, universe.class.new) }
      pre_process = args.stack.fetch(2){ args.locals.fetch(:__preprocess, true) }

      imported = open(file).read

      PreParser.pre_process!(imported) if pre_process
      parser.process(input: imported, additional_builtins: passed_args.locals)

    },

    QT_Variable.new( :text ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      to_text = fetch(args, 0, :__to_text)
      quote1   = fetch(args, 1, :quote, :__quote,  :quote1, :__quote1, default: QT_Text.new( '"' ))
      quote2   = fetch(args, 2, :quote2, :__quote2, default: quote1)
      res = to_text.qt_to_text
      res.quotes = [quote1.qt_to_text, quote2.qt_to_text]
      res
      # sep     = fetch(args, 1, :sep, :__sep, default: QT_Text.new( ' ' ))
      # QT_Text.new( args._stackeach.collect{|arg| var = arg.qt_to_text(quote: quote)
      #   }.join(sep.qt_to_text.text_val))
    },

    QT_Variable.new( :num ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      qutie_func(args, universe, parser, :__num){ |a| a.qt_to_num }
    },

    QT_Variable.new( :bool ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      qutie_func(args.pop, universe, parser, :__bool){ |a| a.qt_to_bool }
    },

    QT_Variable.new( :len ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
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

  def fetch(args, *search_fors, default: Ignore)
    search_fors.each do |search_for|
      res = (search_for.is_a?(Integer) ? args.stack : args.locals).fetch(
              (search_for.is_a?(Symbol) ? QT_Variable.new( search_for ) : search_for), Ignore)
      return res unless res.equal?( Ignore )
    end
    raise "Cannot find args for #{search_fors}" if default.equal?(Ignore)
    default
  end

  def qutie_func(arg, universe, parser, name)
    uni = UniverseOLD.new(globals: universe.globals.clone.update(universe.locals))
    uni.locals[:__self] ||= arg
    if arg.respond_to?(:locals) && arg.locals.include?(name)
      func = arg.locals[name] or fail "no #{name}` function for #{arg}"
      parser.parse!(stream: func.clone, universe: uni).stack.last
    else
      raise unless block_given?
      yield(arg, universe, parser)
    end
  end

end


