module GoogleCalHelper

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
end