loGet = require 'lodash.get'
_ = require 'underscore'

setPath = (obj, path, value) ->
  path.split('.').reduce((prev, cur, idx, arr) ->
    isLast = (idx == arr.length - 1)
    if isLast
      return prev[cur] = value

    if _.isObject prev[cur]
      prev[cur]
    else
      prev[cur] = {}

  , obj)
  obj

getPath = (obj, path, defaultValue) ->
  loGet(obj, path, defaultValue)

module.exports =
  set: setPath
  get: getPath