require "http/client"
require "../application_service"
require "../../gateway/forwarder"
require "../../config/config"

class Users::RegisterService < ApplicationService
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    service = get_service(context.request.path)
    unless service
      context.response.status_code = 400
      context.response.print "Unknown service"
      return
    end

    Gateway::Forwarder.new(MICROSERVICES).call(context, service)
    return context
  end
end
