describe 'truffle.pageload/application', ->

	sut = null

	beforeEach ->
		sut = new (require 'truffle.pageload/application')()

	describe 'initialize', ->

		callList = null

		beforeEach ->
			callList = [ 'test' ]

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

	describe 'requestComplete', ->

		beforeEach ->
			sinon.stub sut, 'update'

		describe 'when there is a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> true

			it 'should call update', ->
				sut.requestComplete({ url: 'test' })
				sut.update.should.have.been.called

		describe 'when there isnt a match', ->

			beforeEach ->
				sinon.stub sut, 'matchCall', -> false

			it 'should not call update', ->
				sut.requestComplete({ url: 'test' })
				sut.update.should.not.have.been.called

	describe 'update', ->

		beforeEach ->
			sut.configuration =
				progress: sinon.stub()
			sut.tracking =
				totalRequests: 0
				completedRequests: 0
			sinon.stub sut, 'done'

		describe 'when the tracking is not complete', ->

			beforeEach ->
				sut.tracking.totalRequests = 2

			it 'should call progress with the correct value', ->
				sut.update()
				sut.configuration.progress.should.have.been.calledWith 50

			it 'should not call done', ->
				sut.update()
				sut.done.should.not.have.been.called

		describe 'when the tracking is  complete', ->

			beforeEach ->
				sut.tracking.totalRequests = 1

			it 'should call progress with the correct value', ->
				sut.update()
				sut.configuration.progress.should.have.been.calledWith 100

			it 'should call done', ->
				sut.update()
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

