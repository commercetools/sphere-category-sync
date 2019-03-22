#
# Utils file with logger functions
#

{ExtendedLogger} = require 'sphere-node-utils'
package_json = require '../../package.json'
Config = require '../../config'

utils = module.exports = {}

utils.logger = new ExtendedLogger
  additionalFields:
    project_key: Config.config.project_key
  logConfig:
    name: "#{package_json.name}-#{package_json.version}"
    streams: [
      { level: 'info', stream: process.stdout }
    ]

