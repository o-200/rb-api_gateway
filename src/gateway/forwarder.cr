require "http/client"
require "../config"
require "../logger"

module Gateway
  class Forwarder
    def initialize(microservices : Hash(String, String))
      @microservices = microservices
    end

    def call(context : HTTP::Server::Context, service : String)
      forward_url = build_forward_url(context.request.path, service)

      LOG.info { "Forwarding to #{forward_url}" }

      begin
        response = forward_request(context.request, forward_url)
        handle_response(context, response)
      rescue ex
        LOG.error {
          "Error forwarding to #{forward_url}: #{ex.class}: #{ex.message}, Exception: #{ex}"
        }

        context.response.status_code = 502
        context.response.print "Bad Gateway"
      end
    end

    private def build_forward_url(path : String, service : String)
      backend_url = @microservices[service]
      forward_path = path.sub(service, "")

      "#{backend_url}#{service}#{forward_path}"
    end

    private def forward_request(original_request : HTTP::Request, url : String) : HTTP::Client::Response
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      request = HTTP::Request.new(original_request.method, uri.request_target)

      skip_headers = ["Host", "Connection", "Content-Length"]
      original_request.headers.each do |k, v|
        request.headers[k] = v if v && !skip_headers.includes?(k)
      end

      if body = original_request.body
        body_data = body.gets_to_end
        request.body = IO::Memory.new(body_data)
        request.headers["Content-Length"] = body_data.bytesize.to_s
      end

      client.exec(request)
    end

    private def handle_response(context : HTTP::Server::Context, response : HTTP::Client::Response)
      context.response.status_code = response.status_code

      if content_type = response.headers["Content-Type"]?
        context.response.headers["Content-Type"] = content_type
      end

      context.response.print response.body

      LOG.info { "[RES] #{response.status_code}" }
    end
  end
end
