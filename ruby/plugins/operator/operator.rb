class QT_Operator < QT_Object

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
module Operators; end
Operators::OPERATORS = {
  ':'  => QT_Operator.new(priority: 30){ |**kw| Operators::OPERATORS['='].call(**kw) },
  '->' => QT_Operator.new(priority: 30){ |**kw| Operators::OPERATORS['='].call(**kw) },
  '<-' => QT_Operator.new(priority: 30){ |lhs_vars:, rhs_vars:, **kw|
    Operators::OPERATORS['='].call(lhs_vars: rhs_vars, rhs_vars: lhs_vars, **kw)
  },
  '**' => QT_Operator.new(priority: 10){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_pow(right: r) || r.qt_pow_r(left: l)
  },
  '==' => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_equal(right: r) || r.qt_equal_r(left: l) || QT_Boolean::FALSE
  },
  '<>' => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_neq(right: r) || r.qt_neq_r(left: l) || QT_Boolean::TRUE
  },
  '<=' => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_leq(right: r) || r.qt_leq_r(left: l)
  },
  '>=' => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_geq(right: r) || r.qt_geq_r(left: l)
  },
  '&&' => QT_Operator.new(priority: 24){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_to_bool.bool_val ? r : l 
  },
  '||' => QT_Operator.new(priority: 25){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_to_bool.bool_val ? l : r 
  },
  '@0' => QT_Operator.new(priority:  7) { |**kw|
    Operators::OPERATORS['@'].call(**kw).qt_get(pos: QT_Number::NEG_1, type: :STACK) },
  # '.=' => QT_Operator.new(priority: 6){ |arg, pos| args.qt_set(pos, type: :STACK) }, # todo: fix this
  '.S'  => QT_Operator.new(priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :STACK) || QT_Null::INSTANCE
  },
  '.L'  => QT_Operator.new(priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :LOCALS) || QT_Null::INSTANCE
  },
  '.G'  => QT_Operator.new(priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :GLOBALS) || QT_Null::INSTANCE
  },

  '*'  => QT_Operator.new(priority: 11){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_mul(right: r) || r.qt_mul_r(left: l)
  },
  '/'  => QT_Operator.new(priority: 11){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_div(right: r) || r.qt_div_r(left: l)
  },
  '%'  => QT_Operator.new(priority: 11){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_mod(right: r) || r.qt_mod_r(left: l)
  },
  '+'  => QT_Operator.new(priority: 12){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_add(right: r) || r.qt_add_r(left: l)
  },
  '-'  => QT_Operator.new(priority: 12){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_sub(right: r) || r.qt_sub_r(left: l)
  },
  '<'  => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_lth(right: r) || r.qt_lth_r(left: l)
  },
  '>'  => QT_Operator.new(priority: 20){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_gth(right: r) || r.qt_gth_r(left: l)
  },
  '='  => QT_Operator.new(priority: 30){ |lhs_vars:, rhs_vars:, universe:, **_| universe.locals[lhs_vars[0]] = rhs_vars[0] },
  '@'  => QT_Operator.new(priority:  7) { |lhs_vars:, rhs_vars:, **kw|
    func = lhs_vars[0]
    args = rhs_vars[0]
    func.qt_call(args: args, **kw)
  },
  '.'  => QT_Operator.new(priority: 5){ |lhs_vars:, rhs_vars:, **kw|
    arg = lhs_vars[0]
    pos = rhs_vars[0]
    if pos.is_a?(QT_Variable) && pos.var_val.to_s.start_with?('__')
      arg.qt_method(meth: pos.to_s[2..-1].to_sym) || QT_Null::INSTANCE
    else
      arg.qt_get(pos: pos, type: :BOTH) || QT_Null::INSTANCE
    end
  },
  ';'  => QT_Operator.new(priority: 40, operands: [1, 0]){ true },
  ','  => QT_Operator.new(priority: 40, operands: [1, 0]){ |lhs_vars:, **_| lhs_vars[0] },
  '?'  => QT_Operator.new(priority:  1, operands: [1, 0]){ |lhs_vars:, universe:, **_| universe.qt_get(pos: lhs_vars[0], type: :NON_STACK) },
  '!'  => QT_Operator.new(priority:  1, operands: [1, 0]){ |lhs_vars:, **kw|
    lhs_vars[0].qt_eval(**kw)
  },
}







