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

  def call(lhs_vars, rhs_vars, env)
    fail unless lhs_vars.length == @operands[0]
    fail unless rhs_vars.length == @operands[1]
    if @bin_meth
      lhs_vars[0].method(@bin_meth).call( rhs_vars[0], env )
    else
      fail unless @func
      @func.call(*lhs_vars, *rhs_vars, env)
    end
  end


end

module Operators
  module_function
  OPERATORS = [
    QT_Operator.new(name: :':' , priority: 36){ |l, r, e| EQL_OPER.call([l], [r], e)   },
    QT_Operator.new(name: :'<-', priority: 30){ |l, r, e| EQL_OPER.call([l], [r], e);l },
    QT_Operator.new(name: :'->', priority: 30){ |l, r, e| EQL_OPER.call([r], [l], e);r },

    QT_Operator.new(name: :<=>,  priority: 19, bin_meth: :qt_cmp), 
    QT_Operator.new(name: :**,   priority: 10, bin_meth: :qt_pow), 
    QT_Operator.new(name: :==,   priority: 20, bin_meth: :qt_eql), 
    QT_Operator.new(name: :'<>', priority: 20, bin_meth: :qt_neq), # this and the next are equivalent
    QT_Operator.new(name: :'!=', priority: 20, bin_meth: :qt_neq), # equivalent
    QT_Operator.new(name: :<=,   priority: 20, bin_meth: :qt_leq), 
    QT_Operator.new(name: :>=,   priority: 20, bin_meth: :qt_geq), 
    QT_Operator.new(name: :'.=', priority:  6){ |l, r, e| l.qt_set(*r.stack, e, type: QT_Symbol.new( :BOTH ) ) },

    QT_Operator.new(name: :'@0', priority:  7){ |l, r, e| CALL_OPER.call([l], [r], e).qt_eval(e).qt_get(QT_Number::NEG_1, e, type: QT_Symbol.new( :STACK ) ) },

    QT_Operator.new(name: :'&&', priority: 24){ |l, r, e| l.qt_to_bool(e).bool_val ? r : l },
    QT_Operator.new(name: :'||', priority: 25){ |l, r, e| l.qt_to_bool(e).bool_val ? l : r },

    QT_Operator.new(name: :'.S' , priority: 5){ |l, r, e| l.qt_get(r, e, type: QT_Symbol.new( :STACK ) )   },
    QT_Operator.new(name: :'.L' , priority: 5){ |l, r, e| l.qt_get(r, e, type: QT_Symbol.new( :LOCALS ) )  },
    QT_Operator.new(name: :'.G' , priority: 5){ |l, r, e| l.qt_get(r, e, type: QT_Symbol.new( :GLOBALS ) ) },

    QT_Operator.new(name: :* , priority: 11, bin_meth: :qt_mul),
    QT_Operator.new(name: :/ , priority: 11, bin_meth: :qt_div),
    QT_Operator.new(name: :% , priority: 11, bin_meth: :qt_mod),
    QT_Operator.new(name: :+ , priority: 12, bin_meth: :qt_add),
    QT_Operator.new(name: :- , priority: 12, bin_meth: :qt_sub),
    QT_Operator.new(name: :< , priority: 20, bin_meth: :qt_lth),
    QT_Operator.new(name: :> , priority: 20, bin_meth: :qt_gth),

    QT_Operator.new(name: :'=' , priority: 35){ |l, r, e| e.u.locals[l] = r; r }, # this is akin to `.=`
    QT_Operator.new(name: :'@' , priority:  7){ |l, r, e| l.qt_call(r, e)    },
    QT_Operator.new(name: :'.' , priority:  5){ |l, r, e| l.qt_get(r, e, type: QT_Symbol.new( :BOTH ) ) },

    QT_Operator.new(name: :';' , priority: 40, operands: [1, 0]){ true },
    QT_Operator.new(name: :',' , priority: 40, operands: [1, 0]){ |l| l },
    QT_Operator.new(name: :'?' , priority:  1, operands: [1, 0]){ |l, e| e.u.qt_get(l, e, type: QT_Symbol.new( :NON_STACK ) ) }, # akin to `.`
    QT_Operator.new(name: :'!' , priority:  1, operands: [1, 0]){ |l, e| l.qt_eval(e) }, #universe, stream, parser
  ]

  EQL_OPER  = Operators::OPERATORS.find{ |e| e.name == :'=' }
  CALL_OPER = Operators::OPERATORS.find{ |e| e.name == :'@' }
  DELIMS = Operators::OPERATORS.find_all{ |e| [:',', :';'].include?(e.name) }

end























