# Spark Front-end APIs

### Reading a public Google Calendar

Let's try this with the very fun 'Holidays in the United Kingdom' calendar that Google provides.

https://www.google.com/calendar/feeds/en.uk%23holiday%40group.v.calendar.google.com/public/basic

#### Loading a calendar

```ruby
require 'open-uri'
require 'icalendar' # add to Gemfile!

@calendar = Icalendar.parse(open("https://www.google.com/calendar/ical/henrystanley.com_uh7l5drs1sfnju9eivnml389k8%40group.calendar.google.com/private-95d6172bf50f4f3783be77c8a0dfce42/basic.ics"))

# NOTE! This returns an array of calendars if there are more than one
# in the ics document. 

@calendar.class # => Array
@calendar.first.class # => Icalendar::Calendar

@calendar.first.events # returns all events in the calendar
@calendar.first.events.first.summary # => "St. David's Day"

@calendar.first.events.first.today? # false
```

#### Getting all of today's events

```ruby

require 'open-uri'
require 'icalendar' # add to Gemfile!

@calendar = Icalendar.parse(open("https://www.google.com/calendar/ical/henrystanley.com_uh7l5drs1sfnju9eivnml389k8%40group.calendar.google.com/private-95d6172bf50f4f3783be77c8a0dfce42/basic.ics"))

def get_todays_events
  @todays_events = []
  @calendar.first.events.each do |e|
    # put all of today's events into an array
    @todays_events << e if e.dtstart.today?
  end
  @todays_events.reverse!
end

get_todays_events

@todays_events.each do |e|
  if Time.now.zone == "BST"
    eventtime = e.dtstart + 3600
    puts "#{eventtime.strftime("%H:%M")}  #{e.summary}"
  else
    eventtime = e.dtstart
    puts "#{e.dtstart.strftime("%H:%M")}  #{e.summary}"
  end
end
```

In this example, I would get something like

```
10:00  Learning PASCAL with Enrique
11:30  Spark Printer team meeting
14:30  Lovis talks about teamwork
17:00  Demo: life at 1000WPM with Ethel
```

### Google Calendar

[Google API Docs](https://developers.google.com/google-apps/calendar/)

Enable Google+ API and Google Calendar API.

Create Client ID for native application.

```ruby
gem install google-api-client -v 0.6.4 # For me only working with this version


# Authentication with oauth-2

google-api oauth-2-login --scope=https://www.googleapis.com/auth/calendar --client-id=CLIENT_ID --client-secret=CLIENT_SECRET
```

Follow and get the code from [this tutorial](https://github.com/google/google-api-ruby-client-samples/tree/master/calendar) 

##### Server side

```ruby

=begin

This values needs to be changed depending what you want 

		"calendar_api.events.list"

For more info:

https://developers.google.com/google-apps/calendar/v3/reference/events/instances 

=end

get '/' do

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
end
```


##### Client side

```erb
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


##### Server side

```ruby
require 'forecast_io'
require 'open-uri'
require 'JSON'

# https://api.forecast.io/forecast/token_key/latitude,longitude


get '/' do

	forecast_raw = open("https://api.forecast.io/forecast/967ecda5e515e3a4ce315e508/51.5231,-0.0871").read   

	forecast     = JSON.parse(forecast_raw)

	@forecast = forecast
end
```

##### Client side

```erb
<div>
  <h3>Forecast weather</h3>

  <p>Probability of rain <%= @forecast['currently']['precipProbability']%>%</p>
  
  <p>Actual forecast: <%= @forecast['minutely']['summary']%></p>
  
  <img src=<%= "images/#{@forecast['minutely']['icon']}.jpeg"%> alt="forecast image" > 

</div>
```


### TFL (Transport for London)

[TFL API Docs](http://www.tfl.gov.uk/info-for/open-data-users/)

##### Server side

```ruby
# http://cloud.tfl.gov.uk/TrackerNet/LineStatus --> XML format


require 'net/http'
require 'rexml/document'


url = 'http://cloud.tfl.gov.uk/TrackerNet/LineStatus'
xml_data = Net::HTTP.get_response(URI.parse(url)).body

	# extract event information
doc = REXML::Document.new(xml_data)


line_name   = []
line_status = []

doc.elements.each("ArrayOfLineStatus/LineStatus/Line/")   do |ele|
   line_name << ele.attributes["Name"]
end

doc.elements.each("ArrayOfLineStatus/LineStatus/Status/") do |ele|
   line_status << ele.attributes["Description"]
end

get '/' do
 @tfl_lines  = line_name  
 @tfl_status = line_status
end
```

##### Client Side

```erb
<h3>Tube Status</h3>

<ul>
  <% @tfl_lines.zip(@tfl_status).each do |line,status|  %>
    
    <li> <%=line%>   </li>
    <li> <%=status%> </li>
  <%end%>
</ul>
```
