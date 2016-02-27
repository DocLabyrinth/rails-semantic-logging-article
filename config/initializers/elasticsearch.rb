module Elasticsearch
  module Transport
    module Transport
      module Base
        # Log request and response information.
        #
        # @api private
        #
        def __log(method, path, params, body, url, response, json, took, duration)
          logger.info("Request completed", {
            :method => method,
            :url => url,
            :status => response.status,
            :duration => sprintf('%.3fs', duration),
            :query_took => took
          })
          logger.debug("Elasticsearch client sent request", {:body => __convert_to_json(body)}) if body
          logger.debug("Elasticsearch client received response", {:body => response.body})
        end

        # Log failed request.
        #
        # @api private
        def __log_failed(response)
          logger.fatal("Elasticsearch client request failed", :status => response.status, :response_body => response.body)
        end

        # NOTE: __trace also needs to be implemented for complete semantic logging but it is omitted here
      end
    end
  end
end
