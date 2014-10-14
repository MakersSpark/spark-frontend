require 'sinatra'
require 'forecast_io'
require 'JSON'
require 'open-uri'
require 'google/api_client'
require 'yaml'


oauth_yaml = YAML.load_file('../.google-api.yaml')
client = Google::APIClient.new
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.scope = oauth_yaml["application_name"]
#client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

if client.authorization.refresh_token && client.authorization.expired?
  client.authorization.fetch_access_token!
end

service = client.discovered_api('calendar', 'v3')


get '/' do
	forecast_raw = open("https://api.forecast.io/forecast/967ecda5e55eea73c15e3a4ce315e508/51.5231,-0.0871").read   

	forecast = JSON.parse(forecast_raw)
	
	@forecast = forecast

	@calendar = service
	erb :index
end



   
# 
# print my daily mood, 1 to 5 emoticons, prints name, date and image 
#

# google-api oauth-2-login --scope=https://www.googleapis.com/auth/calendar --client-id=825373276554-4nfjhf0392tfmcggcf87o8fqiiefqgt6.apps.googleusercontent.com --client-secret=GJaevEUbbyUAPhgzplo4-Ckc




=begin

require 'rubygems'
require 'google/api_client'
require 'yaml'

oauth_yaml = YAML.load_file('.google-api.yaml')
client = Google::APIClient.new
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

if client.authorization.refresh_token && client.authorization.expired?
  client.authorization.fetch_access_token!
end

service = client.discovered_api('calendar', 'v3')

=end