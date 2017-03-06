_ = require 'underscore'
ExportMapping = require '../../lib/csvMapping/out'

describe 'ExportMapping', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new ExportMapping()).toBeDefined()

  describe '#validate', ->
    it 'should map a simple entry', ->
      ex = new ExportMapping [ 'id' ]
      ex.validate()
      json = ex.map
        id: 'foo'
      expect(json).toEqual [ 'foo' ]

    it 'should map parentId entry', ->
      ex = new ExportMapping [ 'parentId' ]
      ex.validate()
      json = ex.map
        parent:
          type: 'category'
          id: 'root'
      expect(json).toEqual [ 'root' ]

    it 'should not map empty parentId entry', ->
      ex = new ExportMapping [ 'parentId' ]
      ex.validate()
      json = ex.map
        id: 123
      expect(json).toEqual [ '' ]

    it 'should map a localized entry', ->
      ex = new ExportMapping [ 'slug.it', 'name.de' ]
      ex.validate()
      json = ex.map
        slug:
          it: 'ciao'
          en: 'hi'
        name:
          en: 'hello'
          de: 'Hallo'
      expect(json).toEqual [ 'ciao', 'Hallo' ]

    it 'should support region subtags', ->
      ex = new ExportMapping [ 'slug.nl', 'name.nl-BE' ]
      ex.validate()
      json = ex.map
        slug:
          'en-US': 'ciao'
          'nl': 'slak'
        name:
          'nl-BE': 'alee'
          'de': 'hallo'
      expect(json).toEqual [ 'slak', 'alee' ]

    it 'should not map an empty localized entry', ->
      ex = new ExportMapping [ 'slug.de', 'name.it', 'slug', 'name' ],
        language: 'fr'

      ex.validate()
      json = ex.map
        slug:
          it: 'ciao'
          en: 'hi'
        name:
          en: 'hello'
          de: 'Hallo'
      expect(json).toEqual [ undefined, undefined, '', '' ]

    it 'should map to undefined for any unknown header', ->
      ex = new ExportMapping [ 'foo.en', 'bar' ]
      ex.validate()
      json = ex.map {}
      expect(json).toEqual [ undefined, undefined ]

    it 'should map externalId into parentId if requested', ->
      ex = new ExportMapping [ 'parentId' ], parentBy: 'externalId'
      ex.validate()
      json = ex.map
        id: 'i1'
        externalId: 'e1'
        parent:
          type: 'category'
          id: 'i2'
          obj:
            id: 'i2'
            externalId: 'e2'
      expect(json).toEqual [ 'e2' ]

    it 'should map slug into parentId if requested', ->
      ex = new ExportMapping [ 'parentId' ], { language: 'en', parentBy: 'slug' }
      ex.validate()
      json = ex.map
        id: 'i3'
        externalId: 'e3'
        parent:
          type: 'category'
          id: 'i4'
          obj:
            id: 'i4'
            externalId: 'e4'
            slug:
              en: 'slug-4'
      expect(json).toEqual [ 'slug-4' ]
