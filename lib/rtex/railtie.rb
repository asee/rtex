module RTeX
  class Railtie < Rails::Railtie
    initializer "rtex.add_template_handler" do 
      ActionView::Template.register_template_handler("rtex", 
        RTeX::TemplateHandler)
    end
    initializer "rtex.add_controller_methods" do
      ActionController::Base.send(:include, RTeX::ControllerMethods)
    end
    initializer "rtex.add_helper_methods" do
      ActionView::Base.send(:include, RTeX::Helpers)
    end
    initializer "rtex.set_tempdir" do 
      ActiveSupport.on_load(:action_controller) do
        Document.options[:tempdir] = Rails.root.join("tmp")
      end
    end
  end
end
