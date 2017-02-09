require_relative 'object'
class QT_Universe < QT_Object
  def self.from(source:, current_universe:)
    warn("QT_Universe::from doesnt conform to others!")
    new(body: source,
        current_universe: current_universe,
        parens: [source[0], source[-1]])
  end

  def initialize(body:, current_universe:, parens:)
    @body = body
    @current_universe = current_universe
    @parens = parens
  end

  def to_s
    "#{@parens[0]} ... #{@parens[1]}"
  end

end