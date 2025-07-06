# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#     allow do
#         # origins Company.where(accepted_api:true).map{|a| a.resources.where(status: :active).pluck(:web_address).reject { |item| item.empty? }}.flatten
#         origins '*'
#         resource '/api/v1/deliveries',
#             headers: :any,
#             methods: [:get, :post, :put]
#     end
# end
Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        # En desarrollo, puedes usar '*' para permitir solicitudes desde cualquier origen.
        # ¡IMPORTANTE! En producción, reemplaza '*' con el dominio o los dominios específicos
        # donde se aloja tu aplicación React Native.
        # Ejemplo: origins 'https://tuappreactnative.com', 'http://localhost:8081' (para desarrollo local de RN)
        origins '*'

        # El recurso '*' es crucial para permitir que la API de Rails responda a todas
        # las rutas, incluyendo las de Devise Token Auth (como /auth/sign_in, /auth/sign_out)
        # y tus propias rutas de API (como /api/v1/deliveries).
        resource '/api/v1/*',
                 # Permite todos los encabezados HTTP.
                 headers: :any,
                 # Permite los métodos HTTP estándar utilizados en una API RESTful,
                 # incluyendo OPTIONS (para las pre-flights CORS) y PATCH/DELETE.
                 methods: [:get, :post, :put, :patch, :delete, :options, :head],
                 # Es fundamental exponer estos encabezados para que tu aplicación React Native
                 # pueda leer los tokens de autenticación que envía devise_token_auth después
                 # de un inicio de sesión o registro exitoso.
                 expose: ['Access-Token', 'Client', 'UID', 'Expiry', 'token-type', 'Authorization']
    end
end