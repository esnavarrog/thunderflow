class ApiController < ApplicationController
  include Response
  include ExceptionHandler

  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  attr_reader :current_user

  protected

  def authenticate_request
    @resource = AuthorizeApiRequest.new(request.headers).call
  end
end