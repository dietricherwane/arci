# Load the Rails application.
require File.expand_path('../application', __FILE__)
#require "execjs"

#begin
#  Tire.configure do
#    logger STDERR
#    url Settings.elasticsearch_url
#  end
#rescue => e
#  p "Wrong configuration: #{e}"
#end

# Initialize the Rails application.
Arci::Application.initialize!
