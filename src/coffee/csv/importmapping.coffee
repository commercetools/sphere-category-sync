_ = require 'lodash'
Header = require './header'
CONS = require './constants'

class ImportMapping extends Header

  constructor: (@rawHeader) ->
    super @rawHeader
    @index2JsonFn = []
    @customFieldsPrefix = 'customField.'
    @multiValueDelimiter = ';'

  toJSON: (row) ->
    json = {}
    _.each @index2JsonFn, (fn) ->
      fn row, json

    # assemble custom fields object if provided
    if row.customType
      @assembleCustomFields json, row, row.customType

    json

  handleLanguageHeader: (header, attribName, language, index) ->
    @index2JsonFn[index] = (row, json) ->
      json[attribName] or= {}
      json[attribName][language] = row[header]

  handleHeader: (header, index) ->
    if _.isUndefined @index2JsonFn[index]
      @index2JsonFn[index] = if header is CONS.HEADER_PARENT_ID
        (row, json) ->
          if row[header]
            json['parent'] =
              id: row[header]
      else
        (row, json) ->
          # handle custom fields separately
          if header.startsWith('customField.') or header is 'customType'
            return

          json[header] = row[header]

  # take CSV row key:val object and extract items where key starts with "customField."
  extractCustomFieldsFromCsvObject: (csvObject, fieldDefinitions) ->
    prefixLength = @customFieldsPrefix.length

    # create map of fields with subObjects (eg ltext: { en: 'enValue', de: 'deValue' })
    Object
      .keys(csvObject)
      .reduce (fields, key) =>
        if key.startsWith(@customFieldsPrefix)
          path = key.substring(prefixLength)

          # set of lenum is serialized as "SetOfLenum,SetOfLenum.en,SetOfLenum.de"
          # we should take only first column with keys - omit lenum values
          pathChunks = path.split('.')
          isSetOfLenum = @isSetOfLenum(pathChunks[0], fieldDefinitions)

          # field is not set of lenum or it contains lenum keys - do not allow lenum values
          # eg.: fieldName.en
          if not isSetOfLenum or pathChunks.length is 1
            _.set(fields, path, csvObject[key])

        fields
      , {}

  isSetOfLenum: (name, fieldDefinitions) ->
    fieldDefinition = fieldDefinitions
      .find (fieldDefinition) -> fieldDefinition.name is name

    if not fieldDefinition
      throw new Error("Definition for custom field with name \"#{name}\" does not exist.")

    fieldDefinition.type.name is 'Set' and fieldDefinition.type.elementType.name is 'LocalizedEnum'

  assembleCustomFields: (category, csvObject, customType) ->
    # create customFields envelope
    delete category.customType
    category.custom = {
      type: {
        typeId: 'type',
        id: customType.id
      },
      fields: {}
    }

    # extract custom fields from csv
    csvCustomFields = @extractCustomFieldsFromCsvObject(csvObject, customType.fieldDefinitions)

    customType.fieldDefinitions.forEach ({ name, type }) =>
      if not _.isUndefined(csvCustomFields[name])
        try
          category.custom.fields[name] = @mapCustomFieldValue(type, csvCustomFields[name])
        catch err
          throw new Error("Error while mapping field \"#{name}\" - #{err.message}")

  mapCustomFieldValue: (type, value) ->
    mappedValue = switch
      when type.name is 'Boolean' then @mapCustomFieldBoolean(value)
      when type.name is 'String' then value
      when type.name is 'LocalizedString' then value
      when type.name is 'Money' then @mapCustomFieldMoney(value)
      when type.name is 'Number' then Number(value)
      when type.name is 'Enum' then @mapCustomFieldEnum(type, value)
      when type.name is 'LocalizedEnum' then @mapCustomFieldEnum(type, value)
      when type.name is 'Set' then @mapCustomFieldSet(type, value)
      when type.name is 'Reference' then @mapCustomFieldReference(type, value)
      else value # default

    mappedValue

  mapCustomFieldReference: (type, value) ->
    {
      typeId: type.referenceTypeId,
      id: value
    }

  mapCustomFieldBoolean: (value) ->
    truthyValues = ['true', '1', true, 1]

    if _.isString(value)
      value = value.toLowerCase()

    truthyValues.includes(value)

  # Map string or ltext object with multiple values delimited by ; to array
  # set of numbers: 1;2;3 -> [1, 2, 3]
  # set of strings: aa;bb -> ['aa', 'bb']
  # set of ltext: { en: aa1;aa2, de: bb1;bb2 } -> [{en: aa1, de: bb1}, {en: aa2, de: bb2}]
  mapCustomFieldSet: (type, value) ->
    fieldType = type.elementType

    # handle string - eg.: aaa;bbb;ccc
    if _.isString(value)
      values = value.split(@multiValueDelimiter)
      return values.map (val) => @mapCustomFieldValue(fieldType, val)

    # handle language object - eg.: { en: aa1;aa2, de: bb1;bb2 } transform to
    # [{en: aa1, de: bb1}, {en: aa2, de: bb2}]
    resultingSet = []
    value = _.mapValues value, (val) => val.split(@multiValueDelimiter)
    _.forEach value, (items, lang) ->
      items.forEach (item, index) ->
        if _.isUndefined(resultingSet[index])
          resultingSet.push({})
        resultingSet[index][lang] = item

    resultingSet

  mapCustomFieldEnum: (type, value) ->
    enumItem = type.values.find (enumItem) ->
      enumItem.key is value

    if not enumItem
      throw new Error("Enum/Lenum item with key \"#{value}\" was not found.")

    enumItem.key

  # taken from CTP product mapping in sphere-node-product-csv-sync:
  # https://github.com/sphereio/sphere-node-product-csv-sync/blob/master/src/coffee/mapping.coffee#L353
  mapCustomFieldMoney: (value) ->
    moneyRegExp = new RegExp /^([A-Z]{3}) (-?\d+)$/
    matchedMoney = moneyRegExp.exec value

    unless matchedMoney
      throw new Error("Can not parse money custom field \"#{value}\"")

    {
      currencyCode: matchedMoney[1]
      centAmount: parseInt(matchedMoney[2], 10)
      fractionDigits: 2
      type: 'centPrecision'
    }

module.exports = ImportMapping
