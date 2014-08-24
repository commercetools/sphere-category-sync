_ = require 'underscore'
Import = require '../lib/importer'
Validator = require '../lib/validator'
CONS = require '../lib/constants'

describe 'Importer', ->
  beforeEach ->
    @validator = new Validator()
    @import = new Import({})

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new Import()).toBeDefined()
      expect(@import).toBeDefined()

  describe '#_createTree', ->
    it 'should import one root category', (done) ->
      csv = """
      root
      foo
      """
      @validator.parse(csv)
      .then ([header, content]) =>
        tree = @import._createTree(header, content)

        expect(tree.category).toBeUndefined()
        expect(_.size tree.subCategories).toBe 1
        expect(tree.subCategories[0].category.name).toBe 'foo'
        expect(tree.subCategories[0].category.slug).toBe 'foo'
        expect(tree.subCategories[0].subCategories).toEqual []

        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should handle a tree', (done) ->
      csv = """
      root
      foo
      ,foo1
      ,foo2
      ,foo3
      bar
      ,bar1
      ,,bar1-1
      """
      @validator.parse(csv)
      .then ([header, content]) =>
        tree = @import._createTree(header, content)

        expect(tree.category).toBeUndefined()
        expect(_.size tree.subCategories).toBe 2
        expect(tree.subCategories[0].category.name).toBe 'foo'
        expect(tree.subCategories[0].category.slug).toBe 'foo'
        expect(_.size tree.subCategories[0].subCategories).toBe 3
        expect(tree.subCategories[0].subCategories[0].category.name).toBe 'foo1'
        expect(tree.subCategories[0].subCategories[0].category.slug).toBe 'foo1'
        expect(tree.subCategories[0].subCategories[0].subCategories).toEqual []
        expect(tree.subCategories[0].subCategories[1].category.name).toBe 'foo2'
        expect(tree.subCategories[0].subCategories[1].category.slug).toBe 'foo2'
        expect(tree.subCategories[0].subCategories[1].subCategories).toEqual []
        expect(tree.subCategories[0].subCategories[2].category.name).toBe 'foo3'
        expect(tree.subCategories[0].subCategories[2].category.slug).toBe 'foo3'
        expect(tree.subCategories[0].subCategories[2].subCategories).toEqual []
        expect(tree.subCategories[1].category.name).toBe 'bar'
        expect(tree.subCategories[1].category.slug).toBe 'bar'
        expect(_.size tree.subCategories[1].subCategories).toBe 1
        expect(tree.subCategories[1].subCategories[0].category.name).toBe 'bar1'
        expect(tree.subCategories[1].subCategories[0].category.slug).toBe 'bar1'
        expect(_.size tree.subCategories[1].subCategories[0].subCategories).toBe 1
        expect(tree.subCategories[1].subCategories[0].subCategories[0].category.name).toBe 'bar1-1'
        expect(tree.subCategories[1].subCategories[0].subCategories[0].category.name).toBe 'bar1-1'
        expect(tree.subCategories[1].subCategories[0].subCategories[0].subCategories).toEqual []

        done()
      .fail (err) ->
        done(_.prettify err)
      .done()
