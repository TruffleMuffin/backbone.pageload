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
			startedRequests: 0

		# Listen to the appropriate events
		@events.on 'request:start', @requestStart
		@events.on 'request:complete', @requestComplete

		# Create the XMLHttpRequest interceptor
		@interceptor = new (require './interceptor')({ @events })
		# Attach the interceptor
		@interceptor.attach()

	requestStart: (options) ->
		@open() if @matchCall options.url

	requestComplete: (options) ->
		@complete() if @matchCall options.url

	# Called when a request starts
	open: ->
		# bump that number for tracking purposes
		@tracking.startedRequests += 1

		# Update the tracking data and fire any appropriate callback
		@updateTracking()

	# Called when another request has completed
	complete: ->
		# bump that number for tracking purposes
		@tracking.completedRequests += 1

		# Update the tracking data and fire any appropriate callback
		@updateTracking()

	updateTracking: ->
		# Calculate the progress based on the tracking information
		progress = 0

		# A request has a start and complete update, give each function equal priority
		if @tracking.startedRequests > 0
			progress += Math.round(((@tracking.startedRequests / @tracking.totalRequests) * 100) / 2)

		if @tracking.completedRequests > 0
			progress += Math.round(((@tracking.completedRequests / @tracking.totalRequests) * 100) / 2)

		@configuration.progress(progress) if progress > 0
		@done() if @tracking.totalRequests is @tracking.completedRequests

	done: ->
		@interceptor.detach()
		@events.off('request:complete')
		@configuration.done()

	matchCall: (url) ->
		match = false
		for item in @configuration.callList
			if url.toLowerCase().match(item)?
				match = true
				break
		match

