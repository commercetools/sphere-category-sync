_ = require 'underscore'
Matcher = require '../lib/matcher'
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'

describe 'Matcher', ->
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

  describe '#resolveParent', ->
    it 'should not resolve parent when no parentId given', (done) ->
      @matcher.resolveParent { }
      .then (result) ->
        expect(result.parent).toBeUndefined()
        done()
      .catch (err) ->
        done err

    it 'should not resolve parent for unkown parentId', (done) ->
      @matcher.resolveParent { parent: { id: 'externalId123' } }
      .then (result) ->
        done 'Should not resolve if parentId not found'
      .catch (err) ->
        done()

    it 'should resolve parent when mapping added before', (done) ->
      @matcher.addMapping { externalId: 'ex77', id: 'id77'  }
      @matcher.resolveParent { parent: { id: 'ex77' } }
      .then (result) ->
        expect(result.parent.id).toBe 'id77'
        expect(result.parent.typeId).toBe 'category'
        done()
      .catch (err) ->
        done err
