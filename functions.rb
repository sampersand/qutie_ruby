 module Functions
  class BuiltinFunciton
    def initialize(&block)
      @func = block
    end
    def call(func, args, universe, parser)
      @func.call(func, args, universe, parser)
    end
  end
  FUNCTIONS = {
    'clone' => BuiltinFunciton.new{ |func, args, universe, parser|
      to_clone = parser.parse_all(args, universe.to_globals)
      universe <<(case to_clone
                  when true, false, nil, Numeric then to_clone
                  else to_clone.clone
                  end)
    },
    'disp' => BuiltinFunciton.new{ |func, args, universe, parser|
      to_print = parser.parse_all(args, universe.to_globals)
      endl = to_print.get('end') || "\n"
      sep  = to_print.get('sep') || " "
      print(to_print.stack.collect(&:to_s).join(sep) + endl)
    },
    'stop' => BuiltinFunciton.new{ |func, args, universe, parser|
      exit_code = parser.parse_all(args, universe.to_globals).stack.last
      exit(exit_code || 0)
    },
    'text' => BuiltinFunciton.new{ |func, args, universe, parser|
        to_text = parser.parse_all(args, universe.to_globals).stack.last
        universe << to_text.to_s

    },
  }
  module_function

  # def handle_text(stream, universe, parser)
  #   to_text = next_argument(stream, universe, parser, do_eval: true)
  #   universe << to_text.to_s
  # end

end










