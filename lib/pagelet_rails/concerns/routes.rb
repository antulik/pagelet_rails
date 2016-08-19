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

    # Define inline single route for the following method.
    # It automatically adds :controller and :action names to the route
    #
    #     class PageletRails::Examples::ExamplesController
    #       pageletlet_route :get, ''
    #       def bingo
    #       end
    #     end
    #
    # will generate routes
    #   Helper:            pagelets_examples_path
    #   HTTP Verb:         GET
    #   Path:              /pagelets/examples(.:format)
    #   Controller#Action: pagelets/examples/examples#bingo
    #
    def pagelet_route *args
      @pagelet_route << args
    end

    def method_added method_name
      return unless @pagelet_route
      @pagelet_route.each do |args|
        options = args.extract_options!
        options[:controller] ||= self.controller_name
        options[:action] ||= method_name

        @pagelet_routes << Proc.new do
          scope path: options[:controller], as: options[:controller] do
            self.send *args, options
          end
        end
      end

      @pagelet_route = []
      super
    end

    def load_pagelet_routes! context
      @pagelet_routes.each do |proc|
        context.instance_eval &proc
      end
    end

    def inherited subklass
      subklass.instance_variable_set(:@pagelet_routes, [])
      subklass.instance_variable_set(:@pagelet_route, [])
      super
    end
  end
end


