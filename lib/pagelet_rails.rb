require "pagelet_rails/engine"
require "pagelet_rails/version"

require "action_controller/action_caching"


module PageletRails
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Encryptor
    autoload :Router
  end

  module Concerns
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Cache
      autoload :Controller
      autoload :Options
      autoload :Placeholder
      autoload :ResponseWrapper
      autoload :Routes
    end
  end

end
