Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Mailer default URL
  config.action_mailer.default_url_options = { :host => "landing.dev" }
  
  # config.action_mailer.smtp_settings = {
  #   :port           => ENV['MAILGUN_SMTP_PORT'],
  #   :address        => ENV['MAILGUN_SMTP_SERVER'],
  #   :domain         => ENV['MAILGUN_DOMAIN'],
  #   :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
  #   :password       => ENV['MAILGUN_SMTP_PASSWORD'],
  #   :authentication => :plain,
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_region=> 'us-west-2',
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

  config.armor_payments = {
    :key => ENV['ARMOR_KEY'],
    :secret => ENV['ARMOR_SECRET']
  }

end
