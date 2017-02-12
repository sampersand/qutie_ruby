p '`'.chr.ord.to_s(16)
require_relative 'text'
module Text
  QUOTES = [ QT_Default.new( :"'" ),
             QT_Default.new( :'"' ),
             QT_Default.new( :'`' ) ]
  ESCAPE_CHAR = QT_Default.new( :'\\')
  module_function

  def escape(stream:)
    case (chr=stream._next)
    when QT_Default.new( :'0' ) then QT_Default.new( :"\u0000" )
    when QT_Default.new( :n )   then QT_Default.new( :"\n"     )
    when QT_Default.new( :t )   then QT_Default.new( :"\t"     )
    when QT_Default.new( :r )   then QT_Default.new( :"\r"     )
    when QT_Default.new( :f )   then QT_Default.new( :"\f"     )
    when QT_Default.new( :u )   then QT_Default.new( stream._next( 4 ).text_val.to_i(16).chr(Encoding::UTF_8 ).to_sym )
    when QT_Default.new( :U )   then QT_Default.new( stream._next( 8 ).text_val.to_i(16).chr(Encoding::UTF_16).to_sym )
    else chr
    end
  end
  def next_token!(stream:, **_)
    # this iwll need to be changed if any of the quotes or escape chars change to longer than 1 char

    return unless QUOTES.any?{ |q| q == stream._peek }
    quote = stream._next # if quotes change length this will break
    body = quote

    catch(:EOF) {
      until quote == stream._peek
        if ESCAPE_CHAR == stream._peek
          stream._next
          body += escape(stream: stream)
        else
          body += stream._next
        end
      end
      fail unless quote == stream._peek
      body += stream._next
      true
    } or fail "Reach EOF before finishing string starting with: #{quote}"
    QT_Text::from( body )
  end

  def handle(token:, universe:, **_)
    universe << token
  end
end
