require "http/client"
require "../application_service"
require "../../gateway/forwarder"

require "../../config"

class Users::RegisterService < ApplicationService
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    microservice_hash = MICROSERVICES["rb-user"]
    domain = microservice_hash["domain"]
    path = microservice_hash["paths"]["register"]

    Gateway::Forwarder.new.call(context, domain, path)
    return context
  end
end
