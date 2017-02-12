class QT_Operator < QT_Object

  attr_reader :name
  attr_reader :operands
  attr_reader :priority

  def initialize(name:, priority:, operands: [1, 1], bin_meth: nil,  &func)
    @name = name
    @priority = priority
    @operands = operands # operands is [left amount of vars, right amount of vars]
    @func = func 
    @bin_meth = bin_meth
  end

  def to_s
    @name.to_s
  end

  def call(lhs_vars:, rhs_vars:, universe:, stream:, parser:)
    fail unless lhs_vars.length == @operands[0]
    fail unless rhs_vars.length == @operands[1]
    if @func
      @func.call(lhs_vars: lhs_vars,
                 rhs_vars: rhs_vars,
                 universe: universe,
                 stream: stream,
                 parser: parser)
    else
      lhs_vars[0].method(@bin_meth).call( rhs_vars[0] )
    end
  end

end
module Operators; end
Operators::OPERATORS = [
  QT_Operator.new(name: :':' , priority: 30){ |**kw| Operators::OPERATORS['='].call(**kw) },
  QT_Operator.new(name: :'->', priority: 30){ |**kw| Operators::OPERATORS['='].call(**kw) },
  QT_Operator.new(name: :'<-', priority: 30){ |lhs_vars:, rhs_vars:, **kw|
    Operators::OPERATORS['='].call(lhs_vars: rhs_vars, rhs_vars: lhs_vars, **kw)
  },
  QT_Operator.new(name: :<=>,  priority: 19, bin_meth: :qt_cmp), 
  QT_Operator.new(name: :**,   priority: 10, bin_meth: :qt_pow), 
  QT_Operator.new(name: :==,   priority: 20, bin_meth: :qt_eql), 
  QT_Operator.new(name: :'<>', priority: 20, bin_meth: :qt_neq), 
  QT_Operator.new(name: :<=,   priority: 20, bin_meth: :qt_leq), 
  QT_Operator.new(name: :>=,   priority: 20, bin_meth: :qt_geq), 

  QT_Operator.new(name: :'&&', priority: 24){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_to_bool.bool_val ? r : l 
  },
  QT_Operator.new(name: :'||', priority: 25){ |lhs_vars:, rhs_vars:, **_|
    l = lhs_vars[0]; r = rhs_vars[0]; l.qt_to_bool.bool_val ? l : r 
  },
  QT_Operator.new(name: :'@0', priority:  7) { |**kw|
    Operators::OPERATORS['@'].call(**kw).qt_get(pos: QT_Number::NEG_1, type: :STACK)
  },
  # QT_Operator.new(name: :'.=', priority: 6){ |arg, pos| args.qt_set(pos, type: :STACK) }, # todo: fix this
  QT_Operator.new(name: :'.S' , priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :STACK) || QT_Null::INSTANCE
  },
  QT_Operator.new(name: :'.L' , priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :LOCALS) || QT_Null::INSTANCE
  },
  QT_Operator.new(name: :'.G' , priority: 5){ |lhs_vars:, rhs_vars:, **_| 
    lhs_vars[0].qt_get(pos: rhs_vars[0], type: :GLOBALS) || QT_Null::INSTANCE
  },

  QT_Operator.new(name: :* , priority: 11, bin_meth: :qt_mul),
  QT_Operator.new(name: :/ , priority: 11, bin_meth: :qt_div),
  QT_Operator.new(name: :% , priority: 11, bin_meth: :qt_mod),
  QT_Operator.new(name: :+ , priority: 12, bin_meth: :qt_add),
  QT_Operator.new(name: :- , priority: 12, bin_meth: :qt_sub),
  QT_Operator.new(name: :< , priority: 20, bin_meth: :qt_lth),
  QT_Operator.new(name: :> , priority: 20, bin_meth: :qt_gth),
  QT_Operator.new(name: :'=' , priority: 30){ |lhs_vars:, rhs_vars:, universe:, **_| universe.locals[lhs_vars[0]] = rhs_vars[0] },
  QT_Operator.new(name: :'@' , priority:  7) { |lhs_vars:, rhs_vars:, **kw|
    func = lhs_vars[0]
    args = rhs_vars[0]
    func.qt_call(args: args, **kw)
  },
  QT_Operator.new(name: :'.' , priority: 5){ |lhs_vars:, rhs_vars:, **kw|
    arg = lhs_vars[0]
    pos = rhs_vars[0]
    if pos.is_a?(QT_Variable) && pos.var_val.to_s.start_with?('__')
      arg.qt_method(meth: pos.to_s[2..-1].to_sym) || QT_Null::INSTANCE
    else
      arg.qt_get(pos: pos, type: :BOTH) || QT_Null::INSTANCE
    end
  },
  QT_Operator.new(name: :';' , priority: 40, operands: [1, 0]){ true },
  QT_Operator.new(name: :',' , priority: 40, operands: [1, 0]){ |lhs_vars:, **_| lhs_vars[0] },
  QT_Operator.new(name: :'?' , priority:  1, operands: [1, 0]){ |lhs_vars:, universe:, **_| universe.qt_get(pos: lhs_vars[0], type: :NON_STACK) },
  QT_Operator.new(name: :'!' , priority:  1, operands: [1, 0]){ |lhs_vars:, **kw|
    lhs_vars[0].qt_eval(**kw)
  },
]







