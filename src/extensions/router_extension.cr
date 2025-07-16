class RouterExtension
  def self.log_request(context : HTTP::Server::Context)
    msg = "[REQ] #{context.request.method} #{context.request.path} from #{context.request.remote_address}"
    record_log(msg, :info)
  end

  def self.get_service(path : String) : String?
    MICROSERVICES.keys.find { |prefix| path.starts_with?(prefix) }
  end

  def self.record_log(message : String, type : Symbol)
    case type
    when :info
      LOG.info { message }
    when :error
      LOG.error { message }
    end
  end
end
