_ = require 'underscore'
lodash = require 'lodash'
{ MapProductData } = require '@commercetools/product-json-to-csv'
Header = require './header'
CONS = require './constants'

class ExportMapping extends Header

  constructor: (@rawHeader, options = {}) ->
    super @rawHeader
    @language = options.language
    @parentBy = options.parentBy
    @index2CsvFn = []

  toCSV: (category) ->
    if category.custom
      category.custom.fields = @completeCustomFieldValues(category.custom)

    row = []
    _.each @index2CsvFn, (fn) ->
      fn category, row
    row

  # find a custom field definition based on given field name
  getCustomFieldDefinition: (fieldDefinitions, name) ->
    lodash.find(fieldDefinitions, ['name', name])

  # find value object in the list of values for enum/lenum field
  mapCustomFieldKeyToValueObject: (values, key) ->
    lodash.find(values, ['key', key])

  # custom fields contain only keys in case of enum/lenum and set of enum/lenum
  # this functions replaces keys with the whole enum/lenum definition object
  # map lenum/enum and set of lenum/enum fields from keys to value objects (key with label(s))
  completeCustomFieldValues: (customObj) ->
    lodash.mapValues customObj.fields, (value, name) =>
      definition = @getCustomFieldDefinition(customObj.type.obj.fieldDefinitions, name)

      if ['Enum', 'LocalizedEnum'].includes(definition?.type.name)
        value = @mapCustomFieldKeyToValueObject(definition.type.values, value)

      if definition?.type.name is 'Set' and Array.isArray(value)
        { elementType } = definition.type

        if ['Enum', 'LocalizedEnum'].includes(elementType.name)
          value = value.map (val) =>
            @mapCustomFieldKeyToValueObject(definition.type.elementType.values, val)
      value

  handleLanguageHeader: (header, attribName, language, index) ->
    @index2CsvFn[index] = (json, row) ->
      val = json[attribName]?[language]
      row[index] = if val then val else ''

  handleCustomField: (header, index, customFieldKey) =>
    # use productMapper from product-json-to-csv for mapping attribute values to CSV
    productMapping = new MapProductData()
    (json, row) =>
      baseName = customFieldKey.split('.')[0] # convert for example fieldName.en to fieldName
      customFieldValue = lodash.get(json, "custom.fields.#{baseName}")

      if customFieldValue
        mappedValue = productMapping._mapAttribute({
          name: baseName
          value: customFieldValue
        })
        row[index] = mappedValue[customFieldKey]

  handleHeader: (header, index) ->
    if header is 'customType'
      @index2CsvFn[index] = (json, row) ->
        row[index] = lodash.get(json, 'custom.type.obj.key')

    else if header.startsWith('customField.')
      customFieldKey = header.substring('customField.'.length)
      @index2CsvFn[index] = @handleCustomField(header, index, customFieldKey)

    else if _.isUndefined @index2CsvFn[index]
      @index2CsvFn[index] = if header is CONS.HEADER_PARENT_ID
        (json, row) =>
          row[index] = if json['parent']
            if json['parent']['obj'] and @parentBy
              v = json['parent']['obj'][@parentBy]
              if @parentBy is CONS.HEADER_SLUG
                v[@language]
              else
                v
            else
              json['parent']['id']
          else
            ''
      else
        (json, row) ->
          row[index] = json[header]

module.exports = ExportMapping
