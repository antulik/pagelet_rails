module PageletRails::Concerns::Options
  extend ActiveSupport::Concern

  included do
    include Shared

    helper_method :pagelet_options
  end

  def pagelet_options *args
    set_pagelet_options *args

    opts = self.class.pagelet_options
    class_default_opts = opts.fetch('default', {})
    class_action_opts = opts.fetch(action_name, {})

    instance_default_opts = @pagelet_options.fetch('default', {})
    instance_action_opts = @pagelet_options.fetch(action_name, {})

    result = {}.with_indifferent_access
      .deep_merge!(class_default_opts)
      .deep_merge!(class_action_opts)
      .deep_merge!(instance_default_opts)
      .deep_merge!(instance_action_opts)

    OpenStruct.new result
  end

  module Shared
    def set_pagelet_options *args
      opts = args.extract_options!
      actions = args
      actions << 'default' if actions.blank?

      @pagelet_options ||= {}.with_indifferent_access

      if opts.any?
        actions.each do |action|
          @pagelet_options.deep_merge! action => opts
        end
      end
      @pagelet_options
    end
  end

  module ClassMethods
    include Shared

    def pagelet_options *args
      set_pagelet_options *args

      if superclass && superclass.instance_variable_defined?(:@pagelet_options)
        parent = superclass.instance_variable_get :@pagelet_options
        parent.merge(@pagelet_options)
      else
        @pagelet_options
      end
    end

    def inherited subklass
      existing = subklass.ancestors.reverse.
        reduce({}.with_indifferent_access) do |memo, ancestor|

        if ancestor.instance_variable_defined?(:@pagelet_options)
          memo.deep_merge! ancestor.instance_variable_get :@pagelet_options
        end
        memo
      end

      subklass.instance_variable_set(:@pagelet_options, existing)

      super
    end
  end

end
