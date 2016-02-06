describe 'truffle.pageload/events', ->

	sut = null

	beforeEach ->
		sut = new (require 'truffle.pageload/events')()

	it 'should establish a listeners property', ->
		expect(sut.listeners).to.exist

	describe 'trigger', ->

		args = null

		beforeEach ->
			args = { value: 1 }

		describe 'when there are no listeners', ->

			it 'should not fail', ->
				try
					sut.trigger('event', args)
				catch e
					expect(e).to.not.exist

		describe 'when there is one listener', ->

			callback = badCallback = null

			beforeEach ->
				callback = sinon.stub()
				badCallback = sinon.stub()
				sut.listeners['event'] = [ callback ]
				sut.listeners['bad'] = [ badCallback ]

			it 'should call that listener', ->
				sut.trigger('event', args)
				callback.should.have.been.calledWith args
				badCallback.should.not.have.been.called

		describe 'when there is more than one listener', ->

			callback = callback2 = badCallback = null

			beforeEach ->
				callback = sinon.stub()
				callback2 = sinon.stub()
				badCallback = sinon.stub()
				sut.listeners['event'] = [ callback, callback2 ]
				sut.listeners['bad'] = [ badCallback ]

			it 'should call all listeners', ->
				sut.trigger('event', args)
				callback.should.have.been.calledWith args
				callback2.should.have.been.calledWith args
				badCallback.should.not.have.been.called

	describe 'on', ->

		callback = null

		beforeEach ->
			callback = sinon.stub()
			sut.listeners['event'] = [ callback ]

		describe 'when the listener event name does not exist', ->

			it 'should attach a new listener', ->
				sut.on('newEvent', callback)
				sut.listeners['event'].length.should.equal 1
				sut.listeners['newEvent'].length.should.equal 1

		describe 'when the listener already exists', ->

			it 'should append the listener', ->
				sut.on('event', callback)
				sut.listeners['event'].length.should.equal 2

	describe 'off', ->

		callback = null

		beforeEach ->
			callback = sinon.stub()
			sut.listeners['event'] = [ callback ]

		describe 'when the listener event name does not exist', ->

			it 'should do nothing', ->
				sut.off('random')
				sut.listeners['event'].length.should.equal 1

		describe 'when the listener and callback exists', ->

			callback2 = null

			beforeEach ->
				callback2 = sinon.stub()
				sut.listeners['event'] = [ callback, callback2 ]

			it 'should remove just one callback the listener', ->
				sut.off('event', callback)
				sut.listeners['event'].length.should.equal 1
				sut.listeners['event'][0].should.equal callback2


