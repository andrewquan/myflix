# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Myflix::Application.initialize!

# CarrierWave extension for Active Record
require 'carrierwave/orm/activerecord'