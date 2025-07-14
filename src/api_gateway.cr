require "kemal"
require "./logger"
require "./gateway/router"

add_handler Gateway::Router.new

Kemal.run
