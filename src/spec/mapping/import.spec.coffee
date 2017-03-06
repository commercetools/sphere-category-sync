_ = require 'underscore'
ImportMapping = require '../../lib/csvMapping/import'

describe 'ImportMapping', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ImportMapping()).toBeDefined()

  describe '#validate', ->
    it 'should map a simple entry', ->
      im = new ImportMapping [ 'id' ]
      im.validate()
      json = im.map
        id: 'foo'
      expect(json).toEqual
        id: 'foo'

    it 'should map parentId entry', ->
      im = new ImportMapping [ 'parentId' ]
      im.validate()
      json = im.map
        parentId: 'root'
      expect(json).toEqual
        parent:
          id: 'root'

    it 'should not map empty parentId entry', ->
      im = new ImportMapping [ 'parentId' ]
      im.validate()
      json = im.map
        parentId: ''
      expect(json).toEqual {}

    it 'should map a localized entry', ->
      im = new ImportMapping [ 'slug.it' ]
      im.validate()
      json = im.map
        'slug.it': 'ciao'
      expect(json).toEqual
        slug:
          it: 'ciao'