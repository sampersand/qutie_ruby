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

  def process(inp, builtins: nil)
    stream = Universe.from_string inp
    universe = Universe.new
    universe.globals.update(builtins) if builtins
    parse(stream: stream, universe: universe)
  end

  def parse(stream:, universe:)
    parse!(stream: stream.clone, universe: universe)
  end

  def parse!(stream:, universe:)
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

  module PreParser
    module_function
    def get_parens!(text, start)
      pos = start + 1
      parens = 1
      until parens == 0
        if text[pos] =~ /[({\[]/
          parens += 1
        elsif text[pos] =~ /[)}\]]/
          parens -=1
        end
        pos += 1
      end
      text.slice!(start...pos)

    end

    NEW_CLS_REG = /new\s+([a-z_][a-z_0-9]+)/i
    # METHOD_CALL_REG = /([a-z_][a-z_0-9]*\?(?:\.[a-z_0-9]*)*)\.([a-z_0-9]*)(?=[\[({])/i
    METHOD_CALL_REG = /([a-z_][a-z_0-9]*\?)\.([a-z_0-9]*)(?=[\[({])/i
    def pre_process!(text)
      text.gsub!(/(?<!__)(self|args|current)(?!\?)/, '__\1?')

      while pos = text.index(/(?<=clone|disp|text|num|stop|debug|len|if|switch|while|for|del)[({\[]/)
        parens = get_parens!(text, pos)
        text.insert(pos, "?@#{parens}!")
      end
      while pos = text.index(NEW_CLS_REG)
        cls = text.match(NEW_CLS_REG)[1]
        text.sub!(NEW_CLS_REG, '')
        parens = get_parens!(text, pos)
        text.insert(pos, "(i=clone?@(#{cls}?)$@();i?.__init@(__self=i?;#{parens[1...-1]})!;i?)$")
      end

      while pos = text.index(METHOD_CALL_REG)
        match=text.match(METHOD_CALL_REG)
        var=match[1]
        func=match[2]
        text.sub!(METHOD_CALL_REG, '')
        parens = get_parens!(text, pos)
        text.insert(pos, "(#{var}.#{func}@$#{parens[0]}__self=#{var};#{parens[1..-1]}!)$")
      end

      text.gsub!(/class\s+([{(\[])/i, '\1__init={};') # replace 'class {'
      text.gsub!(/([a-z_0-9]+)\s*(\+|-|\*|\/|%|\*\*|or|and|xor)=/i,'\1=\1?\2') # or=
      text.gsub!(/(^\s*__self\?(?:\s*\.\s*.+?)*)\s*\.\s*(.+?)\s*=\s(.+);/,'\1.=(\2,\3)!;') # replace '__self?.x=y' with '__self?.=(y,z)'
      text.gsub!(/\b([a-z_0-9]+)(\+|-)(\2)/i,'__temp=\1?;\1=\1?\21;__temp?') # i++
      text.gsub!(/(\+|-)\1([a-z_0-9]+)\b/i,'\2=\2?\11') # ++i
    end

    # def pre_process!(text, show_text: false)
    #   text.gsub!(/
    #       new\s+
    #       ([a-z_][a-z_0-9]+\?)
    #       [(]
    #         (.*?)
    #       [)]/xi, '(i=clone?@(\1)$@();i?.__init@(__self=i?;\2)!;i?)$') # replace 'new cls?()'

    #   text.gsub!(/\b
    #       ([a-zA-Z_][a-zA-Z_0-9]*\?)
    #       \.
    #       ([a-zA-Z_][a-zA-Z_0-9]*)
    #       ([(])
    #       \s*/x,'\1.\2@$\3__self=\1;') # replace 'x.y(z)' with '(x.y @(__self=x;z)!)$$'
    #   text.gsub!(/\b([a-z_0-9]+)(\+|-)(\2)/i,'__temp=\1?;\1=\1?\21;__temp?') # i++
    #   text.gsub!(/(\+|-)\1([a-z_0-9]+)\b/i,'\2=\2?\11') # ++i
    
      

    
    #   if show_text
    #     puts text
    #     puts '---'
    #   end
    # end
  end
end








 