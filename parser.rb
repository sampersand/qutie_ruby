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

  def process(inp, default_locals: nil)
    stream = Universe.from_string inp
    universe = Universe.new
    universe.locals.update(default_locals) if default_locals
    parse(stream, universe)
  end

  def parse(stream, universe)
    parse!(stream.clone, universe)
  end

  def parse!(stream, universe)
    catch(:EOF) {
      until stream.stack.empty?
        token, plugin = next_token!(stream, universe)
        plugin.handle(token, stream, universe, self)
      end
    }
    universe
  end

  def next_token(stream, universe)
    next_token!(stream.clone, universe)
  end

  def next_token!(stream, universe)
    @plugins.each do |pl|
      token = pl.next_token!(stream, universe, self)
      next unless token
      return token == :retry ? next_token!(stream, universe) : [token, pl]
    end or fail
  end

  def pre_process!(text, show_text: false)
    # text.gsub!(/
    #     class\s+
    #     ([{(\[])
    #     /x, '\1__init={};') # replace 'class {'
    text.gsub!(/
        new\s+
        ([a-zA-Z_][a-zA-Z_0-9]+\?)
        [(]
          (.*?)
        [)]/x, '(i=clone?@$(\1)$@();i?.__init@(__self=i?;\2)!;i?)$') # replace 'new cls?()'

    # text.gsub!(/\b
    #     ([a-zA-Z_][a-zA-Z_0-9]*\?)
    #     \.
    #     ([a-zA-Z_][a-zA-Z_0-9]*)
    #     ([(])
    #     \s*/x,'\1.\2@$\3__self=\1;') # replace 'x.y(z)' with '(x.y @(__self=x;z)!)$$'
    text.gsub!(/\b
        (clone|disp|text|num|stop|debug|len|if|switch)
        ([\[{(])
        /x,'\1?@\2') # replace 'kwf(' with 'kwf?@('

    text.gsub!(/(__self\?)\.(\w+)\s*=\s*(.*?);/,'\1.=(\2,\3);') # replace 'x[y]=z' with 'x.=(y,z)'
    # if show_text
    #   puts text
    #   puts '---'
    # end
  end
end








 