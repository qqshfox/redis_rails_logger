require 'rails/railtie'
require 'active_support/lazy_load_hooks'

class Redis
  module Rails
    class Railtie < ::Rails::Railtie
      # Expose redis runtime to controller for logging.
      initializer "redis.log_runtime" do |app|
        require "redis-rails/railties/controller_runtime"
        ::ActiveSupport.on_load(:action_controller) do
          include Redis::Rails::Railties::ControllerRuntime
        end
      end
    end
  end
end
