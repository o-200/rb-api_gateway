require "http/client"
require "../config"
require "../logger"

module Gateway
  class Router
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      log_request(context)

      if service = get_service(context.request.path)
        forward(context, service)
      else
        call_next(context)
      end
    end

    private def log_request(context)
      msg = "[REQ] #{context.request.method} #{context.request.path} from #{context.request.remote_address}"
      record_log(msg, :info)
    end

    private def get_service(path : String) : String?
      MICROSERVICES.keys.find { |prefix| path.starts_with?(prefix) }
    end

    private def forward(context, service)
      forward_url = build_forward_url(context.request.path, service)

      msg = "Forwarding to #{forward_url}"
      record_log(msg, :info)

      begin
        response = forward_request(context.request, forward_url)
        handle_response(context, response)
      rescue ex
        msg = "Error forwarding to #{forward_url}: #{ex.class}: #{ex.message}"
        record_log(msg, :error)

        context.response.status_code = 502
        context.response.print "Bad Gateway"
      end
    end

    private def build_forward_url(path, service)
      backend_url = MICROSERVICES[service]
      forward_path = path.sub(service, "")
      "#{backend_url}#{service}#{forward_path}"
    end

    private def forward_request(original_request, url) : HTTP::Client::Response
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      request = HTTP::Request.new(original_request.method, uri.request_target)

      # Copy all headers except sensitive ones
      skip_headers = ["Host", "Connection", "Content-Length"]
      original_request.headers.each do |k, v|
        request.headers[k] = v if v && !skip_headers.includes?(k)
      end

      if body = original_request.body
        request.body = IO::Memory.new(body.gets_to_end)
      end

      client.exec(request)
    end

    private def handle_response(context, response)
      context.response.status_code = response.status_code

      if content_type = response.headers["Content-Type"]?
        context.response.headers["Content-Type"] = content_type
      end

      context.response.print response.body

      msg = "[RES] #{response.status_code}"
      record_log(msg, :info)
    end

    private def record_log(message : String, type : Symbol)
      if type == :info
        LOG.info { message }
      elsif type == :error
        LOG.error { message }
      end
    end
  end
end
