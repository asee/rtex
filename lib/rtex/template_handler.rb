
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
        File.open(Rails.root.join("tmp","last_document.latex"), "w"){|f| f.puts orig} if Rails.env.development?
        Document.new(orig, options.merge(:processed => true)).to_pdf do |f|
          serve_file = Tempfile.new('rtex-pdf')

          if options[:user_pw].present? && options[:owner_pw].present?
            pdf_path = File.dirname(f)
            pdf_name = File.basename(f, '.pdf')
            encrypted_filename = File.join(pdf_path, "#{pdf_name}_encrypted.pdf")
            owner_pw = options[:owner_pw].is_a?(Proc)? options[:owner_pw].call : options[:owner_pw]
            user_pw = options[:user_pw].is_a?(Proc)? options[:user_pw].call : options[:user_pw]

            pdftk_commands = [
              f,
              'output', encrypted_filename,
              'owner_pw', owner_pw,
              'user_pw', user_pw
            ]

            unless options[:disallow_printing]
              pdftk_commands << 'allow'
              pdftk_commands << 'printing'
            end

            unless options[:disallow_screenreaders]
              pdftk_commands << 'allow'
              pdftk_commands << 'screenreaders'
            end

            PDF::Toolkit.pdftk(*pdftk_commands)
            f = encrypted_filename
          end

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
