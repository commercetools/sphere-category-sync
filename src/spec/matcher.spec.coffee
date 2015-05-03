_ = require 'underscore'
Matcher = require '../lib/matcher'
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'

describe 'ApiClient', ->
  beforeEach ->
    @logger = new ExtendedLogger()
    @matcher = new Matcher(@logger)

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new Matcher()).toBeDefined()
      expect(@matcher).toBeDefined()

  describe '#match', ->
    it 'should not find a match without initialize/add', (done) ->
      @matcher.match({})
      .then (result) ->
        expect(result).toBeUndefined()
        done()
      .catch (err) ->
        done err

    it 'should find a match after initialize', (done) ->
      apiClient =
        getByExternalIds: ->
          new Promise (resolve, reject) ->
            console.log "HAJO"
            res =
              body:
                results: [
                  { externalId: 'ex123', id: 'i123' }
                ]
            resolve res
      matcher = new Matcher(@logger, apiClient)
      category =
        externalId: 'ex123'
      matcher.initialize [ category ]
      .then ->
        matcher.match(category)
        .then (result) ->
          expect(result).toBeDefined()
          expect(result.id).toBe 'i123'
          done()
      .catch (err) ->
        done err
