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
    parse_all(stream, universe)
  end

  def parse_all(stream, universe)
    catch(:EOF) {
      until stream.stack.empty?
        token, plugin = parse(stream, universe)
        plugin.handle(token, stream, universe, self)
      end
    }
    universe
  end

  def parse(stream, universe)
    @plugins.find do |pl|
      token = pl.parse(stream, universe, self)
      next unless token
      return token == :retry ? parse(stream, universe) : [token, pl]
    end
  end

end




















