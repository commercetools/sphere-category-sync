_ = require 'underscore'
ApiClient = require '../lib/apiclient'
Promise = require 'bluebird'

describe 'ApiClient', ->
  beforeEach ->
    options =
      config:
        project_key: 'p'
        client_id: 'i'
        client_secret: 's'
    @apiClient = new ApiClient null, options

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ApiClient()).toBeDefined()
      expect(@apiClient).toBeDefined()

  describe '#create', ->
    it 'should POST a new category', ->
      spyOn(@apiClient.client.categories, 'create').andCallFake -> Promise.resolve()
      @apiClient.create { name: 'myCat' }, { sourceInfo: 'row 7' }
      expect(@apiClient.client.categories.create).toHaveBeenCalled()

    it 'should do nothing when in dryRun mode', (done) ->
      @apiClient.dryRun = true
      @apiClient.create(
        { name: 'myCat' }
        { sourceInfo: 'row 7' }
      ).then (res) ->
        expect(res).toBe '[row 7] DRY-RUN - create new category.'
        done()

    it 'should do nothing when in updateOnly mode', (done) ->
      @apiClient.updatesOnly = true
      @apiClient.create(
        { name: 'myCat' }
        { sourceInfo: 'line 18' }
      ).then (res) ->
        expect(res).toBe '[line 18] UPDATES ONLY - nothing done.'
        done()

    it 'should reject promise on problems', (done) ->
      spyOn(@apiClient.client.categories, 'create').andCallFake ->
        new Promise (resolve, reject) -> reject({statusCode: 500})
      @apiClient.create({ name: 'myCat' }, { sourceInfo: 'row 7' })
      .then (r) ->
        done("creation should end in error, but: #{res}")
      .catch (err) ->
        expect(err).toMatch /Error on creating new category/
        done()

    it 'should reject promise on data problems', (done) ->
      spyOn(@apiClient.client.categories, 'create').andCallFake ->
        new Promise (resolve, reject) -> reject({statusCode: 400})
      @apiClient.create({ name: 'myCat' }, { sourceInfo: 'row 7' })
      .then (res) ->
        done("creation should end in problem, but: #{res}")
      .catch (err) ->
        expect(err).toMatch /Problem on creating new category/
        done()

    it 'should resolve promise on data problems in continueOnProblems mode', (done) ->
      @apiClient.continueOnProblems = true
      spyOn(@apiClient.client.categories, 'create').andCallFake ->
        new Promise (resolve, reject) -> reject({statusCode: 400})
      @apiClient.create({ name: 'myCat' }, { sourceInfo: 'row 7' })
      .then (res) ->
        expect(res).toMatch /ignored!/
        done()
      .catch (err) ->
        done(err)