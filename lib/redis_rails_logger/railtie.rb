require 'rails/railtie'
require 'active_support/lazy_load_hooks'

module RedisRailsLogger
  class Railtie < Rails::Railtie
    initializer "redis.log_runtime" do |app|
      require "redis_rails_logger/railties/controller_runtime"
      ActiveSupport.on_load(:action_controller) do
        include RedisRailsLogger::Railties::ControllerRuntime
      end
    end
  end
end
