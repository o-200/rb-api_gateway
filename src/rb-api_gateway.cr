require "kemal"

require "./config/logger"
require "./routes/*"

require "./handlers/cors_handler"

add_handler CORSHandler.new
Kemal.run
