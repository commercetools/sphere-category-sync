_ = require 'underscore'
Header = require '../../lib/csv/header'

describe 'Header', ->

  describe '#constructor', ->
    it 'should initialize', ->
      expect(-> new Header()).toBeDefined()

  describe '#validate', ->
    it 'should complain about duplicate header entries', ->
      h = new Header [ 'same', 'same' ]
      errors = h.validate()
      expect(_.size errors).toBe 1
      expect(errors[0]).toBe 'There are duplicate header entries!'

    it 'should call handleHeader for each header', ->
      h = new Header [ 'id' ]
      spyOn(h, 'handleHeader')
      h.validate()
      expect(h.handleHeader.callCount).toBe 1
      expect(h.handleHeader).toHaveBeenCalledWith 'id', 0

    it 'should call handleLanguageHeader for localized header', ->
      h = new Header [ 'name.de' ]
      spyOn(h, 'handleLanguageHeader')
      h.validate()
      expect(h.handleLanguageHeader.callCount).toBe 1
      expect(h.handleLanguageHeader).toHaveBeenCalledWith 'name.de', 'name', 'de', 0
