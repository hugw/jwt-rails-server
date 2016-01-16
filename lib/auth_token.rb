require 'jwt'

module AuthToken
  def self.encode(payload)
    payload['exp'] = 5.days.from_now.to_i
    JWT.encode(payload, ENV['devise_key'])
  end

  def self.decode(token)
    begin
      JWT.decode(token, ENV['devise_key']).first
    rescue
      false
    end
  end
end
