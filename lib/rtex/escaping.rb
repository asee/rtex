module RTeX
  
  module Escaping
    
    # Escape text using +replacements+
    def escape(text)
      replacements.inject(text.to_s) do |corpus, (pattern, replacement)|
        corpus.gsub(pattern, replacement)
      end.html_safe
    end

    def simple_format(text)
      text=escape(text)
      text.gsub(/([\n])/, '\newline{}').html_safe
    end
    
    # List of replacements
    def replacements
      @replacements ||= [
        [/([{}])/,    '\\\\\1'],
        [/\\/,        '\textbackslash{}'],
        [/\^/,        '\textasciicircum{}'],
        [/~/,         '\textasciitilde{}'],
        [/\|/,        '\textbar{}'],
        [/\</,        '\textless{}'],
        [/\>/,        '\textgreater{}'],
        [/([_$&%#])/, '\\\\\1']
      ]
    end
    
  end
  
end