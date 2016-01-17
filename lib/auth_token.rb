require 'jwt'

module AuthToken
  def self.encode(payload)
    payload['exp'] = 10.days.from_now.to_i
    JWT.encode(payload, ENV['DEVISE_KEY'])
  end

  def self.decode(token)
    begin
      JWT.decode(token, ENV['DEVISE_KEY']).first
    rescue
      false
    end
  end
end
