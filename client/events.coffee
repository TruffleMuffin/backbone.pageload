# A simple class to handle binding and triggering events, matches classic on/trigger specification.
module.exports = class Events

	constructor: (context) ->
		# Establish an object to keep track of all the events we are listening to
		@listeners = {}
		# Save the context to apply when using the callback, default to this
		@context = context ? this

	# Trigger the event with the arguments
	trigger: (name, args) ->
		if @listeners[name]?
			for callback in @listeners[name]
				callback.call @context, args

	# Detach a listener
	off: (name, callback) ->
		# Skip if there are no listeners for the provided name
		return unless @listeners[name]?

		# If the callback is passed remove just that listener
		if callback?
			listeners = []
			for fn, index in @listeners[name]
				if fn isnt callback
					listeners.push fn
			@listeners[name] = listeners
		else
			# Otherwise just remove all listeners
			delete @listeners[name]

	# Attach a listener for event 'name' to execute the function 'callback'
	on: (name, callback) ->
		# Ensure there is an array available on the listeners object to track one or more callback functions
		@listeners[name] ?= []
		# Push the callback onto the listeners stack for this event name
		@listeners[name].push callback
