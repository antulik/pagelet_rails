module PageletRails::Controller
  extend ActiveSupport::Concern

  included do
    # order is important
    include PageletRails::Concerns::ResponseWrapper
    include PageletRails::Concerns::Routes
    include PageletRails::Concerns::Options
    include PageletRails::Concerns::Cache
    include PageletRails::Concerns::Placeholder
    include PageletRails::Concerns::Tags

    include PageletsHelper

    prepend_before_action :merge_original_pagelet_options

    layout :layout_name

    helper_method :pagelet_request?
    helper_method :pagelet_encoded_original_options
  end

  def layout_name
    if (layout = pagelet_options.layout)
      "pagelet_rails/#{layout}"
    else
      nil
    end
  end

  def pagelet_request?
    request.headers['X-Pagelet'].present? || params[:target_container]
  end

  private

  def merge_original_pagelet_options
    if params[:original_pagelet_options]
      opts = PageletRails::Encryptor.decode(params[:original_pagelet_options])
      pagelet_options(opts)
      pagelet_options(original_options: opts)
    end
  end

  def pagelet_encoded_original_options new_opts = {}
    encode_data = pagelet_options.original_options.to_h
      .with_indifferent_access.except('remote').deep_merge(new_opts)
    PageletRails::Encryptor.encode(encode_data)
  end

  def pagelet_render_remotely?
    case pagelet_options.remote
    when :stream
      render_remotely = true
    when :turbolinks
      # render now if request coming from turbolinks
      is_turbolinks_request = request.headers['Turbolinks-Referrer'].present?
      render_remotely = !is_turbolinks_request
    when true, :ajax
      render_remotely = true
    when :ssi
      render_remotely = true
    when false, :inline
      render_remotely = false
    else
      render_remotely = false
    end

    render_remotely
  end

  def redirect_to *args
    return super unless pagelet_options.enabled

    begin
      redirect_url = url_for(*args)
      path_opts = Rails.application.routes.recognize_path(redirect_url)
    rescue ActionController::RoutingError
      return super
    end

    controller_class = path_opts[:controller].camelize.concat('Controller').safe_constantize
    is_pagelet = controller_class && controller_class.include?(PageletRails::Method)

    if is_pagelet
      options = args.extract_options!
      new_params = options.merge(original_pagelet_options: pagelet_encoded_original_options)

      render plain: pagelet(url_for(*args, new_params))
    else
      super
    end
  end

  module ClassMethods
    def pagelet_method(*methods)
      pagelet_options *methods, layout: 'container', enabled: true
    end
  end
end
