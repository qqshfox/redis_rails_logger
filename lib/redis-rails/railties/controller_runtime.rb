require 'active_support/concern'
require 'active_support/core_ext/module/attr_internal'

class Redis
  module Rails
    module Railties
      module ControllerRuntime
        extend ::ActiveSupport::Concern

        protected

        attr_internal :redis_runtime

        def process_action(action, *args)
          # We also need to reset the runtime before each action
          # because of queries in redis or in cases we are streaming
          # and it won't be cleaned up by the method below.
          Redis::Rails::LogSubscriber.reset_runtime
          super
        end

        def cleanup_view_runtime
          redis_rt_before_render = Redis::Rails::LogSubscriber.reset_runtime
          runtime = super
          redis_rt_after_render = Redis::Rails::LogSubscriber.reset_runtime
          self.redis_runtime = redis_rt_before_render + redis_rt_after_render
          runtime - redis_rt_after_render
        end

        def append_info_to_payload(payload)
          super
          payload[:redis_runtime] = (redis_runtime || 0) + Redis::Rails::LogSubscriber.reset_runtime
        end

        module ClassMethods
          def log_process_action(payload)
            messages, redis_runtime = super, payload[:redis_runtime]
            messages << ("Redis: %.1fms" % redis_runtime.to_f) if redis_runtime
            messages
          end
        end
      end
    end
  end
end
