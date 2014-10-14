module ClientHelper

	def formating_time(time)
		time.strftime('%d/%m/%Y')
	end

	def set_tfl_api

		url = 'http://cloud.tfl.gov.uk/TrackerNet/LineStatus'
		xml_data = Net::HTTP.get_response(URI.parse(url)).body

		# extract event information
		doc = REXML::Document.new(xml_data)

		line_name   = []
		line_status = []

		doc.elements.each("ArrayOfLineStatus/LineStatus/Line/") do |ele|
		   line_name << ele.attributes["Name"]
		end

		doc.elements.each("ArrayOfLineStatus/LineStatus/Status/") do |ele|
		   line_status << ele.attributes["Description"]
		end

		@tfl_lines   =  line_name
		@tfl_status  =  line_status

	end

	def set_forecast_api
		forecast_raw = open("https://api.forecast.io/forecast/967ecda5e55eea73c15e3a4ce315e508/51.5231,-0.0871").read   

		forecast     = JSON.parse(forecast_raw)

		@forecast = forecast
	end

	def set_google_cal_api

	  page_token = nil
		result = api_client.execute(:api_method => calendar_api.events.list,
	                              :parameters => {'calendarId' => 'primary'})
		while true
		  @events = result.data.items
		  
		  if !(page_token = result.data.next_page_token)
		    break
		  end
		  result = api_client.execute(:api_method => calendar_api.events.list,
		                              :parameters => {'calendarId' => 'primary',
		                                          'pageToken' => page_token})
		end
	end

end