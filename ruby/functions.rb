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
      switch_on = fetch(args, 0, :__switch_on);
      args.qt_get(switch_on, type: :BOTH)
    },
    QT_Variable.new( :if ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = fetch(args, 0, :__cond)
      if_true  = fetch(args, 1, QT_True::INSTANCE , :true)
      if_false = fetch(args, 2, QT_False::INSTANCE, :false, else_: QT_Null::INSTANCE)
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, QT_Boolean::NIL) } }
      cond.qt_to_bool.bool_val ? if_true : if_false
    },

    QT_Variable.new( :return ) => QT_BuiltinFunciton.new{ |args, universe, stream|

      # value = args.locals.fetch(:__value){ args.stack.fetch(0, NoRet) }
      # levels = args.locals.fetch(:__levels){ args.stack.fetch(1, 1) }
      # if levels > 0
      #   universe.program_stack.pop # to remove us
      #   throw :EOF, [levels, value]
      # end
    },

    QT_Variable.new( :while ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = fetch(args, 0, :__cond)
      body = fetch(args, 1, :__body)
      while cond.clone.qt_eval(universe, stream, parser).pop.qt_to_bool.bool_val
        body.clone.qt_eval(universe, stream, parser)
      end
      true
    },
    QT_Variable.new( :unless ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond     = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      if_true  = args.locals.fetch(true){ args.stack.fetch(1){ args.locals.fetch(:true) }   }
      if_false = args.locals.fetch(false){ args.stack.fetch(2){ args.locals.fetch(:false, nil) } }
      cond ? if_false : if_true
    },
    QT_Variable.new( :until ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      cond = args.stack.fetch(0){ args.locals.fetch(:__cond) }
      body = args.stack.fetch(1){ args.locals.fetch(:__body) }
      parser.parse!(stream: body.clone, universe: universe) until parser.parse!(stream: cond.clone, universe: universe).pop 
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

    QT_Variable.new( :for ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      start = args.stack.fetch(0){ args.locals.fetch(:__start) }
      cond = args.stack.fetch(1){ args.locals.fetch(:__cond) }
      incr = args.stack.fetch(2){ args.locals.fetch(:__incr) }
      body = args.stack.fetch(3){ args.locals.fetch(:__body) }
      parser.parse!(stream: start.clone, universe: universe)
      while parser.parse!(stream: cond.clone, universe: universe).pop
        parser.parse!(stream: body.clone, universe: universe)
        parser.parse!(stream: incr.clone, universe: universe)
      end
    },

    # i dont know how many of these work...

    QT_Variable.new( :clone ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      case args
      when true, false, nil, Numeric, Fixnum then args
      else qutie_func(args, universe, parser, :__clone){ |a| a.clone }
      end
    },
    QT_Variable.new( :disp ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|

      endl = fetch(args, :end, else_: QT_Text.new("\n"))
      sep = fetch(args, :sep, else_: QT_Text.new(""))
      args = args.clone
      args.locals[QT_Variable.new( :sep ) ] ||= sep
      to_print = FUNCTIONS[ QT_Variable.new( :text ) ].qt_call(args, universe, stream, parser) 
      print(to_print.qt_add( endl ).text_val)
      true
    },

    QT_Variable.new( :prompt ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      prompt = args.stack.fetch(0){ args.locals.fetch(:__prompt, '') }
      prefix = args.stack.fetch(2){ args.locals.fetch(:__prefix, "\n>") }
      endl = args.stack.fetch(1){ args.locals.fetch(:__endl, "\n") }
      # args.locals[:sep] ||= '' # forces it to be '' if not specified, but doesnt override text's default
      # prefix=FUNCTIONS[:text].call(prefix, universe, stream, parser) 
      print prompt + prefix
      STDIN.gets endl
    },

    QT_Variable.new( :syscall ) => QT_BuiltinFunciton.new{ |args, universe, stream, parser|
      sep  = args.get(:sep) || " "
      args.locals[:sep] = sep # forces it to be '' if not specified, but doesnt override text's default
      to_call=FUNCTIONS[:text].qt_call(args: args,
                                       universe: universe,
                                       stream: stream,
                                       parser: parser) 
      `#{to_call}`
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
      if args.respond_to?(:qt_get)
        sep  = args.qt_get(QT_Variable.new( :sep ), type: :BOTH)
        sep = QT_Text::new(' ') if sep == QT_Null::INSTANCE;
        QT_Text::new(args.stack.collect{ |arg|
            qutie_func(arg, universe, parser, :__text){ |a| a.nil? ? a.inspect : a.qt_to_text.text_val }
          }.join(sep.qt_to_text.text_val))
      else
        args.qt_to_text
      end
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

  def fetch(args, *search_fors, else_: Ignore)
    search_fors.each do |search_for|
      res = (search_for.is_a?(Integer) ? args.stack : args.locals).fetch(
              (search_for.is_a?(Symbol) ? QT_Variable.new( search_for ) : search_for), Ignore)
      return res unless res.equal?( Ignore )
    end
    raise "Cannot find args for #{search_fors}" if else_.equal?(Ignore)
    else_
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


