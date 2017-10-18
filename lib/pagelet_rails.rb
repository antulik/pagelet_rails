require "pagelet_rails/engine"
require "pagelet_rails/version"

require "action_controller/action_caching"


module PageletRails
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Component
    autoload :Encryptor
    autoload :Method
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
      autoload :Tags
    end
  end

end
