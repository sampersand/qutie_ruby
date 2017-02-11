require_relative 'plugins/builtins/boolean'
require_relative 'plugins/builtins/null'
require_relative 'plugins/number/number'
require_relative 'plugins/variable/variable'
module Constants

  CONSTANTS = {
    QT_Variable.new( :true     ) => QT_True::INSTANCE,
    QT_Variable.new( :false    ) => QT_False::INSTANCE,
    QT_Variable.new( :nil      ) => QT_Null::INSTANCE,
    QT_Variable.new( :null     ) => QT_Null::INSTANCE,
    QT_Variable.new( :none     ) => QT_Null::INSTANCE,
    QT_Variable.new( :math_e   ) => QT_Number::E,
    QT_Variable.new( :math_pi  ) => QT_Number::PI,
    QT_Variable.new( :math_nan ) => QT_Number::NaN,
  }
end
