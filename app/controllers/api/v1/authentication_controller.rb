# app/controllers/api/v1/authentication_controller.rb

# require 'googleauth/id_tokens' # Asegúrate de que esta línea esté al inicio del archivo o en un initializer
# require 'googleauth/jwt_store' # Necesario para Google::Auth::IDTokens

class Api::V1::AuthenticationController < ::ApiController
  wrap_parameters format: []
  skip_before_action :verify_authenticity_token

  before_action :authenticate_request, except: [:login, :create]

  def login
    user = User.find_by(email: user_params[:email])

    # if user&.valid_password?(user_params[:password])
    if user
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        auth_token: token,
        user_data: user_data(user)
      }, status: :ok
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  def create
    user = User.find_by_email(user_params[:email])
    if user
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        auth_token: token,
        user_data: user_data(user)
      }, status: :ok
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  # **ACCIÓN CLAVE PARA EL LOGIN CON GOOGLE DESDE FLUTTER**
  def google_login
    id_token = params[:id_token]

    # **MUY IMPORTANTE: CONFIGURACIÓN DE AUDIENCE (AUD)**
    # El 'aud' (audience) es el Client ID de tu aplicación que ha solicitado el ID Token.
    # Si tu Flutter app utiliza `GoogleSignIn` con el parámetro `serverClientId`,
    # entonces `aud` DEBE SER EL CLIENT ID DE TU APLICACIÓN WEB (EL MISMO QUE USAS EN DEVISE/OMNIAUTH).
    #
    # Si tu Flutter app NO usa `serverClientId` al iniciar sesión,
    # el ID Token tendrá como audience el Client ID de tu aplicación Android o iOS.
    # En ese caso, deberías poner los CLIENT IDs DE TU APP ANDROID/IOS en `aud_list`.
    #
    # Lo más común y recomendado para la comunicación entre Flutter (cliente) y Rails (servidor)
    # es que Flutter use `serverClientId` (que es el Client ID de la app web de Google Cloud Console)
    # al hacer `GoogleSignIn.signIn`. Así, el ID Token es emitido para tu backend,
    # y tu backend puede validarlo directamente con su Client ID de app web.

    # Recupera tu Client ID de la aplicación web de Google Cloud Console.
    # Asegúrate de que esta variable de entorno esté configurada.
    web_client_id = ENV['GOOGLE_WEB_CLIENT_ID'] # O GOOGLE_KEY como lo tenías, pero el nombre importa

    if web_client_id.blank?
      Rails.logger.error("Error: GOOGLE_WEB_CLIENT_ID no configurado en el backend para la validación del token.")
      render json: { error: "Configuración de Google Client ID faltante en el servidor." }, status: :internal_server_error and return
    end

    begin
      # Usa Google::Auth::IDTokens.verify_oidc para una validación completa de OpenID Connect.
      # El `aud` (audience) aquí DEBE coincidir con el Client ID de tu aplicación que obtuvo el token.
      # Si Flutter pasa el ID Token obtenido con `serverClientId` (que es el ID de la app web),
      # entonces `aud: web_client_id` es lo correcto.
      payload = Google::Auth::IDTokens.verify_oidc(id_token, aud: web_client_id)

      # Extrae la información del usuario del payload
      email = payload['email']
      google_uid = payload['sub'] # 'sub' es el identificador único de Google para el usuario
      name = payload['name']
      picture = payload['picture'] # URL de la foto de perfil

      # Llama a tu método existente en el modelo User para encontrar o crear el usuario
      # Asegúrate de que `find_or_create_by_google_oauth` pueda manejar `name` y `picture`
      @user = User.find_or_create_by_google_oauth(email, google_uid, name, picture)

      if @user.persisted?
        # Genera tu token JWT personalizado
        token = JsonWebToken.encode(user_id: @user.id)

        # Retorna el JWT y los datos del usuario a la aplicación Flutter
        render json: {
          auth_token: token,
          user_data: {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            role: @user.role,
            avatar_url: @user.avatar_url # Si mapeas la URL de la foto de Google al avatar
          }
        }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Google::Auth::IDTokens::VerificationError => e
      # Error específico de validación del token de Google
      Rails.logger.error("Error de validación de Google ID Token: #{e.message}")
      render json: { error: "Token de Google inválido: #{e.message}" }, status: :unauthorized
    rescue StandardError => e
      # Captura cualquier otro error inesperado
      Rails.logger.error("Error interno en la autenticación de Google: #{e.class.name} - #{e.message}")
      render json: { error: "Error interno en autenticación de Google. Por favor, inténtelo de nuevo." }, status: :internal_server_error
    end
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      avatar_url: user.avatar_url
    }
  end

  def destroy
    # Lógica para cerrar sesión (si tienes un mecanismo de invalidación de JWT)
    # Por ejemplo: JsonWebToken.blacklist_token(token)
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, device_info: {})
  end
end