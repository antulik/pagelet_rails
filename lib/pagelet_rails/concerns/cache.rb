module PageletRails::Concerns::Cache
  extend ActiveSupport::Concern

  included do
    include ActionController::Caching::Actions

    pagelet_options cache_defaults: {
      expires_in: 5.seconds,
      cache_path: {}
    }

    around_action :pagelet_cache
  end

  def pagelet_cache &block
    # puts 'pagelet_cache'.blue
    cache_enabled = pagelet_options.cache || pagelet_options.cache_path || pagelet_options.expires_in

    if !cache_enabled
      return yield
    end

    cache_defaults = (pagelet_options.cache_defaults || {}).to_h.symbolize_keys
    store_options = cache_defaults.except(:cache_path)
    store_options[:expires_in] = pagelet_options.expires_in if pagelet_options.expires_in

    cache_path = pagelet_options.cache_path || cache_defaults[:cache_path]

    cache_path = if cache_path.is_a?(Proc)
      self.instance_exec(self, &cache_path)
    elsif cache_path.respond_to?(:call)
      cache_path.call(self)
    elsif cache_path.is_a?(String)
      {
        custom: cache_path
      }
    else
      cache_path
    end
    cache_path ||= {}
    cache_path[:controller] = params[:controller]
    cache_path[:action] = params[:action]

    path_object = ActionController::Caching::Actions::ActionCachePath.new(self, cache_path)
    has_cache = fragment_exist?(path_object.path, store_options)
    pagelet_options has_cache: has_cache


    if (pagelet_render_remotely? && has_cache) || !pagelet_render_remotely?
      cache_options = {
        layout: false,
        store_options: store_options,
        cache_path: cache_path
      }

      filter = ActionController::Caching::Actions::ActionCacheFilter.new(cache_options)

      filter.around(self, &block)

    else
      yield
    end
  end

end
