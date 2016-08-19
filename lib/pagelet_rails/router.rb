class PageletRails::Router

  def self.load_routes! context
    controllers = Dir[Rails.root.join('app', 'pagelets', '*', '*controller.rb')]

    controllers.each do |controller_file|
      pagelet_name = File.basename(File.dirname(controller_file))

      basename_controller_name = File.basename controller_file, '.rb'
      controller = "#{pagelet_name}/#{basename_controller_name}".camelize.constantize

      next unless controller.respond_to? :load_pagelet_routes!

      context.instance_eval do
        scope module: pagelet_name, path: "/pagelets", as: "pagelets" do
          controller.load_pagelet_routes! self
        end
      end

    end
  end

end
