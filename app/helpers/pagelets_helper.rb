module PageletsHelper

  def pagelet_stream
    return nil if pagelet_stream_objects.empty?
    pagelet_stream_objects.each do |key, block|
      concat content_tag('script', raw("PageletRails.pageletArrived('#{key}', '#{j capture(&block)}');\n"), type: 'text/javascript')
    end
    nil
  end

  def pagelet_default_id
    "pagelet_#{rand(2**60).to_s(36)}"
  end

  def add_pagelet_stream key, &block
    objects = pagelet_stream_objects
    raise "duplicate key: #{key}" if objects.has_key?(key)
    objects[key] = block
    request.instance_variable_set(:@pagelet_stream_objects, objects)
  end

  def pagelet_stream_objects
    request.instance_variable_get(:@pagelet_stream_objects) || {}
  end

  def pagelet path, p_options = {}
    puts "Rendering pagelet #{path}".blue

    p_params = p_options.delete(:params) { {} }.with_indifferent_access

    if path.is_a? Symbol
      path = self.send("#{path}_path", p_params)
    else
      uri = URI(path)
      p_params.merge! Rack::Utils.parse_nested_query(uri.query)
      p_options.merge! remote: false
    end

    path_opts = Rails.application.routes.recognize_path(path)
    p_params.reverse_merge!(path_opts)

    controller_class = path_opts[:controller].camelize.concat('Controller').constantize
    action = path_opts[:action]


    if p_options[:remote] == :stream
      html_id = p_options.dig(:html, :id) || pagelet_default_id
      p_options.deep_merge! html: { id: html_id }

      add_pagelet_stream html_id, &Proc.new {
        pagelet path, p_options.merge(remote: false, skip_container: true)
      }
    end

    p_options.deep_merge! parent_params: params.to_h

    c = controller_class.new
    c.pagelet_options p_options
    c.pagelet_options original_options: p_options

    env = Rack::MockRequest.env_for(path,
      'REMOTE_ADDR'              => request.env['REMOTE_ADDR'],
      'HTTP_HOST'                => request.env['HTTP_HOST'],
      'HTTP_TURBOLINKS_REFERRER' => request.env['HTTP_TURBOLINKS_REFERRER'],
      'HTTP_USER_AGENT'          => request.env['HTTP_USER_AGENT'],
      'HTTP_X_CSRF_TOKEN'        => request.env['HTTP_X_CSRF_TOKEN'],
      'HTTP_X_PAGELET'           => request.env['HTTP_X_PAGELET'],
      'HTTP_X_REQUESTED_WITH'    => "XMLHttpRequest",
    )

    p_request = ActionDispatch::Request.new(env)
    p_request.parameters.clear
    p_request.parameters.merge! p_params

    p_response = controller_class.make_response! p_request
    c.dispatch(action, p_request, p_response)

    body = c.response.body
    body.html_safe
  end

end
