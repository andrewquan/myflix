Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environments = ['test', 'staging', 'production']
end