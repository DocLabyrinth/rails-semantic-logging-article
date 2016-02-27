require "semantic_logger"
require "gelf"

# adapted from custom appender in semantic_logger docs
# http://rocketjob.github.io/semantic_logger/custom_appenders.html
class SemanticLogger::Appender::GraylogAppender < SemanticLogger::Appender::Base
  def initialize(level=nil, &block)
    # Set the log level and formatter if supplied
    super(level, &block)
    @notifier = GELF::Notifier.new(
      Rails.configuration.graylog_host || "localhost",
      Rails.configuration.graylog_port || 12201
    )
  end

  # most semantic_logger appenders need a reopen() function
  # for use after the process has forked. Because the
  # Graylog gelf gem uses UDP there is no active connection
  # and a reopen() function is not necessary

  # Display the log struct and the text formatted output
  def log(log)
    # Ensure minimum log level is met, and check filter
    return false if (level_index > (log.level_index || 0)) || !include_message?(log)

    log_tags = if log.tags && log.tags.length
      Rails.configuration.log_tags.zip(log.tags).to_h
    else
      {}
    end

    log_hash = log.to_h.merge({
      :short_message => log.message || log.name,
      :request_id => log_tags[:uuid] || 'UNKNOWN',
      :level => log.level_index,
    })

    @notifier.notify!(log_hash)
  end
end

graylog_appender = SemanticLogger::Appender::GraylogAppender.new(Rails.configuration.log_level)
graylog_appender.name = 'SemanticLoggerGraylog'
SemanticLogger.add_appender(graylog_appender) if Rails.configuration.graylog_enabled
