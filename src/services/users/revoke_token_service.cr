require "http/client"
require "../application_service"
require "../../gateway/forwarder"

require "../../config"

class Users::RevokeTokenService < ApplicationService
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    microservice_hash = MICROSERVICES["rb-user"]
    domain = microservice_hash["domain"]
    path = microservice_hash["paths"]["user"]["logout"]

    Gateway::Forwarder.new.call(context, domain, path)
    return context
  end
end
