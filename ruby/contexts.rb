class Context
  NEWL = "\n"
  attr_reader :stream, :file
  def initialize(stream, file)
    @stream = stream
    @orig_stream = @stream.clone
    @start_line_no = newlines_left
    @file = file
  end

  def newlines_left
    @stream.stack.select{ |e| e.text_val == NEWL }.length
  end

  def current_line
    @start_line_no - newlines_left + 1
  end

  # def to_s
  #   file = @file.gsub(/\n/, "\n\t")
  #   line_no = current_line.to_s.gsub(/\n/, "\n\t")
  #   # "File    - #{file}\nLine No - #{line_no}: #{line(current_line)}"
  #   "#{file}: #{line_no}\n\t#{line(current_line)}"
  # end

  def line(line_no)
    stream = @orig_stream.clone
    stream << QT_Default.new( :"\n" )
    lines = 1
    line = ''
    catch(:EOF) do
      until lines == line_no
        lines += 1 if NEWL == stream._next.text_val
      end
      line += stream._next.text_val until NEWL == stream._peek.text_val
      true
    end or fail "Error with finding line for `#{line_no}`"
    line
  end

end

class Contexts
  def initialize()
    @stacks = []
  end

  def start(stream)
    @stacks << Context.new(stream, `pwd`.chomp)
  end

  def stop(expected)
    fail "CONTEXT MISMATCH! expected: #{expected}" unless @stacks.pop.stream.eql?(expected)
  end

  def current
    @stacks.last.clone
  end

  def to_s
    @stacks.collect(&:to_s).join("\n")
  end

end