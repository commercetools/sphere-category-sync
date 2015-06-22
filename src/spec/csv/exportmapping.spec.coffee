_ = require 'underscore'
ExportMapping = require '../../lib/csv/exportmapping'

describe 'ExportMapping', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ExportMapping()).toBeDefined()

  describe '#validate', ->
    it 'should map a simple entry', ->
      ex = new ExportMapping [ 'id' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 1
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      json = ex.toCSV
        id: 'foo'
      expect(json).toEqual [ 'foo' ]

    it 'should map parentId entry', ->
      ex = new ExportMapping [ 'parentId' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 1
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      json = ex.toCSV
        parent:
          type: 'category'
          id: 'root'
      expect(json).toEqual [ 'root' ]

    it 'should not map empty parentId entry', ->
      ex = new ExportMapping [ 'parentId' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 1
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      json = ex.toCSV
        id: 123
      expect(json).toEqual [ '' ]

    it 'should map a localized entry', ->
      ex = new ExportMapping [ 'slug.it', 'name.de' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 2
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      expect(_.isFunction(ex.index2CsvFn[1])).toBe true
      json = ex.toCSV
        slug:
          it: 'ciao'
          en: 'hi'
        name:
          en: 'hello'
          de: 'Hallo'
      expect(json).toEqual [ 'ciao', 'Hallo' ]

    it 'should not map an empty localized entry', ->
      ex = new ExportMapping [ 'slug.de', 'name.it' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 2
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      expect(_.isFunction(ex.index2CsvFn[1])).toBe true
      json = ex.toCSV
        slug:
          it: 'ciao'
          en: 'hi'
        name:
          en: 'hello'
          de: 'Hallo'
      expect(json).toEqual [ '', '' ]

    it 'should map to undefined for any unknown header', ->
      ex = new ExportMapping [ 'foo.en', 'bar' ]
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 2
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      expect(_.isFunction(ex.index2CsvFn[1])).toBe true
      json = ex.toCSV {}
      expect(json).toEqual [ undefined, undefined ]

    it 'should map externalId into parentId if requested', ->
      ex = new ExportMapping [ 'parentId' ], parentBy: 'externalId'
      ex.validate()
      expect(_.size ex.index2CsvFn).toBe 1
      expect(_.isFunction(ex.index2CsvFn[0])).toBe true
      json = ex.toCSV
        id: 'i1'
        externalId: 'e1'
        parent:
          type: 'category'
          id: 'i2'
          obj:
            id: 'i2'
            externalId: 'e2'
      expect(json).toEqual [ 'e2' ]

