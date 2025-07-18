require "../services/auth/*"

post "/auth/register" do |env|
  Users::RegisterService.new.call(env)
end

post "/auth/login" do |env|
  Users::LoginService.new.call(env)
end
