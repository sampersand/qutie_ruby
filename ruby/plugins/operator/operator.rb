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
    if @bin_meth
      lhs_vars[0].method(@bin_meth).call( rhs_vars[0] )
    else
      @func.call(*lhs_vars, *rhs_vars, universe, stream, parser)
    end
  end

end

module Operators; end

Operators::OPERATORS = [
  QT_Operator.new(name: :':' , priority: 30){ |*a|       EQL_OPER.call(*a)       },
  QT_Operator.new(name: :'->', priority: 30){ |*a|       EQL_OPER.call(*a)       },
  QT_Operator.new(name: :'<-', priority: 30){ |l, r, *a| EQL_OPER.call(r, l, *a) },

  QT_Operator.new(name: :<=>,  priority: 19, bin_meth: :qt_cmp), 
  QT_Operator.new(name: :**,   priority: 10, bin_meth: :qt_pow), 
  QT_Operator.new(name: :==,   priority: 20, bin_meth: :qt_eql), 
  QT_Operator.new(name: :'<>', priority: 20, bin_meth: :qt_neq), # this and the next are equivalent
  QT_Operator.new(name: :'!=', priority: 20, bin_meth: :qt_neq), # equivalent
  QT_Operator.new(name: :<=,   priority: 20, bin_meth: :qt_leq), 
  QT_Operator.new(name: :>=,   priority: 20, bin_meth: :qt_geq), 
  QT_Operator.new(name: :'.=', priority:  6, bin_meth: :qt_set),

  QT_Operator.new(name: :'@0', priority:  7){ |*a| CALL_OPER.call(*a).qt_get(QT_Number::NEG_1, type: :STACK) },

  QT_Operator.new(name: :'&&', priority: 24){ |l, r| l.qt_to_bool.bool_val ? r : l },
  QT_Operator.new(name: :'||', priority: 25){ |l, r| l.qt_to_bool.bool_val ? l : r },

  QT_Operator.new(name: :'.S' , priority: 5){ |l, r| l.qt_get(r, type: :STACK)   },
  QT_Operator.new(name: :'.L' , priority: 5){ |l, r| l.qt_get(r, type: :LOCALS)  },
  QT_Operator.new(name: :'.G' , priority: 5){ |l, r| l.qt_get(r, type: :GLOBALS) },

  QT_Operator.new(name: :* , priority: 11, bin_meth: :qt_mul),
  QT_Operator.new(name: :/ , priority: 11, bin_meth: :qt_div),
  QT_Operator.new(name: :% , priority: 11, bin_meth: :qt_mod),
  QT_Operator.new(name: :+ , priority: 12, bin_meth: :qt_add),
  QT_Operator.new(name: :- , priority: 12, bin_meth: :qt_sub),
  QT_Operator.new(name: :< , priority: 20, bin_meth: :qt_lth),
  QT_Operator.new(name: :> , priority: 20, bin_meth: :qt_gth),

  QT_Operator.new(name: :'=' , priority: 30){ |l, r,  u| u.locals[l] = r               },
  QT_Operator.new(name: :'@' , priority:  7){ |l, r, *a| l.qt_call(r, *a)              },
  QT_Operator.new(name: :'.' , priority:  5){ |r, l,  u| l.qt_get(r, type: :BOTH) },

  QT_Operator.new(name: :';' , priority: 40, operands: [1, 0]){ true },
  QT_Operator.new(name: :',' , priority: 40, operands: [1, 0]){ |l| l },
  QT_Operator.new(name: :'?' , priority:  1, operands: [1, 0]){ |l,  u| u.qt_get(l, type: :NON_STACK) },
  QT_Operator.new(name: :'!' , priority:  1, operands: [1, 0]){ |l, u, s, p| l.qt_eval(u, s, p) }, #universe, stream, parser
]

EQL_OPER  = Operators::OPERATORS.find{ |e| e.name == :'=' }
CALL_OPER = Operators::OPERATORS.find{ |e| e.name == :'@' }

























