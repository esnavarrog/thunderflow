require 'json_web_token'

class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, ENV["jwt_secret"], 'HS256')
  end

  def self.decode(token)
    body = JWT.decode(token, ENV["jwt_secret"], true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new body
  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end