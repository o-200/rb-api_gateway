require "log"

LOG = Log.for("api_gateway")

Log.setup("*", Log::Severity::Info, Log::IOBackend.new)
