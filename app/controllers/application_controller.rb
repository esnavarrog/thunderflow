class ApplicationController < ActionController::Base
    include Pundit::Authorization
    APP_DOMAIN = 'sociosaltyro.cl'
    # before_action :ensure_domain
    protect_from_forgery  with: :exception
    before_action :force_ssl, :set_current_company, :validate_company
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    before_action :configure_permitted_parameters, if: :devise_controller?
    helper_method :current_company

    def ensure_domain
        unless request.env['HTTP_HOST'] == APP_DOMAIN || Rails.env.development?
            redirect_to "https://#{APP_DOMAIN}", status: 301
        end
    end

    def force_ssl
        if Rails.env.production?
            redirect_to protocol:'https' unless request.ssl?
        end
    end

    def user_not_authorized
        redirect_to root_path
    end

    def build_token
        begin
            token = SecureRandom.urlsafe_base64
        end while Branch.exists?(orden_number: token)
        token
    end

    def current_company
        return nil unless current_user
        Company.find_by(id: session[:current_company_id])
    end

    def api_request?
        request.path.start_with?('/api') || request.path.start_with?('/auth') # /auth es para Devise Token Auth
    end

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :avatar, :rut, :role, :password, :password_confirmation) }
        devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :avatar, :rut, :role, :status, :password, :password_confirmation) }
    end

    def validate_company
        return redirect_to root_url if new_first_company_companies_path == request.path && policy(:welcome).valid_user?
        return if new_first_company_companies_path == request.path
        redirect_to new_first_company_companies_path unless policy(:welcome).valid_user?
    end

    def set_current_company
        return if current_user.nil? || !current_user.client?
        return if current_user.companies.empty?
        session[:current_company_id] = current_user.companies.first.id if session[:current_company_id].nil?
    end
end
