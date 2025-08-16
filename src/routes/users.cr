require "../services/users/*"

# users
post "/auth/register" do |env|
  Users::RegisterService.new.call(env)
end

post "/auth/login" do |env|
  Users::LoginService.new.call(env)
end

# tokens
get "/auth/current_user" do |env|
  Users::GetCurrentUser.new.call(env)
end

post "/auth/refresh" do |env|
  Users::RefreshTokenService.new.call(env)
end

post "/auth/logout" do |env|
  Users::RevokeTokenService.new.call(env)
end
