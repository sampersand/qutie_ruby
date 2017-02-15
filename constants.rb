require_relative 'plugins/builtins/boolean'
require_relative 'plugins/builtins/null'
require_relative 'plugins/number/number'
require_relative 'plugins/symbol/symbol'
module Constants

  CONSTANTS = {
    QT_Symbol.new( :true     ) => QT_True::INSTANCE,
    QT_Symbol.new( :false    ) => QT_False::INSTANCE,
    QT_Symbol.new( :nil      ) => QT_Null::INSTANCE,
    QT_Symbol.new( :null     ) => QT_Null::INSTANCE,
    QT_Symbol.new( :none     ) => QT_Null::INSTANCE,
    QT_Symbol.new( :missing  ) => QT_Missing::INSTANCE,
    QT_Symbol.new( :math_e   ) => QT_Number::E,
    QT_Symbol.new( :math_pi  ) => QT_Number::PI,
    QT_Symbol.new( :math_nan ) => QT_Number::NaN,
    QT_Symbol.new( :NEG_1 ) =>  QT_Number::NEG_1,
    # QT_Symbol.new( :QT_Symbol ) => QT_Symbol.new(:'').qt_to_type(nil),
    # QT_Symbol.new( :QT_Number ) => QT_Number.new(:'').qt_to_type(nil),
  }
end
