require_relative 'object'
class QT_Universe < QT_Object
  def self.from(source:, current_universe:)
    warn("QT_Universe::from doesnt conform to others!")
    new(body: source[1...-1],
        current_universe: current_universe,
        parens: [source[0], source[-1]])
  end

  def initialize(body:, current_universe:, parens:)
    @body = body
    @current_universe = current_universe
    @parens = parens
    @universe = @current_universe.clone

    @universe.stack = @body.each_char.to_a
  end

  def to_s
    "#{@parens[0]} ... #{@parens[1]}"
    @body
  end

  def method_missing(meth, *a)
    @universe.method(meth).call(*a)
  end

  def qt_eval(universe:, parser:, **_)
    parser.parse(stream: @universe, universe: universe)
  end
end






