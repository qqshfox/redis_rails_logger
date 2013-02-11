require 'rack_rails_logger/middleware'
require "redis_rails_logger/railties/controller_runtime"

RackRailsLogger::Middleware.class_eval do
  include RedisRailsLogger::Railties::ControllerRuntime
end
