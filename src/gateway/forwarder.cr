require "http/client"
require "../config/logger"

module Gateway
  class Forwarder
    def call(context : HTTP::Server::Context, domain : String, path : String)
      forward_url = build_forward_url(domain, path)
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

    private def forward_request(original_request : HTTP::Request, url : String) : HTTP::Client::Response
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      request = HTTP::Request.new(original_request.method, uri.request_target)

      set_request_headers(original_request, request)
      calculate_request_body(original_request, request)

      client.exec(request)
    end

    private def set_request_headers(original_request : HTTP::Request, request : HTTP::Request)
      skip_headers = ["Host", "Connection", "Content-Length"]
      original_request.headers.each do |k, v|
        request.headers[k] = v if v && !skip_headers.includes?(k)
      end
    end

    private def calculate_request_body(original_request : HTTP::Request, request : HTTP::Request)
      if body = original_request.body
        body_data = body.gets_to_end
        request.body = IO::Memory.new(body_data)
        request.headers["Content-Length"] = body_data.bytesize.to_s
      end
    end

    private def handle_response(context : HTTP::Server::Context, response : HTTP::Client::Response)
      context.response.status_code = response.status_code

      if content_type = response.headers["Content-Type"]?
        context.response.headers["Content-Type"] = content_type
      end

      context.response.print response.body

      LOG.info { "[RES] #{response.status_code}" }
    end

    private def build_forward_url(domain : String, path : String)
      "http://#{domain}/#{path}"
    end
  end
end
