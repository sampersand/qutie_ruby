module Operators
  class Operator

    attr_reader :operands
    attr_reader :priority

    def initialize(priority:, operands: [1, 1], &func)
      @priority = priority
      @operands = operands # operands is [left amount of vars, right amount of vars]
      @func = func
    end

    def call(lhs_vars:, rhs_vars:, universe:, stream:, parser:)
      fail unless lhs_vars.length == @operands[0]
      fail unless rhs_vars.length == @operands[1]
      @func.call(lhs_vars: lhs_vars,
                 rhs_vars: rhs_vars,
                 universe: universe,
                 stream: stream,
                 parser: parser)
    end

  end
  OPERATORS = {
    '->' => Operator.new(priority: 30){ |l, r, u| OPERATORS['='].call(r, l, u) },
    '<-' => Operator.new(priority: 30){ |l, r, u| OPERATORS['='].call(l, r, u) },
    ':'  => Operator.new(priority: 30){ |l, r, u| OPERATORS['='].call(l, r, u) },
    '**' => Operator.new(priority: 10){ |l, r| l.qt_pow(right: r) || r.qt_pow_r(left: l) },
    '==' => Operator.new(priority: 20){ |l, r| l.qt_eql(right: r) || r.qt_eql_r(left: l) || QT_Boolean::FALSE },
    '<>' => Operator.new(priority: 20){ |l, r| l.qt_neq(right: r) || r.qt_neq_r(left: l) || QT_Boolean::TRUE },
    '<=' => Operator.new(priority: 20){ |l, r| l.qt_leq(right: r) || r.qt_leq_r(left: l) },
    '>=' => Operator.new(priority: 20){ |l, r| l.qt_geq(right: r) || r.qt_geq_r(left: l) },
    '&&' => Operator.new(priority: 24){ |l, r| l.qt_to_bool.bool_val ? r : l  },
    '||' => Operator.new(priority: 25){ |l, r| l.qt_to_bool.bool_val ? l : r  },
    '@0' => Operator.new(priority:  7) { |f, a, u, s, p| OPERATORS['@'].call(f, a, u, s, p).qt_get(QT_Number.new(num_val: -1), type: :STACK) },
    '.=' => Operator.new(priority: 6){ |arg, pos| args.qt_set(pos, type: :STACK) }, # todo: fix this
    '.S'  => Operator.new(priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :STACK) },
    '.L'  => Operator.new(priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :LOCALS) },
    '.G'  => Operator.new(priority: 5){ |arg, pos| arg.qt_get(pos: pos, type: :GLOBALS) },

    '*'  => Operator.new(priority: 11){ |l, r| l.qt_mul(right: r) || r.qt_mul_r(left: l) },
    '/'  => Operator.new(priority: 11){ |l, r| l.qt_div(right: r) || r.qt_div_r(left: l) },
    '%'  => Operator.new(priority: 11){ |l, r| l.qt_mod(right: r) || r.qt_mod_r(left: l) },
    '+'  => Operator.new(priority: 12){ |l, r| l.qt_add(right: r) || r.qt_add_r(left: l) },
    '-'  => Operator.new(priority: 12){ |l, r| l.qt_sub(right: r) || r.qt_sub_r(left: l) },
    '<'  => Operator.new(priority: 20){ |l, r| l.qt_lth(right: r) || r.qt_lth_r(left: l) },
    '>'  => Operator.new(priority: 20){ |l, r| l.qt_gth(right: r) || r.qt_gth_r(left: l) },
    '='  => Operator.new(priority: 30){ |lhs_vars:, rhs_vars:, universe:, **_| universe.locals[lhs_vars[0]] = rhs_vars[0] },
    '@'  => Operator.new(priority:  7) { |func, args, universe, stream, parser|
      if func.respond_to?(:call)
        func.call(args, universe, stream, parser)
      else
        func.qt_call(args: args, universe: universe, stream: stream, parser: parser)
      end
    },
    '.'   => Operator.new(priority: 5){ |arg, pos|
      if pos.is_a?(QT_Variable) && pos.var_val.to_s.start_with?('__')
        arg.qt_method(meth: pos.to_s[2..-1].to_sym) || QT_Boolean::NULL
      else
        arg.qt_get(pos: pos, type: :BOTH) || QT_Boolean::NULL
      end },
    ';'  => Operator.new(priority: 40, operands: [1, 0]){ true },
    ','  => Operator.new(priority: 40, operands: [1, 0]){ |lhs_vars:, **_| lhs_vars[0] },
    '?'  => Operator.new(priority:  1, operands: [1, 0]){ |lhs_vars:, universe:, **_| universe.qt_get(pos: lhs_vars[0]) },
    '!'  => Operator.new(priority:  1, operands: [1, 0]){ |lhs_vars:, **kw|
      lhs_vars[0].qt_eval(**kw)
    },
  }
end






