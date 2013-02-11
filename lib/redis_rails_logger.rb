require "redis_rails_logger/version"
require 'redis_rails_logger/log_subscriber'
require 'redis_rails_logger/railtie' if defined?(Rails)

module RedisRailsLogger
end

require 'redis'
require 'redis/client'
require 'active_support/notifications'

class Redis
  class Client
    alias :old_logging :logging unless method_defined? :old_logging

    def logging(commands, &block)
      ::ActiveSupport::Notifications.instrument('logging.redis', commands: commands) do |payload|
        payload[:result] = old_logging(commands, &block)
      end
    end
  end
end
