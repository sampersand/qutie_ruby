require_relative 'object'
class QT_Universe < QT_Object
  def self.from(source:, current_universe:)
    warn("QT_Universe::from doesnt conform to others!")
    new_universe = current_universe.clone
    new_universe.stack = source[1...-1].each_char.to_a
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
    "#{@parens[0]} ... #{@parens[1]}"
    @body
  end

  def method_missing(meth, *a)
    @universe.method(meth).call(*a)
  end

  def qt_eval(universe:, parser:, **_)
    res = parser.parse(stream: @universe, universe: universe)
    QT_Universe.new(body: '', universe: res, parens: nil) # this is where it gets hacky
  end

  def qt_call(args:, parser:, **_)
    args.locals[:__args] = args #somethign here with spawn off
    # func.program_stack.push args
    parser.parse(stream: @universe, universe: args)
    # func.program_stack.pop
  end
  def qt_index(pos: )
    @universe.locals[pos] || 
    @universe.stack[pos.qt_to_num.num_val]
  end
end












