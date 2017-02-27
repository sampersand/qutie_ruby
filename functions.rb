
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
  ELSE_KEYWORD_FOR_IF = QT_Symbol.new( :else )
  NoRet = Class.new
  FUNCTIONS = {
    QT_Symbol.new( :switch ) => QT_BuiltinFunciton.new{ |args, env|
      switch_on = fetch(args, env, 0, :__switch_on)
      cases = fetch(args, env, :__cases, default: args, can_pass_block: true)

      cases = cases.qt_eval(env) if $BLOCK_GIVEN
      res = cases.qt_get(switch_on, env, type: QT_Symbol.new( :BOTH ))
      if res._missing?
        cases.qt_get(QT_Symbol.new( :DEFAULT ), env, type: QT_Symbol.new( :BOTH ))
      else
        res
      end
    },
    QT_Symbol.new( :if ) => QT_BuiltinFunciton.new{ |args, env|
      cond     = fetch(args, env, 0, :__cond)
      if_true  = fetch(args, env, 1, QT_True::INSTANCE, :true, can_pass_block: true)
      true_block = $BLOCK_GIVEN
      if true_block && ELSE_KEYWORD_FOR_IF == env.p.next_token!(env.clone)[0]
        raise unless ELSE_KEYWORD_FOR_IF == env.p.next_token!(env)[0]
      end
      if_false = fetch(args, env, 2, QT_False::INSTANCE, :false, default: QT_Null::INSTANCE, can_pass_block: true)
      false_block = $BLOCK_GIVEN
      if cond.qt_to_bool(env).bool_val
        true_block ? if_true.qt_eval(env) : if_true
      else
        false_block ? if_false.qt_eval(env) : if_false
      end
    },
    QT_Symbol.new( :unless ) => QT_BuiltinFunciton.new{ |args, env| 
      cond = fetch(args, env, 0, :__cond)

      if_false = fetch(args, env, 1, QT_False::INSTANCE, :false, can_pass_block: false)
      false_block = $BLOCK_GIVEN

      if false_block && ELSE_KEYWORD_FOR_IF == env.p.next_token!(env.clone)[0]
        raise unless ELSE_KEYWORD_FOR_IF == env.p.next_token!(env)[0]
      end

      if_true = fetch(args, env, 2, QT_True::INSTANCE, :true, default: QT_Null::INSTANCE, can_pass_block: false)
      true_block = $BLOCK_GIVEN

      if cond.qt_to_bool(env).bool_val
        false_block ? if_false.qt_eval(env) : if_false
      else
        true_block ? if_true.qt_eval(env) : if_true
      end

    },

    QT_Symbol.new( :while ) => QT_BuiltinFunciton.new{ |args, env|
      cond = fetch(args, env, 0, :__cond)
      body = fetch(args, env, 1, :__body, can_pass_block: true)
      while cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },
    QT_Symbol.new( :until ) => QT_BuiltinFunciton.new{ |args, env|
      cond = fetch(args, env, 0, :__cond)
      body = fetch(args, env, 1, :__body, can_pass_block: trues)
      until cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },

    QT_Symbol.new( :for ) => QT_BuiltinFunciton.new{ |args, env|
      start = fetch(args, env, 0, :__start)
      cond =  fetch(args, env, 1, :__cond)
      incr =  fetch(args, env, 2, :__incr)
      body =  fetch(args, env, 3, :__body, can_pass_block: true)
      start.is_a?(QT_Universe) && start.qt_eval(env)
      while cond.clone.qt_eval(env).pop.qt_to_bool(env).bool_val
        body.clone.qt_eval(env)
        incr.clone.qt_eval(env)
      end
      QT_Null::INSTANCE
    },

    QT_Symbol.new( :disp ) => QT_BuiltinFunciton.new{ |args, env|

      endl = fetch(args, env, :end, default: QT_Text.new("\n"))
      sep = fetch(args, env, :sep, default: QT_Text.new(""))
      to_print = args.stack.collect{ |arg| arg.qt_to_text(env).text_val }.join(sep.qt_to_text(env).text_val)
      print(to_print + endl.qt_to_text(env).text_val)
      QT_Null::INSTANCE
    },
    QT_Symbol.new( :prompt ) => QT_BuiltinFunciton.new{ |args, env|
      prompt = fetch(args, env, 0, :__prompt, default: QT_Text.new( '' ))
      prefix = fetch(args, env, 1, :__prefix, default: QT_Text.new( " = " ))
      endl = fetch(args, env, 2, :__endl, default: QT_Text.new( "\n" ))
      print prompt.text_val + prefix.text_val
      QT_Text.new( STDIN.gets(endl.text_val).chomp )
    },

    QT_Symbol.new( :read_file ) => QT_BuiltinFunciton.new{ |args, env|
      file_path = fetch(args, env, 0, :file, :file_path).qt_to_text(env)
      file = open(file_path.text_val, 'r')
      QT_Text.new( file.read, quotes: file_path.quotes )
    },
    QT_Symbol.new( :write_file ) => QT_BuiltinFunciton.new{ |args, env|
      file_path = fetch(args, env, 0, :file, :file_path).qt_to_text(env)
      text = fetch(args, env, 1, :text).qt_to_text(env)
      file = open(file_path.text_val, 'w'){ |f|
        f.write(text.text_val)
      }
      QT_Null::INSTANCE
      # QT_Text.new( file.read, quotes: file_path.quotes )
    },

    QT_Symbol.new( :text ) => QT_BuiltinFunciton.new{ |args, env|
      to_text = fetch(args, env, 0, :__to_text, default: QT_Text::EMPTY)
      quote1   = fetch(args, env, 1, :quote, :__quote,  :quote1, :__quote1, default: QT_Text.new( '"' ))
      quote2   = fetch(args, env, 2, :quote2, :__quote2, default: quote1)
      res = to_text.qt_to_text(env)
      res.quotes = [quote1.qt_to_text(env), 
                    quote2.qt_to_text(env)]
      res
    },

    QT_Symbol.new( :num ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, env, 0, :__to_num, default: QT_Number::ZERO).qt_to_num(env)
    },

    QT_Symbol.new( :stop ) => QT_BuiltinFunciton.new{ |args, env|
      exit fetch(args, env, 0, :__code, default: QT_Number::ZERO).qt_to_num(env).num_val
    },


    QT_Symbol.new( :bool ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, env, 0, :__to_num, default: QT_False::INSTANCE).qt_to_bool(env)
    },

    QT_Symbol.new( :type ) => QT_BuiltinFunciton.new{ |args, env|
      fetch(args, env, 0, :__to_type).qt_to_type(env)
    },

    QT_Symbol.new( :len ) => QT_BuiltinFunciton.new{ |args, env|
      arg = fetch(args, env, 0, :__arg)
      arg.qt_length( env, type: fetch(args, env, 1, :__type, default: QT_Symbol.new( :BOTH )))
    },


    # i dont know how many of these work...

    QT_Symbol.new( :clone ) => QT_BuiltinFunciton.new{ |args, env|
      # qutie_func(args, universe, parser, :qt_clone){ |a| a.clone }
    },


    QT_Symbol.new( :return ) => QT_BuiltinFunciton.new{ |args, env|

      # value = args.locals.fetch(:__value){ args.stack.fetch(0, NoRet) }
      # levels = args.locals.fetch(:__levels){ args.stack.fetch(1, 1) }
      # if levels > 0
      #   universe.program_stack.pop # to remove us
      #   throw :EOF, [levels, value]
      # end
      QT_Null::INSTANCE
    },

    QT_Symbol.new( :import ) => QT_BuiltinFunciton.new{ |args, env|
      file = fetch(args, env, 0, :__file)
      pre_process = fetch(args, env, 1, :__preprocess, default: QT_True::INSTANCE).qt_to_bool(env)
      imported = open(file).read
      PreParser.pre_process!(imported) if pre_process.bool_val
      parser.process(input: imported, additional_builtins: passed_args.locals)

    },

    QT_Symbol.new( :del ) => QT_BuiltinFunciton.new{ |args, env|
        
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

  def fetch(args, env, *search_fors, default: Ignore, can_pass_block: false)
    $BLOCK_GIVEN = false
    search_fors.each do |search_for|
      res = (search_for.is_a?(Integer) ? args.stack : args.locals).fetch(
              (search_for.is_a?(Symbol) ? QT_Symbol.new( search_for ) : search_for), Ignore)
      return res unless res.equal?( Ignore )
    end
    if can_pass_block
      ntoken = env.p.next_token!(env.clone)
      raise unless Operators::DELIMS.include?(env.p.next_token!(env)[0]) if Operators::DELIMS.include?(ntoken[0])
      # ^^ get rid of the [';' or ','] outside the function.
      $BLOCK_GIVEN = true
      return env.p.next_token!(env)[0]
    end
    raise "Cannot find args for #{search_fors}" if default.equal?(Ignore)
    default
  end

end


