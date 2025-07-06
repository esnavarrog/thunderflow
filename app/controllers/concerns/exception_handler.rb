module ExceptionHandler
  extend ActiveSupport::Concern

  # Definir clases de excepción personalizadas ANIDADAS dentro del módulo ExceptionHandler
  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end
  class ExpiredSignature < StandardError; end # Para JWT::ExpiredSignature
  class DecodeError < StandardError; end    # Para JWT::DecodeError

  included do
    # Manejo de errores de ActiveRecord
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    # Manejo de errores específicos de JWT (de la gema 'jwt')
    rescue_from JWT::DecodeError do |e|
      json_response({ message: 'Token inválido o malformado', error: e.message }, :unauthorized)
    end
    rescue_from JWT::ExpiredSignature do |e|
      json_response({ message: 'Token expirado', error: e.message }, :unauthorized)
    end

    # Manejo de nuestras excepciones personalizadas
    rescue_from ExceptionHandler::AuthenticationError, with: :four_zero_one
    rescue_from ExceptionHandler::MissingToken, with: :four_zero_one
    rescue_from ExceptionHandler::InvalidToken, with: :four_zero_one
    rescue_from ExceptionHandler::ExpiredSignature, with: :four_zero_one
    rescue_from ExceptionHandler::DecodeError, with: :four_zero_one

    private

    # Método auxiliar para manejar respuestas 401 Unauthorized
    def four_zero_one(e)
      json_response({ message: e.message }, :unauthorized)
    end
  end
end