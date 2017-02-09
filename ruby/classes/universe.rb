require_relative 'object'
class QT_Universe < QT_Object
  def self.from(source:, current_universe:)
    # warn("QT_Universe::from doesnt conform to others!")
    new_universe = current_universe.class.new
    new_universe.stack = source[1...-1].each_char.to_a
    new_universe.locals = current_universe.locals
    new_universe.globals = current_universe.globals

    new(body: source[1...-1],
        universe: new_universe,
        parens: [source[0], source[-1]])
  end

  def initialize(body:, universe:, parens:)
    @body = body
    @parens = parens
    @universe = universe
  end

  def to_s
    # "#{@parens[0]} ... #{@parens[1]}"
    # @body
    @universe.to_s
  end

  def method_missing(meth, *a)
    @universe.method(meth).call(*a)
  end

  def qt_eval(universe:, parser:, **_)
    res = parser.parse(stream: @universe, universe: universe)
    QT_Universe.new(body: '', universe: res, parens: nil) # this is where it gets hacky
  end

  def qt_call(args:, parser:, **_)
    passed_args = args.clone
    passed_args.globals.update(passed_args.locals)
    passed_args.locals.clear
    passed_args.stack.clear
    passed_args.locals[:__args] = args #somethign here with spawn off
    # func.program_stack.push args
    parser.parse(stream: @universe, universe: passed_args)
    # func.program_stack.pop
  end
  def qt_index(pos:, type: )
    if type == :BOTH
      if @universe.locals.include?(pos)
        type = :LOCALS
      else
        type = :STACK
      end
    end
    case type 
    when :STACK then @universe.stack[(pos.qt_to_num or return QT_Boolean::NULL).num_val] or QT_Boolean::NULL
    when :LOCALS then @universe.locals[pos] or QT_Boolean::NULL
    else fail "Unknown qt_index type `#{type}`!"
    end
  end
end




















