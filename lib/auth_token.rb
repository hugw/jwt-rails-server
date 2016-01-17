require 'jwt'

module AuthToken
  def self.encode(payload)
    payload['exp'] = 5.days.from_now.to_i

    # Firebase related
    payload['iat'] = Time.now.to_i
    payload['v'] = 0
    uid = "user_" + payload[:user][:id].to_s
    payload['d'] = { uid: uid }

    JWT.encode(payload, ENV['JWT_SECRET'])
  end

  def self.decode(token)
    begin
      JWT.decode(token, ENV['JWT_SECRET']).first
    rescue
      false
    end
  end
end
