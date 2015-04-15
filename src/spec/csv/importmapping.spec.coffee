_ = require 'underscore'
ImportMapping = require '../../lib/csv/importmapping'

describe 'ImportMapping', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ImportMapping()).toBeDefined()

  describe '#validate', ->
    it 'should add a function for normal simple header entry', ->
      im = new ImportMapping [ 'id' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        id: 'foo'
      expect(json).toEqual
        id: 'foo'

    it 'should add a function for localized header entry', ->
      im = new ImportMapping [ 'slug.it' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        'slug.it': 'ciao'
      expect(json).toEqual
        slug:
          it: 'ciao'