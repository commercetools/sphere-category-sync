_ = require 'underscore'
fs = require 'fs'
path = require 'path'
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

    it 'should map custom fields', ->
      csvRowObject = require('../data/csvRowObjectWithCustomType')

      im = new ImportMapping Object.keys(csvRowObject)
      im.validate()

      json = im.toJSON csvRowObject
      expect(json).toEqual {
        name: {
          en: 'categoryName'
        },
        key: 'categoryKeys',
        externalId: 'categoryExternalId',
        slug: {
          en: 'category-en-slug'
        },
        custom: {
          type: {
            typeId: 'type',
            id: 'bcb4f88a-bd42-4478-bf20-9a6ad4936e2e'
          },
          fields: {
            booleanAttr: true,
            stringAttr: 'string value',
            ltextAttr: {
              en: 'En value',
              de: 'De value'
            },
            moneyAttr: {
              currencyCode: 'EUR',
              centAmount: 1234,
              fractionDigits: 2,
              type: 'centPrecision'
            },
            enumAttr: 'enumKey1',
            lenumAttr: 'lenumKey1',
            setOfString: ['setOfStringVal1', 'setOfStringVal2'],
            setOfLtext: [{
              en: 'setLtextEn1',
              de: 'setLtextDe1'
            }, {
              en: 'setLtextEn2',
              de: 'setLtextDe2'
            }],
            number: 123,
            setOfNumber: [1, 2, 3],
            SetOfEnum: ['setOfEnumKey1', 'setOfEnumKey2'],
            SetOfLenum: ['setOflenumKey1', 'setOflenumKey2']
          }
        }
      }
