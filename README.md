# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# SwaggerClient::DeliveriesApi

All URIs are relative to *https://despachos-staging.herokuapp.com/api/v1/deliveries/*

Method | HTTP request | Description
------------- | ------------- | -------------
[**id_delivery_get**](DeliveriesApi.md#id_delivery_get) | **GET** /{idDelivery} | Obtiene información de la solicitud
[**root_post**](DeliveriesApi.md#root_post) | **POST** / | Crea una nueva solicitud

# **id_delivery_get**
> SuccessDeliveryGet id_delivery_get(token, id_delivery)

Obtiene información de la solicitud

### Example
```ruby
# load the gem
require 'swagger_client'

api_instance = SwaggerClient::DeliveriesApi.new
token = 'token_example' # String | Token de autenticación
id_delivery = 'id_delivery_example' # String | Identificador de la solicitud requerida.


begin
  #Obtiene información de la solicitud
  result = api_instance.id_delivery_get(token, id_delivery)
  p result
rescue SwaggerClient::ApiError => e
  puts "Exception when calling DeliveriesApi->id_delivery_get: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**| Token de autenticación | 
 **id_delivery** | **String**| Identificador de la solicitud requerida. | 

### Return type

[**SuccessDeliveryGet**](SuccessDeliveryGet.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



# **root_post**
> SuccessDeliveryPost root_post(bodytoken)

Crea una nueva solicitud

### Example
```ruby
# load the gem
require 'swagger_client'

api_instance = SwaggerClient::DeliveriesApi.new
body = SwaggerClient::BodyDeliveriesPost.new # BodyDeliveriesPost | 
token = 'token_example' # String | Token de autenticación


begin
  #Crea una nueva solicitud
  result = api_instance.root_post(bodytoken)
  p result
rescue SwaggerClient::ApiError => e
  puts "Exception when calling DeliveriesApi->root_post: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**BodyDeliveriesPost**](BodyDeliveriesPost.md)|  | 
 **token** | **String**| Token de autenticación | 

### Return type

[**SuccessDeliveryPost**](SuccessDeliveryPost.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

# Thunderflow - Docker y Despliegue en AWS EC2

## Desarrollo local con Docker

1. Copia tus archivos de ejemplo de configuración si es necesario:
   ```sh
   cp config/database.yml.example config/database.yml
   cp config/master.key.example config/master.key
   ```
   (Asegúrate de tener las claves y configuraciones necesarias)

2. Levanta los servicios (Rails, PostgreSQL 16, Redis):
   ```sh
   docker-compose up --build
   ```
   Esto iniciará la app en http://localhost:3000

3. Ejecuta las migraciones y carga datos si es necesario:
   ```sh
   docker-compose exec web rails db:create db:migrate db:seed
   ```

4. Hot reload: cualquier cambio en el código se reflejará automáticamente.

---

## Producción en AWS EC2 (con Nginx)

1. Construye la imagen de producción:
   ```sh
   docker build -t thunderflow:prod .
   ```

2. Prepara un archivo `docker-compose.prod.yml` (ejemplo):
   ```yaml
   version: '3.9'
   services:
     db:
       image: postgres:16
       environment:
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: password
         POSTGRES_DB: thunderflow_production
       volumes:
         - pgdata:/var/lib/postgresql/data
     redis:
       image: redis:7
     web:
       image: thunderflow:prod
       environment:
         RAILS_ENV: production
         DATABASE_HOST: db
         DATABASE_USERNAME: postgres
         DATABASE_PASSWORD: password
         REDIS_URL: redis://redis:6379/0
       depends_on:
         - db
         - redis
     nginx:
       image: nginx:alpine
       ports:
         - "80:80"
       volumes:
         - ./nginx.conf:/etc/nginx/nginx.conf:ro
         - ./public:/app/public:ro
       depends_on:
         - web
   volumes:
     pgdata:
   ```

3. Sube los archivos necesarios a tu EC2 (código, Dockerfile, nginx.conf, etc.)

4. Levanta los servicios en producción:
   ```sh
   docker-compose -f docker-compose.prod.yml up --build -d
   ```

5. Accede a la app desde el navegador usando la IP pública de tu EC2.

---

## Notas
- Cambia las variables de entorno y contraseñas en producción.
- Puedes agregar Sidekiq fácilmente conectando el servicio a Redis.
- Para más seguridad, configura HTTPS en Nginx.




