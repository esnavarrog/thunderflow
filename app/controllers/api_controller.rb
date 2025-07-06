class ApiController < ApplicationController
  # Incluir los concerns de manejo de excepciones y respuestas JSON
  include Response # <-- ¡Añade esta línea!
  include ExceptionHandler # <-- ¡Añade esta línea!

  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  attr_reader :current_user

  protected

  def authenticate_request
    @resource = AuthorizeApiRequest.new(request.headers).call
  end
end