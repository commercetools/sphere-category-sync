_ = require('underscore')._
Validator = require '../lib/validator'
Header = require '../lib/header'
CONS =  require '../lib/constants'

describe 'Validator', ->
  beforeEach ->
    @validator = new Validator()

  describe '@constructor', ->
    it 'should initialize', ->
      expect(@validator).toBeDefined()

  describe '#parse', ->
    it 'should return header and content', (done) ->
      csv =
        """
        root
        row1
        """
      @validator.parse(csv)
      .then ([header, content]) ->
        expect(header).toBeDefined
        expect(header.rawHeader).toEqual ['root']
        expect(content).toBeDefined
        expect(content).toEqual [['row1']]
        done()
      .fail (err) ->
        done(_.prettify err)
      .done()
