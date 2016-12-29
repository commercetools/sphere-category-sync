fs = require 'fs'
_ = require 'underscore'
str = require 'underscore.string'
cons = require './constants'

class CategorySort

  constructor: (@logger, @options = {}) ->
    @logger.debug 'Sort::init', {
      parentBy: @options.parentBy,
      language: @options.language
    }

  getValueByHeader: (row, header, colName) ->
    index = header.indexOf(colName)
    if index < 0
      throw new Error("CSV header does not have #{colName} column")
    str.trim(row[index], '"')

  # will take externalId, id or slug.language (eg: slug.de) from csv row
  getRowId: (row, header) ->
    parentBy = @options.parentBy || cons.HEADER_EXTERNAL_ID

    # if parentBy is externalId or ID just return value from a row by headerIndex
    if cons.HEADER_SLUG == parentBy
      parentBy = cons.HEADER_SLUG+'.'+@options.language

    @getValueByHeader(row, header, parentBy)

  parseRow: (row, header) ->
    parsed = row.split(',')
    {
      row: row,
      parentId: @getValueByHeader(parsed, header, cons.HEADER_PARENT_ID),
      rowId: @getRowId(parsed, header)
    }

  sort: (fileIn, fileOut) ->
    parentMap = {}
    processed = {}
    outBuffer = []
    dataToProcess = []

    rows = fs.readFileSync(fileIn, "utf-8").split "\n"

    outBuffer.push(rows.shift())
    header = outBuffer[0].split(',')

    # preprocess: parse id and parentIds
    rows.forEach (row) =>
      if row.length
        parsed = @parseRow(row, header)
        dataToProcess.push parsed
        parentMap[parsed.rowId] = parsed.parentId

    # fill missing parents
    dataToProcess.forEach (row) ->
      if row.parentId and not (row.parentId in parentMap)
        parentMap[row.parentId] = ''

    # sort: write rows but only if parents have been already written
    while dataToProcess.length
      @logger.debug("SortingCycle::Processing batch of #{dataToProcess.length} lines", )
      data = dataToProcess
      dataToProcess = []

      data.forEach (row) ->
        if row.parentId == '' or processed[row.parentId]
          processed[row.rowId] = 1
          outBuffer.push(row.row)
        else
          dataToProcess.push row

      @logger.debug("SortingCycle::Batch of #{dataToProcess.length} rows left")

      if data.length == dataToProcess.length and dataToProcess.length
        @logger.debug("SortingCycle::Could not find parents anymore,"
          + " flushing the res of #{dataToProcess.length} rows")

        outBuffer = outBuffer.concat _.pluck(dataToProcess, 'row')
        dataToProcess = []

    fs.writeFileSync(fileOut, outBuffer.join('\n'), 'utf-8')

module.exports = CategorySort