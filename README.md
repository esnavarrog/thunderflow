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




