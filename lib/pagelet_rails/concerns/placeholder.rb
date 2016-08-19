module PageletRails::Concerns::Placeholder
  extend ActiveSupport::Concern

  # This concern should be called after cache callback
  # #process_action method does not give such order
  # as it's called before callbacks
  def send_action *args
    render_remote_load
    if !performed?
      super
    end
  end

  def render_remote_load
    # puts 'render_remote_load'.blue
    render_remotely = pagelet_render_remotely?
    if render_remotely && pagelet_options.has_cache
      render_remotely = false
    end

    return unless render_remotely

    data = params.deep_dup
    data.permit!

    if pagelet_options.remote != :stream
      pagelet_options html: { 'data-widget-url' => url_for(data) }
    end

    default_view = '/layouts/pagelet_rails/loading_placeholder'
    view = pagelet_options.placeholder.try(:[], :view).presence || default_view

    render view
  end
end
