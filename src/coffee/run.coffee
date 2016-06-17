_ = require 'underscore'
Importer = require '../lib/csv/importer'
Exporter = require '../lib/csv/exporter'
package_json = require '../package.json'
Promise = require 'bluebird'
{ProjectCredentialsConfig,ExtendedLogger} = require 'sphere-node-utils'


yargs = require 'yargs'
  .usage 'Usage: $0 <command> [options]'
  .describe 'p', 'project key'
  .alias 'p', 'project-key'
  .demand 'p'

  .describe 'i', 'client id'
  .alias 'i', 'client-id'

  .describe 's', 'client secret'
  .alias 's', 'client-secret'

  .describe 'accessToken', 'an OAuth access token for the SPHERE.IO API'

  .describe 'sphereHost', 'SPHERE.IO API host to connecto to'
  .describe 'sphereProtocol', 'SPHERE.IO API protocol to connect to'
  .describe 'sphereAuthHost', 'SPHERE.IO OAuth host to connect to'
  .describe 'sphereAuthProtocol', 'SPHERE.IO OAuth protocol to connect to'

  .describe 'language', 'Language used for slugs when referencing parent.'
  .nargs 'language', 1
  .default 'language', 'en'

  .describe 'parentBy', 'Property used to reference parent - use externalId or slug or id'
  .nargs 'parentBy', 1
  .default 'parentBy', 'externalId'

  .describe 'continueOnProblems', 'Continue with creating/updating further categories even if API returned with 400 status code.'
  .boolean 'continueOnProblems'
  .default 'continueOnProblems', false

  .describe 'debug', 'Enable debug mode'
  .describe 'verbose', 'Enable verbose mode'

  .command 'export', 'Export categories'
  .command 'import', 'Import categories'

  .help 'h'
  .alias 'h', 'help'

  .version package_json.version

  .epilog 'copyright 2015'

argv = yargs.argv
command = argv._[0]
project_key = argv.p
language = argv.language
parentBy = argv.parentBy
continueOnProblems = argv.continueOnProblems

logger = new ExtendedLogger
  additionalFields:
    project_key: project_key
  logConfig:
    name: "#{package_json.name}-#{package_json.version}"
  if argv.verbose
    streams = [
      {level: 'info', stream: process.stdout}
    ]
  else if argv.debug
    streams = [
      {level: 'debug', stream: process.stdout}
    ]
  else
    streams: [
      { level: 'warn', stream: process.stdout }
    ]

ensureCredentials = (argv) ->
  if argv.accessToken
    Promise.resolve
      config:
        project_key: argv.projectKey
      access_token: argv.accessToken
  else
    ProjectCredentialsConfig.create()
    .then (credentials) ->
      Promise.resolve
        config: credentials.enrichCredentials
          project_key: argv.projectKey
          client_id: argv.clientId
          client_secret: argv.clientSecret

ensureCredentials(argv)
.then (credentials) ->
  options = _.extend credentials,
    language: language
    parentBy: parentBy
    continueOnProblems: continueOnProblems

  options.host = argv.sphereHost if argv.sphereHost
  options.protocol = argv.sphereProtocol if argv.sphereProtocol
  if argv.sphereAuthHost
    options.oauth_host = argv.sphereAuthHost
    options.rejectUnauthorized = false
  options.oauth_protocol = argv.sphereAuthProtocol if argv.sphereAuthProtocol

  if command is 'import'
    yargs.reset()
    .usage 'Usage: $0 -p <project-key> import -f <CSV file>'
    .example '$0 -p my-project-42 import -f categories.csv', 'Import categories from "categories.csv" file into SPHERE project with key "my-project-42".'

    .describe 'f', 'CSV file name'
    .nargs 'f', 1
    .alias 'f', 'file'
    .demand 'f'
    .argv

    im = new Importer logger, options
    im.run argv.f
    .then (result) ->
      logger.info result

  else if command is 'export'
    yargs.reset()
    .usage 'Usage: $0 -p <project-key> [options] export -t <CSV file> -o <CSV file>'
    .example '$0 -p my-project-42 export -t header.csv -o output.csv', 'Export categories from SPHERE project with key "my-project-42" into "output.csv" file using the template "header.csv".'

    .describe 't', 'CSV template file name'
    .nargs 't', 1
    .alias 't', 'template'

    .describe 'o', 'CSV output file name'
    .nargs 'o', 1
    .alias 'o', 'output'
    .demand 'o'
    .argv

    ex = new Exporter logger, options
    ex.run argv.t, argv.o

  else
    yargs.showHelp()

.catch (err) ->
  logger.error err
  process.exit 1
