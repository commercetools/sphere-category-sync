_ = require 'underscore'
ImportMapping = require '../../lib/csv/importmapping'

describe 'ImportMapping', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ImportMapping()).toBeDefined()

  describe '#validate', ->
    it 'should map a simple entry', ->
      im = new ImportMapping [ 'id' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        id: 'foo'
      expect(json).toEqual
        id: 'foo'

    it 'should map parentId entry', ->
      im = new ImportMapping [ 'parentId' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        parentId: 'root'
      expect(json).toEqual
        parent:
          type: 'category'
          id: 'root'

    it 'should not map empty parentId entry', ->
      im = new ImportMapping [ 'parentId' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        parentId: ''
      expect(json).toEqual {}

    it 'should map a localized entry', ->
      im = new ImportMapping [ 'slug.it' ]
      im.validate()
      expect(_.size im.index2JsonFn).toBe 1
      expect(_.isFunction(im.index2JsonFn[0])).toBe true
      json = im.toJSON
        'slug.it': 'ciao'
      expect(json).toEqual
        slug:
          it: 'ciao'