require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'sinatra'
require 'logger'
require 'JSON'
require 'forecast_io'
require 'open-uri'

enable :sessions

CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"

def logger; settings.logger end

def api_client; settings.api_client; end

def calendar_api; settings.calendar; end

def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
  )
end

configure do
  log_file = File.open('calendar.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG

  client = Google::APIClient.new(
    :application_name => 'Ruby Calendar sample',
    :application_version => '1.0.0')
  
  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load
    client.authorization = client_secrets.to_authorization
    client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
  else
    client.authorization = file_storage.authorization
  end

  # Since we're saving the API definition to the settings, we're only retrieving
  # it once (on server start) and saving it between requests.
  # If this is still an issue, you could serialize the object and load it on
  # subsequent runs.
  calendar = client.discovered_api('calendar', 'v3')

  set :logger, logger
  set :api_client, client
  set :calendar, calendar
end

before do
  # Ensure user has authorized the app
  unless user_credentials.access_token || request.path_info =~ /\A\/oauth2/
    redirect to('/oauth2authorize')
  end
end

after do
  # Serialize the access/refresh token to the session and credential store.
  session[:access_token] = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in] = user_credentials.expires_in
  session[:issued_at] = user_credentials.issued_at

  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  file_storage.write_credentials(user_credentials)
end

get '/oauth2authorize' do
  # Request authorization
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  redirect to('/')
end

get '/' do

	forecast_raw = open("https://api.forecast.io/forecast/967ecda5e55eea73c15e3a4ce315e508/51.5231,-0.0871").read   

	forecast = JSON.parse(forecast_raw)

  # Fetch list of events on the user's default calendar
  @result = api_client.execute(:api_method => calendar_api.events.list,
                              :parameters => {'calendarId' => 'primary'},
                              :authorization => user_credentials)
  [@result.status, {'Content-Type' => 'application/json'}, @result.data.to_json]

  calendar = JSON.parse(@result.body)

  @forecast = forecast
  
  @calendar = calendar

  erb :index
end

# require 'sinatra'
# require 'forecast_io'
# require 'JSON'
# require 'open-uri'
# require 'google/api_client'
# require 'yaml'


# oauth_yaml = YAML.load_file('../.google-api.yaml')
# client = Google::APIClient.new(options = { application_name: "spark-printer" })
# client.authorization.client_id = oauth_yaml["client_id"]
# client.authorization.client_secret = oauth_yaml["client_secret"]
# client.authorization.scope = oauth_yaml["scope"]
# client.authorization.scope = oauth_yaml["application_name"]
# #client.authorization.refresh_token = oauth_yaml["refresh_token"]
# client.authorization.access_token = oauth_yaml["access_token"]

# if client.authorization.refresh_token && client.authorization.expired?
#   client.authorization.fetch_access_token!
# end

# service = client.discovered_api('calendar', 'v3')



# get '/' do
# 	forecast_raw = open("https://api.forecast.io/forecast/967ecda5e55eea73c15e3a4ce315e508/51.5231,-0.0871").read   

# 	forecast = JSON.parse(forecast_raw)

# 	result = client.execute(:api_method => service.calendars.get,
# 													:parameters => {'calendarId'=> 'ovm197v9n0jccgqraca5b351ko@group.calendar.google.com'})


# 	p result

# 	@forecast = forecast

# 	@calendar = result
# 	erb :index
# end

# get '/oauth2callback' do
# end



   
# # 
# # print my daily mood, 1 to 5 emoticons, prints name, date and image 
# #

# # server --> google-api oauth-2-login --scope=https://www.googleapis.com/auth/calendar --client-id=825373276554-4nfjhf0392tfmcggcf87o8fqiiefqgt6.apps.googleusercontent.com --client-secret=GJaevEUbbyUAPhgzplo4-Ckc

# # client --> google-api oauth-2-login --scope=https://www.googleapis.com/auth/calendar --client-id=825373276554-grlp225vpg7o4e89ll9qfeugnsqkq78k.apps.googleusercontent.com --client-secret=bAR4AdShTZ7-gxDm2e9a4ucX


# # https://www.googleapis.com/calendar/v3/calendars/ovm197v9n0jccgqraca5b351ko@group.calendar.google.com/events

# =begin

# require 'rubygems'
# require 'google/api_client'
# require 'yaml'

# oauth_yaml = YAML.load_file('.google-api.yaml')
# client = Google::APIClient.new
# client.authorization.client_id = oauth_yaml["client_id"]
# client.authorization.client_secret = oauth_yaml["client_secret"]
# client.authorization.scope = oauth_yaml["scope"]
# client.authorization.refresh_token = oauth_yaml["refresh_token"]
# client.authorization.access_token = oauth_yaml["access_token"]

# if client.authorization.refresh_token && client.authorization.expired?
#   client.authorization.fetch_access_token!
# end

# service = client.discovered_api('calendar', 'v3')

# =end
