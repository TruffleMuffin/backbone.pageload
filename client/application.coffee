module.exports = class Application

	# Create the default configuration for the application
	_defaultConfiguration: ->
		callList: []

	# Place all appropriate configuration information onto this instance
	initialize: (options = {}) ->
		# Establish the correct configuration for this instance
		@configuration = @_defaultConfiguration()
		for property, name of options
			@configuration[name] = property

		# Create the events instance we will use here
		@events = new (require './events')()

		# Listen to the appropriate events
		@events.on 'request:start', @requestStart
		@events.on 'request:complete', @requestComplete

		# Create the XMLHttpRequest interceptor
		@interceptor = new (require './interceptor')({ @events })
		# Attach the interceptor
		@interceptor.attach()

	requestStart: (options) ->
		console.log options

	requestComplete: (options) ->
		console.log options


