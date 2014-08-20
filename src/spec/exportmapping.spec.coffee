_ = require 'underscore'
ExportMapping = require '../lib/exportmapping'
Header = require '../lib/header'
CONS = require '../lib/constants'

describe 'ExportMapping', ->
  beforeEach ->
    header = new Header([CONS.HEADER_ID, CONS.HEADER_ROOT])
    header.validate()
    @exportMapping = new ExportMapping header

  describe '#constructor', ->
    it 'should initialize', ->
      expect(@exportMapping).toBeDefined()

  describe '#mapCategories', ->
    it 'should map a single category', ->
      categories = [
        id: '123'
        name:
          en: 'foo'
      ]
      csv = @exportMapping.mapCategories categories
      expect(csv).toEqual [['123', 'foo']]

    it 'should map category with child', ->
      categories = [
        { id: '234', name: { en: 'bar' }, ancestors: [ { id: '123' } ] }
        { id: '123', name: { en: 'foo' }, ancestors: [] }
      ]
      csv = @exportMapping.mapCategories categories
      expect(csv).toEqual [
        ['123', 'foo']
        ['234', undefined, 'bar']
      ]

    it 'should map a category tree', ->
      categories = [
        { id: '11', name: { en: 'eleven' }, ancestors: [ { id: '1' } ] }
        { id: '12', name: { en: 'twelve' }, ancestors: [ { id: '1' } ] }
        { id: '122', name: { en: 'one-two-two' }, ancestors: [ { id: '1' }, { id: '12' } ] }
        { id: '1', name: { en: 'one' }, ancestors: [] }
        { id: '121', name: { en: 'one-two-one' }, ancestors: [ { id: '1' }, { id: '12' } ] }
        { id: '111', name: { en: 'one-one-one' }, ancestors: [ { id: '1' }, { id: '11' } ] }
      ]
      csv = @exportMapping.mapCategories categories
      expect(csv).toEqual [
        ['1', 'one']
        ['11', undefined, 'eleven']
        ['111', undefined, undefined, 'one-one-one']
        ['12', undefined, 'twelve']
        ['122', undefined, undefined, 'one-two-two']
        ['121', undefined, undefined, 'one-two-one']
      ]