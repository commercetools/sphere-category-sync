_ = require 'underscore'
Streaming = require '../../lib/streaming'
{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../../package.json'
Config = require '../../config'
Promise = require 'bluebird'

mockCategories = [
  {
    externalId: 'a',
    slug: { en: 'category-a' },
    name: { en: 'categoryA' },
    description: { en: 'descA' }
  },
  {
    externalId: 'a.a',
    slug: { en: 'category-a-a' },
    name: { en: 'categoryAA' },
    description: { en: 'descAA' }
    parent: { id: 'a22d6d8f-8d72-4806-bce0-d3bcf60aae60' }
  }
]


cleanup = (logger, apiClient) ->
  apiClient.client.categories.where('parent is not defined').all().fetch()
  .then (result) ->
    logger.info "Cleaning categories: #{_.size result.body.results}"
    Promise.all _.map result.body.results, (cat) ->
      apiClient.delete cat

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
      parentBy: 'externalId'
    cleanup(@logger, @streaming.apiClient)
    .then -> done()
    .catch (err) -> done(_.prettify err)

  describe '#constructor', ->
    it 'should initialize', (done) ->
      expect(-> new Streaming()).toBeDefined()
      expect(@streaming).toBeDefined()
      done()

  describe '#processStream', ->
    it 'should create one new category', (done) ->
      chunk = [
        { name: { en: 'myCat1' }, slug: { en: 'my-cat-1' }}
      ]
      @streaming.processStream chunk, =>
        expect(@streaming.summaryReport()).toEqual 'Summary: there were 1 imported categories (1 were new and 0 were updates)'
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
        @streaming.processStream chunk, =>
          expect(@streaming.summaryReport()).toEqual 'Summary: there were 2 imported categories (2 were new and 0 were updates)'
          done()

    it 'should create a tree of categories', (done) ->
      chunk = [
        { externalId: 'root', name: { en: 'root' }, slug: { en: 'root' }},
      ]
      @streaming.processStream chunk, =>
        chunk = [
          { externalId: 'l1', name: { en: 'level1' }, slug: { en: 'l-1' }, parent: { id: 'root' }}
        ]
        @streaming.processStream chunk, =>
          expect(@streaming.summaryReport()).toEqual 'Summary: there were 2 imported categories (2 were new and 0 were updates)'
          done()

  describe '#streaming', ->
    it 'should import new category', (done) ->
      newCategory = {
        externalId: 'a',
        slug: { en: 'slug' },
        name: { en: 'name' },
        description: { en: 'desc' }
      }

      @streaming.processStream [newCategory], =>
        @streaming.apiClient.client.categories
        .all()
        .fetch()
        .then (res) ->
          list = res.body.results
          expect(list.length).toBe 1

          category = list[0]
          expect(category.name).toEqual newCategory.name
          expect(category.slug).toEqual newCategory.slug
          expect(category.description).toEqual newCategory.description
          expect(category.externalId).toEqual newCategory.externalId
          done()

    it 'should update category', (done) ->
      newCategory = {
        externalId: 'a',
        slug: { en: 'slug' },
        name: { en: 'name' },
        description: { en: 'desc' }
      }
      updatedCategory = {
        externalId: 'a',
        slug: { en: 'slugUpdated' },
        orderHint: '0.2937'
      }

      @streaming.processStream [newCategory], =>
        @streaming.processStream [updatedCategory], =>

          @streaming.apiClient.client.categories
          .all()
          .fetch()
          .then (res) ->
            list = res.body.results
            expect(list.length).toBe 1

            category = list[0]
            expect(category.name).toEqual newCategory.name
            expect(category.description).toEqual newCategory.description
            expect(category.externalId).toEqual newCategory.externalId

            expect(category.slug).toEqual updatedCategory.slug
            expect(category.orderHint).toEqual updatedCategory.orderHint
            done()

    it 'should import category tree with slug as a parentBy param', (done) ->
      categories = JSON.parse(JSON.stringify(mockCategories))
      categories[1].parent.id = 'category-a'

      @streaming.matcher.parentBy = 'slug'
      @streaming.matcher.language = 'en'

      @streaming.apiClient.client.categories
      .create(categories[0])
      .then =>
        @streaming.processStream [categories[1]], =>
          expect(@streaming._summary.created).toBe 1

          @streaming.apiClient.client.categories
            .all()
            .fetch()
            .then (res) ->
              list = res.body.results
              expect(list.length).toBe 2

              categoryA = list.find (cat) -> cat.externalId is 'a'
              categoryAA = list.find (cat) -> cat.externalId is 'a.a'
              expect(categoryAA.parent.id).toBe categoryA.id
              done()

    it 'should import category tree with id as a parentBy param', (done) ->
      categories = JSON.parse(JSON.stringify(mockCategories))

      @streaming.matcher.parentBy = 'id'
      @streaming.apiClient.client.categories
        .create(categories[0])
        .then (res) =>
          categories[1].parent.id = res.body.id

          @streaming.processStream [categories[1]], =>
            expect(@streaming._summary.created).toBe 1
            @streaming.apiClient.client.categories
              .all()
              .fetch()
              .then (res) ->
                list = res.body.results
                expect(list.length).toBe 2

                categoryA = list.find (cat) -> cat.externalId is 'a'
                categoryAA = list.find (cat) -> cat.externalId is 'a.a'
                expect(categoryAA.parent.id).toBe categoryA.id
                done()

    it 'should return an error when category parent was not resolved', (done) ->
      categories = JSON.parse(JSON.stringify(mockCategories))

      @streaming.matcher.parentBy = 'id'
      @streaming.processStream categories, ->
        done('Should log an error about an unresolved parent category')
      .catch (err) ->
        expect(err).toContain("Problem on resolving parent for '#{categories[1].parent.id}'")
        done()
