module Operators
  class Operator
    attr_reader :type
    attr_reader :priority
    def initialize(name:, priority:, type: :BINARY, &func)
      @name = name
      @priority = priority
      @type = type
      @func = func
    end
    def call(*a)
      @func.call(*a)
    end

  end
  OPERATORS = {
    '->' => Operator.new(name: '->', priority: 30){ |l, r, u| OPERATORS['='].call(r, l, u) },
    '<-' => Operator.new(name: '<-', priority: 30){ |l, r, u| OPERATORS['='].call(l, r, u) },
    ':'  => Operator.new(name: ':' , priority: 30){ |l, r, u| OPERATORS['='].call(l, r, u) },
    '**' => Operator.new(name: '**', priority: 10){ |l, r| l.qt_pow(right: r) || r.qt_pow_r(left: l) },
    '==' => Operator.new(name: '==', priority: 20){ |l, r| l.qt_eql(right: r) || r.qt_eql_r(left: l) || QT_Boolean::FALSE },
    '<>' => Operator.new(name: '<>', priority: 20){ |l, r| l.qt_neq(right: r) || r.qt_neq_r(left: l) || QT_Boolean::TRUE },
    '<=' => Operator.new(name: '<=', priority: 20){ |l, r| l.qt_leq(right: r) || r.qt_leq_r(left: l) },
    '>=' => Operator.new(name: '>=', priority: 20){ |l, r| l.qt_geq(right: r) || r.qt_geq_r(left: l) },
    '&&' => Operator.new(name: '&&', priority: 24){ |l, r| l.qt_to_bool.bool_val ? r : l  },
    '||' => Operator.new(name: '||', priority: 25){ |l, r| l.qt_to_bool.bool_val ? l : r  },
    '@0' => Operator.new(name: '@0', priority:  7) { |f, a, u, s, p| OPERATORS['@'].call(f, a, u, s, p).qt_get(QT_Number.new(num_val: -1), type: :STACK) },
    '.=' => Operator.new(name: '.=', priority: 6){ |arg, pos| args.qt_set(pos, type: :STACK) }, # todo: fix this
    '.S'  => Operator.new(name: '.S', priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :STACK) },
    '.L'  => Operator.new(name: '.L', priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :LOCALS) },
    '.G'  => Operator.new(name: '.G', priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :GLOBALS) },

    '*'  => Operator.new(name: '*' , priority: 11){ |l, r| l.qt_mul(right: r) || r.qt_mul_r(left: l) },
    '/'  => Operator.new(name: '/' , priority: 11){ |l, r| l.qt_div(right: r) || r.qt_div_r(left: l) },
    '%'  => Operator.new(name: '%' , priority: 11){ |l, r| l.qt_mod(right: r) || r.qt_mod_r(left: l) },
    '+'  => Operator.new(name: '+' , priority: 12){ |l, r| l.qt_add(right: r) || r.qt_add_r(left: l) },
    '-'  => Operator.new(name: '-' , priority: 12){ |l, r| l.qt_sub(right: r) || r.qt_sub_r(left: l) },
    '<'  => Operator.new(name: '<' , priority: 20){ |l, r| l.qt_lth(right: r) || r.qt_lth_r(left: l) },
    '>'  => Operator.new(name: '>' , priority: 20){ |l, r| l.qt_gth(right: r) || r.qt_gth_r(left: l) },
    '='  => Operator.new(name: '=' , priority: 30){ |lhs, rhs, universe, | universe.locals[lhs] = rhs },
    '@'  => Operator.new(name: '@',  priority:  7) { |func, args, universe, stream, parser|
      if func.respond_to?(:call)
        func.call(args, universe, stream, parser)
      else
        func.qt_call(args: args, universe: universe, stream: stream, parser: parser)
      end
    },
    '.'   => Operator.new(name: '.' , priority: 5){ |arg, pos|
      if pos.is_a?(QT_Variable) && pos.var_val.to_s.start_with?('__')
        arg.qt_method(meth: pos.to_s[2..-1].to_sym) || QT_Boolean::NULL
      else
        arg.qt_get(pos: pos, type: :BOTH) || QT_Boolean::NULL
      end },
    ';'  => Operator.new(name: ';', priority: 40, type: :UNARY_POSTFIX){ |lhs, universe|
      true
      },
    ','  => Operator.new(name: ',', priority: 40, type: :UNARY_POSTFIX){ |lhs| lhs},
    '?'  => Operator.new(name: '?', priority:  1, type: :UNARY_POSTFIX){ |args, universe|
      # universe.qt_get(pos: args)
        universe[args]
    },
  }
end






