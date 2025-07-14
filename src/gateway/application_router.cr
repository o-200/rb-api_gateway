module Gateway
  class ApplicationRouter
    private def handle_root_path(context : HTTP::Server::Context) : Bool
      if context.request.path == "/"
        context.response.content_type = "text/plain"
        context.response.print "Hello, World"

        true
      else
        false
      end
    end

    private def forwarder
      @forwarder ||= Forwarder.new(MICROSERVICES)
    end

    private def log_request(context : HTTP::Server::Context)
      msg = "[REQ] #{context.request.method} #{context.request.path} from #{context.request.remote_address}"
      record_log(msg, :info)
    end

    private def get_service(path : String) : String?
      MICROSERVICES.keys.find { |prefix| path.starts_with?(prefix) }
    end

    private def record_log(message : String, type : Symbol)
      case type
      when :info
        LOG.info { message }
      when :error
        LOG.error { message }
      end
    end
  end
end
