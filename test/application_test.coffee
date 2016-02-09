describe 'truffle.pageload/application', ->

	sut = null

	beforeEach ->
		sut = new (require 'truffle.pageload/application')()

	describe 'initialize', ->

		callList = null

		beforeEach ->
			callList = [ 'test' ]

		describe 'when all features are not supported', ->

			done = null

			beforeEach ->
				done = sinon.stub()
				sinon.stub sut, 'supportedFeatures', -> false

			it 'should create a configuration element', ->
				sut.initialize({ done })
				expect(sut.configuration).to.exist
				sut.configuration.callList.should.not.equal callList

			it 'should call the done function', ->
				sut.initialize({ done })
				done.should.have.been.called

			it 'should not create events', ->
				sut.initialize()
				expect(sut.events).to.not.exist

			it 'should not establish tracking data', ->
				sut.initialize()
				expect(sut.tracking).to.not.exist

			it 'should not create the interceptor', ->
				sut.initialize()
				expect(sut.interceptor).to.not.exist

		describe 'when all features are supported', ->

			beforeEach ->
				sinon.stub sut, 'supportedFeatures', -> true

			it 'should create a configuration element', ->
				sut.initialize()
				expect(sut.configuration).to.exist
				sut.configuration.callList.should.not.equal callList

			it 'should override provided properties on the configuration element', ->
				sut.initialize({ callList })
				sut.configuration.callList.should.equal callList

			it 'should create events', ->
				sut.initialize()
				expect(sut.events).to.exist

			it 'should establish tracking data', ->
				sut.initialize()
				expect(sut.tracking).to.exist

			it 'should create the interceptor', ->
				sut.initialize()
				expect(sut.interceptor).to.exist

	describe 'requestStart', ->

		beforeEach ->
			sinon.stub sut, 'open'

		describe 'when there is a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> true

			it 'should call open', ->
				sut.requestStart({ url: 'test' })
				sut.open.should.have.been.called

		describe 'when there isnt a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> false

			it 'should not call open', ->
				sut.requestStart({ url: 'test' })
				sut.open.should.not.have.been.called

	describe 'requestComplete', ->

		beforeEach ->
			sinon.stub sut, 'complete'

		describe 'when there is a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> true

			it 'should call complete', ->
				sut.requestComplete({ url: 'test' })
				sut.complete.should.have.been.called

		describe 'when there isnt a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> false

			it 'should not call complete', ->
				sut.requestComplete({ url: 'test' })
				sut.complete.should.not.have.been.called

	describe 'open', ->

		beforeEach ->
			sut.tracking =
				totalRequests: 1
				completedRequests: 0
				startedRequests: 0
			sinon.stub sut, 'updateTracking'

		it 'should bump the started requests only', ->
			sut.open()
			sut.tracking.startedRequests.should.equal 1
			sut.tracking.totalRequests.should.equal 1
			sut.tracking.completedRequests.should.equal 0

		it 'should call updateTracking', ->
			sut.open()
			sut.updateTracking.should.have.been.called

	describe 'complete', ->

		beforeEach ->
			sut.tracking =
				totalRequests: 1
				completedRequests: 0
				startedRequests: 0
			sinon.stub sut, 'updateTracking'

		it 'should bump the completed requests only', ->
			sut.complete()
			sut.tracking.startedRequests.should.equal 0
			sut.tracking.totalRequests.should.equal 1
			sut.tracking.completedRequests.should.equal 1

		it 'should call updateTracking', ->
			sut.complete()
			sut.updateTracking.should.have.been.called

	describe 'updateTracking', ->

		beforeEach ->
			sut.configuration =
				progress: sinon.stub()
			sut.tracking =
				totalRequests: 1
				completedRequests: 0
				startedRequests: 1
			sinon.stub sut, 'done'

		describe 'when the tracking is not complete', ->

			it 'should call progress with the correct value', ->
				sut.updateTracking()
				sut.configuration.progress.should.have.been.calledWith 50

			it 'should not call done', ->
				sut.updateTracking()
				sut.done.should.not.have.been.called

		describe 'when the tracking is  complete', ->

			beforeEach ->
				sut.tracking.completedRequests = 1

			it 'should call progress with the correct value', ->
				sut.updateTracking()
				sut.configuration.progress.should.have.been.calledWith 100

			it 'should call done', ->
				sut.updateTracking()
				sut.done.should.have.been.called

	describe 'done', ->

		beforeEach ->
			sut.interceptor =
				detach: sinon.stub()
			sut.events =
				off: sinon.stub()
			sut.configuration =
				done: sinon.stub()

		it 'should detach the interceptor', ->
			sut.done()
			sut.interceptor.detach.should.have.been.called

		it 'should turn off events', ->
			sut.done()
			sut.events.off.should.have.been.calledWith 'request:complete'

		it 'should call done', ->
			sut.done()
			sut.configuration.done.should.have.been.called

	describe 'matchCall', ->

		beforeEach ->
			sut.configuration =
				callList: [ 'test' ]

		it 'should return true when there is a match', ->
			result = sut.matchCall 'test'
			result.should.equal true

		it 'should return false when there isnt a match', ->
			result = sut.matchCall 'teasdfst'
			result.should.equal false

		it 'should return do a case insensitive match', ->
			result = sut.matchCall 'teSt'
			result.should.equal true

