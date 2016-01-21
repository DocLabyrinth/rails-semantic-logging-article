ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails/commands/server'

# this code is extracted from the rails_semantic_logger gem
# it monkey-patches the 'rails server' command so it logs to
# stdout using the SemanticLogger library if logging to stdout
# is enabled
# https://github.com/rocketjob/rails_semantic_logger/blob/master/lib/rails_semantic_logger/railtie.rb#L119
module Rails #:nodoc:
  class Server < ::Rack::Server #:nodoc:
    private

    def log_to_stdout
      SemanticLogger.add_appender($stdout, &SemanticLogger::Appender::Base.colorized_formatter)
    end
  end
end
