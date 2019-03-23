_ = require 'underscore'
path = require 'path'
Importer = require '../../lib/csv/importer'
loggerUtils = require '../utils/logger'
Config = require '../../config'

getAllRootCategories = (apiClient) ->
  apiClient.categories
    .where('parent is not defined')
    .all()
    .fetch()
    .then (result) ->
      result.body.results

importType = (apiClient, newType) ->
  apiClient.types
    .where("key=#{JSON.stringify(newType.key)}")
    .all()
    .fetch()
    .then (res) ->
      res.body.results
    .map (type) ->
      apiClient.types.byId(type.id).delete(type.version)
    .then () ->
      apiClient.types.create(newType)
    .then (res) ->
      res.body

cleanup = (logger, apiClient) ->
  getAllRootCategories(apiClient)
    .tap (categories) ->
      logger.info "Cleaning categories: #{_.size categories}"
    .map (category) ->
      apiClient.categories
        .byId(category.id)
        .delete(category.version)

describe 'Importer', ->
  logger = loggerUtils.logger
  importer = new Importer logger, Config
  api = importer.apiClient.client

  beforeEach (done) =>
    customTypeSchema = require('../../data/customTypeSchema')

    cleanup(logger, api)
      .then ->
        importType(api, customTypeSchema)
      .then -> done()
      .catch (err) -> done(_.prettify err)

  it 'should import simple category', (done) =>
    testFilePath = path.join(__dirname, '../../data/exportSimple.csv')
    importer.run(testFilePath)
      .then () =>
        # validate result
        api.categories.fetch()
      .then (res) ->
        res.body.results
      .then (importedCategories) ->
        expect(importedCategories).toBeDefined()
        expect(importedCategories.length).toBe(1)
        expect(importedCategories[0]).toEqual(jasmine.objectContaining({
          key: 'categoryKeys',
          name: { en: 'categoryName' },
          slug: { en: 'category-en-slug' },
          externalId: 'categoryExternalId',
        }))

        done()
      .catch (err) ->
        done(err)

  it 'should import category with custom fields', (done) =>
    testFilePath = path.join(__dirname, '../../data/exportWithCustomFields.csv')

    importer.run(testFilePath)
      .then () =>
        # validate result
        api.categories.fetch()
      .then (res) ->
        res.body.results
      .then (importedCategories) ->
        expect(importedCategories).toBeDefined()
        expect(importedCategories.length).toBe(1)
        expect(importedCategories[0].custom).toBeDefined()
        expect(importedCategories[0].custom.fields).toBeDefined()
        expect(importedCategories[0].custom.fields).toEqual(jasmine.objectContaining({
          number: 123,
          moneyAttr: {
            fractionDigits: 2,
            centAmount: 1234,
            currencyCode: 'EUR',
            type: 'centPrecision'
          },
          lenumAttr: 'lenumKey1',
          setOfString: ['setOfStringVal1', 'setOfStringVal2'],
          setOfLtext: [{
            de: 'setLtextDe1',
            en: 'setLtextEn1'
          }, {
            de: 'setLtextDe2',
            en: 'setLtextEn2'
          }],
          SetOfLenum: ['setOflenumKey1', 'setOflenumKey2'],
          stringAttr: 'string value',
          SetOfEnum: ['setOfEnumKey1', 'setOfEnumKey2'],
          booleanAttr: true,
          setOfNumber: [1, 2, 3],
          enumAttr: 'enumKey1',
          ltextAttr: {
            de: 'De value',
            en: 'En value'
          }
        }))
        done()
      .catch (err) ->
        done(err)

  it 'should throw an error when importing custom fields without custom type', (done) =>
    testFilePath = path.join(__dirname, '../../data/invalidCsvWithMissingCustomType.csv')

    importer.run(testFilePath)
      .then () ->
        done('Should throw an error with missing customType property.')
      .catch (err) ->
        expect(err.toString()).toContain('Custom fields were provided without customType property.')
        done()
