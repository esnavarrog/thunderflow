# app/commands/authorize_api_request.rb
# Asumo que SimpleCommand está definido en tu proyecto.
# Si no lo tienes, puedes quitar `prepend SimpleCommand` y asegurarte de que `call`
# devuelva `user` o lance una excepción.
class AuthorizeApiRequest
  prepend SimpleCommand # O tu patrón de comando/servicio

  def initialize(headers = {})
    @headers = headers
  end

  # `call` ahora lanzará una excepción si falla la autenticación
  def call
    user
  end

  private

  attr_reader :headers

  def user
    # Intenta encontrar el usuario. Si no se encuentra, o el token es inválido,
    # las excepciones serán lanzadas por `decoded_auth_token` o por la búsqueda de usuario.
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    # Si el usuario no se encuentra después de decodificar el token, lanza un error.
    raise ExceptionHandler::AuthenticationError.new('User not found or invalid token payload') unless @user
    @user
  rescue ActiveRecord::RecordNotFound => e
    # Captura RecordNotFound si el user_id del token no existe en la DB
    raise ExceptionHandler::AuthenticationError.new('Invalid credentials or token: User not found.')
  end


  def decoded_auth_token
    # Intenta decodificar el token. Si hay errores, lanza excepciones.
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  rescue JWT::ExpiredSignature => e
    # Lanza nuestra excepción personalizada para token expirado
    raise ExceptionHandler::ExpiredSignature.new(e.message)
  rescue JWT::DecodeError => e
    # Lanza nuestra excepción personalizada para token inválido/malformado
    raise ExceptionHandler::InvalidToken.new(e.message)
  end

  def http_auth_header
    # Verifica la cabecera de autorización. Si falta, lanza una excepción.
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    end
    # Lanza nuestra excepción personalizada si falta el token
    raise ExceptionHandler::MissingToken.new('Missing token.')
  end
end