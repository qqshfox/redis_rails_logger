require 'redis-rails'
require "redis_rails_logger/version"
require 'redis-rails/railtie' if defined?(Rails)
require 'redis-rails/log_subscriber'
require 'active_support/notifications'

class Redis
  module Rails
    module Logger
    end
  end
end

class Redis
  class Client
    alias :old_logging :logging unless method_defined? :old_logging

    def logging(commands, &block)
      ::ActiveSupport::Notifications.instrument('logging.rails.redis', commands: commands) do |payload|
        payload[:result] = old_logging(commands, &block)
      end
    end
  end
end
