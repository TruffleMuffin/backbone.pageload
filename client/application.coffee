module.exports = class Application

	# Create the default configuration for the application
	_defaultConfiguration: ->
		callList: []
		done: ->
		progress: ->

	# Place all appropriate configuration information onto this instance
	initialize: (options = {}) ->
		# Establish the correct configuration for this instance
		@configuration = @_defaultConfiguration()
		for name, property of options
			@configuration[name] = property

		# Create the events instance we will use here
		@events = new (require './events')(this)

		# Establish the internal tracking object to understand how far through the page load we are
		@tracking =
			totalRequests: @configuration.callList.length
			completedRequests: 0

		# Listen to the appropriate events
		@events.on 'request:complete', @requestComplete

		# Create the XMLHttpRequest interceptor
		@interceptor = new (require './interceptor')({ @events })
		# Attach the interceptor
		@interceptor.attach()

	requestComplete: (options) ->
		@update() if @matchCall options.url

	update: ->
		# Called when another request has completed, so bump that number for tracking purposes
		@tracking.completedRequests += 1

		# Calculate the progress based on the tracking information
		progress = 0
		if @tracking.completedRequests > 0
			progress = Math.round((@tracking.completedRequests / @tracking.totalRequests) * 100)

		@configuration.progress(progress) if progress > 0
		@done() if @tracking.totalRequests is @tracking.completedRequests

	done: ->
		@interceptor.detach()
		@events.off('request:complete')
		@configuration.done()

	matchCall: (url) ->
		match = false
		for item in @configuration.callList
			if url.match(item)?
				match = true
				break
		match

