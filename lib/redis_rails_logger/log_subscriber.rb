require 'active_support/log_subscriber'

module RedisRailsLogger
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime
      @runtime ||= 0
    end

    def self.runtime=(runtime)
      @runtime = runtime
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super
      @odd_or_even = false
    end

    def logging(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = "Redis (%.3fms)" % event.duration
      cmds = event.payload[:commands]
      result = event.payload[:result]

      cmds_output = ''
      cmds.each do |cmd, *args|
        if args.present?
          cmds_output << " [ #{cmd.to_s.upcase} #{args.map(&:inspect).join(" ")} ]"
        else
          cmds_output << " [ #{cmd.to_s.upcase} ]"
        end
      end

      if odd?
        name = color(name, CYAN, true)
        cmds_output = color(cmds_output, nil, true)
      else
        name = color(name, MAGENTA, true)
      end

      debug "  #{name} #{cmds_output} #{result.inspect}"
    end

    private
    def odd?
      @odd_or_even = !@odd_or_even
    end
  end
end

RedisRailsLogger::LogSubscriber.attach_to('redis')
