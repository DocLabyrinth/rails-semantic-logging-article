require 'semantic_logger'

SemanticLogger.add_appender($stdout, Rails.configuration.log_level) do |log|
  colors      = SemanticLogger::Appender::AnsiColors
  level_color = colors::LEVEL_MAP[log.level]

  # Header with date, time, log level and process info
  entry = "#{log.formatted_time} #{level_color}#{log.level_to_s}#{colors::CLEAR}" # [#{log.process_info}]"

  # Tags
  entry << ' ' << log.tags.collect { |tag| "[#{level_color}#{tag}#{colors::CLEAR}]" }.join(' ') if log.tags && (log.tags.size > 0)

  # Duration
  entry << " (#{colors::BOLD}#{log.duration_human}#{colors::CLEAR})" if log.duration

  # Class / app name
  entry << " #{level_color}#{log.name}#{colors::CLEAR}"

  # Log message
  entry << " -- #{log.message}" if log.message

  # Payload
  unless log.payload.nil? || (log.payload.respond_to?(:empty?) && log.payload.empty?)
    # payload = log.payload
    # payload = (defined?(AwesomePrint) && payload.respond_to?(:ai)) ? payload.ai(multiline: false) : payload.inspect
    entry << ' -- ' << log.payload.map{|k,v| "#{colors::BOLD}#{level_color}#{k}#{colors::CLEAR}=#{JSON.dump(v)}"}.join(' ')
  end

  # Exceptions
  log.each_exception do |exception, i|
    entry << (i == 0 ? ' -- Exception: ' : "\nCause: ")
    entry << "#{colors::BOLD}#{exception.class}: #{exception.message}#{colors::CLEAR}\n#{(exception.backtrace || []).join("\n")}"
  end

  entry
end

module ActiveRecord
  class LogSubscriber < ActiveSupport::LogSubscriber
    def sql(event)
      # don't log trivial SQL events e.g. schema lookups
      # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/log_subscriber.rb
      return if ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])

      SemanticLogger[ActiveRecord].info(event.payload[:name], {
        :duration => event.duration.round(3),
        :sql => event.payload[:sql],
      })
    end
  end
end

ActiveRecord::LogSubscriber.attach_to :active_record

module Lograge
  class RequestLogSubscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      return if Lograge.ignore?(event)

      payload = event.payload
      data = extract_request(event, payload)
      data = before_format(data, payload)

      # original code:
      # formatted_message = Lograge.formatter.call(data)
      # logger.send(Lograge.log_level, formatted_message)

      # pass the event name and extracted data to the semantic logger
      # instead of formatting everything into a single string
      data[:params] = payload[:params] if payload
      SemanticLogger[Rails].send(Lograge.log_level, payload[:name], data)
    end
  end
end
