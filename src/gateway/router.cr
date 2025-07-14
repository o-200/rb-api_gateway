# src/gateway/router.cr

require "http/client"
require "../config"
require "../logger"

module Gateway
  class Router
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      path = context.request.path
      method = context.request.method
      ip = context.request.remote_address

      LOG.info { "[REQ] #{method} #{path} from #{ip}" }

      service = MICROSERVICES.keys.find { |prefix| path.starts_with?(prefix) }

      unless service
        call_next(context)
        return
      end

      backend_url = MICROSERVICES[service]
      forward_path = path.sub(service, "")
      forward_url = "#{backend_url}#{service}#{forward_path}"

      LOG.info { "Forwarding to #{forward_url}" }

      begin
        uri = URI.parse(forward_url)
        client = HTTP::Client.new(uri)

        # Build the request
        request = HTTP::Request.new(method, uri.request_target)

        # Copy request headers
        context.request.headers.each do |k, v|
          request.headers[k] = v if v
        end

        # Copy request body
        if body = context.request.body
          request.body = IO::Memory.new(body.gets_to_end)
        end

        # Send request to microservice
        response = client.exec(request)

        LOG.info { "[RES] #{response.status_code} from #{forward_url}" }

        context.response.status_code = response.status_code

        # Safely set Content-Type if present
        if content_type = response.headers["Content-Type"]?
          context.response.headers["Content-Type"] = content_type
        end

        context.response.print response.body
      rescue ex
        LOG.error { "Error forwarding to #{forward_url}: #{ex.message}" }
        context.response.status_code = 502
        context.response.print "Bad Gateway"
      end
    end
  end
end
