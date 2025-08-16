require "http/client"
require "../application_service"
require "../../gateway/forwarder"

require "../../config"

class Birds::FindBirdsByUserIdService < ApplicationService
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    microservice_hash = MICROSERVICES["rb-user"]
    domain = microservice_hash["domain"]
    path = microservice_hash["paths"]["bird"]["birds_by_user_id"]

    Gateway::Forwarder.new.call(context, domain, path)
    return context
  end
end
