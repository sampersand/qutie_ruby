require_relative 'object'
module Default

  class QT_Default < QT_Object
    def self.from(source:)
      new(source: source)
    end

    def initialize(source:)
      warn("Source for #{self.class} is not a String, but `#{source.class}`)") unless source.is_a?(String)
      @source = source
    end

    def to_s
      @source.to_s
    end

    # qt methods
      # conversion
        def qt_to_text
          to_s
        end
  end

  module_function
  def next_token!(stream:, **_)
    stream.next
  end
  
  def handle(token, universe, **_)
    universe << QT_Default::from(source: token)
  end
end