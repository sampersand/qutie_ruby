class Environment
  attr_reader :stream, :universe, :parser
  alias :s :stream
  alias :u :universe
  alias :p :parser
  def initialize(stream, universe, parser)
    @stream = stream
    @universe = universe
    @parser = parser
    fail @stream.class.to_s unless @universe.is_a?(UniverseOLD) || @universe.is_a?(QT_Universe)
    fail @universe.class.to_s unless @universe.is_a?(UniverseOLD) || @universe.is_a?(QT_Universe)
    fail @parser.class.to_s unless @parser.is_a?(Parser)
  end
  def fork(stream: @stream, universe: @universe, parser: @parser)
    self.class.new(stream, universe, parser)
  end
  def clone
    self.class.new(@stream.clone, @universe.clone, @parser.clone)
  end
end