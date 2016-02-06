# A simple XMLHttpRequest interceptor
module.exports = class Interceptor

	# Request must be on the prototype as we can't override context to the interceptor to make the call
	Request = XMLHttpRequest

	constructor: (options = {}) ->
		@events = options.events ? new (require './events')()
		@requests = {}
		# Listen to all request:complete method and delete wrappers from @requests
		@events.on 'request:complete', (options) =>
			delete @requests[options.id]

	attach: ->
		window.XMLHttpRequest = (options) =>
			# Construct the request as usual
			request = new Request(options)
			# Replace the open method to trigger the initial event
			@replaceOpen(request)
			# Return the request to use as usual
			return request

	detach: ->
		XMLHttpRequest = Request

	replaceOpen: (request) ->
		open = request.open
		request.open = ( method = '', url = '') =>
			# Create a unique identifier for this request
			id = method + url + '@' + (new Date()).getTime()
			# Wrap the request and add it to the intercepted items
			@requests[id] = new Wrapper({ id, @events, request})
			# trigger the request start for the url
			@events.trigger 'request:start', { url, method, id }
			# Actuall call the real open method
			open.apply request, arguments

	class Wrapper

		constructor: (options = {}) ->
			@request = options.request
			@events = options.events
			@id = options.id

			for name in ['load', 'abort', 'timeout', 'error']
				@request.addEventListener name, @requestComplete

		requestComplete: =>
			@events.trigger 'request:complete', { @id }
