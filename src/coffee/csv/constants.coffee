constants =
  HEADER_ROOT: 'root'

  HEADER_ID: 'id'
  HEADER_EXTERNAL_ID: 'externalId'
  HEADER_ORDER_HINT: 'orderHint'
  HEADER_PARENT_ID: 'parentId'

  HEADER_NAME: 'name'
  HEADER_DESCRIPTION: 'description'
  HEADER_SLUG: 'slug'
  HEADER_META_TITLE: 'metaTitle'
  HEADER_META_DESCRIPTION: 'metaDescription'
  HEADER_META_KEYWORDS: 'metaKeywords'

  HEADER_CREATED_AT: 'createdAt'
  HEADER_LAST_MODIFIED_AT: 'lastModifiedAt'

  REGEX_LANGUAGE: new RegExp /^(.+)\.([a-z]{2,3}(?:-[A-Z]{2,3}(?:-[a-zA-Z]{4})?)?)$/

for name, value of constants
  exports[name] = value

exports.BASE_HEADERS = [
  constants.HEADER_ID
  constants.HEADER_EXTERNAL_ID
  constants.HEADER_PARENT_ID
  constants.HEADER_ORDER_HINT
  constants.HEADER_CREATED_AT
  constants.HEADER_LAST_MODIFIED_AT
]

exports.LOCALIZED_HEADERS = [
  constants.HEADER_NAME
  constants.HEADER_DESCRIPTION
  constants.HEADER_SLUG
  constants.HEADER_META_TITLE
  constants.HEADER_META_DESCRIPTION
  constants.HEADER_META_KEYWORDS
]
