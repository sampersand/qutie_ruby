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

  def handle_func_arg(arg, ind)
    if arg.include?('=')
      name, val = arg.split('=')
      "#{name.strip}||=#{val.strip};"
    elsif arg.end_with?('?')
      "#{arg[0...-1]}||=__args?.#{ind};"
    else
      "#{arg}=__args?.#{ind};"
    end
  end

  NEW_CLS_REG = /new\s+([a-z_][a-z_0-9]+)/i
<<<<<<< HEAD
  METHOD_CALL_REG = /([a-z_][a-z_0-9]*(?:\.[a-z_0-9]*)*)\.([a-z_0-9]*)(?=[\[({])/i
=======
  # METHOD_CALL_REG = /([a-z_][a-z_0-9]*\?(?:\.[a-z_0-9]*)*)\.([a-z_0-9]*)(?=[\[({])/i
>>>>>>> parent of 86eaa06... Import is a macro
  # METHOD_CALL_REG = /([a-z_][a-z_0-9]*\?)\.([a-z_0-9]*)(?=[\[({])/i
  FUNCTION_DECL_REG = /([a-z_][a-z_0-9 ]*\s*=\s*)function\s*[(]([^)]*?)[)]\s*([{(\[])/i
  CLASS_INSTANCE_REG = /new\s+([a-z_][a-z_0-9]*)(?=[(])/i
    # text.gsub!(/(\$|[a-z][a-z_0-9]*\?)([({\[])/i, '\1@\2') # replace 'function(args)' with''
    # text.gsub!(/(\$|[a-z][a-z_0-9]*)([({\[])/i, '\1?@\2') # replace 'function(args)' with''
  FUNCTION_CALL_REG = /([a-z_][a-z_0-9]*)\s*(?=[\[({])/i
  ADD_QUESTION_MARK = /\b([a-z_][a-z_0-9]*)(?=\s*[^=?\s]|$)(?![\w\s]*')\b/i
  def pre_process!(text)
    # text.gsub!(/(?<!__)(self|args)(?!\?)/, '__\1?')
<<<<<<< HEAD
    # text.gsub!(/import[({\[](['"])([^)\]}]+)[)\]}]/, '((\1\1+`cat \1\2.qt`!)!.0,!)!.0')
    text.gsub!(/import[({\[]([^)\]}]+)[)\]}];/, '""+`cat \1.qt`!,!;')
=======
>>>>>>> parent of 86eaa06... Import is a macro
    keys = Functions::FUNCTIONS.keys.collect(&:to_s).join('|')
    while pos = text.index(/(?<=#{keys})[({\[]/)
      parens = get_parens!(text, pos)
      text.insert(pos, "?@#{parens},")
    end

    while pos = text.index(FUNCTION_CALL_REG)
      func_name = text.match(FUNCTION_CALL_REG)[1]
      text.sub!(FUNCTION_CALL_REG, '')
      parens = get_parens!(text, pos)
      text.insert(pos, "#{func_name}?@#{parens}!,.NEG_1?,")
    end


    while pos = text.index(CLASS_INSTANCE_REG)
      match=text.match(CLASS_INSTANCE_REG)
      class_name=match[1]
      text.sub!(CLASS_INSTANCE_REG, '')
      parens = get_parens!(text, pos)
      text.insert(pos, "#{class_name}?@#{parens},")
    end

    # while pos = text.index(METHOD_CALL_REG)
    #   match=text.match(METHOD_CALL_REG)
    #   var=match[1]
    #   func=match[2]
    #   text.sub!(METHOD_CALL_REG, '')
    #   parens = get_parens!(text, pos)
    #   text.insert(pos, "#{var}.#{func}@#{parens[0]}__self=#{var};#{parens[1..-1]}!,")
    # end
<<<<<<< HEAD

    while pos = text.index(FUNCTION_CALL_REG)
      func_name = text.match(FUNCTION_CALL_REG)[1]
      text.sub!(FUNCTION_CALL_REG, '')
      parens = get_parens!(text, pos)
      text.insert(pos, "#{func_name}@#{parens},")#,.NEG_1?,")
    end
    while pos = text.index(FUNCTION_DECL_REG)
      match=text.match(FUNCTION_DECL_REG)
=======
    while pos = text.index(FUNCITON_DECL_REG)
      match=text.match(FUNCITON_DECL_REG)
>>>>>>> parent of 86eaa06... Import is a macro
      func=match[1]
      func_start_paren=match[3]
      args=match[2].split(/(?<!\\),/).collect{|e| e.gsub(/\\,/, ',')}.collect(&:strip)
      args_str = args.each_with_index.collect(&method(:handle_func_arg)).join
      text.sub!(FUNCTION_DECL_REG, '')
      text.insert(pos, "#{func}#{func_start_paren}#{args_str}")
    end
    # puts text
    # text.gsub!(ADD_QUESTION_MARK, '\1?')
    # puts text
    # text.gsub!(/(function|class)(\(.*?\))?\s*/i, '') # replace 'function(args)' with''
    # text.gsub!(/([a-z_0-9]+)\s*(\*\*|\+|-|\*|\/|%|\|\||&&|\^)=/i,'\1=\1?\2') # x=
    # text.gsub!(/([a-z_0-9]+)\s*<(\*\*|\+|-|\*|\/|%|\|\||&&|\^)-/i,'\1<-\1?\2') # -x>
    # text.gsub!(/-(\*\*|\+|-|\*|\/|%|\|\||&&|\^)>\s*([a-z_0-9]+)/i,'\1\2?->\2') # <x-
    # text.gsub!(/(^\s*__self\?(?:\s*\.\s*.+?)*)\s*\.\s*(.+?)\s*=\s(.+);/,'\1.=(\2,\3)!;') # replace '__self?.x=y' with '__self?.=(y,z)'
    # text.gsub!(/(\+|-)\1([a-z_0-9]+)\b/i,'\2=\2?\11') # ++i
    # text.gsub!(/\b([a-z_0-9]+)(\+|-)(\2)/i,'($?.-1,.=(\1,\1?\21)!;\1?)@(),') # i++
  end
end