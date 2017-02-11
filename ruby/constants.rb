require_relative 'plugins/builtins/boolean'
require_relative 'plugins/builtins/null'
require_relative 'plugins/number/number'
require_relative 'plugins/variable/variable'
module Constants

  CONSTANTS = {
    QT_Variable.new(var_val: :true)    => QT_True::INSTANCE,
    QT_Variable.new(var_val: :false)   => QT_False::INSTANCE,
    QT_Variable.new(var_val: :nil)     => QT_Null::INSTANCE,
    QT_Variable.new(var_val: :null)    => QT_Null::INSTANCE,
    QT_Variable.new(var_val: :none)    => QT_Null::INSTANCE,
    QT_Variable.new(var_val: :math_e)  => QT_Number::E,
    QT_Variable.new(var_val: :math_pi) => QT_Number::PI,
    QT_Variable.new(var_val: :math_nan) => QT_Number::NaN,
  }
end
