require_relative 'universe'
require_relative 'plugins/default'

class Parser
  attr_accessor :plugins
  def initialize(plugins=nil)
    @plugins = plugins || []
    @plugins.push Default
  end

  def add_plugin(plugin)
    @plugins.unshift plugin
  end

  def process(inp)
    stream = Universe.from_string inp
    universe = Universe.new
    parse stream, universe
  end

  def parse(stream, universe)
    until stream.stack.empty?
      token = next_token stream, universe 
      eval_token token, stream, universe
    end
    universe
  end

  def next_token(stream, universe)
    self.class.next_token(stream, universe, self)
  end

  def self.next_token(stream, universe, parser)
    parser.plugins.find{ |pl|
      res = pl.next_token(stream, universe, self)
      return (res == :retry ? next_token(stream, universe, parser) : res) if res
    }
  end

  def eval_token(token, stream, universe)
    parser.plugins.each do |pl|
      res = pl.eval_token(stream, universe, self)
      return (res == :retry ? next_token(stream, universe, parser) : res) if res
    end
  end

end




















