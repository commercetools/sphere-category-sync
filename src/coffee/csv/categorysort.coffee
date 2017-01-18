fs = require 'fs'
_ = require 'underscore'
str = require 'underscore.string'
cons = require './constants'
csv = require 'csv-parser'
csvStringify = require 'csv-stringify'

class CategorySort

  constructor: (@logger, @options = {}) ->
    @logger.debug 'Sort::init', {
      parentBy: @options.parentBy,
      language: @options.language
    }

  # will take externalId, id or slug.language (eg: slug.de) from csv row
  getRowId: (data) ->
    parentBy = @options.parentBy || cons.HEADER_EXTERNAL_ID

    # if parentBy is externalId or ID just return value from a row by headerIndex
    if cons.HEADER_SLUG == parentBy
      parentBy = cons.HEADER_SLUG + '.' + @options.language


    @getParentIdHeader data, parentBy

  getParentIdHeader: (data, colName=cons.HEADER_PARENT_ID) ->
    if not data[colName]
      throw new Error("CSV header does not have #{colName} column")
    colName

  sort: (fileIn, fileOut) ->
    new Promise (resolve, reject) =>
      outBuffer = []
      processed = {}
      insertPosition = 0
      parentId = undefined
      rowId = undefined
      fs.createReadStream(fileIn)
        .pipe(csv(strict:true))
        .on('data', (data) =>
          if not parentId
            parentId = @getParentIdHeader data, cons.HEADER_PARENT_ID
          if not rowId
            rowId = @getRowId data
          if data[parentId] and not processed[data[parentId]]
            outBuffer.push(data)
          else
            outBuffer.splice(insertPosition, 0, data)
            insertPosition++
          processed[data[rowId]] = true
        )
        .on('end', () ->
          keys = Object.keys(outBuffer[0])
          options =
            header: true
            eof: false
          csvStringify(outBuffer, options, (err, output) ->
            fs.writeFileSync(fileOut, output, 'utf-8')
            resolve()
          )
        )

module.exports = CategorySort
