require "../services/users/register_service"

post "/auth/register" do |env|
  Users::RegisterService.new.call(env)
end

post "/auth/login" do
end
