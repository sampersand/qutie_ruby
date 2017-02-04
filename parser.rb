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

  def parse_all(stream, universe, do_clone: true)
    stream = stream.clone if do_clone
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

  def pre_process!(text)
    text.gsub!(/
        new\s+
        ([a-zA-Z_][a-zA-Z_0-9]+\?)
        [(]
          ((?:.(?!=[({\[];\n))*)
        [)]
        ;/x, '(inst=\1@();inst?.__init=(__self=inst?;\2)!;inst?)$;') # replace 'new cls?()'
        # );/x, '(inst=\1@();inst?.V=(__self,inst?)!;inst?.__init@\2!;inst?)$;') # replace 'new cls?()'
    text.gsub!(/\b
        ([a-zA-Z_][a-zA-Z_0-9]*\?)\s*
        ([\[])\s*
          ([a-zA-Z_][a-zA-Z_0-9]*)\s*
        ([\]])\s*
        =
        (.*?)\s*
        ;\s*(?=(?:(?:\/\/|\#|\/\*).*)?$) /x,'\1.=\2\3,\5\4!;') # replace 'x[y]=z'

    text.gsub!(/\b
        ([a-zA-Z_][a-zA-Z_0-9]*\?)\s*
        \.
        ([a-zA-Z_][a-zA-Z_0-9]*)\s*
        ([(])
          (.*)
        ([)])/x,'\1.\2,@\3\4\5!') # replace 'x.y()'

    text.gsub!(/\b
        ([a-zA-Z_][a-zA-Z_0-9]*\?)#\s* <-- dont use whitespace, thats how we id it.
        ([(])
          (.*)
        ([)])
          \s*/x,'\1@\2\3\4!,') # replace 'x.y()'

    puts text
    puts '---'
  end
end















