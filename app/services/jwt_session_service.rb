# frozen_string_literal: true

class JwtSessionService
  # Inspired from: https://gist.github.com/riskimidiw/5a45be71446caf940ecbb3e58b6a322d#file-json_web_token-rb

  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, expiration = 24.hours.from_now)
    JWT.encode(payload.merge(exp: expiration.to_i), SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  end
end
