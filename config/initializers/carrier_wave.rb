CarrierWave.configure do |config|
  config.storage = :aws
  config.aws_credentials = {
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  }
  if Rails.env.production?
    config.aws_bucket = ENV['AWS_S3_BUCKET_PRODUCTION']
  elsif Rails.env.staging?
    config.aws_bucket = ENV['AWS_S3_BUCKET_STAGING']
  else
    config.aws_bucket = ENV['AWS_S3_BUCKET_DEVELOPMENT']
    # If you instead want to save files directly to local machine
    # config.storage = :file
    # config.enable_processing = Rails.env.development?
  end
end