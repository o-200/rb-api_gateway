require "../services/birds/*"

get "/birds/:user_id" do |env|
  Birds::FindBirdsByUserIdService.new.call(env)
end
