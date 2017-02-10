require_relative 'number'
module Number

  module_function

  def next_token!(stream:,  **_)
    return unless stream.peek =~ /\d/
    num = ''
    catch(:EOF) {
      num += stream.next while stream.peek =~ /\d/
      if stream.peek?(str: '.')
        num += stream.next
        num += stream.next while stream.peek =~ /\d/
      end
      nil
    }
    num
  end

  def handle(token:, universe:, **_)
    universe << QT_Number::from(source: token)
  end

end