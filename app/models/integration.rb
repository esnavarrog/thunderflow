class Integration < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :app_type, presence: true
  validates :url, presence: true

  before_validation :validate_url
  before_create :crypt_token

  attr_accessor :consumer_key, :consumer_secret

  enum app_type: [:shopify, :woocommerce]

  def api
    return ShopifyApi.new(url, decrypted_token, id) if shopify?
    return WoocommerceApi.new(url, decrypted_token) if woocommerce?
  end

  private

  def decrypted_token
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'][0..31])
    crypt.decrypt_and_verify(token)
  end

  def validate_url
    errors[:url] << "Debe ingresar una URL válida" unless url =~ URI::regexp
  end

  def crypt_token
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'][0..31])
    self.token = crypt.encrypt_and_sign("#{consumer_key},#{consumer_secret}") if woocommerce?
    self.token = crypt.encrypt_and_sign(token) if shopify?
  end
end
