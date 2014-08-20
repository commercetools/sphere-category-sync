_ = require 'underscore'
Exporter = require '../lib/exporter'

describe 'Export', ->
  beforeEach ->
    @exporter = new Exporter()

  describe '#constructor', ->
    it 'should initialize', ->
      expect(@exporter).toBeDefined()

  describe '#export', ->
    it 'should fail on validation errors', (done) ->
      @exporter.export 'foo,bar'
      .fail (err) ->
        done()
      .then (result) ->
        done result
      .done()

    it 'should export into file', (done) ->
      jasmine
      @exporter.client =
        categories:
          all: ->
            fetch: ->
              then: (f) ->
                result =
                  body:
                    total: 1
                    results: [
                      { name: { en: 'foo' } }
                    ]
                f.call(null, result)
      template =
        """
        root
        """
      @exporter.export template, '/tmp/category-sync.csv'
      .then (result) ->
        expect(result).toBe 'Export done.'
        done()
      .fail (err) ->
        done _.prettify err
      .done()
