require 'sinatra'
require 'omniauth-openid'
require 'openid'
require 'openid/store/filesystem'
require 'gapps_openid'

get '/' do
	erb :index
end
