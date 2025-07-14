require "http/client"
require "../config"
require "../logger"
require "./forwarder"
require "./application_router"

module Gateway
  class Router < ApplicationRouter
    include HTTP::Handler

    def call(context : HTTP::Server::Context)
      log_request(context)

      return if handle_root_path(context)

      if service = get_service(context.request.path)
        forwarder.call(context, service)
      else
        call_next(context)
      end
    end
  end
end
