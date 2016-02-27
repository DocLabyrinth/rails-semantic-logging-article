require 'semantic_logger'

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

# this code is adapted from the rails_semantic_logger gem:
# https://github.com/rocketjob/rails_semantic_logger/blob/master/lib/rails_semantic_logger/railtie.rb#L37
log_path = ((Rails.configuration.paths.log.to_a rescue nil) || Rails.configuration.paths['log']).first
unless File.exist? File.dirname(log_path)
  FileUtils.mkdir_p File.dirname(log_path)
end

appender                      = SemanticLogger::Appender::File.new(log_path, Rails.configuration.log_level)
appender.name                 = 'SemanticLogger'
SemanticLogger.add_appender(appender)

Rails.logger = SemanticLogger[Rails]
