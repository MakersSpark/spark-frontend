require 'sinatra'
require 'forecast_io'
require 'JSON'
require 'open-uri'

require 'omniauth-openid'
require 'openid'
require 'openid/store/filesystem'
require 'gapps_openid'



get '/' do
erb :index

end

post '/' do
	forecast_raw = open("https://api.forecast.io/forecast/967ecda5e55eea73c15e3a4ce315e508/51.5231,-0.0871").read   

	forecast = JSON.parse(forecast_raw)

	if forecast  
	  @forecast = forecast["minutely"]["summary"]
	end
	erb :index
end
   
#
# print my daily mood, 1 to 5 emoticons, prints name, date and image 
#