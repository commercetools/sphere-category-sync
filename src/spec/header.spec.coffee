_ = require('underscore')._
Header = require '../lib/header'
Validator = require '../lib/validator'
CONS = require '../lib/constants'

describe 'Header', ->
  beforeEach ->
    @validator = new Validator()

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new Header()).toBeDefined()

    it 'should initialize rawHeader', ->
      header = new Header ['name']
      expect(header.rawHeader).toEqual ['name']

  describe '#validate', ->
    it 'should return error for missing root header', (done) ->
      csv =
        """
        foo,bar
        """
      @validator.parse csv
      .fail (err) ->
        expect(err.length).toBe 1
        expect(err[0]).toBe "Can't find necessary base header 'root'!"
        done()
      .then (result) ->
        done(_.prettify result)
      .done()

    it 'should return error on duplicate header', (done) ->
      csv =
        """
        name,root,name
        """
      @validator.parse csv
      .fail (err) ->
        expect(err.length).toBe 1
        expect(err[0]).toBe "There are duplicate header entries!"
        done()
      .then (result) ->
        done(_.prettify result)
      .done()

    it 'should set rootIndex',(done) ->
      csv =
        """
        slug,description,root
        """
      @validator.parse csv
      .then ([header]) ->
        expect(header.rootIndex).toBe 2
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should set root language to default',(done) ->
      csv =
        """
        root
        """
      @validator.parse csv
      .then ([header]) ->
        expect(header.rootLanguages).toEqual ['en']
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should set root language to single language',(done) ->
      csv =
        """
        root.it
        """
      @validator.parse csv
      .then ([header]) ->
        expect(header.rootLanguages).toEqual ['it']
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should set root language for multiple languages',(done) ->
      csv =
        """
        root.de;it;en
        """
      @validator.parse csv
      .then ([header]) ->
        expect(header.rootLanguages).toEqual ['de', 'it', 'en']
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should return error on wrong root header', (done) ->
      csv =
        """
        root.de.es
        """
      @validator.parse csv
      .fail (err) ->
        expect(err.length).toBe 1
        expect(err[0]).toBe "Can't parse root header 'root.de.es'."
        done()
      .then (result) ->
        done(_.prettify result)
      .done()

  describe '#toIndex', ->
    it 'should create mapping', (done) ->
      csv =
        """
        slug,description,root
        """
      @validator.parse csv
      .then ([header]) ->
        h2i = header.toIndex()
        expect(_.size h2i).toBe 3
        expect(h2i['slug']).toBe 0
        expect(h2i['description']).toBe 1
        expect(h2i['root']).toBe 2
        
        expect(header.toIndex('slug')).toBe 0
        expect(header.toIndex('description')).toBe 1
        expect(header.toIndex('root')).toBe 2
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should return undefined for unkown header', ->
      expect(new Header().toIndex('foo')).toBeUndefined()

  describe '#has', ->
    it 'should return true of header is present', (done) ->
      csv =
        """
        slug,description,root
        """
      @validator.parse csv
      .then ([header]) ->
        expect(header.has('slug')).toBe true
        expect(header.has('description')).toBe true
        expect(header.has('root')).toBe true
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()
    
    it 'should return false if header is not present', ->
      expect(new Header().has('foo')).toBe false

  describe '#toRow', ->
    it 'should map base attributes', (done) ->
      csv =
        """
        id,externalId,createdAt,lastModifiedAt,orderHint,root
        """
      cat =
        id: '123'
        externalId: 'xyz'
        orderHint: '0.5'
        lastModifiedAt: '2014-08-04T22:22:22.123Z'
        createdAt: '2000-01-01T01:01:01.000Z'
        name:
          en: 'myCat'

      @validator.parse csv
      .then ([header]) ->
        expect(header.toRow(cat)).toEqual [
          '123', 'xyz', '2000-01-01T01:01:01.000Z', '2014-08-04T22:22:22.123Z', '0.5', 'myCat'
        ]
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

    it 'should map language attributes', (done) ->
      csv =
        """
        id,slug.de,description.de,slug.en,description.en,root.en;de
        """
      cat =
        id: '123'
        name:
          en: 'myCat'
          de: 'Kategorie'
        slug:
          en: 'my-cat'
          de: 'kategorie'
        description:
          en: 'foo bar'
          de: 'Bla bla'

      @validator.parse csv
      .then ([header]) ->
        expect(header.toRow(cat, 2)).toEqual [
          '123', 'kategorie', 'Bla bla', 'my-cat', 'foo bar', undefined, undefined, 'myCat;Kategorie'
        ]
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()

  describe '#_createLanguageIndex', ->
    it 'should create mapping for language attributes', (done) ->
      csv =
        """
        foo,slug.de,bar,slug.it,root
        """
      @validator.parse csv
      .then ([header]) ->
        langH2i = header._createLanguageIndex(['slug'])
        expect(_.size langH2i).toBe 1
        expect(_.size langH2i['slug']).toBe 2
        expect(langH2i['slug']['de']).toBe 1
        expect(langH2i['slug']['it']).toBe 3
        expect(header.hasLanguageFor 'foo').toBe false
        expect(header.hasLanguageFor 'bar').toBe false
        expect(header.hasLanguageFor 'slug').toBe true
        expect(header.toLanguageIndex 'slug').toEqual { de: 1, it: 3 }
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()
