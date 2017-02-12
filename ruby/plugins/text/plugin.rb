require_relative 'text'

module Text
  QUOTES = [ QT_Default.new( :"'" ),
             QT_Default.new( :'"' ),
             QT_Default.new( :'`' ) ]

  ESCAPE_CHAR = QT_Default.new( :'\\' )

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

    return unless QUOTES.any?{ |q| q == stream._peek( q._length ) }
    start_quote = stream._next # if quotes change length this will break
    end_quote = nil
    body = QT_Default.new( :'' )

    catch(:EOF) {
      until start_quote == stream._peek( start_quote._length )
        if ESCAPE_CHAR == stream._peek(ESCAPE_CHAR._length )
          stream._next( ESCAPE_CHAR._length )
          body += escape(stream: stream)
        else
          body += stream._next
        end
      end
      end_quote = stream._next( start_quote._length )
      fail unless start_quote == end_quote
      true
    } or fail "Reach EOF before finishing string starting with: #{start_quote}"
    QT_Text::from( body, quotes: [start_quote, end_quote] )
  end

  def handle(token:, universe:, **_)
    universe << token
  end
end
