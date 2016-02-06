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
			path = path.replace /^client/, 'truffle.pageload'
			path

	files:
		javascripts:
			joinTo:
				'javascripts/truffle.pageload.js': /^(client)/

				'../lib/truffle.pageload.js': /^(client)/

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