_ = require 'underscore'
ApiClient = require '../lib/apiclient'
Promise = require 'bluebird'
{ExtendedLogger} = require 'sphere-node-utils'

describe 'ApiClient', ->
  beforeEach ->
    options =
      config:
        project_key: 'p'
        client_id: 'i'
        client_secret: 's'
    @logger = new ExtendedLogger
    @apiClient = new ApiClient @logger, options

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

  describe '#update', ->
    it 'should POST an category update', ->
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.resolve( { statusCode: 200 } )
      @apiClient.update { name: 'myCat' }, {}, [], { sourceInfo: 'row 7' }
      expect(@apiClient.client.categories.update).toHaveBeenCalled()

    it 'should resolve without differences', (done) ->
      @apiClient.dryRun = true
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.resolve()
      @apiClient.update { name: 'myCat' }, { id: '123', name: 'myCat' }
      .then (res) ->
        expect(res).toMatch /nothing to update./
        done()
      .catch (err) ->
        done("Failed dryRun update:\n#{_.prettify err}")

    it 'should resolve on dryRun with differences', (done) ->
      @apiClient.dryRun = true
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.resolve()
      @apiClient.update { name: 'myCat' }, { id: '123', name: 'otherCat' }
      .then (res) ->
        expect(res).toMatch /DRY-RUN - updates for category with id '123':/
        done()
      .catch (err) ->
        done("Failed dryRun update:\n#{_.prettify err}")

    it 'should reject on update errors', (done) ->
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.reject( { statusCode: 500 })
      @apiClient.update { name: 'myCat' }, { id: '123', name: 'otherCat' }
      .then (res) ->
        done(res)
      .catch (err) ->
        expect(err).toMatch /Error on updating category:/
        done()

    it 'should reject on update problems', (done) ->
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.reject( { statusCode: 400 })
      @apiClient.update { name: 'myCat' }, { id: '123', name: 'otherCat' }
      .then (res) ->
        done(res)
      .catch (err) ->
        expect(err).toMatch /Problem on updating category:/
        done()

    it 'should resolve with continueOnProblems on update problems', (done) ->
      @apiClient.continueOnProblems = true
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.reject( { statusCode: 400 })
      @apiClient.update { name: 'myCat' }, { id: '123', name: 'otherCat' }
      .then (res) ->
        expect(res).toMatch /ignored!/
        done()
      .catch (err) ->
        done(err)

    it 'should filter action', (done) ->
      spyOn(@apiClient.client.categories, 'update').andCallFake -> Promise.resolve( { statusCode: 200 })
      @apiClient.update { name: 'myCat' }, { name: 'otherCat', orderHint: '0.1', version: 1 }, [ 'changeOrderHint' ]
      .then (res) =>
        expect(@apiClient.client.categories.update).toHaveBeenCalledWith { actions: [ { action: 'changeName', name: 'myCat' } ], version: 1 }
        done()
      .catch (err) ->
        done(err)


  describe '#delete', ->
    it 'should DELETE a category', ->
      spyOn(@apiClient.client.categories, 'delete').andCallFake -> Promise.resolve()
      @apiClient.delete { id: 'abc', version: 3 }, { sourceInfo: 'row 7' }
      expect(@apiClient.client.categories.delete).toHaveBeenCalled()

    it 'should reject promise on deletion problems', (done) ->
      spyOn(@apiClient.client.categories, 'delete').andCallFake ->
        new Promise (resolve, reject) -> reject({statusCode: 400})
      @apiClient.delete({ id: 'abc', version: 3 }, { sourceInfo: 'none' })
      .then (res) ->
        done("deletion should end in problem, but: #{res}")
      .catch (err) ->
        expect(err).toMatch /Error on deleting category/
        done()