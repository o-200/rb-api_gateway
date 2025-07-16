class ApplicationService
  def get_service(path : String) : String?
    MICROSERVICES.keys.find { |prefix| path.starts_with?(prefix) }
  end
end
