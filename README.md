# Spark Front-end APIs

### Google Calendar

[Google API Docs]()

```ruby

# Server side

page_token = nil

result = api_client.execute(:api_method => calendar_api.events.list,
                            :parameters => {'calendarId' => 'primary'})

while true
  @events = result.data.items
  if !(page_token = result.data.next_page_token)
    break
  end
  result = api_client.execute(:api_method =>   calendar_api.events.list,
                              :parameters => {'calendarId' => 'primary',
                                              'pageToken' => page_token})
end


# Client side
 
 <h3>Calendar</h3>

<% @events.each do | item | %>

<% if formating_time(item.start.dateTime) === formating_time(Time.new) %>
  
 <p>Event date:        <%= item.start.dateTime %> </p>
 <p>Event summary:     <%= item.summary %>        </p>
 <p>Event description: <%= item.description %>    </p>
 
 <p>Event location:    <%= item.location %>       </p>

 <%end%>

<%end%>

```


### Forecast.io

[Forecast API Docs](https://developer.forecast.io/docs/v2)

```ruby
require 'forecast_io'
require 'open-uri'
require 'JSON'

# https://api.forecast.io/forecast/token_key/latitude,longitude

# Server side

forecast_raw = open("https://api.forecast.io/forecast/967ecda5e515e3a4ce315e508/51.5231,-0.0871").read   

forecast     = JSON.parse(forecast_raw)

@forecast = forecast
```

```erb
# Client side
	<div>
	  <h3>Forecast weather</h3>

	  <p>Probability of rain <%= @forecast['currently']['precipProbability']%>%</p>
	  
	  <p>Actual forecast: <%= @forecast['minutely']['summary']%></p>
	  
	  <img src=<%= "images/#{@forecast['minutely']['icon']}.jpeg"%> alt="forecast image" > 

	</div>
```

### TFL (Transport for London)

[TFL API Docs](http://www.tfl.gov.uk/info-for/open-data-users/)

```ruby
# http://cloud.tfl.gov.uk/TrackerNet/LineStatus --> XML format

# Server side

require 'net/http'
require 'rexml/document'

url = 'http://cloud.tfl.gov.uk/TrackerNet/LineStatus'
xml_data = Net::HTTP.get_response(URI.parse(url)).body

	# extract event information
doc = REXML::Document.new(xml_data)


line_name   = []
status_line = []

doc.elements.each("ArrayOfLineStatus/LineStatus/Line/")   do |ele|
   line_name << ele.attributes["Name"]
end

doc.elements.each("ArrayOfLineStatus/LineStatus/Status/") do |ele|
   status_line << ele.attributes["Description"]
end

# Client Side
	<h3>Tube Status</h3>

	<ul>
	  <% @tfl_lines.zip(@tfl_status).each do |line,status|  %>
	    
	    <li> <%=line%>   </li>
	    <li> <%=status%> </li>
	  <%end%>
	</ul>
```
