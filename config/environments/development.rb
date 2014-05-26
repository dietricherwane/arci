Arci::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  
  # Tire gem configuration
  Tire.configure do
    logger STDERR, :level => "debug"
  end

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  # Mail config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  ActionMailer::Base.smtp_settings = {
  	:openssl_verify_mode => 'none',
		:address => "smtp.gmail.com",
		:enable_starttls_auto => true,
		:port => 587,
		:authentication => :plain,
		:user_name => "dietricherwane@gmail.com",
		:password => '20dianapopoulos12'		
	}

=begin  
  ActionMailer::Base.smtp_settings = {
  	:openssl_verify_mode => 'none',
		:address => "smtp.live.com",
		:enable_starttls_auto => true,
		:port => 587,
		:authentication => :plain,
		:user_name => "dietricherwane@live.fr",
		:password => 'coco444cure464'		
	}
=end

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
end
