module PageletsHelper

  def html_container_attributes
    html_opts = pagelet_options.html || {}
    classes = html_opts.fetch(:class, '').split(' ')
    classes << "pagelet-#{controller_name}"
    classes << "pagelet-#{controller_name}-#{action_name}"

    html_opts[:id] ||= pagelet_default_id
    html_opts[:class] = classes.join(' ')

    html_opts['data-pagelet-container'] = true
    html_opts['data-pagelet-options'] = pagelet_encoded_original_options

    if pagelet_options.ajax_group
      html_opts['data-pagelet-group'] = pagelet_options.ajax_group
    end
    html_opts
  end

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
    Rails.logger.info "Rendering pagelet #{path}"

    p_params = p_options.delete(:params) { {} }.with_indifferent_access

    if path.is_a? Symbol
      path = self.send("#{path}_url", p_params)
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

    parent_params =
      if params.respond_to?(:permit)
        if defined?(controller)
          h = controller.send(:pagelet_params)
          h.to_h
        else
          {}
        end
      else
        params.to_h
      end

    p_options.deep_merge! parent_params: parent_params

    c = controller_class.new
    c.pagelet_options p_options
    c.pagelet_options original_options: p_options

    env = request.env.select do |key, value|
      case key.to_s
      when /^action_dispatch\.request/i,
        /^action_controller/i,
        /^rack\.request/i,
        /^request/i,
        'HTTP_ACCEPT',
        'CONTENT_TYPE',
        'CONTENT_LENGTH',
        'REQUEST_METHOD'
        false
      else
        true
      end
    end

    env['HTTP_X_REQUESTED_WITH'] = "XMLHttpRequest"
    env = Rack::MockRequest.env_for(path, env)

    p_request = ActionDispatch::Request.new(env)
    p_request.parameters.clear
    p_request.parameters.merge! p_params

    if c.method(:dispatch).arity == 3
      p_response = controller_class.make_response! p_request
      c.dispatch(action, p_request, p_response)
    else
      c.dispatch(action, p_request)
    end

    body = c.response.body
    body.html_safe
  end

end
