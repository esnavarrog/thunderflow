require_relative 'boot'

require 'rails/all'
require 'raygun4ruby'
require 'logger'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DespachosPyme
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.time_zone = 'America/Santiago'
    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.i18n.load_path += Dir[Rails.root.join('locales', '*.{rb,yml}').to_s]
    config.assets.precompile += ['mailer.css']
    config.i18n.default_locale = :es
    config.assets.initialize_on_precompile = false
    config.action_view.embed_authenticity_token_in_remote_forms = true
    config.assets.paths << "#{Rails.root}/app/assets/images"

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'application.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exist?(env_file)
    end

    # config.middleware.use WickedPdf::Middleware

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
