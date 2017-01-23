fs = require 'fs'
CategorySort = require '../../lib/csv/categorysort'
{ExtendedLogger} = require 'sphere-node-utils'

tempFile = '/tmp/categories.csv'
resultFile = '/tmp/categories.csv-sorted'

ddescribe 'CategorySort', ->
  beforeEach ->
    @logger = new ExtendedLogger()
    @sorter = new CategorySort(@logger)


  describe '#constructor', ->
    runTest = (input, output, sorter, done) ->
      fs.writeFileSync tempFile, input.join('\n')
      sorter.sort tempFile, resultFile
        .then () ->
          expect(fs.readFileSync(resultFile, 'utf-8')).toEqual output.join('\n')
          done()

    it 'should initialize', (done) ->
      expect(@sorter).toBeDefined()

    it 'should sort an empty file', (done) ->
      input = ['']
      runTest(input, input, @sorter, done)

    it 'should sort a file only with header', (done) ->
      input = ['id,parentId,externalId']
      runTest(input, input, @sorter, done)

    it 'should sort a file by externalId', (done) ->
      input = [
        'id,externalId,parentId',
        'c,3,1',
        'd,4,3',
        'a,1,',
        'b,2,1',
        'e,5,4',
        'e,6,'
      ]

      expected = [
        'id,externalId,parentId',
        'd,4,3',
        'a,1,',
        'b,2,1',
        'e,5,4',
        'e,6,',
        'c,3,1'
      ]

      runTest(input, expected, @sorter, done)

    it 'should sort a file with loops', (done) ->
      input = [
        'id,externalId,parentId',
        'c,3,1',
        'd,4,3',
        'a,1,',
        'b,2,1',
        'e,5,6',
        'f,6,5'
      ]

      expected = [
        'id,externalId,parentId',
        'a,1,',
        'b,2,1',
        'c,3,1',
        'd,4,3',
        'e,5,6',
        'f,6,5'
      ]

      runTest(input, expected, @sorter, done)

    it 'should sort a file with missing parents', (done) ->
      input = [
        'id,externalId,parentId',
        'c,3,4',
        'a,1,',
        'b,2,1',
      ]

      expected = [
        'id,externalId,parentId',
        'a,1,',
        'b,2,1',
        'c,3,4',
      ]

      runTest(input, expected, @sorter, done)

    it 'should sort a file by slug', (done) ->
      sorter = new CategorySort @logger,
        parentBy: 'slug'
        language: 'en'

      input = [
        'id,externalId,parentId,slug.en',
        'c,3,bbb,ccc',
        'b,2,aaa,bbb',
        'e,2,ddd,eee',
        'a,1,,aaa',
      ]

      expected = [
        'id,externalId,parentId,slug.en',
        'a,1,,aaa',
        'b,2,aaa,bbb',
        'c,3,bbb,ccc',
        'e,2,ddd,eee',
      ]

      runTest(input, expected, sorter, done)

    it 'should sort a file by id', (done) ->
      sorter = new CategorySort @logger,
        parentBy: 'id'

      input = [
        'id,externalId,parentId',
        'c,3,b',
        'a,1,',
        'b,2,a',
        'e,2,d',
      ]

      expected = [
        'id,externalId,parentId',
        'a,1,',
        'b,2,a',
        'c,3,b',
        'e,2,d',
      ]

      runTest(input, expected, sorter, done)
