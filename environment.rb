class Environment

  attr_reader :stream, :universe, :parser
  alias :s :stream
  alias :u :universe
  alias :p :parser

  def initialize(stream:, universe:, parser:)
    @stream = stream
    @universe = universe
    @parser = parser
    assert_is_any(@stream, QT_Universe)
    assert_is_any(@universe, QT_Universe)
    assert_is_any(@parser, Parser)
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