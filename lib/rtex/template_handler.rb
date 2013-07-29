
module RTeX

  class TemplateHandler < ActionView::Template::Handlers::ERB
    def call(template)
      super.sub(/^(?!#)/m, "Thread.current[:_rendering_rtex] = true;\n")
    end   
  end

  module ControllerMethods
    def self.included(base)
      base.alias_method_chain :render, :rtex 
    end

    def render_with_rtex(options = nil, *args, &block)
      orig = render_without_rtex(options, *args, &block)
      if Thread.current[:_rendering_rtex] == true
        Thread.current[:_rendering_rtex] = false
        options = {} if options.class != Hash        
        Document.new(orig, options.merge(:processed => true)).to_pdf do |f|
          serve_file = Tempfile.new('rtex-pdf')
          FileUtils.mv f, serve_file.path
          send_file serve_file.path,
            :disposition => (options[:disposition] rescue nil) || 'inline',
            :url_based_filename => true,
            :filename => (options[:filename] rescue nil),
            :type => "application/pdf",
            :length => File.size(serve_file.path),
            :stream => false
          serve_file.close
        end   
      end
      orig
    end    

  end

end
