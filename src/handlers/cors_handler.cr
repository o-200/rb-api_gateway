require "http/server"

class CORSHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    context.response.headers["Access-Control-Allow-Origin"] = "http://localhost:5173"
    context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    context.response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    context.response.headers["Access-Control-Allow-Credentials"] = "true"

    # Handle OPTIONS preflight
    if context.request.method == "OPTIONS"
      context.response.status_code = 204
      context.response.print ""
      return
    end

    call_next(context)
  end
end
