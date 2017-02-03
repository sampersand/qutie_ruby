require_relative 'stream'
require_relative 'tokens'
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
    inp += "\n"
    stream = Stream::from inp
    tokens = Tokens.new
    parse stream, tokens
  end
  def parse(stream, tokens)
    self.class.parse stream, tokens, self
    tokens
  end

  def next_token(stream, tokens)
    return if stream.empty?
    @plugins.each do |pl|
      res = pl.parse(stream, tokens, self)
      return next_token(stream, tokens) if res == :retry
      return tokens if res
    end
  end

  def self.parse(stream, tokens, parser)
    parser.next_token(stream, tokens) until stream.empty?
    true
  end
end


