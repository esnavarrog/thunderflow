class Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    id_token = params[:id_token]
    begin
      # Verify the ID token with Google
      validator = Google::Auth::IDTokens.new
      certs = Google::Auth::CertificateStore.new
      payload = validator.get_payload(id_token, "599132305675-fuotg01erv5td8arnpajhnhe9ei27j2u.apps.googleusercontent.com", certs)

      # Extract user info from the payload
      email = payload['email']
      name = payload['name']

      # Find or create user
      @user = User.find_or_create_by(email: email) do |user|
        user.name = name
        user.password = Devise.friendly_token.first(20)
      end

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      else
        session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
        render json: { error: "Could not authenticate user" }, status: :unprocessable_entity
      end
    rescue Google::Auth::IDTokens::VerificationError => e
      render json: { error: "Invalid Google ID token: #{e.message}" }, status: :unprocessable_entity
    rescue => e
      puts "Error during Google OAuth2 callback: #{e.message}"
      render json: { error: 'Failed to authenticate with Google' }, status: :internal_server_error
    end
  end
end