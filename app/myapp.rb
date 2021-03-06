require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'sinatra'
require 'logger'
require 'JSON'
require 'forecast_io'
require 'open-uri'

require 'net/http'
require 'rexml/document'

require '../helpers/client_helper'
require '../helpers/google_cal_helper'

include ClientHelper
include GoogleCalHelper

enable :sessions


# Google Calendar 

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

	# End Google Calendar


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

	# Setting forecast, client_helper method 

	set_forecast_api

	
	# Setting tfl, client_helper method 

	set_tfl_api

	# Setting Google Calendar, client_helper method 

	set_google_cal_api

	erb :index
end


