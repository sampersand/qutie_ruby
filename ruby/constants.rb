require_relative 'classes/boolean_and_null'
require_relative 'classes/variable'


module Constants

  CONSTANTS = {
    QT_Variable::from(source: 'true')    => QT_True::INSTANCE,
    QT_Variable::from(source: 'false')   => QT_False::INSTANCE,
    QT_Variable::from(source: 'nil')     => QT_Null::INSTANCE,
    QT_Variable::from(source: 'null')    => QT_Null::INSTANCE,
    QT_Variable::from(source: 'none')    => QT_Null::INSTANCE,
    QT_Variable::from(source: 'math_e')  => QT_Number::E,
    QT_Variable::from(source: 'math_pi') => QT_Number::PI,
    QT_Variable::from(source: 'math_nan') => QT_Number::NaN,
  }
end
