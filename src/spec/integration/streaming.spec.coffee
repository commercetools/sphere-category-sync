_ = require 'underscore'
Streaming = require '../../lib/streaming'
{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../../package.json'
Config = require '../../config'
Promise = require 'bluebird'

cleanup = (logger, apiClient) ->
  apiClient.client.categories.all().fetch()
  .then (result) ->
    logger.info "Cleaning categories: #{_.size result.body.results}"
    Promise.all _.map result.body.results, (cat) ->
      apiClient.delete cat
  .then (results) ->
    Promise.resolve()

describe 'Streaming', ->
  beforeEach (done) ->
    @logger = new ExtendedLogger
      additionalFields:
        project_key: Config.config.project_key
      logConfig:
        name: "#{package_json.name}-#{package_json.version}"
        streams: [
          { level: 'info', stream: process.stdout }
        ]
    @streaming = new Streaming @logger,
      config: Config.config
    cleanup(@logger, @streaming.apiClient)
    .then -> done()
    .catch (err) -> done(_.prettify err)

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new Streaming()).toBeDefined()
      expect(@streaming).toBeDefined()

  describe '#processStream', ->
    it 'should create one new category', (done) ->
      chunk = [
        { name: { en: 'myCat1' }, slug: { en: 'my-cat-1' }}
      ]
      @streaming.processStream chunk, ->
        done()

    it 'should update an existing category', (done) ->
      chunk = [
        { externalId: '21', name: { en: 'myCat2' }, slug: { en: 'my-cat-2' }},
        { externalId: '42', name: { en: 'myCat3' }, slug: { en: 'my-cat-3' }}
      ]
      @streaming.processStream chunk, =>
        chunk = [
          { externalId: '42', name: { en: 'myCatCHANGED' }, slug: { en: 'my-cat-3' }, orderHint: '0.1' }
        ]
        @streaming.processStream chunk, ->
          done()

    it 'should create a tree of categories', (done) ->
      chunk = [
        { externalId: 'root', name: { en: 'root' }, slug: { en: 'root' }},
      ]
      @streaming.processStream chunk, =>
        chunk = [
          { externalId: 'l1', name: { en: 'level1' }, slug: { en: 'l-1' }, parent: { id: 'root' }}
        ]
        @streaming.processStream chunk, ->
          done()