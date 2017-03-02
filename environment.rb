class Environment

  attr_reader :stream, :universe, :parser
  alias :s :stream
  alias :u :universe
  alias :p :parser

  def initialize(stream:, universe:, parser:)
    @stream = stream
    @universe = universe
    @parser = parser
    assert_is_a(@stream, QT_Universe, '@stream')
    assert_is_a(@universe, QT_Universe, '@universe')
    assert_is_a(@parser, Parser, '@parser')
  end

  def fork(stream:   @stream,
           universe: @universe,
           parser:   @parser)
    self.class.new(stream:   stream,
                   universe: universe,
                   parser:   parser)
  end

  def clone
    self.class.new(stream:   @stream.clone,
                   universe: @universe.clone,
                   parser:   @parser.clone)
  end

end