_ = require 'underscore'
Header = require '../../lib/csvMapping/header'

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

    it 'should complain about whitespaces in headers', ->
      h = new Header [ 'trailing ', ' prefix', 'fine in the middle' ]
      errors = h.validate()
      expect(_.size errors).toBe 2
      expect(errors[0]).toBe "Header 'trailing ' contains a padding whitespace!"
      expect(errors[1]).toBe "Header ' prefix' contains a padding whitespace!"
