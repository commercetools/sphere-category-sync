_ = require 'underscore'
{ExtendedLogger} = require 'sphere-node-utils'
{SphereClient} = require 'sphere-node-sdk'
Promise = require 'bluebird'
config = require '../../config'

cleanCategories = (logger, client) ->
  client.categories.where('parent is not defined').all().fetch()
    .then (result) ->
      logger.info "Cleaning categories: #{_.size result.body.results}"
      Promise.all _.map result.body.results, (cat) ->
        client.categories.byId(cat.id).delete(cat.version)

initLogger = ->
  new ExtendedLogger
    additionalFields:
      project_key: config.project_key
    logConfig:
      streams: [
        { level: 'info', stream: process.stdout }
      ]

getClient = ->
  new SphereClient config

module.exports =
  config: config
  cleanCategories: cleanCategories
  getClient: getClient
  initLogger: initLogger
