exports.config =

	server:
		port: 3000

	paths:
		watched: [
			'client'
			'test'
		]

	modules:
		nameCleaner: (path) ->
			path = path.replace /^client/, 'backbone.pageload'
			path

	files:
		javascripts:
			joinTo:
				'javascripts/vendor.js': /^(bower_components)/
				'javascripts/backbone.pageload.js': /^(client)/

				'../lib/backbone.pageload.js': /^(client)/

				'test/javascripts/test.js': /^test/

			order:
				before: [
					'bower_components/jquery/dist/jquery.js'
				]

	plugins:
		uglify:
			mangle: false
			compress: true

	sourceMaps: no