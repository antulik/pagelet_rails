module PageletRails::Component
  extend ActiveSupport::Concern

  included do
    include PageletRails::Controller

    prepend_before_action :append_pagelet_view_paths

    append_view_path 'app/pagelets/'
    append_view_path 'test/dummy/app/pagelets/' if Rails.env.test?

    pagelet_options layout: 'container'
  end

  private

  def append_pagelet_view_paths
    # lookup_context.prefixes.clear
    view = "#{controller_name}/views"
    if lookup_context.prefixes.exclude?(view)
      lookup_context.prefixes.unshift view
    end

    # https://github.com/rails/actionpack-action_caching/issues/32
    if lookup_context.formats.exclude?(:html)
      lookup_context.formats.unshift :html
    end
  end
end
