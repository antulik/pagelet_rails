module PageletRails::Concerns::Routes
  extend ActiveSupport::Concern

  module ClassMethods
    # Define routes inline in controller
    #
    #     pagelet_routes do
    #       resources :users
    #     end
    #
    def pagelet_routes &block
      @pagelet_routes << block
    end

    def pagelet_resources *args, &block
      controller_name = self.controller_name
      @pagelet_routes << Proc.new do
        resources controller_name, *args, &block
      end
    end

    def pagelet_resource *args, &block
      controller_name = self.controller_name
      opts = args.extract_options!
      opts[:controller] ||= controller_name

      @pagelet_routes << Proc.new do
        resource controller_name, *args, opts, &block
      end
    end

    def load_pagelet_routes! context
      @pagelet_routes.each do |proc|
        context.instance_eval(&proc)
      end
    end

    def inherited subklass
      subklass.instance_variable_set(:@pagelet_routes, [])
      super
    end
  end
end


